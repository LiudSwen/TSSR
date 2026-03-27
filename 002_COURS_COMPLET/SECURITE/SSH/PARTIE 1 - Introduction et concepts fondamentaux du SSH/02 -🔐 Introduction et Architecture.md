

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

## 🎯 Introduction et concepts fondamentaux

### Qu'est-ce que SSH ?

**SSH (Secure Shell)** est un protocole réseau cryptographique permettant d'établir des communications sécurisées sur un réseau non sécurisé. Il remplace les anciens protocoles comme Telnet, rlogin ou rsh qui transmettaient les données en clair.

> [!info] Définition SSH est à la fois un protocole de communication et un ensemble d'outils permettant d'administrer à distance des machines de manière sécurisée et chiffrée.

### Pourquoi SSH est-il essentiel ?

SSH résout plusieurs problématiques critiques en matière de sécurité et d'administration système :

**🔒 Sécurité**

- Chiffrement de bout en bout de toutes les communications
- Protection contre l'interception des identifiants (attaques man-in-the-middle)
- Authentification forte par clés cryptographiques
- Intégrité des données garantie

**⚙️ Fonctionnalités**

- Administration à distance de serveurs
- Transfert sécurisé de fichiers (SCP, SFTP)
- Tunneling de connexions (port forwarding)
- Exécution de commandes à distance

**🌍 Cas d'usage courants**

- Gestion de serveurs Linux/Unix distants
- Déploiement d'applications
- Automatisation de tâches avec des scripts
- Accès sécurisé aux services internes via des tunnels
- Administration de bases de données distantes

> [!warning] Contexte historique Avant SSH, les administrateurs système utilisaient Telnet qui transmettait les mots de passe en clair sur le réseau. SSH a été créé en 1995 par Tatu Ylönen en réponse à une attaque par reniflage de mots de passe (password sniffing) à l'Université de technologie d'Helsinki.

### Les versions du protocole SSH

|Version|Année|État|Caractéristiques|
|---|---|---|---|
|SSH-1|1995|⛔ Obsolète|Vulnérabilités de sécurité connues, ne doit plus être utilisé|
|SSH-2|2006|✅ Standard actuel|Sécurité renforcée, algorithmes modernes, incompatible avec SSH-1|

> [!tip] Bonne pratique Désactivez toujours le support de SSH-1 dans vos configurations. Tous les systèmes modernes utilisent exclusivement SSH-2.

### Concepts clés du protocole

**Le chiffrement en couches**

SSH utilise une approche multicouche pour sécuriser les communications :

1. **Couche de transport** : Établit le canal sécurisé, négocie les algorithmes de chiffrement
2. **Couche d'authentification** : Vérifie l'identité du client
3. **Couche de connexion** : Multiplexe plusieurs canaux logiques sur une seule connexion

**L'authentification bidirectionnelle**

Contrairement à de nombreux protocoles, SSH authentifie les deux parties :

- Le **serveur** s'authentifie auprès du client via sa clé d'hôte
- Le **client** s'authentifie auprès du serveur (mot de passe, clé publique, etc.)

> [!example] Exemple de première connexion Lors de votre première connexion à un serveur, SSH vous avertit qu'il ne connaît pas l'empreinte de la clé d'hôte :
> 
> ```
> The authenticity of host 'exemple.com (192.168.1.10)' can't be established.
> ED25519 key fingerprint is SHA256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.
> Are you sure you want to continue connecting (yes/no)?
> ```
> 
> Cette vérification protège contre les attaques man-in-the-middle.

---

## 🏗️ Architecture et composants

L'écosystème SSH repose sur quatre composants principaux qui interagissent pour fournir des connexions sécurisées.

### Client SSH

Le client SSH est l'application que vous utilisez pour initier une connexion vers un serveur distant.

#### Qu'est-ce qu'un client SSH ?

Le client SSH est le logiciel côté utilisateur qui :

- Initie la connexion vers le serveur distant
- Négocie les paramètres de chiffrement
- Authentifie l'utilisateur
- Fournit l'interface pour interagir avec le système distant

#### Implémentations courantes

|Système|Client par défaut|Alternatives populaires|
|---|---|---|
|Linux/Unix|OpenSSH (`ssh`)|Dropbear, lsh|
|macOS|OpenSSH (`ssh`)|-|
|Windows 10/11|OpenSSH (intégré)|PuTTY, MobaXterm, Windows Terminal|

> [!info] OpenSSH OpenSSH est l'implémentation libre et open-source la plus répandue, développée par le projet OpenBSD. Elle est devenue le standard de facto sur pratiquement toutes les plateformes.

