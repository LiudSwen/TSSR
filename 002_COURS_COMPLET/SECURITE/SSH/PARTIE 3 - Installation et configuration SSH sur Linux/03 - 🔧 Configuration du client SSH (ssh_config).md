

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

## 🎯 Introduction

Le fichier `ssh_config` permet de configurer le comportement du **client SSH** (celui qui initie la connexion). Il définit comment votre machine se connecte aux serveurs distants : quels paramètres utiliser, quelles options de sécurité appliquer, et comment simplifier vos commandes de connexion.

> [!info] Client vs Serveur
> 
> - **ssh_config** : configuration du CLIENT (votre machine qui se connecte)
> - **sshd_config** : configuration du SERVEUR (la machine qui accepte les connexions)

---

## 📁 Fichier global vs fichier utilisateur

### Les deux niveaux de configuration

SSH utilise un système de configuration à deux niveaux qui permet une grande flexibilité :

|Fichier|Emplacement|Portée|Priorité|
|---|---|---|---|
|**Utilisateur**|`~/.ssh/config`|Uniquement pour l'utilisateur actuel|**Haute** (prioritaire)|
|**Global**|`/etc/ssh/ssh_config`|Tous les utilisateurs du système|Basse|

### Fichier utilisateur (~/.ssh/config)

> [!tip] Recommandation Utilisez toujours le fichier utilisateur pour vos configurations personnelles. C'est plus sûr et ne nécessite pas de privilèges root.

**Création et permissions :**

```bash
# Créer le fichier s'il n'existe pas
touch ~/.ssh/config

# Définir les bonnes permissions (important pour la sécurité)
chmod 600 ~/.ssh/config

# Vérifier les permissions
ls -l ~/.ssh/config
# Résultat attendu : -rw------- (600)
```

> [!warning] Permissions strictes requises SSH refuse de lire un fichier de configuration s'il est accessible en écriture par d'autres utilisateurs. Les permissions 600 (lecture/écriture uniquement pour le propriétaire) sont obligatoires.

**Avantages du fichier utilisateur :**

- Pas besoin de sudo pour modifier
- Configuration personnalisée par utilisateur
- Pas de risque d'impacter d'autres utilisateurs
- Priorité sur le fichier global

### Fichier global (/etc/ssh/ssh_config)

Le fichier global définit les paramètres par défaut pour tous les utilisateurs du système.

```bash
# Éditer le fichier global (nécessite sudo)
sudo nano /etc/ssh/ssh_config

# Vérifier les permissions
ls -l /etc/ssh/ssh_config
# Résultat typique : -rw-r--r-- (644)
```

**Quand utiliser le fichier global :**

- Politiques de sécurité à l'échelle du système
- Configuration dans des environnements multi-utilisateurs
- Paramètres standards pour toute l'organisation
- Serveurs partagés ou stations de travail d'entreprise

### Hiérarchie et priorité

L'ordre de priorité pour les paramètres SSH est :

1. **Options en ligne de commande** (`ssh -o Option=value`)
2. **Fichier utilisateur** (`~/.ssh/config`)
3. **Fichier global** (`/etc/ssh/ssh_config`)
4. **Valeurs par défaut** de SSH

> [!example] Exemple de priorité Si vous définissez `Port 2222` dans `~/.ssh/config` et `Port 22` dans `/etc/ssh/ssh_config`, SSH utilisera le port 2222 car le fichier utilisateur est prioritaire.

---

## 🖥️ Configuration par hôte

La configuration par hôte permet de définir des paramètres spécifiques pour chaque serveur distant. C'est l'une des fonctionnalités les plus puissantes de ssh_config.

### Syntaxe de base

```bash
Host <nom_ou_pattern>
    Option1 valeur1
    Option2 valeur2
    # Les options sont indentées (4 espaces ou 1 tab)
```

> [!info] Indentation L'indentation n'est pas strictement obligatoire, mais elle améliore considérablement la lisibilité. Utilisez 4 espaces ou 1 tabulation.

### Configuration simple d'un hôte

```bash
# Définition d'un alias simple
Host serveur-prod
    HostName 192.168.1.100
    User admin
    Port 2222
```

**Utilisation :**

```bash
# Au lieu de taper :
ssh admin@192.168.1.100 -p 2222

# Vous tapez simplement :
ssh serveur-prod
```

### Configuration multiple avec des patterns

Les patterns permettent d'appliquer des configurations à plusieurs hôtes :

```bash
# Configuration pour tous les serveurs de production
Host prod-*
    User admin
    Port 2222
    IdentityFile ~/.ssh/id_rsa_prod

# Configuration pour tous les serveurs de développement
Host dev-*
    User developer
    Port 22
    IdentityFile ~/.ssh/id_rsa_dev

# Serveurs spécifiques
Host prod-web1
    HostName 192.168.1.10

Host prod-web2
    HostName 192.168.1.11

Host prod-db
    HostName 192.168.1.20
```

**Utilisation :**

```bash
ssh prod-web1  # Se connecte avec user=admin, port=2222, clé prod
ssh dev-app1   # Se connecte avec user=developer, port=22, clé dev
```

