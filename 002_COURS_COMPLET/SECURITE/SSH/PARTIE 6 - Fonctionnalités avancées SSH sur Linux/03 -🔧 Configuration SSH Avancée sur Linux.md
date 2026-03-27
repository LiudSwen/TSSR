

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

La configuration SSH avancée permet d'optimiser et d'automatiser vos connexions à distance. Au lieu de taper de longues commandes avec de nombreuses options à chaque fois, vous pouvez définir des configurations persistantes qui rendent vos connexions plus rapides, plus sûres et plus pratiques.

> [!info] Pourquoi configurer SSH ?
> 
> - **Gain de temps** : remplacer `ssh -p 2222 -i ~/.ssh/key user@server.example.com` par simplement `ssh myserver`
> - **Cohérence** : garantir que les bonnes options sont toujours utilisées
> - **Sécurité** : appliquer automatiquement les meilleures pratiques
> - **Productivité** : simplifier les connexions complexes (bastion, proxy, tunnels)

---

## Fichier ~/.ssh/config

### 📖 Concept

Le fichier `~/.ssh/config` est le fichier de configuration personnel de SSH pour chaque utilisateur. Il permet de définir des paramètres par défaut et des configurations spécifiques pour différents hôtes.

### 🎯 Emplacement et permissions

```bash
# Fichier de configuration utilisateur
~/.ssh/config

# Fichier de configuration système (pour tous les utilisateurs)
/etc/ssh/ssh_config
```

> [!warning] Permissions importantes Le fichier `~/.ssh/config` doit avoir les bonnes permissions pour être pris en compte :
> 
> ```bash
> chmod 600 ~/.ssh/config
> ```
> 
> SSH ignorera le fichier s'il est accessible en écriture par d'autres utilisateurs.

### 📝 Structure de base

Le fichier `config` utilise une syntaxe simple avec des directives `Host` suivies de paramètres :

```bash
# Structure générale
Host nom_ou_pattern
    Option1 valeur1
    Option2 valeur2
    Option3 valeur3

Host autre_hote
    Option1 valeur1
```

> [!tip] Indentation L'indentation (4 espaces ou 1 tab) n'est pas obligatoire mais fortement recommandée pour la lisibilité.

### 🔧 Options principales

|Option|Description|Exemple|
|---|---|---|
|`HostName`|Nom ou IP réel du serveur|`HostName 192.168.1.100`|
|`User`|Nom d'utilisateur pour la connexion|`User admin`|
|`Port`|Port SSH (défaut: 22)|`Port 2222`|
|`IdentityFile`|Clé privée à utiliser|`IdentityFile ~/.ssh/id_rsa_perso`|
|`IdentitiesOnly`|Utiliser uniquement les clés spécifiées|`IdentitiesOnly yes`|
|`ForwardAgent`|Activer l'agent forwarding|`ForwardAgent yes`|
|`ServerAliveInterval`|Intervalle keepalive (secondes)|`ServerAliveInterval 60`|
|`ServerAliveCountMax`|Nombre max de keepalive sans réponse|`ServerAliveCountMax 3`|
|`Compression`|Activer la compression|`Compression yes`|
|`LogLevel`|Niveau de verbosité|`LogLevel DEBUG`|

### 💡 Exemple de configuration complète

```bash
# Configuration par défaut pour tous les hôtes
Host *
    # Garder la connexion active
    ServerAliveInterval 60
    ServerAliveCountMax 3
    
    # Réutiliser les connexions existantes
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h:%p
    ControlPersist 10m
    
    # Sécurité
    HashKnownHosts yes
    StrictHostKeyChecking ask
    
    # Compression pour connexions lentes
    Compression yes

# Serveur de production
Host prod
    HostName prod.example.com
    User deploy
    Port 2222
    IdentityFile ~/.ssh/id_rsa_prod
    IdentitiesOnly yes
    ForwardAgent no

# Serveur de développement
Host dev
    HostName 192.168.1.50
    User developer
    IdentityFile ~/.ssh/id_rsa_dev
    ForwardAgent yes

# GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_github
    IdentitiesOnly yes
```

### 🎨 Patterns et wildcards

Vous pouvez utiliser des patterns pour appliquer des configurations à plusieurs hôtes :

```bash
# Tous les serveurs se terminant par .local
Host *.local
    User admin
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

# Tous les serveurs du sous-réseau 10.0.0.x
Host 10.0.0.*
    User root
    Port 22
    IdentityFile ~/.ssh/id_rsa_internal

# Pattern avec alternatives
Host web* mail* db*
    User sysadmin
    ForwardAgent yes

# Négation (tous sauf gitlab.com)
Host * !gitlab.com
    Compression yes
```

> [!tip] Ordre de priorité SSH lit le fichier de haut en bas et applique la **première** valeur trouvée pour chaque option. Placez les configurations les plus spécifiques en haut et les plus générales en bas.