#### Commande de base

```bash
# Syntaxe générale
ssh [options] [utilisateur@]hôte [commande]

# Exemples
ssh serveur.exemple.com                    # Connexion avec l'utilisateur courant
ssh admin@192.168.1.100                    # Connexion avec un utilisateur spécifique
ssh -p 2222 user@serveur.com               # Connexion sur un port personnalisé
ssh user@serveur.com "ls -la /var/log"     # Exécuter une commande à distance
```

#### Fichiers de configuration du client

Le client SSH utilise plusieurs fichiers pour sa configuration :

**`~/.ssh/config`** - Configuration personnelle de l'utilisateur

```bash
# Exemple de configuration
Host monserveur
    HostName 192.168.1.100
    User admin
    Port 2222
    IdentityFile ~/.ssh/ma_cle_privee

Host *.entreprise.com
    User monnom
    ForwardAgent yes
```

**`/etc/ssh/ssh_config`** - Configuration globale du système

**`~/.ssh/known_hosts`** - Empreintes des clés d'hôtes connus

> [!tip] Astuces client
> 
> - Utilisez des alias dans `~/.ssh/config` pour simplifier vos connexions fréquentes
> - La touche `~` suivie de `.` permet de fermer une connexion bloquée
> - `Ctrl+Z` suspend la session SSH et vous ramène au shell local (utilisez `fg` pour y revenir)

#### Options importantes du client

```bash
# Connexion avec redirection X11 (interface graphique)
ssh -X user@serveur

# Mode verbeux (débogage)
ssh -v user@serveur      # Niveau 1
ssh -vv user@serveur     # Niveau 2
ssh -vvv user@serveur    # Niveau 3 (très détaillé)

# Compression des données (utile sur connexions lentes)
ssh -C user@serveur

# Désactiver l'allocation de pseudo-terminal
ssh -T user@serveur

# Forcer l'allocation de pseudo-terminal
ssh -t user@serveur
```

> [!warning] Piège courant Ne confondez pas `ssh -t` (allocation de terminal) avec `ssh -T` (pas de terminal). Le premier est utile pour exécuter des commandes interactives, le second pour les scripts automatisés.

---

### Serveur SSH (sshd)

Le serveur SSH est le daemon (service) qui écoute les connexions entrantes et authentifie les clients.

#### Qu'est-ce que sshd ?

**sshd** (SSH daemon) est le processus serveur qui :

- Écoute sur un port réseau (par défaut le port 22)
- Accepte les connexions des clients SSH
- Authentifie les utilisateurs
- Crée des sessions sécurisées pour les clients authentifiés
- Gère l'exécution des commandes demandées

#### Installation et gestion du service

```bash
# Installation (Debian/Ubuntu)
sudo apt update
sudo apt install openssh-server

# Installation (Red Hat/CentOS/Fedora)
sudo dnf install openssh-server

# Gestion du service
sudo systemctl start sshd       # Démarrer le service
sudo systemctl stop sshd        # Arrêter le service
sudo systemctl restart sshd     # Redémarrer le service
sudo systemctl reload sshd      # Recharger la configuration sans couper les connexions
sudo systemctl enable sshd      # Activer au démarrage
sudo systemctl status sshd      # Vérifier l'état du service

# Vérifier que le serveur écoute
sudo ss -tlnp | grep sshd       # Voir les ports d'écoute
sudo netstat -tlnp | grep sshd  # Alternative avec netstat
```

> [!info] Reload vs Restart `reload` recharge la configuration sans interrompre les sessions actives, tandis que `restart` coupe toutes les connexions en cours. Privilégiez `reload` pour les mises à jour de configuration.

#### Fichier de configuration principal

Le serveur SSH est configuré via **`/etc/ssh/sshd_config`**

```bash
# Exemple de configuration sécurisée
Port 22                              # Port d'écoute (22 par défaut)
ListenAddress 0.0.0.0                # Interface d'écoute (toutes par défaut)

# Authentification
PermitRootLogin no                   # ⚠️ Désactiver la connexion root directe
PasswordAuthentication yes           # Autoriser l'authentification par mot de passe
PubkeyAuthentication yes             # Autoriser l'authentification par clé publique
PermitEmptyPasswords no              # Interdire les mots de passe vides

# Sécurité
Protocol 2                           # Forcer SSH-2 uniquement
MaxAuthTries 3                       # Limite de tentatives d'authentification
LoginGraceTime 60                    # Temps maximum pour s'authentifier (en secondes)
ClientAliveInterval 300              # Envoyer un message toutes les 5 minutes
ClientAliveCountMax 2                # Déconnecter après 2 messages sans réponse

# Restrictions utilisateurs
AllowUsers admin user1 user2         # Liste blanche des utilisateurs autorisés
DenyUsers baduser                    # Liste noire des utilisateurs interdits
AllowGroups sshusers                 # Autoriser uniquement un groupe spécifique

# Journalisation
SyslogFacility AUTH                  # Facilité de journalisation
LogLevel INFO                        # Niveau de détail des logs

# Subsystèmes
Subsystem sftp /usr/lib/openssh/sftp-server  # Activer le serveur SFTP
```