### Wildcards et patterns avancés

|Pattern|Signification|Exemple|
|---|---|---|
|`*`|N'importe quelle chaîne|`Host *.example.com`|
|`?`|Un seul caractère|`Host server?` (server1, server2, etc.)|
|`!`|Négation|`Host * !prod-*` (tous sauf prod-*)|

```bash
# Tous les serveurs sauf ceux de production
Host * !prod-*
    ForwardAgent no
    StrictHostKeyChecking ask

# Tous les serveurs d'un domaine
Host *.entreprise.com
    User employe
    ProxyJump bastion.entreprise.com

# Configuration par défaut (toujours en dernier)
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

> [!warning] Ordre des Host Les sections Host sont évaluées **de haut en bas**. La première correspondance l'emporte. Placez toujours les configurations spécifiques AVANT les configurations génériques, et `Host *` en dernier.

### Exemple complet et réaliste

```bash
# ~/.ssh/config

# ========================================
# Serveurs de production
# ========================================

Host prod-bastion
    HostName bastion.prod.example.com
    User admin
    Port 2222
    IdentityFile ~/.ssh/id_ed25519_prod
    # Bastion : pas de forwarding d'agent par sécurité
    ForwardAgent no

Host prod-web-*
    User www-data
    Port 2222
    IdentityFile ~/.ssh/id_ed25519_prod
    # Passage par le bastion
    ProxyJump prod-bastion
    # Multiplexage pour performance
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h:%p
    ControlPersist 10m

Host prod-web-1
    HostName 10.0.1.10

Host prod-web-2
    HostName 10.0.1.11

Host prod-db
    HostName 10.0.2.20
    User postgres
    ProxyJump prod-bastion

# ========================================
# Serveurs de développement
# ========================================

Host dev-*
    User developer
    Port 22
    IdentityFile ~/.ssh/id_rsa
    ForwardAgent yes
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

Host dev-local
    HostName localhost
    Port 2222

# ========================================
# GitHub et GitLab
# ========================================

Host github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github
    IdentitiesOnly yes

Host gitlab.com
    User git
    IdentityFile ~/.ssh/id_ed25519_gitlab
    IdentitiesOnly yes

# ========================================
# Configuration par défaut
# ========================================

Host *
    # Sécurité
    PasswordAuthentication no
    PubkeyAuthentication yes
    
    # Keep-alive
    ServerAliveInterval 60
    ServerAliveCountMax 3
    
    # Performance
    Compression yes
    
    # Logs (utile pour debug)
    # LogLevel INFO
```

> [!tip] Organisation du fichier Organisez votre fichier par sections avec des commentaires clairs. Groupez les serveurs par environnement, projet, ou fonction. Cela facilite grandement la maintenance.

---

## ⚙️ Paramètres de connexion

Les paramètres de connexion contrôlent comment SSH établit et maintient la connexion avec le serveur distant.

### HostName - Adresse du serveur

Définit l'adresse réelle du serveur (IP ou nom de domaine).

```bash
Host monserveur
    HostName 192.168.1.100
    # ou
    HostName exemple.com
```

> [!info] Host vs HostName
> 
> - **Host** : l'alias que vous tapez dans la commande SSH
> - **HostName** : l'adresse réelle du serveur (IP ou FQDN)

### User - Nom d'utilisateur

Définit le nom d'utilisateur par défaut pour la connexion.

```bash
Host serveur
    HostName example.com
    User admin
```

```bash
# Sans User défini :
ssh admin@serveur

# Avec User défini :
ssh serveur  # Utilise automatiquement "admin"
```

### Port - Port de connexion

Définit le port SSH (par défaut : 22).

```bash
Host serveur
    HostName example.com
    Port 2222
```

> [!tip] Sécurité par obscurité Changer le port SSH par défaut réduit les tentatives d'attaques automatisées, mais ce n'est pas une vraie mesure de sécurité. Combinez avec l'authentification par clé et d'autres mesures.

### IdentityFile - Clé privée

Spécifie quelle clé privée utiliser pour l'authentification.

```bash
Host serveur
    HostName example.com
    IdentityFile ~/.ssh/id_ed25519
    # Vous pouvez spécifier plusieurs clés (essayées dans l'ordre)
    IdentityFile ~/.ssh/id_rsa
    IdentityFile ~/.ssh/id_ecdsa
```

### IdentitiesOnly - Forcer une clé spécifique

Force SSH à utiliser uniquement les clés spécifiées dans IdentityFile.

```bash
Host github.com
    IdentityFile ~/.ssh/id_ed25519_github
    IdentitiesOnly yes
    # Sans cette option, SSH essaierait toutes vos clés
```

> [!warning] Trop de tentatives d'authentification Par défaut, SSH essaie toutes les clés de votre agent SSH. Si vous avez beaucoup de clés, vous pouvez dépasser la limite du serveur (souvent 3-5 tentatives) et être bloqué. Utilisez `IdentitiesOnly yes` pour éviter ce problème.

### ConnectTimeout - Délai de connexion

Définit le temps maximum pour établir la connexion (en secondes).

```bash
Host serveur-lent
    HostName example.com
    ConnectTimeout 30
    # Par défaut : illimité (peut bloquer longtemps)
