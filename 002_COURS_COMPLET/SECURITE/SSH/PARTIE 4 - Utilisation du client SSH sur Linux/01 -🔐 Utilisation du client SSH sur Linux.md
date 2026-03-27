

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

SSH (Secure Shell) est un protocole réseau cryptographique qui permet de se connecter de manière sécurisée à un système distant. Le client SSH est l'outil que vous utilisez depuis votre machine locale pour établir ces connexions. Cette partie couvre les bases essentielles de l'utilisation du client SSH sur Linux.

> [!info] Pourquoi SSH ? SSH remplace les anciens protocoles non sécurisés comme Telnet ou RSH en chiffrant toutes les communications entre le client et le serveur, incluant les mots de passe et les données échangées.

---

## 1. Syntaxe de la commande ssh

### Structure générale

La commande `ssh` suit une syntaxe simple mais flexible :

```bash
ssh [options] [utilisateur@]hôte [commande]
```

### Décomposition des éléments

|Élément|Obligatoire|Description|
|---|---|---|
|`ssh`|✅ Oui|La commande elle-même|
|`[options]`|❌ Non|Paramètres modificateurs (port, clés, verbosité, etc.)|
|`[utilisateur@]`|❌ Non|Nom d'utilisateur sur la machine distante|
|`hôte`|✅ Oui|Adresse IP ou nom de domaine du serveur|
|`[commande]`|❌ Non|Commande à exécuter sur le serveur distant|

> [!example] Exemples de base
> 
> ```bash
> # Connexion la plus simple
> ssh 192.168.1.100
> 
> # Connexion avec utilisateur
> ssh admin@192.168.1.100
> 
> # Connexion et exécution d'une commande
> ssh admin@192.168.1.100 ls -la
> ```

### Options courantes

```bash
# -p : Spécifier le port
ssh -p 2222 user@host

# -i : Utiliser une clé privée spécifique
ssh -i ~/.ssh/ma_cle user@host

# -v : Mode verbeux (debug)
ssh -v user@host

# -l : Spécifier l'utilisateur (alternative à user@)
ssh -l admin host

# -4 ou -6 : Forcer IPv4 ou IPv6
ssh -4 user@host
```

> [!tip] Astuce : Combinaison d'options Les options peuvent être combinées :
> 
> ```bash
> ssh -p 2222 -i ~/.ssh/ma_cle -v user@host
> ```

---

## 2. Connexion avec utilisateur et hôte

### Spécification de l'utilisateur

Il existe deux méthodes pour spécifier l'utilisateur distant :

#### Méthode 1 : Notation user@host (recommandée)

```bash
ssh utilisateur@hôte
```

**Exemple :**

```bash
ssh john@192.168.1.100
ssh admin@server.example.com
```

#### Méthode 2 : Option -l

```bash
ssh -l utilisateur hôte
```

**Exemple :**

```bash
ssh -l john 192.168.1.100
ssh -l admin server.example.com
```

> [!info] Quelle méthode choisir ? La notation `user@host` est plus courante et intuitive. L'option `-l` est utile dans les scripts où vous construisez la commande dynamiquement.

### Utilisateur par défaut

Si vous omettez l'utilisateur, SSH utilise votre nom d'utilisateur local :

```bash
# Si vous êtes connecté en tant que "alex" localement
ssh 192.168.1.100
# Équivaut à :
ssh alex@192.168.1.100
```

### Types d'hôtes supportés

#### Adresse IP

```bash
# IPv4
ssh user@192.168.1.100

# IPv6 (entre crochets)
ssh user@[2001:db8::1]
```

#### Nom de domaine

```bash
# FQDN (Fully Qualified Domain Name)
ssh user@server.example.com

# Hostname court (si résolu par DNS/hosts)
ssh user@server
```

#### Alias depuis ~/.ssh/config

```bash
# Si configuré dans ~/.ssh/config
ssh monserveur
```