> [!warning] Pièges de configuration
> 
> - Après modification de `sshd_config`, testez toujours la configuration avec `sudo sshd -t` avant de recharger
> - Ne fermez jamais votre session SSH active avant d'avoir vérifié que la nouvelle configuration fonctionne
> - Gardez toujours une session SSH ouverte pendant les tests de configuration

#### Paramètres de sécurité recommandés

```bash
# Configuration sécurisée minimale
PermitRootLogin no                   # Jamais de connexion root directe
PasswordAuthentication no            # Désactiver après configuration des clés
PubkeyAuthentication yes             # Privilégier l'authentification par clés
PermitEmptyPasswords no              # Toujours interdit
MaxAuthTries 3                       # Limiter les tentatives
X11Forwarding no                     # Désactiver si non nécessaire
AllowAgentForwarding no              # Désactiver si non nécessaire
AllowTcpForwarding no                # Désactiver si non nécessaire
```

> [!tip] Bonne pratique - Changer le port Changer le port SSH par défaut (22) vers un port non standard (ex: 2222, 8022) réduit considérablement les scans automatisés et tentatives d'intrusion. N'oubliez pas d'ouvrir le nouveau port dans votre pare-feu !

#### Journalisation et débogage

```bash
# Logs du serveur SSH (Debian/Ubuntu)
sudo tail -f /var/log/auth.log

# Logs du serveur SSH (Red Hat/CentOS)
sudo tail -f /var/log/secure

# Tester la configuration sans redémarrer
sudo sshd -t                         # Test de syntaxe
sudo sshd -T                         # Afficher la configuration complète

# Mode debug (pour troubleshooting)
sudo /usr/sbin/sshd -d -p 2222       # Démarre en mode debug sur le port 2222
```

---

### Modèle client-serveur

SSH implémente une architecture client-serveur classique avec des spécificités de sécurité.

#### Fonctionnement du modèle

```
┌─────────────┐                    ┌─────────────┐
│   CLIENT    │                    │   SERVEUR   │
│    SSH      │                    │    SSHD     │
└─────────────┘                    └─────────────┘
       │                                  │
       │  1. Demande de connexion        │
       │─────────────────────────────────>│
       │                                  │
       │  2. Envoi clé publique serveur  │
       │<─────────────────────────────────│
       │                                  │
       │  3. Vérification + Accord algo. │
       │─────────────────────────────────>│
       │                                  │
       │  4. Authentification client     │
       │─────────────────────────────────>│
       │                                  │
       │  5. Session chiffrée établie    │
       │<────────────────────────────────>│
```

#### Établissement de la connexion

Le processus de connexion SSH suit plusieurs étapes strictes :

**Phase 1 : Établissement du transport**

1. Le client initie une connexion TCP vers le serveur (port 22 par défaut)
2. Le serveur et le client échangent leurs versions et capacités
3. Ils négocient les algorithmes de chiffrement, d'intégrité et de compression
4. Un échange de clés Diffie-Hellman génère une clé de session partagée

**Phase 2 : Authentification du serveur** 5. Le serveur envoie sa clé publique d'hôte 6. Le client vérifie cette clé contre ses clés connues (`~/.ssh/known_hosts`) 7. Si c'est une nouvelle clé, l'utilisateur doit l'approuver

**Phase 3 : Authentification du client** 8. Le client s'authentifie (plusieurs méthodes possibles, nous les verrons dans une autre partie) 9. Si l'authentification réussit, une session est créée

**Phase 4 : Session** 10. Le canal sécurisé est établi, toutes les communications sont chiffrées 11. Le client peut maintenant exécuter des commandes, transférer des fichiers, etc.