```

### ServerAliveInterval et ServerAliveCountMax - Keep-alive

Maintient la connexion active en envoyant des paquets réguliers.

```bash
Host *
    ServerAliveInterval 60
    # Envoie un paquet toutes les 60 secondes
    
    ServerAliveCountMax 3
    # Déconnecte après 3 paquets sans réponse (60s × 3 = 3 minutes)
```

> [!tip] Éviter les déconnexions Ces paramètres sont essentiels si vous travaillez derrière un firewall ou NAT qui ferme les connexions inactives. Recommandé : 60 secondes d'intervalle.

### ConnectionAttempts - Nombre de tentatives

Définit combien de fois SSH essaie de se connecter avant d'abandonner.

```bash
Host serveur-instable
    HostName example.com
    ConnectionAttempts 5
    # Par défaut : 1
```

### TCPKeepAlive - Keep-alive TCP

Active les paquets keep-alive au niveau TCP (différent de ServerAlive).

```bash
Host *
    TCPKeepAlive yes
    # Permet de détecter les connexions mortes au niveau réseau
```

> [!info] ServerAlive vs TCPKeepAlive
> 
> - **ServerAliveInterval** : keep-alive au niveau SSH (crypté, recommandé)
> - **TCPKeepAlive** : keep-alive au niveau TCP (non crypté, peut traverser les NAT)

### Compression - Compression des données

Active la compression des données transférées.

```bash
Host serveur-lent
    HostName example.com
    Compression yes
    # Utile pour connexions lentes ou transferts de texte
    # Peut ralentir sur connexions rapides ou fichiers binaires
```

### Multiplexage des connexions (ControlMaster)

Permet de réutiliser une connexion existante pour plusieurs sessions SSH.

```bash
Host *
    ControlMaster auto
    # auto : crée une connexion maître si elle n'existe pas
    
    ControlPath ~/.ssh/sockets/%r@%h:%p
    # Chemin du socket de contrôle
    # %r = nom d'utilisateur, %h = hôte, %p = port
    
    ControlPersist 10m
    # Garde la connexion ouverte 10 minutes après la dernière session
```

**Créer le dossier des sockets :**

```bash
mkdir -p ~/.ssh/sockets
chmod 700 ~/.ssh/sockets
```

> [!tip] Avantages du multiplexage
> 
> - Connexions ultérieures instantanées (pas de nouvelle authentification)
> - Réduit la charge sur le serveur
> - Idéal pour Git, SCP, rsync répétés
> - Parfait pour les scripts

**Gestion manuelle des connexions maîtres :**

```bash
# Lister les connexions actives
ssh -O check serveur

# Fermer une connexion maître
ssh -O exit serveur

# Forcer l'arrêt
ssh -O stop serveur
```

### Exemple de configuration optimisée

```bash
# Configuration pour connexions lentes/instables
Host serveur-distant
    HostName remote.example.com
    User admin
    Port 2222
    
    # Connexion
    ConnectTimeout 30
    ConnectionAttempts 3
    
    # Keep-alive agressif
    ServerAliveInterval 30
    ServerAliveCountMax 5
    TCPKeepAlive yes
    
    # Performance
    Compression yes
    
    # Multiplexage
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h:%p
    ControlPersist 30m
```

---

## 🔒 Options de sécurité client

Les options de sécurité client permettent de contrôler comment SSH vérifie l'identité des serveurs et quelles méthodes d'authentification sont autorisées.

### StrictHostKeyChecking - Vérification des clés d'hôte

Contrôle la vérification de l'identité du serveur via sa clé d'hôte.

```bash
Host serveur-prod
    HostName prod.example.com
    StrictHostKeyChecking yes
    # yes : refuse la connexion si la clé est inconnue ou a changé
    # ask : demande confirmation (défaut)
    # no : accepte automatiquement (DANGEREUX)
```

|Valeur|Comportement|Cas d'usage|
|---|---|---|
|`yes`|Refuse si clé inconnue/changée|**Production** (sécurité max)|
|`ask`|Demande confirmation|Utilisation normale|
|`no`|Accepte automatiquement|Dev/test uniquement (dangereux)|
|`accept-new`|Accepte nouvelles clés, refuse changements|Bon compromis|

> [!warning] Danger du mode "no" `StrictHostKeyChecking no` expose à des attaques man-in-the-middle. N'utilisez JAMAIS en production. Réservé aux environnements de test jetables.

**Bonne pratique pour le développement :**

```bash
Host dev-*
    StrictHostKeyChecking accept-new
    # Accepte les nouveaux serveurs, mais détecte les changements de clé
```

### UserKnownHostsFile - Fichier des hôtes connus

Définit où stocker les clés d'hôte connues.

```bash
# Configuration normale
Host prod-*
    UserKnownHostsFile ~/.ssh/known_hosts

# Ignorer l'historique (dev/test uniquement)
Host dev-*
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking no
    # Les clés ne sont pas enregistrées