> [!warning] Attention aux noms d'hôtes Assurez-vous que le nom d'hôte est résolvable. En cas de doute, utilisez l'adresse IP directement.

### Exemples pratiques

```bash
# Connexion à un serveur web
ssh webmaster@web01.production.com

# Connexion à un Raspberry Pi sur le réseau local
ssh pi@raspberrypi.local

# Connexion root (déconseillé en production)
ssh root@10.0.0.5

# Connexion avec nom d'utilisateur contenant des caractères spéciaux
ssh 'user.name'@host
```

> [!tip] Bonne pratique : Éviter root Connectez-vous avec un utilisateur normal et utilisez `sudo` pour les opérations privilégiées plutôt que de vous connecter directement en root.

---

## 3. Spécification du port

### Port SSH par défaut

Par défaut, SSH utilise le **port 22**. Vous n'avez pas besoin de le spécifier explicitement :

```bash
ssh user@host
# Connexion automatique sur le port 22
```

### Pourquoi changer de port ?

- **Sécurité par obscurité** : Réduire les attaques automatisées
- **Cohabitation de services** : Plusieurs serveurs SSH sur la même machine
- **Restrictions réseau** : Contournement de pare-feu (utilisation éthique uniquement)

> [!warning] Sécurité par obscurité Changer le port SSH n'est PAS une mesure de sécurité suffisante. C'est un complément, pas un remplacement des bonnes pratiques (clés SSH, fail2ban, etc.).

### Spécifier un port custom

#### Option -p

```bash
ssh -p PORT user@host
```

**Exemples :**

```bash
# Connexion sur le port 2222
ssh -p 2222 admin@192.168.1.100

# Port 8022
ssh -p 8022 user@server.com

# Combinaison avec d'autres options
ssh -p 2222 -i ~/.ssh/id_rsa user@host
```

#### Notation avec URL (non standard)

Bien que non standard pour SSH, certains outils acceptent :

```bash
# Ceci NE FONCTIONNE PAS avec ssh standard
ssh user@host:2222  # ❌ INCORRECT

# Utilisez toujours -p
ssh -p 2222 user@host  # ✅ CORRECT
```

### Configuration permanente

Pour éviter de spécifier le port à chaque fois, utilisez `~/.ssh/config` :

```bash
# ~/.ssh/config
Host monserveur
    HostName 192.168.1.100
    Port 2222
    User admin
```

Puis connectez-vous simplement avec :

```bash
ssh monserveur
```

> [!tip] Astuce : Scanner de ports Si vous ne connaissez pas le port SSH d'un serveur :
> 
> ```bash
> nmap -p 1-65535 192.168.1.100 | grep ssh
> ```

### Ports courants alternatifs

|Port|Usage typique|
|---|---|
|22|Port SSH standard|
|2222|Alternative commune|
|8022|Alternative commune|
|2200-2299|Plage souvent utilisée|

---

## 4. Première connexion et vérification de l'hôte

### Le processus de première connexion

Lors de votre première connexion à un serveur SSH, vous verrez un message de vérification :

```bash
$ ssh user@newserver.com

The authenticity of host 'newserver.com (192.168.1.100)' can't be established.
ED25519 key fingerprint is SHA256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

### Que se passe-t-il ?

1. **Échange de clé publique** : Le serveur envoie sa clé publique
2. **Calcul de l'empreinte** : SSH calcule l'empreinte (fingerprint) de cette clé
3. **Demande de confirmation** : SSH vous demande de vérifier l'authenticité

> [!info] Pourquoi cette vérification ? Cette étape protège contre les **attaques MITM** (Man-In-The-Middle). Elle garantit que vous vous connectez au bon serveur et non à un imposteur.

### Réponses possibles

#### 1. Répondre "yes"

```bash
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'newserver.com' (ED25519) to the list of known hosts.
```

- L'empreinte est enregistrée dans `~/.ssh/known_hosts`
- Les connexions futures ne demanderont plus confirmation
- **⚠️ Assurez-vous de vérifier l'empreinte avant d'accepter !**

#### 2. Répondre "no"

```bash
Are you sure you want to continue connecting (yes/no/[fingerprint])? no
Host key verification failed.
```

La connexion est abandonnée. Utilisez cette option si vous doutez de l'authenticité.

#### 3. Fournir l'empreinte directement

```bash
Are you sure you want to continue connecting (yes/no/[fingerprint])? SHA256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Méthode la plus sécurisée si vous avez l'empreinte vérifiée.