> [!example] Trace d'une connexion
> 
> ```bash
> $ ssh -v user@serveur.com
> OpenSSH_8.9p1, OpenSSL 3.0.2 15 Mar 2022
> debug1: Connecting to serveur.com [192.168.1.100] port 22.
> debug1: Connection established.
> debug1: Remote protocol version 2.0, remote software version OpenSSH_8.9
> debug1: compat_banner: match: OpenSSH_8.9 pat OpenSSH* compat 0x04000000
> debug1: kex: algorithm: curve25519-sha256
> debug1: kex: host key algorithm: ssh-ed25519
> debug1: kex: server->client cipher: chacha20-poly1305@openssh.com
> debug1: Server host key: ssh-ed25519 SHA256:xxxxxxxxxxxxxxxxxxx
> debug1: Authentications that can continue: publickey,password
> debug1: Next authentication method: publickey
> debug1: Offering public key: /home/user/.ssh/id_ed25519
> debug1: Server accepts key: /home/user/.ssh/id_ed25519
> debug1: Authentication succeeded (publickey).
> ```

#### Multiplexage de connexions

SSH permet de multiplexer plusieurs "canaux" (channels) sur une seule connexion TCP :

```bash
# Activer le multiplexage dans ~/.ssh/config
Host *
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h:%p
    ControlPersist 10m
```

**Avantages du multiplexage :**

- Connexions supplémentaires instantanées (pas de nouvelle négociation)
- Économie de ressources (une seule connexion TCP)
- Amélioration des performances pour les scripts avec multiples connexions

> [!tip] Cas d'usage du multiplexage Particulièrement utile quand vous utilisez des outils comme `rsync`, `scp` ou `ansible` qui ouvrent plusieurs connexions successives vers le même serveur.

#### Architecture de la communication

**Couche de transport (SSH-TRANS)**

- Établit le canal chiffré
- Gère l'échange de clés et la réauthentification périodique
- Assure la compression des données si activée

**Couche d'authentification (SSH-AUTH)**

- Gère les différentes méthodes d'authentification
- Vérifie les identités

**Couche de connexion (SSH-CONN)**

- Gère le multiplexage de canaux
- Contrôle les requêtes de terminaux, X11 forwarding, agent forwarding, etc.

> [!info] Concept important Ces trois couches sont indépendantes et modulaires, ce qui permet à SSH d'être flexible et d'ajouter facilement de nouvelles fonctionnalités ou méthodes d'authentification.

---

### Agents SSH

L'agent SSH est un gestionnaire de clés privées en mémoire qui facilite l'utilisation des clés cryptographiques.

#### Qu'est-ce qu'un agent SSH ?

L'agent SSH (`ssh-agent`) est un programme qui :

- Conserve les clés privées en mémoire de manière sécurisée
- Répond aux demandes d'authentification sans exposer les clés privées
- Évite de retaper la passphrase des clés à chaque connexion
- Peut transférer l'accès aux clés à travers des connexions SSH (agent forwarding)

> [!info] Pourquoi utiliser un agent ? Sans agent, vous devez entrer la passphrase de votre clé privée à chaque connexion SSH. Avec un agent, vous ne la saisissez qu'une seule fois au démarrage, et l'agent gère ensuite toutes les authentifications automatiquement.

#### Démarrage et utilisation

```bash
# Démarrer l'agent SSH
eval "$(ssh-agent -s)"
# Affiche quelque chose comme : Agent pid 12345

# Vérifier que l'agent tourne
echo $SSH_AUTH_SOCK        # Doit afficher un chemin vers un socket
echo $SSH_AGENT_PID        # Doit afficher le PID de l'agent

# Ajouter une clé privée à l'agent
ssh-add ~/.ssh/id_ed25519
# Demande la passphrase une fois, puis la conserve en mémoire

# Ajouter toutes les clés par défaut (~/.ssh/id_*)
ssh-add

# Lister les clés actuellement chargées
ssh-add -l
# Affiche les empreintes des clés : 256 SHA256:xxx... user@host (ED25519)

# Supprimer une clé spécifique de l'agent
ssh-add -d ~/.ssh/id_ed25519

# Supprimer toutes les clés de l'agent
ssh-add -D

# Arrêter l'agent SSH
eval "$(ssh-agent -k)"
```

> [!tip] Astuce - Démarrage automatique Sur la plupart des systèmes Linux modernes avec un gestionnaire de sessions (GNOME, KDE), l'agent SSH démarre automatiquement au login. Vérifiez avec `echo $SSH_AUTH_SOCK`.

#### Configuration avancée

**Définir une durée de vie pour les clés**

```bash
# Ajouter une clé pour 1 heure seulement
ssh-add -t 3600 ~/.ssh/id_ed25519

# Ajouter toutes les clés avec expiration de 8 heures
ssh-add -t 28800
```

**Confirmation requise avant utilisation**