```

> [!tip] Multiple fichiers Vous pouvez spécifier plusieurs fichiers :
> 
> ```bash
> UserKnownHostsFile ~/.ssh/known_hosts ~/.ssh/known_hosts_extra
> ```

### HashKnownHosts - Hachage des noms d'hôtes

Hash les noms d'hôtes dans known_hosts pour plus de confidentialité.

```bash
Host *
    HashKnownHosts yes
    # Les noms d'hôtes sont hachés (protection de la vie privée)
```

**Exemple dans known_hosts :**

```bash
# Sans hash :
example.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5...

# Avec hash :
|1|abcd1234...== ssh-ed25519 AAAAC3NzaC1lZDI1NTE5...
```

> [!info] Avantage du hachage Si quelqu'un accède à votre fichier known_hosts, il ne peut pas voir la liste de vos serveurs. Cependant, cela complique la gestion manuelle du fichier.

### PasswordAuthentication - Authentification par mot de passe

Contrôle l'utilisation des mots de passe (à désactiver en production).

```bash
Host prod-*
    PasswordAuthentication no
    # Force l'authentification par clé uniquement
    
Host dev-local
    PasswordAuthentication yes
    # Autorise le mot de passe
```

> [!warning] Sécurité critique Désactivez toujours `PasswordAuthentication` en production. Les attaques par force brute sont extrêmement courantes sur SSH.

### PubkeyAuthentication - Authentification par clé publique

Active l'authentification par clé publique (devrait toujours être yes).

```bash
Host *
    PubkeyAuthentication yes
    # Méthode d'authentification recommandée
```

### PreferredAuthentications - Ordre des méthodes d'authentification

Définit l'ordre de préférence des méthodes d'authentification.

```bash
Host serveur
    PreferredAuthentications publickey,keyboard-interactive,password
    # Essaie d'abord la clé publique, puis keyboard-interactive, puis mot de passe
```

**Méthodes disponibles :**

- `publickey` : clé SSH (recommandé)
- `keyboard-interactive` : prompt interactif (2FA, etc.)
- `password` : mot de passe simple
- `gssapi-with-mic` : authentification Kerberos
- `hostbased` : authentification basée sur l'hôte

> [!tip] Forcer uniquement les clés
> 
> ```bash
> PreferredAuthentications publickey
> PasswordAuthentication no
> ```

### ForwardAgent - Transfert de l'agent SSH

Permet au serveur distant d'utiliser votre agent SSH local.

```bash
Host bastion
    ForwardAgent yes
    # Le bastion peut utiliser vos clés pour rebondir
    
Host prod-*
    ForwardAgent no
    # Les serveurs de production ne doivent pas avoir accès à vos clés
```

> [!warning] Risque de sécurité `ForwardAgent yes` donne au serveur distant un accès temporaire à vos clés SSH. N'activez que sur des machines de confiance (bastions, machines de développement personnelles).

**Alternative plus sûre : ProxyJump**

```bash
# Au lieu de ForwardAgent
Host serveur-final
    ProxyJump bastion
    # Établit un tunnel sans exposer vos clés
```

### ForwardX11 - Transfert X11

Active le transfert de l'affichage graphique X11.

```bash
Host serveur-graphique
    ForwardX11 yes
    ForwardX11Trusted yes
    # Permet de lancer des applications graphiques distantes
```

> [!info] X11 Forwarding Rarement utilisé de nos jours. La plupart des administrateurs préfèrent VNC ou les applications web. Peut avoir des implications de sécurité.

### Cipher et MAC - Algorithmes cryptographiques

Spécifie les algorithmes de chiffrement et d'authentification autorisés.

```bash
# Limiter aux algorithmes modernes et sûrs
Host secure-server
    Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
    MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
    KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group18-sha512
```

> [!tip] Recommandation Laissez SSH utiliser ses valeurs par défaut sauf si vous avez des exigences de conformité spécifiques. Les valeurs par défaut sont régulièrement mises à jour avec les meilleures pratiques.

### LogLevel - Niveau de journalisation

Contrôle la verbosité des logs SSH (utile pour le debug).

```bash
Host *
    # LogLevel QUIET      # Aucun message (sauf erreurs critiques)
    # LogLevel FATAL      # Seulement erreurs fatales
    # LogLevel ERROR      # Erreurs
    LogLevel INFO         # Informations générales (défaut)
    # LogLevel VERBOSE    # Mode verbeux
    # LogLevel DEBUG      # Debug (très verbeux)
    # LogLevel DEBUG1     # Debug niveau 1
    # LogLevel DEBUG2     # Debug niveau 2
    # LogLevel DEBUG3     # Debug niveau 3 (maximum)