### ⚠️ Pièges courants

> [!warning] Erreur : Options non reconnues Si SSH ignore votre configuration, vérifiez :
> 
> - Les permissions du fichier (`chmod 600 ~/.ssh/config`)
> - La syntaxe (pas d'espaces autour du `=`, majuscules correctes)
> - La version de votre client SSH (certaines options sont récentes)

> [!warning] Ordre des Host
> 
> ```bash
> # ❌ INCORRECT - Le pattern * sera appliqué avant prod
> Host *
>     User generic
> 
> Host prod
>     User admin  # Cette ligne sera ignorée !
> 
> # ✅ CORRECT - Spécifique d'abord, général ensuite
> Host prod
>     User admin
> 
> Host *
>     User generic
> ```

---

## Alias d'hôtes

### 📖 Concept

Les alias permettent de remplacer des commandes SSH longues et complexes par des noms courts et mémorables. C'est la fonctionnalité la plus basique mais la plus utilisée du fichier `config`.

### 🎯 Pourquoi utiliser des alias ?

**Sans alias :**

```bash
ssh -i ~/.ssh/keys/production.pem -p 2222 ubuntu@ec2-52-14-123-456.us-east-2.compute.amazonaws.com
```

**Avec alias :**

```bash
ssh aws-prod
```

### 💡 Exemples pratiques

#### Alias simple

```bash
Host myserver
    HostName 192.168.1.100
    User admin
```

Utilisation : `ssh myserver`

#### Alias avec clé spécifique

```bash
Host gitlab
    HostName gitlab.company.com
    User git
    IdentityFile ~/.ssh/id_rsa_gitlab
    IdentitiesOnly yes
```

> [!tip] IdentitiesOnly L'option `IdentitiesOnly yes` force SSH à utiliser **uniquement** la clé spécifiée, sans essayer toutes les clés de votre agent SSH. Cela évite l'erreur "Too many authentication failures".

#### Alias multiples pour le même serveur

```bash
# Différents utilisateurs sur le même serveur
Host server-admin
    HostName server.example.com
    User admin
    IdentityFile ~/.ssh/id_rsa_admin

Host server-user
    HostName server.example.com
    User regularuser
    IdentityFile ~/.ssh/id_rsa_user
```

#### Alias avec port non-standard

```bash
Host raspberry
    HostName 192.168.1.200
    User pi
    Port 2222
```

### 🔧 Alias avec variables d'environnement

SSH ne supporte pas directement les variables d'environnement dans le fichier config, mais vous pouvez utiliser la commande `Match exec` pour des configurations dynamiques :

```bash
# Configuration conditionnelle basée sur une commande
Match host prod exec "test -f ~/.ssh/use_vpn"
    ProxyJump vpn-gateway

Host prod
    HostName prod.internal
    User deploy
```

### 🎨 Nommage intelligent des alias

> [!tip] Bonnes pratiques de nommage
> 
> - **Descriptif** : `web-prod`, `db-staging`, `bastion-us-east`
> - **Hiérarchique** : `company-prod-web1`, `company-dev-db1`
> - **Court mais clair** : `prod` plutôt que `production-server-primary`
> - **Cohérent** : utiliser toujours le même schéma de nommage

```bash
# Organisation par environnement
Host prod-web
    HostName web.prod.company.com
    User www-data

Host staging-web
    HostName web.staging.company.com
    User www-data

Host dev-web
    HostName web.dev.company.com
    User developer

# Organisation par fonction
Host web-prod
    HostName prod-web.company.com
    User deploy

Host web-staging
    HostName staging-web.company.com
    User deploy
```

### ⚙️ Combiner alias et options avancées

```bash
Host jump
    HostName bastion.company.com
    User bastion-user
    IdentityFile ~/.ssh/bastion_key
    # Garder la connexion bastion ouverte
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h:%p
    ControlPersist 10m

Host internal
    HostName 10.0.1.50
    User admin
    ProxyJump jump
    IdentityFile ~/.ssh/internal_key
```

Utilisation : `ssh internal` se connectera automatiquement via le bastion.

### 📊 Tester votre configuration

```bash
# Afficher la configuration effective pour un alias
ssh -G myserver

# Mode verbeux pour déboguer
ssh -v myserver

# Très verbeux
ssh -vvv myserver
```

> [!example] Sortie de ssh -G
> 
> ```bash
> $ ssh -G myserver
> user admin
> hostname 192.168.1.100
> port 22
> identityfile ~/.ssh/id_rsa
> compression yes
> ...
> ```

---

## ProxyJump et ProxyCommand

### 📖 Concept

**ProxyJump** et **ProxyCommand** permettent de se connecter à un serveur cible à travers un ou plusieurs serveurs intermédiaires (bastions, jump hosts). C'est essentiel pour accéder à des serveurs dans des réseaux privés non directement accessibles depuis Internet.

### 🏗️ Architecture typique

```
Internet → Bastion (accessible publiquement) → Serveurs internes (privés)
```

### 🎯 ProxyJump (méthode moderne)

**ProxyJump** est la méthode recommandée depuis OpenSSH 7.3 (2016). Elle est simple, sécurisée et automatique.

#### Syntaxe de base

```bash
Host internal-server
    HostName 10.0.1.100
    User admin
    ProxyJump bastion.example.com
```

Équivalent en ligne de commande :

```bash
ssh -J bastion.example.com admin@10.0.1.100
```

#### Multi-hop (sauts multiples)

```bash
# Chaîne de sauts : local → bastion1 → bastion2 → target
Host target
    HostName 10.0.2.50
    User admin
    ProxyJump bastion1.example.com,bastion2.internal
```

Équivalent en ligne de commande :

```bash
ssh -J bastion1.example.com,bastion2.internal admin@10.0.2.50
```

#### Configuration complète avec alias

```bash
# Définition du bastion
Host bastion
    HostName bastion.example.com
    User bastion-user
    Port 2222
    IdentityFile ~/.ssh/bastion_key
    ServerAliveInterval 60

# Serveur cible utilisant le bastion
Host prod-db
    HostName 10.0.1.100
    User dbadmin
    ProxyJump bastion
    IdentityFile ~/.ssh/prod_key
    LocalForward 5432 localhost:5432

# Plusieurs serveurs utilisant le même bastion
Host prod-*
    ProxyJump bastion
    User admin
    
Host prod-web
    HostName 10.0.1.10
    
Host prod-api
    HostName 10.0.1.20
```

> [!tip] Avantages de ProxyJump
> 
> - Syntaxe simple et lisible
> - Gestion automatique des connexions intermédiaires
> - Supporte l'agent forwarding nativement
> - Pas besoin de configuration complexe

### 🔧 ProxyCommand (méthode legacy mais puissante)

**ProxyCommand** est l'ancienne méthode, plus complexe mais plus flexible. Elle permet d'exécuter une commande arbitraire pour établir la connexion.

#### Syntaxe de base avec netcat

```bash
Host internal-server
    HostName 10.0.1.100
    User admin
    ProxyCommand ssh -W %h:%p bastion.example.com
```

> [!info] Option -W L'option `-W %h:%p` établit un tunnel direct vers `%h:%p` (hôte:port de destination) via le serveur spécifié.

#### Avec netcat (nc)

```bash
Host internal-server
    HostName 10.0.1.100
    User admin
    ProxyCommand ssh bastion.example.com nc %h %p
```

#### Configuration avancée

```bash
# Bastion avec configuration
Host bastion
    HostName bastion.example.com
    User jump-user
    IdentityFile ~/.ssh/bastion_key

# Serveur interne via ProxyCommand
Host internal
    HostName 10.0.1.50
    User admin
    IdentityFile ~/.ssh/internal_key
    ProxyCommand ssh -W %h:%p bastion
    ServerAliveInterval 60
```

### 🆚 Comparaison ProxyJump vs ProxyCommand

|Caractéristique|ProxyJump|ProxyCommand|
|---|---|---|
|**Simplicité**|✅ Très simple|⚠️ Plus complexe|
|**Lisibilité**|✅ Excellente|⚠️ Moyenne|
|**Flexibilité**|⚠️ Limitée|✅ Totale|
|**Compatibilité**|OpenSSH ≥ 7.3|Toutes versions|
|**Performance**|✅ Optimisée|✅ Bonne|
|**Agent forwarding**|✅ Natif|⚠️ Configuration manuelle|
|**Cas d'usage**|95% des cas|Besoins très spécifiques|

> [!tip] Recommandation Utilisez **ProxyJump** sauf si vous avez besoin de fonctionnalités très spécifiques (protocoles non-SSH, commandes personnalisées).

### 💡 Cas d'usage avancés

#### Bastion avec authentification différente

```bash
Host bastion
    HostName bastion.example.com
    User bastion-user
    IdentityFile ~/.ssh/bastion_key
    
Host prod-*
    ProxyJump bastion
    User different-user
    IdentityFile ~/.ssh/prod_key
    
Host prod-web
    HostName 10.0.1.10
```

#### ProxyCommand avec Tor

```bash
Host hidden-service
    HostName abc123def456.onion
    ProxyCommand nc -X 5 -x 127.0.0.1:9050 %h %p
```

#### ProxyCommand conditionnel

```bash
# Utiliser le proxy seulement si on n'est pas sur le réseau local
Host internal-*
    HostName 10.0.1.%h
    ProxyCommand bash -c 'if ping -c1 -W1 %h; then nc %h %p; else ssh -W %h:%p bastion; fi'
```

### 🎨 Patterns pour infrastructure complexe

```bash
# Configuration du bastion
Host bastion-*
    User bastion
    IdentityFile ~/.ssh/bastion_key
    ServerAliveInterval 30

Host bastion-us
    HostName bastion-us.example.com

Host bastion-eu
    HostName bastion-eu.example.com

# Serveurs US (via bastion US)
Host us-*
    ProxyJump bastion-us
    User admin
    IdentityFile ~/.ssh/us_key

Host us-web1
    HostName 10.0.1.10

Host us-db1
    HostName 10.0.1.20

# Serveurs EU (via bastion EU)
Host eu-*
    ProxyJump bastion-eu
    User admin
    IdentityFile ~/.ssh/eu_key

Host eu-web1
    HostName 10.1.1.10

Host eu-db1
    HostName 10.1.1.20
```

### 🔍 Debugging des connexions proxy

```bash
# Mode verbeux pour voir le cheminement
ssh -v internal-server

# Très verbeux pour déboguer les problèmes
ssh -vvv internal-server

# Tester la connexion au bastion seul
ssh -v bastion

# Tester la chaîne complète
ssh -J bastion -v internal-server
```

### ⚠️ Pièges courants

> [!warning] Clés SSH différentes Si le bastion et le serveur cible utilisent des clés différentes, spécifiez-les explicitement :
> 
> ```bash
> Host bastion
>     IdentityFile ~/.ssh/bastion_key
> 
> Host internal
>     ProxyJump bastion
>     IdentityFile ~/.ssh/internal_key
>     IdentitiesOnly yes  # Important !
> ```

> [!warning] Timeouts en cascade Les timeouts peuvent s'accumuler. Ajustez les valeurs :
> 
> ```bash
> Host bastion
>     ServerAliveInterval 30
>     ServerAliveCountMax 3
>     ConnectTimeout 10
> 
> Host internal
>     ProxyJump bastion
>     ServerAliveInterval 30
>     ConnectTimeout 30  # Plus long car passe par bastion
> ```

> [!warning] Agent forwarding avec ProxyCommand Avec ProxyCommand, l'agent forwarding ne fonctionne pas automatiquement. Utilisez ProxyJump à la place.

---

## Multiplexing de connexions (ControlMaster)

### 📖 Concept

Le **multiplexing SSH** permet de réutiliser une connexion SSH existante pour ouvrir de nouvelles sessions, au lieu de créer une nouvelle connexion TCP à chaque fois. Cela accélère considérablement les connexions répétées au même serveur.

### 🎯 Pourquoi utiliser le multiplexing ?

**Sans multiplexing :**

- Chaque `ssh`, `scp`, `rsync` établit une nouvelle connexion complète
- Authentification répétée
- Handshake TCP/SSH à chaque fois
- 2-5 secondes par connexion

**Avec multiplexing :**

- Première connexion normale
- Connexions suivantes quasi-instantanées (<0.1s)
- Partage de l'authentification
- Utilisation d'un socket Unix local

### 🔧 Configuration de base

```bash
Host *
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h:%p
    ControlPersist 10m
```

> [!info] Créer le dossier sockets
> 
> ```bash
> mkdir -p ~/.ssh/sockets
> chmod 700 ~/.ssh/sockets
> ```

### 📝 Options ControlMaster

|Valeur|Comportement|
|---|---|
|`no`|Désactive le multiplexing (défaut)|
|`yes`|Connexion maître uniquement, échoue si socket existe|
|`auto`|Devient maître si pas de socket, réutilise sinon (recommandé)|
|`ask`|Demande à l'utilisateur|
|`autoask`|Auto + demande si ambiguïté|

### 📝 Options ControlPath

**ControlPath** définit l'emplacement du socket de contrôle. Les variables disponibles :

|Variable|Signification|Exemple|
|---|---|---|
|`%r`|Utilisateur distant|`admin`|
|`%h`|Nom d'hôte|`server.example.com`|
|`%p`|Port|`22`|
|`%l`|Nom d'hôte local|`laptop`|
|`%n`|Nom d'hôte original de la ligne de commande|`myserver`|
|`%%`|Caractère `%` littéral|`%`|

> [!tip] Pattern recommandé
> 
> ```bash
> ControlPath ~/.ssh/sockets/%r@%h:%p
> ```
> 
> Cela crée des sockets nommés comme `admin@server.example.com:22`

> [!warning] Longueur du chemin Sur certains systèmes (macOS, BSD), le chemin du socket est limité à environ 104 caractères. Si vos noms d'hôtes sont longs, utilisez un hash :
> 
> ```bash
> ControlPath ~/.ssh/sockets/%C  # %C = hash de %l%h%p%r
> ```

### 📝 Option ControlPersist

**ControlPersist** garde la connexion maître ouverte en arrière-plan après la fermeture de toutes les sessions.

```bash
# Exemples de valeurs
ControlPersist yes          # Indéfiniment
ControlPersist no           # Ferme dès que toutes les sessions sont fermées
ControlPersist 10m          # 10 minutes
ControlPersist 1h           # 1 heure
ControlPersist 30           # 30 secondes
```

> [!tip] Valeur recommandée
> 
> ```bash
> ControlPersist 10m
> ```
> 
> - Assez long pour réutiliser lors d'opérations multiples
> - Pas trop long pour éviter des connexions zombies

### 💡 Configuration complète optimale

```bash
Host *
    # Activer le multiplexing automatique
    ControlMaster auto
    
    # Socket dans un dossier dédié avec nom descriptif
    ControlPath ~/.ssh/sockets/%r@%h:%p
    
    # Garder la connexion 10 minutes après fermeture
    ControlPersist 10m
    
    # Keepalive pour éviter les timeouts
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

### 🎨 Configurations spécifiques

#### Multiplexing pour serveur spécifique uniquement

```bash
# Multiplexing désactivé par défaut
Host *
    ControlMaster no

# Activé seulement pour serveurs de production
Host prod-*
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h:%p
    ControlPersist 30m
```

#### Multiplexing avec ProxyJump

```bash
Host bastion
    HostName bastion.example.com
    User bastion-user
    # Multiplexing pour le bastion
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h:%p
    ControlPersist 1h

Host internal-*
    ProxyJump bastion
    # Multiplexing pour les serveurs internes aussi
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h:%p
    ControlPersist 10m
```

> [!tip] Double bénéfice Avec cette configuration, les connexions au bastion ET aux serveurs internes sont multiplexées.

### 🔧 Gestion manuelle des connexions maîtres

SSH fournit l'option `-O` pour contrôler les connexions maîtres :

```bash
# Vérifier si une connexion maître existe
ssh -O check myserver

# Ouvrir une connexion maître en arrière-plan sans session
ssh -fN myserver

# Stopper proprement la connexion maître
ssh -O stop myserver

# Stopper immédiatement (tue toutes les sessions)
ssh -O exit myserver

# Forwarder un nouveau port sur connexion existante
ssh -O forward -L 8080:localhost:80 myserver

# Annuler un forward
ssh -O cancel -L 8080:localhost:80 myserver
```

### 📊 Comparaison de performance

> [!example] Test de connexions répétées
> 
> **Sans multiplexing :**
> 
> ```bash
> $ time ssh myserver hostname
> myserver
> real    0m2.341s
> 
> $ time ssh myserver hostname
> myserver
> real    0m2.289s
> ```
> 
> **Avec multiplexing :**
> 
> ```bash
> # Première connexion (établit le master)
> $ time ssh myserver hostname
> myserver
> real    0m2.356s
> 
> # Connexions suivantes (réutilisent le master)
> $ time ssh myserver hostname
> myserver
> real    0m0.083s
> 
> $ time ssh myserver hostname
> myserver
> real    0m0.079s
> ```
> 
> **Gain : 96% plus rapide !**

### 🛠️ Cas d'usage pratiques

#### Scripts avec multiples opérations SSH

```bash
#!/bin/bash
# Script qui fait plusieurs opérations sur le même serveur

SERVER="prod-web"

# Ces commandes réutilisent automatiquement la même connexion
ssh "$SERVER" "systemctl status nginx"
scp config.conf "$SERVER:/etc/nginx/"
ssh "$SERVER" "nginx -t && systemctl reload nginx"
ssh "$SERVER" "curl -I localhost"

# La connexion maître reste ouverte 10m après la fin du script
```

#### Ansible / Automation

```bash
# Configuration pour Ansible
Host prod-*
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%C
    ControlPersist 30m
```

Ansible ouvrira une seule connexion par hôte et la réutilisera pour tous les modules.

#### Développement avec synchronisation continue

```bash
# Gardez une connexion ouverte pendant le développement
Host dev
    HostName dev.example.com
    User developer
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h:%p
    ControlPersist 2h  # Toute la session de travail
```

Vos `rsync`, `scp`, et commandes SSH seront quasi-instantanés.

### 🔍 Debugging et monitoring

```bash
# Lister les connexions maîtres actives
ls -la ~/.ssh/sockets/

# Voir les détails d'un socket
ssh -O check myserver

# Mode verbeux pour voir le multiplexing en action
ssh -v myserver
# Vous verrez : "Reusing existing connection to myserver:22."

# Vérifier qu'une connexion réutilise le master
ssh -vv myserver 2>&1 | grep -i "reusing\|control"
```

### ⚠️ Pièges courants

> [!warning] Permissions du dossier sockets
> 
> ```bash
> # Le dossier doit être accessible uniquement par vous
> chmod 700 ~/.ssh/sockets
> 
> # Les sockets eux-mêmes auront automatiquement 600
> ```

> [!warning] Connexions zombies Si vous ne définissez pas `ControlPersist`, la connexion maître restera active indéfiniment après la première connexion, même si vous ne l'utilisez plus. Cela peut causer :
> 
> - Connexions ouvertes inutiles
> - Problèmes si le serveur redémarre
> - Confusion lors du debugging
> 
> **Solution :** Toujours définir `ControlPersist` avec une durée raisonnable.

> [!warning] Incompatibilité avec certaines commandes Certaines commandes qui modifient la configuration SSH ne fonctionnent pas avec le multiplexing :
> 
> ```bash
> # Ceci pourrait ne pas fonctionner si multiplexing actif
> ssh -D 8080 myserver
> 
> # Solution : forcer une nouvelle connexion
> ssh -S none -D 8080 myserver
> ```

> [!warning] Sockets obsolètes Si un serveur redémarre ou si votre réseau change, les sockets peuvent devenir invalides :
> 
> ```bash
> # Erreur typique
> Control socket connect(...): Connection refused
> 
> # Solution : nettoyer les sockets
> ssh -O exit myserver
> # ou
> rm ~/.ssh/sockets/*
> ```

### 🧹 Maintenance des sockets

```bash
# Script de nettoyage (à mettre dans crontab ou alias)
# Supprime les sockets de plus de 24h
find ~/.ssh/sockets/ -type s -mtime +1 -delete

# Vérifier tous les sockets et fermer les inactifs
for socket in ~/.ssh/sockets/*; do
    if [ -S "$socket" ]; then
        ssh -O check -S "$socket" 2>/dev/null || rm "$socket"
    fi
done
```

> [!tip] Alias utile
> 
> ```bash
> # Ajouter à ~/.bashrc ou ~/.zshrc
> alias ssh-clean='find ~/.ssh/sockets/ -type s -delete && echo "SSH sockets cleaned"'
> ```

---

## 🎯 Bonnes pratiques générales

### 📋 Organisation du fichier config

```bash
# ~/.ssh/config - Structure recommandée

# ============================================
# CONFIGURATION GLOBALE (en bas du fichier)
# ============================================
Host *
    # Multiplexing pour toutes les connexions
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%C
    ControlPersist 10m
    
    # Keepalive
    ServerAliveInterval 60
    ServerAliveCountMax 3
    
    # Sécurité
    HashKnownHosts yes
    
    # Compression pour connexions lentes
    Compression yes
    
    # Pas de forward X11 par défaut
    ForwardX11 no

# ============================================
# BASTIONS / JUMP HOSTS
# ============================================
Host bastion-*
    User bastion
    IdentityFile ~/.ssh/bastion_key
    ServerAliveInterval 30
    ControlPersist 1h

Host bastion-prod
    HostName bastion.prod.example.com

Host bastion-staging
    HostName bastion.staging.example.com

# ============================================
# SERVEURS DE PRODUCTION
# ============================================
Host prod-*
    ProxyJump bastion-prod
    User deploy
    IdentityFile ~/.ssh/prod_key
    StrictHostKeyChecking yes
    ForwardAgent no

Host prod-web1
    HostName 10.0.1.10

Host prod-web2
    HostName 10.0.1.11

Host prod-db1
    HostName 10.0.1.20
    LocalForward 5432 localhost:5432

# ============================================
# SERVEURS DE STAGING
# ============================================
Host staging-*
    ProxyJump bastion-staging
    User deploy
    IdentityFile ~/.ssh/staging_key

Host staging-web
    HostName 10.1.1.10

# ============================================
# DÉVELOPPEMENT LOCAL
# ============================================
Host dev-*
    User developer
    IdentityFile ~/.ssh/dev_key
    ForwardAgent yes
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

Host dev-vm
    HostName 192.168.56.10

# ============================================
# SERVICES EXTERNES
# ============================================
Host github.com
    User git
    IdentityFile ~/.ssh/id_rsa_github
    IdentitiesOnly yes

Host gitlab.com
    User git
    IdentityFile ~/.ssh/id_rsa_gitlab
    IdentitiesOnly yes

# ============================================
# SERVEURS PERSONNELS
# ============================================
Host home
    HostName home.ddns.net
    User pi
    Port 2222
    IdentityFile ~/.ssh/id_rsa_home
```

### 🔐 Sécurité

> [!warning] Règles de sécurité essentielles
> 
> **Permissions des fichiers :**
> 
> ```bash
> chmod 600 ~/.ssh/config
> chmod 700 ~/.ssh/sockets
> chmod 600 ~/.ssh/id_rsa*
> chmod 644 ~/.ssh/id_rsa*.pub
> ```
> 
> **Dans la configuration :**
> 
> - `IdentitiesOnly yes` : éviter l'énumération de clés
> - `ForwardAgent no` par défaut : activer uniquement si nécessaire
> - `StrictHostKeyChecking yes` en production
> - Ne jamais désactiver la vérification des clés d'hôte en production

### 🎨 Patterns avancés

#### Configuration par environnement

```bash
# Match exec permet des configurations conditionnelles
Match host prod-* exec "test -f ~/.ssh/vpn_active"
    ProxyJump vpn-gateway

Match host prod-* exec "! test -f ~/.ssh/vpn_active"
    ProxyJump bastion-prod

# Configuration par heure (exemple : backup nocturne)
Match host backup-* exec "test $(date +%H) -ge 22"
    Compression no
    Cipher aes128-gcm@openssh.com

# Configuration selon l'utilisateur local
Match user root
    IdentityFile /root/.ssh/id_rsa_root

Match user !root
    IdentityFile ~/.ssh/id_rsa
```

#### Tunnels et forwards automatiques

```bash
# Base de données avec tunnel automatique
Host db-prod
    HostName db.internal
    ProxyJump bastion-prod
    LocalForward 5432 localhost:5432
    LocalForward 6379 redis.internal:6379

# Forward dynamique (SOCKS proxy)
Host socks-proxy
    HostName proxy.example.com
    DynamicForward 1080
    
# Forward distant (expose un port local sur le serveur distant)
Host reverse-tunnel
    HostName server.example.com
    RemoteForward 8080 localhost:3000
```

#### Configuration pour scripts

```bash
# Connexion sans interaction pour scripts
Host auto-*
    BatchMode yes
    StrictHostKeyChecking yes
    UserKnownHostsFile ~/.ssh/known_hosts_auto
    IdentitiesOnly yes
    
Host auto-backup
    HostName backup.example.com
    User backup-bot
    IdentityFile ~/.ssh/backup_key
```

### 📊 Tableau récapitulatif des options importantes

|Option|Défaut|Recommandé|Usage|
|---|---|---|---|
|`ControlMaster`|`no`|`auto`|Multiplexing|
|`ControlPersist`|`no`|`10m`|Durée du master|
|`ServerAliveInterval`|`0`|`60`|Keepalive|
|`ServerAliveCountMax`|`3`|`3`|Max keepalive|
|`StrictHostKeyChecking`|`ask`|`yes` (prod)|Vérif. clés|
|`ForwardAgent`|`no`|`no` (par défaut)|Agent forwarding|
|`Compression`|`no`|`yes`|Compression|
|`ConnectTimeout`|`none`|`10`|Timeout connexion|
|`IdentitiesOnly`|`no`|`yes`|Limite clés testées|

### 🔍 Debugging de configuration

#### Afficher la configuration effective

```bash
# Voir toute la config pour un hôte
ssh -G myserver

# Voir uniquement certaines options
ssh -G myserver | grep -i "user\|hostname\|port"

# Tester sans se connecter
ssh -T myserver
```

#### Mode verbeux

```bash
# Niveau 1 : informations de base
ssh -v myserver

# Niveau 2 : détails des négociations
ssh -vv myserver

# Niveau 3 : debug complet
ssh -vvv myserver 2>&1 | less
```

#### Vérifier les sockets de multiplexing

```bash
# Lister les connexions actives
ls -lh ~/.ssh/sockets/

# Vérifier une connexion spécifique
ssh -O check myserver

# Voir les infos de multiplexing
ssh -vv myserver 2>&1 | grep -i control
```

### 🛠️ Outils et commandes utiles

#### Gestion des clés avec config

```bash
# Lister toutes les clés configurées
grep -h "IdentityFile" ~/.ssh/config | sort -u

# Tester quelle clé est utilisée
ssh -vv myserver 2>&1 | grep "identity file"

# Forcer une clé spécifique (ignore config)
ssh -i ~/.ssh/specific_key myserver
```

#### Scripts utiles

```bash
# Tester toutes les connexions définies
#!/bin/bash
for host in $(grep "^Host " ~/.ssh/config | grep -v "\*" | awk '{print $2}'); do
    echo "Testing $host..."
    ssh -o ConnectTimeout=5 -o BatchMode=yes "$host" echo "OK" 2>/dev/null && echo "  ✓ Success" || echo "  ✗ Failed"
done

# Nettoyer les sockets obsolètes
#!/bin/bash
for socket in ~/.ssh/sockets/*; do
    if [ -S "$socket" ]; then
        ssh -O check -S "$socket" 2>/dev/null || {
            echo "Removing stale socket: $socket"
            rm "$socket"
        }
    fi
done

# Sauvegarder la config avec horodatage
cp ~/.ssh/config ~/.ssh/config.backup.$(date +%Y%m%d_%H%M%S)
```

### ⚡ Astuces de productivité

#### Raccourcis shell

```bash
# Ajouter à ~/.bashrc ou ~/.zshrc

# Liste les hôtes du config
alias ssh-list='grep "^Host " ~/.ssh/config | grep -v "\*" | awk "{print \$2}" | sort'

# Édite le config
alias ssh-config='$EDITOR ~/.ssh/config'

# Teste une connexion
ssh-test() {
    ssh -o ConnectTimeout=5 -o BatchMode=yes "$1" echo "Connection OK"
}

# Copie de fichiers avec progression
alias scpp='rsync -avzP -e ssh'

# SSH avec forward X11 automatique
alias sshx='ssh -X'

# Nettoie tous les sockets
alias ssh-clean='rm -f ~/.ssh/sockets/* && echo "SSH sockets cleaned"'

# Recharge le multiplexing
ssh-reload() {
    ssh -O exit "$1" 2>/dev/null
    ssh -fN "$1"
}
```

#### Completion automatique

```bash
# Pour bash - ajouter à ~/.bashrc
_ssh_hosts() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local hosts=$(grep "^Host " ~/.ssh/config 2>/dev/null | grep -v "\*" | awk '{print $2}')
    COMPREPLY=($(compgen -W "$hosts" -- "$cur"))
}
complete -F _ssh_hosts ssh scp sftp

# Pour zsh - ajouter à ~/.zshrc
zstyle ':completion:*:ssh:*' hosts $(grep "^Host " ~/.ssh/config 2>/dev/null | grep -v "\*" | awk '{print $2}')
```

### 📝 Template de configuration starter

```bash
# ~/.ssh/config - Template de démarrage

# ============================================
# CONFIGURATION GLOBALE
# ============================================
Host *
    # Multiplexing
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%C
    ControlPersist 10m
    
    # Keepalive
    ServerAliveInterval 60
    ServerAliveCountMax 3
    
    # Sécurité
    HashKnownHosts yes
    StrictHostKeyChecking ask
    
    # Performance
    Compression yes
    
    # Éviter les problèmes de timeout
    ConnectTimeout 10

# ============================================
# VOS SERVEURS ICI
# ============================================

# Exemple : serveur de développement
Host dev
    HostName dev.example.com
    User developer
    IdentityFile ~/.ssh/id_rsa
    ForwardAgent yes

# Exemple : serveur via bastion
Host bastion
    HostName bastion.example.com
    User jump-user
    IdentityFile ~/.ssh/bastion_key

Host prod
    HostName 10.0.1.100
    User admin
    ProxyJump bastion
    IdentityFile ~/.ssh/prod_key

# ============================================
# SERVICES EXTERNES
# ============================================

Host github.com
    User git
    IdentityFile ~/.ssh/id_rsa_github
    IdentitiesOnly yes
```

### 🎯 Checklist de configuration optimale

> [!tip] Checklist
> 
> - [ ] Fichier `~/.ssh/config` avec permissions 600
> - [ ] Dossier `~/.ssh/sockets/` créé avec permissions 700
> - [ ] Multiplexing activé avec `ControlMaster auto`
> - [ ] `ControlPersist` défini (10m recommandé)
> - [ ] Keepalive configuré (ServerAliveInterval 60)
> - [ ] Clés spécifiques par environnement
> - [ ] `IdentitiesOnly yes` où nécessaire
> - [ ] ProxyJump configuré pour bastions
> - [ ] Alias courts et mémorables
> - [ ] Configuration testée avec `ssh -G`
> - [ ] Sauvegardes régulières du config
> - [ ] Documentation des alias critiques

---

## 🎓 Conclusion

La configuration SSH avancée transforme votre expérience quotidienne avec SSH :

### Gains principaux

**🚀 Performance**

- Connexions instantanées grâce au multiplexing (96% plus rapide)
- Réduction de la charge réseau et serveur
- Opérations batch accélérées

**⚡ Productivité**

- Alias courts : `ssh prod` au lieu de longues commandes
- Automatisation des tunnels et forwards
- Configuration centralisée et versionnable

**🔒 Sécurité**

- Clés dédiées par environnement
- Bonnes pratiques appliquées automatiquement
- Audit facilité des connexions

**🎯 Simplicité**

- Une seule configuration pour tous vos outils (ssh, scp, rsync, git, ansible...)
- Réduction des erreurs de frappe
- Partage facile avec l'équipe

### Commandes essentielles à retenir

```bash
# Éditer la config
vim ~/.ssh/config

# Tester la config d'un hôte
ssh -G myserver

# Se connecter avec debug
ssh -vv myserver

# Gérer le multiplexing
ssh -O check myserver
ssh -O stop myserver

# Nettoyer les sockets
rm ~/.ssh/sockets/*
```

Avec ces configurations avancées, SSH devient un outil encore plus puissant et agréable à utiliser au quotidien. 🎉