```bash
# Demander confirmation à chaque utilisation de la clé
ssh-add -c ~/.ssh/id_ed25519
# Une popup apparaîtra à chaque tentative d'utilisation
```

#### Agent Forwarding

L'agent forwarding permet de "transférer" l'accès à vos clés SSH locales à travers une connexion SSH.

```bash
# Activer l'agent forwarding pour une connexion
ssh -A user@serveur-intermediaire

# Dans ~/.ssh/config
Host serveur-intermediaire
    ForwardAgent yes
```

**Scénario d'utilisation :**

```
Votre machine  →  Serveur A  →  Serveur B
  (vos clés)    (pas de clés)  (nécessite vos clés)
```

Avec l'agent forwarding, depuis le Serveur A, vous pouvez vous connecter au Serveur B en utilisant vos clés locales sans avoir à copier ces clés sur le Serveur A.

> [!warning] Sécurité de l'Agent Forwarding **Attention :** L'agent forwarding comporte des risques de sécurité. Si le serveur intermédiaire est compromis, un attaquant pourrait utiliser temporairement vos clés pendant votre session. Ne l'activez que sur des serveurs de confiance.
> 
> **Alternative plus sûre :** Utilisez des clés dédiées pour chaque serveur ou créez un tunnel SSH manuel avec `-L` ou `-J` (ProxyJump) qui ne transfère pas l'agent.

#### Intégration avec keychain

Sur des systèmes avec de longues sessions, vous pouvez utiliser `keychain` pour gérer votre agent :

```bash
# Installation
sudo apt install keychain  # Debian/Ubuntu
sudo dnf install keychain  # Fedora

# Dans ~/.bashrc ou ~/.zshrc
eval $(keychain --eval --quiet id_ed25519)
```

`keychain` maintient un agent SSH persistant entre les sessions et les redémarrages.

#### Agents SSH alternatifs

|Agent|Description|Particularité|
|---|---|---|
|`ssh-agent`|Agent standard OpenSSH|Inclus avec OpenSSH, léger|
|`gpg-agent`|Agent GPG avec support SSH|Unifie gestion GPG et SSH|
|`GNOME Keyring`|Gestionnaire de mots de passe GNOME|Intégration desktop, démarrage auto|
|`KDE Wallet`|Gestionnaire de mots de passe KDE|Intégration desktop KDE|

> [!example] Vérification de l'agent actif
> 
> ```bash
> # Voir quel agent est utilisé
> echo $SSH_AUTH_SOCK
> 
> # Exemples de sorties :
> /tmp/ssh-XXXXXXxxxxxx/agent.12345    # ssh-agent
> /run/user/1000/keyring/ssh           # GNOME Keyring
> /run/user/1000/gnupg/S.gpg-agent.ssh # gpg-agent
> ```

#### Bonnes pratiques avec l'agent

✅ **À faire :**

- Toujours protéger vos clés privées avec une passphrase forte
- Utiliser `ssh-add -t` pour limiter la durée de vie des clés en mémoire
- Vider l'agent (`ssh-add -D`) avant de quitter une session sur une machine partagée
- Désactiver l'agent forwarding par défaut, l'activer uniquement quand nécessaire

❌ **À éviter :**

- Charger des clés sans passphrase dans l'agent
- Activer l'agent forwarding sur des serveurs non fiables
- Laisser des clés sensibles chargées indéfiniment sur des machines partagées

---

## 🎯 Résumé de l'architecture SSH

L'écosystème SSH repose sur quatre piliers interconnectés :

|Composant|Rôle|Fichiers clés|
|---|---|---|
|**Client SSH**|Initie les connexions|`~/.ssh/config`, `~/.ssh/known_hosts`|
|**Serveur SSH**|Accepte et authentifie|`/etc/ssh/sshd_config`|
|**Modèle client-serveur**|Architecture de communication|-|
|**Agent SSH**|Gère les clés en mémoire|Variables `$SSH_AUTH_SOCK`, `$SSH_AGENT_PID`|

Cette architecture modulaire permet à SSH d'être à la fois :

- **Sécurisé** : chiffrement fort, authentification bidirectionnelle
- **Flexible** : multiples méthodes d'authentification, multiplexage
- **Pratique** : agent pour éviter les passphrases répétées, configuration personnalisable
- **Universel** : fonctionne sur tous les systèmes Unix/Linux et maintenant Windows

---

> [!info] Fin de la Partie 1 Vous maîtrisez maintenant l'architecture fondamentale de SSH. Les concepts présentés ici (client, serveur, agent, modèle de communication) constituent la base nécessaire pour comprendre les fonctionnalités avancées de SSH.