```

**Debug temporaire en ligne de commande :**

```bash
ssh -v serveur        # Verbeux
ssh -vv serveur       # Plus verbeux
ssh -vvv serveur      # Maximum de détails
```

### Exemple de configuration sécurisée complète

```bash
# Configuration de sécurité maximale pour production
Host prod-*
    # Authentification
    PubkeyAuthentication yes
    PasswordAuthentication no
    PreferredAuthentications publickey
    
    # Vérification d'identité
    StrictHostKeyChecking yes
    UserKnownHostsFile ~/.ssh/known_hosts
    HashKnownHosts yes
    
    # Pas de forwarding
    ForwardAgent no
    ForwardX11 no
    
    # Clé spécifique
    IdentityFile ~/.ssh/id_ed25519_prod
    IdentitiesOnly yes
    
    # Keep-alive
    ServerAliveInterval 60
    ServerAliveCountMax 3

# Configuration pour développement local
Host dev-*
    # Plus souple pour faciliter le développement
    StrictHostKeyChecking accept-new
    PasswordAuthentication yes
    ForwardAgent yes
    
    # Multiplexage pour performance
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h:%p
    ControlPersist 10m
```

---

## ✅ Bonnes pratiques

### Organisation du fichier de configuration

```bash
# Structure recommandée de ~/.ssh/config

# ========================================
# En-tête avec informations utiles
# ========================================
# Fichier de configuration SSH
# Dernière mise à jour : 2025-12-15
# Auteur : Votre Nom

# ========================================
# Configurations spécifiques par projet
# ========================================

# Projet A
Host projet-a-*
    # Configuration commune

Host projet-a-prod
    HostName prod.a.example.com

Host projet-a-dev
    HostName dev.a.example.com

# ========================================
# Bastions et serveurs de rebond
# ========================================

Host bastion-*
    # Configuration des bastions

# ========================================
# Services externes (GitHub, GitLab, etc.)
# ========================================

Host github.com
    # Configuration GitHub

# ========================================
# Configuration par défaut (toujours en dernier)
# ========================================

Host *
    # Paramètres par défaut pour tous les hôtes
```

### Vérification et test de la configuration

```bash
# Tester la configuration sans se connecter
ssh -G serveur
# Affiche la configuration effective pour cet hôte

# Tester avec debug
ssh -vvv serveur
# Très verbeux, utile pour diagnostiquer les problèmes

# Vérifier la syntaxe (nécessite une connexion de test)
ssh -F ~/.ssh/config serveur echo "Config OK"
```

### Sécurité des fichiers

```bash
# Vérifier les permissions
ls -la ~/.ssh/

# Permissions correctes :
# drwx------  ~/.ssh/                (700)
# -rw-------  ~/.ssh/config          (600)
# -rw-------  ~/.ssh/id_*            (600) - clés privées
# -rw-r--r--  ~/.ssh/id_*.pub        (644) - clés publiques
# -rw-r--r--  ~/.ssh/known_hosts     (644)
# -rw-------  ~/.ssh/authorized_keys (600)

# Corriger automatiquement :
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/id_*.pub
chmod 644 ~/.ssh/known_hosts
```

> [!warning] Permissions obligatoires SSH refuse de fonctionner si les permissions sont trop permissives. C'est une mesure de sécurité intentionnelle.

### Gestion des clés par environnement

```bash
# Séparer les clés par environnement/usage
Host prod-*
    IdentityFile ~/.ssh/id_ed25519_prod
    IdentitiesOnly yes

Host dev-*
    IdentityFile ~/.ssh/id_ed25519_dev
    IdentitiesOnly yes

Host github.com
    IdentityFile ~/.ssh/id_ed25519_github
    IdentitiesOnly yes

Host gitlab.com
    IdentityFile ~/.ssh/id_ed25519_gitlab
    IdentitiesOnly yes
```

> [!tip] Avantages
> 
> - Isolation des environnements
> - Facilite la rotation des clés
> - Améliore la sécurité en cas de compromission
> - Évite les problèmes de "too many authentication failures"

### Commentaires et documentation

```bash
Host prod-web-1
    HostName 192.168.1.10
    User www-data
    Port 2222
    
    # Cette machine nécessite le passage par le bastion
    ProxyJump prod-bastion
    
    # Note : la clé de production expire le 2026-01-31
    IdentityFile ~/.ssh/id_ed25519_prod
    
    # Multiplexage activé pour les déploiements fréquents
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h:%p
    ControlPersist 1h
```

### Éviter les pièges courants

> [!warning] Piège 1 : Ordre des Host
> 
> ```bash
> # ❌ MAUVAIS : Le wildcard capture tout
> Host *
>     User default
> 
> Host prod-*
>     User admin  # Ne sera jamais utilisé !
> 
> # ✅ BON : Spécifique avant générique
> Host prod-*
>     User admin
> 
> Host *
>     User default
> ```

> [!warning] Piège 2 : Trop de clés chargées Sans `IdentitiesOnly yes`, SSH essaie toutes vos clés et peut dépasser la limite du serveur :
> 
> ```bash
> Host *
>     IdentityFile ~/.ssh/id_specific
>     IdentitiesOnly yes  # Important !
> ```

> [!warning] Piège 3 : Permissions incorrectes
> 
> ```bash
> # ❌ Erreur courante
> chmod 644 ~/.ssh/config
> # SSH refuse : "Bad owner or permissions"
> 
> # ✅ Correct
> chmod 600 ~/.ssh/config
> ```

> [!warning] Piège 4 : Chemins relatifs
> 
> ```bash
> # ❌ Peut causer des problèmes
> ControlPath ./ssh-socket-%r@%h:%p
> 
> # ✅ Toujours utiliser des chemins absolus
> ControlPath ~/.ssh/sockets/%r@%h:%p
> ```

### Configuration minimaliste vs complète

**Approche minimaliste (recommandée pour débuter) :**

```bash
# Configuration simple et claire
Host prod
    HostName prod.example.com
    User admin
    IdentityFile ~/.ssh/id_ed25519_prod