### Vérification de l'empreinte

> [!warning] Étape critique de sécurité **Ne tapez JAMAIS "yes" automatiquement sans vérifier !** C'est le moment où vous pouvez détecter une attaque MITM.

#### Méthode 1 : Vérification côté serveur

Si vous avez accès au serveur, comparez l'empreinte affichée avec celle du serveur :

```bash
# Sur le serveur, affichez les empreintes
ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
ssh-keygen -lf /etc/ssh/ssh_host_rsa_key.pub
ssh-keygen -lf /etc/ssh/ssh_host_ecdsa_key.pub
```

#### Méthode 2 : Demander à l'administrateur

Contactez l'administrateur du serveur par un canal sécurisé (téléphone, signal crypté, etc.) et demandez-lui de confirmer l'empreinte.

#### Méthode 3 : DNS SSHFP (avancé)

Si le serveur publie des enregistrements SSHFP dans son DNS :

```bash
ssh -o "VerifyHostKeyDNS yes" user@host
```

### Types de clés serveur

|Type|Taille|Sécurité|Compatibilité|
|---|---|---|---|
|ED25519|256 bits|⭐⭐⭐ Excellente|Moderne (OpenSSH 6.5+)|
|RSA|2048-4096 bits|⭐⭐ Bonne|Universelle|
|ECDSA|256-521 bits|⭐⭐ Bonne|Bonne|
|DSA|1024 bits|❌ Obsolète|Ancienne|

> [!tip] Préférence ED25519 est recommandé pour sa sécurité et ses performances. Si vous devez supporter des systèmes anciens, utilisez RSA 4096 bits.

### Le fichier known_hosts

Après avoir accepté la clé, elle est stockée dans :

```bash
~/.ssh/known_hosts
```

**Format d'une entrée :**

```
newserver.com,192.168.1.100 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

#### Consulter known_hosts

```bash
# Voir le contenu
cat ~/.ssh/known_hosts

# Rechercher une entrée spécifique
ssh-keygen -F newserver.com
```

#### Supprimer une entrée

```bash
# Supprimer une entrée par hostname
ssh-keygen -R newserver.com

# Supprimer par adresse IP
ssh-keygen -R 192.168.1.100
```

> [!warning] Quand supprimer une entrée ?
> 
> - Le serveur a été réinstallé (nouvelles clés générées)
> - Vous recevez un avertissement de clé modifiée
> - L'adresse IP a changé de serveur

### Avertissement de clé modifiée

Si les clés du serveur changent, vous verrez ce message alarmant :

```bash
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
```

#### Causes légitimes

- Réinstallation du serveur
- Mise à jour majeure du système
- Régénération intentionnelle des clés

#### Causes suspectes

- **Attaque MITM** : Quelqu'un intercepte votre connexion
- Changement non autorisé

> [!warning] Action à prendre
> 
> 1. **NE PAS** ignorer cet avertissement
> 2. Contactez l'administrateur pour confirmer le changement
> 3. Si légitime, supprimez l'ancienne entrée : `ssh-keygen -R hostname`
> 4. Reconnectez-vous et vérifiez la nouvelle empreinte

### Options pour contourner les vérifications (déconseillé)

```bash
# Désactiver la vérification (DANGEREUX)
ssh -o "StrictHostKeyChecking=no" user@host

# Ne pas enregistrer dans known_hosts
ssh -o "UserKnownHostsFile=/dev/null" user@host