Host dev
    HostName dev.example.com
    User developer

Host *
    ServerAliveInterval 60
    PasswordAuthentication no
```

**Approche complète (pour utilisateurs avancés) :**

```bash
# Configuration exhaustive avec toutes les optimisations
Host prod
    # Connexion
    HostName prod.example.com
    User admin
    Port 2222
    
    # Authentification
    IdentityFile ~/.ssh/id_ed25519_prod
    IdentitiesOnly yes
    PubkeyAuthentication yes
    PasswordAuthentication no
    PreferredAuthentications publickey
    
    # Sécurité
    StrictHostKeyChecking yes
    HashKnownHosts yes
    ForwardAgent no
    ForwardX11 no
    
    # Performance
    Compression yes
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h:%p
    ControlPersist 30m
    
    # Robustesse
    ServerAliveInterval 60
    ServerAliveCountMax 3
    TCPKeepAlive yes
    ConnectTimeout 30
    ConnectionAttempts 3
    
    # Debug (commenté par défaut)
    # LogLevel DEBUG
```

> [!tip] Recommandation Commencez simple et ajoutez des options au fur et à mesure que vous en avez besoin. Une configuration trop complexe est plus difficile à maintenir et à débugger.

### Maintenance et mise à jour

**Vérification régulière :**

```bash
# Sauvegarder avant modification
cp ~/.ssh/config ~/.ssh/config.backup.$(date +%Y%m%d)

# Vérifier les hôtes inutilisés
grep "^Host " ~/.ssh/config | sort

# Nettoyer les sockets de multiplexage obsolètes
find ~/.ssh/sockets -type s -mtime +7 -delete
```

**Rotation des clés :**

```bash
# Quand vous changez une clé, pensez à mettre à jour :
# 1. Le fichier de configuration
Host prod-*
    IdentityFile ~/.ssh/id_ed25519_prod_new  # Nouvelle clé

# 2. Supprimer les anciennes entrées dans known_hosts
ssh-keygen -R example.com
# ou supprimer manuellement les lignes concernées
```

### Template de configuration recommandé

```bash
# ~/.ssh/config - Template de démarrage

# ========================================
# CONFIGURATION GLOBALE (en dernier)
# ========================================

Host *
    # Sécurité de base
    PasswordAuthentication no
    PubkeyAuthentication yes
    StrictHostKeyChecking ask
    HashKnownHosts yes
    
    # Keep-alive pour éviter les déconnexions
    ServerAliveInterval 60
    ServerAliveCountMax 3
    
    # Performance
    Compression yes
    
    # Multiplexage (créer le dossier: mkdir -p ~/.ssh/sockets)
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h:%p
    ControlPersist 10m

# ========================================
# VOS SERVEURS (ajouter au-dessus)
# ========================================

# Exemple de serveur
# Host mon-serveur
#     HostName exemple.com
#     User votre-user
#     Port 22
#     IdentityFile ~/.ssh/id_ed25519
#     IdentitiesOnly yes
```

### Cas d'usage avancés

#### Architecture avec bastion (ProxyJump)

```bash
# Bastion principal
Host bastion
    HostName bastion.example.com
    User admin
    Port 2222
    IdentityFile ~/.ssh/id_ed25519_bastion
    ForwardAgent no
    # Le bastion ne doit jamais avoir accès à vos clés

# Serveurs internes accessibles via bastion
Host internal-*
    User root
    Port 22
    ProxyJump bastion
    IdentityFile ~/.ssh/id_ed25519_internal
    # Connexion : client -> bastion -> serveur interne
    # Sans exposer vos clés au bastion

Host internal-web
    HostName 10.0.1.10

Host internal-db
    HostName 10.0.2.20
```

**Utilisation :**

```bash
# Connexion transparente en un seul saut
ssh internal-web
# SSH se connecte automatiquement au bastion puis au serveur cible
```

#### Bastion en cascade

```bash
# Premier bastion (DMZ)
Host bastion-dmz
    HostName bastion-dmz.example.com
    User admin

# Deuxième bastion (réseau privé)
Host bastion-private
    HostName 10.0.0.5
    User admin
    ProxyJump bastion-dmz

# Serveur final
Host app-server
    HostName 10.0.1.100
    User app
    ProxyJump bastion-dmz,bastion-private
    # Chaîne complète : client -> DMZ -> private -> serveur
```

#### Configuration par projet avec Include

SSH supporte les directives `Include` pour organiser la configuration.

```bash
# ~/.ssh/config (fichier principal)

# Inclure les configurations par projet
Include ~/.ssh/config.d/projet-a
Include ~/.ssh/config.d/projet-b
Include ~/.ssh/config.d/github

# Configuration globale
Host *
    ServerAliveInterval 60
    PasswordAuthentication no
```

```bash
# ~/.ssh/config.d/projet-a
Host projet-a-*
    User developer
    IdentityFile ~/.ssh/id_ed25519_projet_a

Host projet-a-prod
    HostName prod.projet-a.com

Host projet-a-dev
    HostName dev.projet-a.com
```

**Créer la structure :**

```bash
mkdir -p ~/.ssh/config.d
chmod 700 ~/.ssh/config.d
```

> [!tip] Avantages du Include
> 
> - Organisation claire par projet/équipe
> - Facilite le partage de configurations (versionning Git)
> - Simplifie la maintenance
> - Permet de désactiver rapidement un projet (renommer/commenter l'Include)

#### Match - Conditions avancées

La directive `Match` permet des configurations conditionnelles basées sur divers critères.

```bash
# Configuration selon l'utilisateur local
Match user developer
    ForwardAgent yes
    StrictHostKeyChecking accept-new

Match user root
    ForwardAgent no
    StrictHostKeyChecking yes

# Configuration selon l'hôte d'origine
Match originalhost prod-*
    LogLevel VERBOSE
    # Active le logging détaillé uniquement pour prod

# Configuration selon le réseau local
Match exec "ip addr | grep -q 192.168.1"
    ProxyJump none
    # Pas de bastion si on est sur le réseau local
```

> [!info] Critères Match disponibles
> 
> - `user` : utilisateur local
> - `host` : pattern de nom d'hôte
> - `originalhost` : hôte avant résolution d'alias
> - `localuser` : utilisateur système local
> - `exec` : commande shell (code de retour 0 = match)
> - `all` : correspond à tout

#### Tunnels SSH (LocalForward / RemoteForward)

Configuration pour créer des tunnels automatiquement.

```bash
# Forward local vers distant
Host db-tunnel
    HostName db-server.example.com
    User admin
    LocalForward 3306 localhost:3306
    # Port local 3306 -> port distant 3306
    # mysql -h 127.0.0.1 -P 3306 se connecte au serveur distant

# Forward distant vers local
Host reverse-tunnel
    HostName remote-server.example.com
    User admin
    RemoteForward 8080 localhost:8080
    # Le serveur distant peut accéder à votre port local 8080

# SOCKS proxy
Host socks-proxy
    HostName proxy-server.example.com
    User admin
    DynamicForward 1080
    # Crée un proxy SOCKS sur le port local 1080
```

**Utilisation des tunnels :**

```bash
# Lancer la connexion avec tunnel
ssh db-tunnel

# En arrière-plan avec multiplexage
ssh -fN db-tunnel
# -f : passe en arrière-plan
# -N : ne pas exécuter de commande distante
```

#### Configuration pour Git avec plusieurs comptes

```bash
# Compte GitHub personnel
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github_personal
    IdentitiesOnly yes

# Compte GitHub professionnel
Host github-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github_work
    IdentitiesOnly yes

# Utilisation dans Git :
# git clone git@github.com:user/repo.git        # Compte personnel
# git clone git@github-work:company/repo.git    # Compte pro
```

### Variables et substitution

SSH supporte plusieurs variables (tokens) dans la configuration :

|Variable|Signification|Exemple|
|---|---|---|
|`%h`|Nom d'hôte cible|example.com|
|`%n`|Nom d'hôte original (avant alias)|serveur|
|`%p`|Port|22|
|`%r`|Nom d'utilisateur distant|admin|
|`%l`|Nom d'hôte local|laptop|
|`%u`|Utilisateur local|jean|
|`%d`|Répertoire home local|/home/jean|
|`%%`|Caractère % littéral|%|

**Exemples d'utilisation :**

```bash
# Logs séparés par hôte
Host *
    LogFile ~/.ssh/logs/%h.log
    # Crée des logs séparés : example.com.log, server2.log, etc.

# Clés par utilisateur distant
Host *
    IdentityFile ~/.ssh/id_%r
    # Utilise id_admin, id_root, etc. selon l'utilisateur

# Socket de contrôle avec toutes les infos
Host *
    ControlPath ~/.ssh/sockets/%r@%h:%p
    # Exemple : admin@example.com:2222
```

### Optimisation pour scripts et automatisation

```bash
# Configuration pour scripts automatisés
Host automated-*
    # Pas d'interaction utilisateur
    BatchMode yes
    StrictHostKeyChecking yes
    
    # Timeout court
    ConnectTimeout 10
    ConnectionAttempts 1
    
    # Pas de prompts
    NumberOfPasswordPrompts 0
    
    # Keep-alive agressif
    ServerAliveInterval 30
    ServerAliveCountMax 2