# Combiner les deux (TRÈS DANGEREUX)
ssh -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" user@host
```

> [!warning] ⚠️ Dangers Ces options vous exposent aux attaques MITM. Ne les utilisez que :
> 
> - Dans des environnements de test isolés
> - Pour des connexions temporaires non sensibles
> - Jamais en production ou avec des données sensibles

### Bonnes pratiques

1. ✅ **Vérifiez toujours** l'empreinte lors de la première connexion
2. ✅ **Obtenez l'empreinte** par un canal sécurisé séparé
3. ✅ **Surveillez** les avertissements de clés modifiées
4. ✅ **Documentez** les empreintes de vos serveurs critiques
5. ❌ **N'acceptez jamais** automatiquement sans vérifier
6. ❌ **Ne désactivez pas** StrictHostKeyChecking en production

---

## 🎯 Pièges courants

### Piège 1 : Oublier le -p pour le port

```bash
# ❌ INCORRECT
ssh user@host:2222

# ✅ CORRECT
ssh -p 2222 user@host
```

### Piège 2 : Accepter une clé sans vérifier

```bash
# ⚠️ DANGEREUX
Are you sure you want to continue connecting (yes/no)? yes
# Sans avoir vérifié l'empreinte !
```

**Toujours vérifier l'empreinte avant d'accepter.**

### Piège 3 : Confusion user local vs user distant

```bash
# Si vous êtes "alex" localement mais devez vous connecter en "admin"
ssh 192.168.1.100  # ❌ Connexion en tant que "alex"
ssh admin@192.168.1.100  # ✅ Connexion en tant que "admin"
```

### Piège 4 : Ignorer les avertissements de sécurité

Ne jamais utiliser `-o "StrictHostKeyChecking=no"` en production sans comprendre les risques.

### Piège 5 : Port bloqué par le pare-feu

```bash
ssh -p 2222 user@host
# ssh: connect to host port 2222: Connection refused
```

Vérifiez que le port est ouvert sur le serveur et les pare-feu intermédiaires.

---

## 💡 Astuces avancées

### Astuce 1 : Vérifier la connectivité sans se connecter

```bash
# Tester juste l'établissement de la connexion
ssh -T user@host
```

### Astuce 2 : Afficher les clés du serveur

```bash
# Voir toutes les clés disponibles sur le serveur
ssh-keyscan host
ssh-keyscan -p 2222 host  # Pour un port custom
```

### Astuce 3 : Mode verbeux pour debug

```bash
# Niveau 1 de verbosité
ssh -v user@host

# Niveau 2 (plus détaillé)
ssh -vv user@host

# Niveau 3 (très détaillé)
ssh -vvv user@host
```

Utile pour diagnostiquer les problèmes de connexion.

### Astuce 4 : Timeout de connexion

```bash
# Définir un timeout de 10 secondes
ssh -o ConnectTimeout=10 user@host
```

### Astuce 5 : Réutiliser les connexions (multiplexing)

Bien que ce soit un sujet plus avancé, sachez que SSH peut réutiliser une connexion existante :

```bash
# Dans ~/.ssh/config (configuration avancée)
Host *
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h:%p
    ControlPersist 10m
```

Cela accélère les connexions multiples au même serveur.

---

## 📝 Récapitulatif

|Concept|Commande|Usage|
|---|---|---|
|Connexion basique|`ssh host`|Connexion avec user local|
|Avec utilisateur|`ssh user@host`|Spécifier l'utilisateur distant|
|Avec port|`ssh -p 2222 user@host`|Port non-standard|
|Mode verbeux|`ssh -v user@host`|Debugging|
|Clé spécifique|`ssh -i ~/.ssh/key user@host`|Utiliser une clé privée|

### Checklist première connexion

- [ ] Vérifier que vous avez la bonne adresse/port
- [ ] Lancer la connexion avec les bons paramètres
- [ ] **Vérifier l'empreinte** de la clé serveur
- [ ] Accepter la clé seulement si l'empreinte est confirmée
- [ ] Tester que la connexion fonctionne
- [ ] Documenter l'empreinte pour référence future