```

**BatchMode expliqué :**

```bash
Host script-server
    BatchMode yes
    # Désactive toutes les interactions :
    # - Pas de prompt de mot de passe
    # - Pas de demande de confirmation de clé
    # - Échec immédiat si authentification impossible
    # Parfait pour les scripts non-interactifs
```

### Debugging et diagnostics

```bash
# Configuration temporaire pour debug
Host debug-server
    HostName example.com
    LogLevel DEBUG3
    # DEBUG1 : informations générales
    # DEBUG2 : plus détaillé
    # DEBUG3 : maximum de détails (chaque paquet)
```

**Commandes de diagnostic :**

```bash
# Voir la config effective pour un hôte
ssh -G mon-serveur

# Debug verbeux (3 niveaux)
ssh -v mon-serveur    # Verbeux
ssh -vv mon-serveur   # Très verbeux
ssh -vvv mon-serveur  # Maximum

# Tester uniquement l'authentification
ssh -o PreferredAuthentications=publickey -v mon-serveur

# Forcer une option temporairement
ssh -o "StrictHostKeyChecking=no" mon-serveur

# Utiliser un fichier de config alternatif
ssh -F ~/.ssh/config.test mon-serveur
```

### Récapitulatif des options essentielles

|Catégorie|Options clés|Valeurs recommandées|
|---|---|---|
|**Connexion**|HostName<br>User<br>Port|IP ou FQDN<br>votre-user<br>22 ou custom|
|**Authentification**|IdentityFile<br>IdentitiesOnly<br>PasswordAuthentication|~/.ssh/id_ed25519<br>yes<br>no|
|**Sécurité**|StrictHostKeyChecking<br>ForwardAgent<br>HashKnownHosts|yes ou accept-new<br>no (sauf besoin)<br>yes|
|**Keep-alive**|ServerAliveInterval<br>ServerAliveCountMax|60<br>3|
|**Performance**|Compression<br>ControlMaster<br>ControlPersist|yes (si lent)<br>auto<br>10m|
|**Debug**|LogLevel|INFO (DEBUG pour debug)|

### Checklist de sécurité

```bash
# ✅ Checklist de configuration sécurisée

# 1. Permissions des fichiers
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub

# 2. Authentification par clé uniquement
PasswordAuthentication no
PubkeyAuthentication yes

# 3. Vérification stricte des hôtes
StrictHostKeyChecking yes  # ou accept-new

# 4. Pas de forwarding par défaut
ForwardAgent no
ForwardX11 no

# 5. Clés spécifiques par usage
IdentityFile ~/.ssh/id_ed25519_specific
IdentitiesOnly yes

# 6. Hash des noms d'hôtes
HashKnownHosts yes

# 7. Keep-alive configuré
ServerAliveInterval 60
ServerAliveCountMax 3

# 8. Timeout de connexion
ConnectTimeout 30
```

### Commandes utiles pour la gestion

```bash
# Lister toutes vos configurations Host
grep "^Host " ~/.ssh/config

# Voir la config effective pour un hôte
ssh -G mon-serveur | grep -i "identityfile\|port\|user\|hostname"

# Tester la connexion sans s'authentifier
nc -zv hostname port
# ou
timeout 5 bash -c "</dev/tcp/hostname/port" && echo "OK" || echo "FAIL"

# Vérifier les clés chargées dans l'agent
ssh-add -l

# Vider les sockets de multiplexage
rm -f ~/.ssh/sockets/*

# Nettoyer une entrée du known_hosts
ssh-keygen -R hostname

# Copier votre config sur un nouveau système
scp ~/.ssh/config nouvel-host:~/.ssh/config

# Sauvegarder toute votre configuration SSH
tar czf ssh-backup-$(date +%Y%m%d).tar.gz ~/.ssh/
```

---

## 🎓 Résumé

Le fichier `ssh_config` est un outil puissant qui transforme votre expérience SSH. Il permet de :

✅ **Simplifier** vos connexions avec des alias et configurations par hôte ✅ **Sécuriser** vos connexions avec des paramètres d'authentification stricts ✅ **Optimiser** les performances avec le multiplexage et la compression ✅ **Automatiser** des configurations complexes (bastions, tunnels, proxy) ✅ **Organiser** vos environnements (prod, dev, projets multiples)

**Points clés à retenir :**

1. **Deux niveaux** : utilisateur (`~/.ssh/config`) prioritaire sur global (`/etc/ssh/ssh_config`)
2. **Ordre des Host** : du plus spécifique au plus générique, `Host *` en dernier
3. **Permissions** : 600 obligatoire sur le fichier config
4. **Sécurité** : désactivez les mots de passe, utilisez des clés dédiées, activez StrictHostKeyChecking
5. **Performance** : multiplexage et keep-alive pour les connexions fréquentes
6. **Organisation** : commentez, structurez, utilisez Include pour les gros projets

> [!tip] Philosophie Commencez simple avec quelques Host basiques, puis enrichissez progressivement votre configuration au fur et à mesure de vos besoins. Une bonne configuration SSH se construit avec le temps et l'expérience.

---

**Prochaine étape du cours :** Configuration du serveur SSH (sshd_config) pour sécuriser et optimiser le côté serveur.