
---

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

## 🔍 Vue d'ensemble de la sécurité SSH

SSH (Secure Shell) repose sur quatre piliers de sécurité fondamentaux qui travaillent ensemble pour établir et maintenir une connexion sécurisée :

```
┌─────────────────────────────────────────────────────────┐
│                    Connexion SSH                        │
├─────────────────────────────────────────────────────────┤
│  1. Authentification du serveur → Qui est le serveur ?  │
│  2. Authentification du client  → Qui est l'utilisateur?│
│  3. Intégrité des données       → Données non modifiées?│
│  4. Confidentialité             → Données chiffrées ?   │
└─────────────────────────────────────────────────────────┘
```

> [!tip] Ordre chronologique Ces mécanismes s'appliquent dans un ordre précis lors de l'établissement d'une connexion SSH :
> 
> 1. **D'abord** : authentification du serveur (pour éviter les attaques man-in-the-middle)
> 2. **Ensuite** : authentification du client (une fois qu'on est sûr du serveur)
> 3. **Pendant toute la session** : intégrité et confidentialité des données échangées

---

## 🖥️ Authentification du serveur

L'authentification du serveur permet au **client de vérifier l'identité du serveur** avant d'envoyer des informations sensibles. C'est la première ligne de défense contre les attaques de type "man-in-the-middle".

### Mécanisme de clés d'hôte

Chaque serveur SSH possède une ou plusieurs **clés d'hôte** (host keys) qui l'identifient de manière unique.

```bash
# Clés d'hôte du serveur (généralement dans /etc/ssh/)
/etc/ssh/ssh_host_rsa_key          # Clé privée RSA
/etc/ssh/ssh_host_rsa_key.pub      # Clé publique RSA
/etc/ssh/ssh_host_ecdsa_key        # Clé privée ECDSA
/etc/ssh/ssh_host_ecdsa_key.pub    # Clé publique ECDSA
/etc/ssh/ssh_host_ed25519_key      # Clé privée Ed25519
/etc/ssh/ssh_host_ed25519_key.pub  # Clé publique Ed25519
```

> [!info] Principe de fonctionnement
> 
> 1. Le serveur envoie sa clé publique au client
> 2. Le serveur prouve qu'il possède la clé privée correspondante (sans la transmettre)
> 3. Le client vérifie cette clé publique contre sa base de données locale

**Afficher les clés publiques du serveur :**

```bash
# Afficher toutes les clés d'hôte publiques
ssh-keygen -l -f /etc/ssh/ssh_host_rsa_key.pub
ssh-keygen -l -f /etc/ssh/ssh_host_ecdsa_key.pub
ssh-keygen -l -f /etc/ssh/ssh_host_ed25519_key.pub

# Exemple de sortie
# 3072 SHA256:xK9q2... root@server (RSA)
# 256 SHA256:7nM4p... root@server (ECDSA)
# 256 SHA256:aB3Cd... root@server (ED25519)
```

### Fichier known_hosts

Le fichier `~/.ssh/known_hosts` stocke les clés publiques des serveurs connus par le client.

```bash
# Format du fichier known_hosts
cat ~/.ssh/known_hosts
```

**Structure d'une entrée :**

```
# Format simple
server.example.com ssh-rsa AAAAB3NzaC1yc2EAAAA...

# Format avec adresse IP
192.168.1.100 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5...

# Format avec port non-standard
[server.example.com]:2222 ecdsa-sha2-nistp256 AAAAE2Vj...

# Format haché (plus sécurisé, cache les noms d'hôtes)
|1|JfKTdBh4b6w=|rNONy2s= ssh-rsa AAAAB3NzaC1yc2EAAAA...
```

> [!warning] Sécurité du fichier known_hosts Les permissions de ce fichier doivent être restrictives :
> 
> ```bash
> chmod 600 ~/.ssh/known_hosts
> ```

**Manipulation du fichier known_hosts :**

```bash
# Ajouter manuellement une clé d'hôte
ssh-keyscan server.example.com >> ~/.ssh/known_hosts

# Ajouter avec un port spécifique
ssh-keyscan -p 2222 server.example.com >> ~/.ssh/known_hosts

# Supprimer une entrée spécifique
ssh-keygen -R server.example.com

# Supprimer avec port spécifique
ssh-keygen -R "[server.example.com]:2222"

# Rechercher une clé dans known_hosts
ssh-keygen -F server.example.com

# Hasher les noms d'hôtes existants (sécurité)
ssh-keygen -H -f ~/.ssh/known_hosts
```

### Vérification à la première connexion

Lors de la **première connexion** à un serveur, SSH affiche un avertissement :

```bash
ssh user@new-server.com
```

**Message affiché :**

```
The authenticity of host 'new-server.com (192.168.1.100)' can't be established.
ED25519 key fingerprint is SHA256:aB3Cd4Ef5Gh6Ij7Kl8Mn9Op0Qr1St2Uv3Wx4Yz5.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

> [!example] Options de réponse
> 
> - **yes** : Accepte et ajoute la clé dans `known_hosts`
> - **no** : Refuse la connexion
> - **fingerprint** : Tape l'empreinte complète pour vérifier (plus sécurisé)

**Bonnes pratiques :**

1. **Vérifier l'empreinte** avant d'accepter (la comparer via un canal sécurisé)
2. **Ne jamais accepter aveuglément** sur un réseau public
3. **Obtenir l'empreinte** du serveur via un autre moyen (email, téléphone, console physique)

```bash
# Sur le serveur, obtenir l'empreinte à communiquer
ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

### Gestion des clés d'hôte

**Scénario : Changement de clé d'hôte**

Quand un serveur change de clé (réinstallation, migration), SSH affiche une **alerte de sécurité** :

```
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
```

> [!warning] Ne jamais ignorer cet avertissement Ce message indique soit :
> 
> - ✅ Un changement légitime (réinstallation serveur)
> - ❌ Une attaque man-in-the-middle en cours
> 
> **Toujours vérifier** la raison du changement avant de continuer.

**Résolution après vérification légitime :**

```bash
# Supprimer l'ancienne clé
ssh-keygen -R server.example.com

# Ou éditer manuellement
nano ~/.ssh/known_hosts
# Supprimer la ligne correspondante

# Puis se reconnecter (nouvelle vérification)
ssh user@server.example.com
```

**Configuration de la vérification stricte :**

```bash
# Dans ~/.ssh/config
Host *
    StrictHostKeyChecking ask    # Par défaut : demande confirmation
    # StrictHostKeyChecking yes  # Strict : refuse si clé inconnue
    # StrictHostKeyChecking no   # Dangereux : accepte automatiquement
```

> [!tip] Cas d'usage
> 
> - **ask** (défaut) : Usage général, bon équilibre sécurité/commodité
> - **yes** : Environnement de production, sécurité maximale
> - **no** : Environnements de test/dev éphémères uniquement

---

## 👤 Authentification du client

L'authentification du client permet au **serveur de vérifier l'identité de l'utilisateur** qui tente de se connecter.

### Authentification par mot de passe

Méthode la plus simple mais **moins sécurisée**.

```bash
# Connexion avec mot de passe
ssh user@server.example.com
# Demande le mot de passe de manière interactive
```

**Processus :**

1. Le client envoie le nom d'utilisateur
2. Le serveur demande le mot de passe
3. Le mot de passe est transmis **chiffré** via le tunnel SSH
4. Le serveur vérifie le mot de passe contre `/etc/shadow` (Linux)

> [!info] Sécurité du mot de passe Même si le mot de passe est transmis chiffré, cette méthode reste vulnérable à :
> 
> - Attaques par force brute
> - Attaques par dictionnaire
> - Réutilisation de mots de passe compromis

**Configuration côté serveur :**

```bash
# Dans /etc/ssh/sshd_config

# Autoriser l'authentification par mot de passe
PasswordAuthentication yes

# Interdire (recommandé après avoir configuré les clés)
PasswordAuthentication no

# Autoriser le root avec mot de passe (déconseillé)
PermitRootLogin yes

# Interdire le root avec mot de passe mais autoriser avec clé
PermitRootLogin prohibit-password
```

> [!warning] Sécurité Il est **fortement recommandé** de désactiver l'authentification par mot de passe en production et d'utiliser uniquement des clés SSH.

### Authentification par clé publique

Méthode **la plus sécurisée** et recommandée.

**Principe cryptographique :**

```
Client                                    Serveur
  │                                         │
  │ 1. "Je suis user, voici ma clé pub"   │
  ├────────────────────────────────────────>
  │                                         │
  │ 2. Challenge chiffré avec clé pub     │
  <────────────────────────────────────────┤
  │                                         │
  │ 3. Réponse signée avec clé privée     │
  ├────────────────────────────────────────>
  │                                         │
  │ 4. Vérification avec clé pub          │
  │         → Authentification OK          │
```

**Configuration complète :**

```bash
# 1. Générer une paire de clés sur le client
ssh-keygen -t ed25519 -C "mon-email@example.com"
# -t ed25519 : type de clé (recommandé)
# -C : commentaire pour identifier la clé

# Options de génération
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_perso -C "usage personnel"
# -f : fichier de sortie personnalisé

# Pour RSA (si Ed25519 non supporté)
ssh-keygen -t rsa -b 4096 -C "mon-email@example.com"
# -b 4096 : taille de clé 4096 bits (minimum sécurisé)

# 2. Copier la clé publique sur le serveur
ssh-copy-id user@server.example.com
# Copie automatique dans ~/.ssh/authorized_keys

# Avec une clé spécifique
ssh-copy-id -i ~/.ssh/id_ed25519_perso.pub user@server.example.com

# Méthode manuelle si ssh-copy-id n'est pas disponible
cat ~/.ssh/id_ed25519.pub | ssh user@server.example.com \
  "mkdir -p ~/.ssh && chmod 700 ~/.ssh && \
   cat >> ~/.ssh/authorized_keys && \
   chmod 600 ~/.ssh/authorized_keys"

# 3. Se connecter avec la clé
ssh user@server.example.com
# Utilise automatiquement la clé privée

# Avec une clé spécifique
ssh -i ~/.ssh/id_ed25519_perso user@server.example.com
```

**Structure du fichier `authorized_keys` sur le serveur :**

```bash
# ~/.ssh/authorized_keys sur le serveur
cat ~/.ssh/authorized_keys
```

**Format des entrées :**

```
# Clé simple
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGq... user@laptop

# Clé avec restrictions
from="192.168.1.*" ssh-ed25519 AAAAC3NzaC1lZDI... user@office

# Clé avec commande forcée
command="rsync --server" ssh-rsa AAAAB3NzaC1yc2... backup-script

# Clé avec options multiples
no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty \
ssh-rsa AAAAB3NzaC1yc2... restricted-user
```

> [!tip] Options courantes pour authorized_keys
> 
> |Option|Description|
> |---|---|
> |`from="pattern"`|Restreint les connexions à certaines IPs|
> |`command="cmd"`|Force l'exécution d'une commande spécifique|
> |`no-port-forwarding`|Désactive le port forwarding|
> |`no-X11-forwarding`|Désactive le X11 forwarding|
> |`no-agent-forwarding`|Désactive le SSH agent forwarding|
> |`no-pty`|Désactive l'allocation de pseudo-terminal|
> |`permitopen="host:port"`|Autorise uniquement certaines redirections|

**Protection de la clé privée avec passphrase :**

```bash
# Générer une clé avec passphrase
ssh-keygen -t ed25519
# Demande une passphrase lors de la génération

# Ajouter/modifier la passphrase d'une clé existante
ssh-keygen -p -f ~/.ssh/id_ed25519

# Supprimer la passphrase (déconseillé)
ssh-keygen -p -f ~/.ssh/id_ed25519
# Laisser vide quand demandé
```

> [!info] Pourquoi utiliser une passphrase ?
> 
> - Protection si la clé privée est volée/copiée
> - Couche de sécurité supplémentaire
> - Peut être gérée avec `ssh-agent` pour ne pas retaper constamment

**Utilisation de ssh-agent (éviter de retaper la passphrase) :**

```bash
# Démarrer l'agent
eval $(ssh-agent)
# Affiche : Agent pid 12345

# Ajouter la clé à l'agent
ssh-add ~/.ssh/id_ed25519
# Demande la passphrase une seule fois

# Vérifier les clés chargées
ssh-add -l

# Ajouter avec durée de vie limitée (en secondes)
ssh-add -t 3600 ~/.ssh/id_ed25519  # 1 heure

# Supprimer toutes les clés de l'agent
ssh-add -D

# Tuer l'agent
ssh-agent -k
```

**Permissions critiques :**

```bash
# Sur le client
chmod 700 ~/.ssh                    # Répertoire .ssh
chmod 600 ~/.ssh/id_ed25519         # Clé privée (CRITIQUE)
chmod 644 ~/.ssh/id_ed25519.pub     # Clé publique
chmod 600 ~/.ssh/config             # Fichier de config

# Sur le serveur
chmod 700 ~/.ssh                    # Répertoire .ssh
chmod 600 ~/.ssh/authorized_keys    # Fichiers de clés autorisées
```

> [!warning] Permissions incorrectes = échec d'authentification SSH **refuse** d'utiliser des fichiers avec des permissions trop permissives pour des raisons de sécurité.

### Autres méthodes d'authentification

SSH supporte plusieurs autres méthodes d'authentification moins courantes :

**1. Authentification par certificat SSH**

```bash
# Signer une clé publique avec une CA (Certificate Authority)
ssh-keygen -s ca_key -I user_id -n user1,user2 -V +52w id_ed25519.pub
# -s : clé de la CA
# -I : identifiant du certificat
# -n : principals (utilisateurs autorisés)
# -V : validité (+52w = 52 semaines)

# Utiliser le certificat
ssh -i id_ed25519-cert.pub user@server.example.com
```

**Configuration serveur pour les certificats :**

```bash
# Dans /etc/ssh/sshd_config
TrustedUserCAKeys /etc/ssh/ca_user.pub
```

> [!info] Avantages des certificats
> 
> - Gestion centralisée des accès
> - Révocation simplifiée
> - Pas besoin de distribuer les clés sur chaque serveur
> - Idéal pour les grandes infrastructures

**2. Authentification GSSAPI/Kerberos**

```bash
# Dans /etc/ssh/sshd_config
GSSAPIAuthentication yes
GSSAPICleanupCredentials yes
```

Utilisé principalement dans les **environnements Active Directory** ou avec Kerberos.

**3. Authentification par clavier interactif (keyboard-interactive)**

```bash
# Dans /etc/ssh/sshd_config
KbdInteractiveAuthentication yes
ChallengeResponseAuthentication yes
```

Permet des authentifications personnalisées (OTP, 2FA, questions-réponses).

### Combinaison de méthodes

SSH peut **exiger plusieurs méthodes** d'authentification successives :

```bash
# Dans /etc/ssh/sshd_config

# Exiger clé publique ET mot de passe (2FA basique)
AuthenticationMethods publickey,password

# Exiger clé publique ET keyboard-interactive (pour OTP)
AuthenticationMethods publickey,keyboard-interactive

# Autoriser clé OU mot de passe (par défaut)
AuthenticationMethods publickey password

# Combinaisons multiples possibles par utilisateur
Match User admin
    AuthenticationMethods publickey,keyboard-interactive

Match User developer
    AuthenticationMethods publickey
```

> [!tip] Sécurité renforcée L'utilisation de `publickey,password` ou `publickey,keyboard-interactive` crée une **authentification à deux facteurs** native dans SSH.

---

## 🛡️ Intégrité des données

L'intégrité des données garantit que les **messages n'ont pas été modifiés** pendant la transmission.

### Codes d'authentification de message (MAC)

Les **MAC (Message Authentication Codes)** sont des signatures cryptographiques ajoutées à chaque paquet SSH.

**Principe de fonctionnement :**

```
Émetteur                              Récepteur
   │                                      │
   │ 1. Message original                 │
   │ 2. Calcul MAC = Hash(message + clé) │
   │ 3. Envoi : message + MAC            │
   ├─────────────────────────────────────>
   │                                      │
   │                    4. Recalcul MAC  │
   │                    5. Comparaison   │
   │                       MAC OK ?      │
   │                       ✓ Accepté     │
   │                       ✗ Rejeté      │
```

> [!info] Propriétés des MAC
> 
> - **Détecte toute modification** : même un bit changé invalide le MAC
> - **Utilise une clé secrète** : impossible à forger sans la clé
> - **Calcul rapide** : impact minimal sur les performances
> - **Indépendant du chiffrement** : vérifie l'intégrité même si données chiffrées

**Visualisation de l'utilisation des MAC :**

```bash
# Voir les MAC utilisés lors d'une connexion
ssh -v user@server.example.com 2>&1 | grep "MAC"

# Exemple de sortie
# debug1: kex: server->client cipher: aes128-ctr MAC: hmac-sha2-256
# debug1: kex: client->server cipher: aes128-ctr MAC: hmac-sha2-256
```

### Protection contre les attaques

Les MAC protègent contre plusieurs types d'attaques :

|Type d'attaque|Protection MAC|Description|
|---|---|---|
|**Modification de données**|✅ Complète|Tout bit modifié invalide le MAC|
|**Injection de paquets**|✅ Complète|Paquets forgés rejetés (pas le bon MAC)|
|**Réordonnancement**|✅ Partielle|Numéros de séquence inclus dans le MAC|
|**Rejeu (replay)**|✅ Complète|Numéros de séquence uniques par paquet|
|**Troncature**|✅ Complète|Longueur incluse dans le calcul du MAC|

> [!example] Exemple d'attaque bloquée Un attaquant intercepte un paquet contenant la commande :
> 
> ```
> "rm file.txt" + MAC_original
> ```
> 
> Il tente de le modifier en :
> 
> ```
> "rm -rf /" + MAC_original
> ```
> 
> Le récepteur recalcule le MAC et obtient un résultat différent de `MAC_original`, le paquet est donc **rejeté**.

### Algorithmes MAC disponibles

**Configuration des MAC dans SSH :**

```bash
# Dans /etc/ssh/sshd_config ou ~/.ssh/config

# Liste des MAC acceptés (ordre de préférence)
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256

# Format : algorithm[@domain]
```

**Algorithmes courants classés par sécurité :**

|Algorithme|Sécurité|Performances|Recommandation|
|---|---|---|---|
|`hmac-sha2-512-etm@openssh.com`|⭐⭐⭐⭐⭐|Bonnes|✅ Recommandé|
|`hmac-sha2-256-etm@openssh.com`|⭐⭐⭐⭐⭐|Excellentes|✅ Recommandé|
|`hmac-sha2-512`|⭐⭐⭐⭐|Bonnes|✅ Acceptable|
|`hmac-sha2-256`|⭐⭐⭐⭐|Excellentes|✅ Acceptable|
|`hmac-sha1`|⭐⭐|Excellentes|⚠️ Déprécié|
|`hmac-md5`|⭐|Excellentes|❌ Non sécurisé|

> [!tip] Suffix "-etm@openssh.com" **ETM = Encrypt-Then-MAC**
> 
> - Calcule le MAC **après** le chiffrement (plus sécurisé)
> - Protection supplémentaire contre certaines attaques cryptographiques
> - Standard moderne recommandé

**Voir les MAC supportés :**

```bash
# Lister les MAC disponibles
ssh -Q mac

# Sortie typique
hmac-sha1
hmac-sha2-256
hmac-sha2-512
hmac-md5
hmac-sha1-etm@openssh.com
hmac-sha2-256-etm@openssh.com
hmac-sha2-512-etm@openssh.com
```

**Forcer un MAC spécifique pour tester :**

```bash
# Connexion avec un MAC particulier
ssh -o MACs=hmac-sha2-512-etm@openssh.com user@server.example.com

# Voir la négociation
ssh -v -o MACs=hmac-sha2-512-etm@openssh.com user@server 2>&1 | grep MAC
```

**Configuration sécurisée recommandée :**

```bash
# Dans /etc/ssh/sshd_config (serveur)
# Désactiver les anciens algorithmes faibles
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256
```

> [!warning] Compatibilité Supprimer des algorithmes peut empêcher la connexion de vieux clients SSH. Tester avant de déployer en production.

---

## 🔒 Confidentialité de la communication

La confidentialité garantit que les **données ne peuvent être lues** que par les parties autorisées.

### Chiffrement symétrique

Une fois la connexion établie, SSH utilise le **chiffrement symétrique** pour chiffrer toutes les données.

**Pourquoi symétrique et non asymétrique ?**

```
Chiffrement asymétrique (RSA, ECDSA...)
   ├─ Avantages : Sécurité, pas de clé partagée
   └─ Inconvénients : TRÈS LENT (1000x plus lent)
   
Chiffrement symétrique (AES, ChaCha20...)
   ├─ Avantages : TRÈS RAPIDE, efficace
   └─ Inconvénients : Nécessite clé partagée secrètement

Solution SSH : 
   1. Asymétrique pour l'échange initial de clé (une fois)
   2. Symétrique pour chiffrer les données (toute la session)
```

**Algorithmes de chiffrement disponibles :**

```bash
# Lister les chiffrements supportés
ssh -Q cipher

# Sortie typique
3des-cbc
aes128-cbc
aes192-cbc
aes256-cbc
aes128-ctr
aes192-ctr
aes256-ctr
aes128-gcm@openssh.com
aes256-gcm@openssh.com
chacha20-poly1305@openssh.com
```

**Comparaison des algorithmes modernes :**

|Algorithme|Sécurité|Performances CPU|Matériel|Recommandation|
|---|---|---|---|---|
|`chacha20-poly1305@openssh.com`|⭐⭐⭐⭐⭐|⚡⚡⚡⚡⚡|Sans AES-NI|✅ Excellent choix|
|`aes256-gcm@openssh.com`|⭐⭐⭐⭐⭐|⚡⚡⚡⚡⚡|Avec AES-NI|✅ Excellent choix|
|`aes128-gcm@openssh.com`|⭐⭐⭐⭐|⚡⚡⚡⚡⚡|Avec AES-NI|✅ Bon choix|
|`aes256-ctr`|⭐⭐⭐⭐|⚡⚡⚡⚡|Avec AES-NI|✅ Acceptable|
|`aes128-ctr`|⭐⭐⭐|⚡⚡⚡⚡|Avec AES-NI|⚠️ Acceptable|
|`aes128-cbc`|⭐⭐|⚡⚡⚡|Avec AES-NI|⚠️ Déprécié|
|`3des-cbc`|⭐|⚡|Tous|❌ Non sécurisé|

> [!info] Termes techniques
> 
> - **AES** : Advanced Encryption Standard (standard actuel)
> - **ChaCha20** : Algorithme moderne, très rapide sans accélération matérielle
> - **GCM** : Galois/Counter Mode (chiffrement + authentification intégrée)
> - **CTR** : Counter Mode (chiffrement par flux)
> - **CBC** : Cipher Block Chaining (mode plus ancien)
> - **AES-NI** : Instructions CPU pour accélérer AES (Intel/AMD modernes)

**Vérifier si votre CPU supporte AES-NI :**

```bash
# Linux
grep -o aes /proc/cpuinfo | head -1
# Sortie "aes" = supporté

# Voir les détails
lscpu | grep -i aes

# macOS
sysctl -a | grep machdep.cpu.features | grep AES
```

> [!tip] Choix selon le matériel
> 
> - **Avec AES-NI** : Préférer `aes256-gcm@openssh.com` ou `aes128-gcm@openssh.com`
> - **Sans AES-NI** : Préférer `chacha20-poly1305@openssh.com`
> - **En doute** : `chacha20-poly1305@openssh.com` fonctionne bien partout

**Configuration des chiffrements :**

```bash
# Dans /etc/ssh/sshd_config (serveur) ou ~/.ssh/config (client)

# Configuration moderne sécurisée
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr

# Configuration haute sécurité (uniquement algorithmes AEAD)
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com

# Forcer un chiffrement spécifique pour une connexion
ssh -c chacha20-poly1305@openssh.com user@server.example.com
```

> [!info] AEAD (Authenticated Encryption with Associated Data) Les algorithmes AEAD comme GCM et ChaCha20-Poly1305 combinent :
> 
> - **Chiffrement** des données (confidentialité)
> - **Authentification** des données (intégrité)
> 
> Ils sont plus efficaces et sécurisés que la combinaison séparée chiffrement + MAC.

**Voir le chiffrement utilisé lors d'une connexion :**

```bash
# Mode verbeux pour voir la négociation
ssh -v user@server.example.com 2>&1 | grep "cipher:"

# Exemple de sortie
# debug1: kex: server->client cipher: chacha20-poly1305@openssh.com
# debug1: kex: client->server cipher: chacha20-poly1305@openssh.com
```

### Négociation des algorithmes

Lors de l'établissement de la connexion, le client et le serveur **négocient** les algorithmes à utiliser.

**Processus de négociation :**

```
Client                                  Serveur
  │                                       │
  │ 1. Liste des algos supportés         │
  │    (par ordre de préférence)          │
  ├──────────────────────────────────────>
  │                                       │
  │         2. Liste des algos supportés │
  │            (par ordre de préférence) │
  <──────────────────────────────────────┤
  │                                       │
  │ 3. Sélection du premier algorithme   │
  │    commun dans chaque catégorie :    │
  │    - Échange de clés (KEX)           │
  │    - Clé d'hôte                      │
  │    - Chiffrement (client→serveur)    │
  │    - Chiffrement (serveur→client)    │
  │    - MAC (client→serveur)            │
  │    - MAC (serveur→client)            │
  │    - Compression                     │
```

> [!example] Exemple de négociation **Client propose :**
> 
> ```
> Ciphers: chacha20-poly1305, aes256-gcm, aes128-ctr
> ```
> 
> **Serveur supporte :**
> 
> ```
> Ciphers: aes256-gcm, aes128-gcm, aes256-ctr
> ```
> 
> **Résultat :** `aes256-gcm` (premier algorithme commun)

**Voir tous les algorithmes négociés :**

```bash
# Connexion avec détails complets de négociation
ssh -vv user@server.example.com 2>&1 | grep -E "kex:|cipher:|MAC:|compression:"

# Sortie typique
# debug2: KEX algorithms: curve25519-sha256,ecdh-sha2-nistp256,diffie-hellman-group14-sha256
# debug2: host key algorithms: ssh-ed25519,ecdsa-sha2-nistp256,rsa-sha2-512
# debug2: ciphers ctos: chacha20-poly1305@openssh.com,aes128-ctr,aes256-ctr
# debug2: ciphers stoc: chacha20-poly1305@openssh.com,aes128-ctr,aes256-ctr
# debug2: MACs ctos: hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com
# debug2: MACs stoc: hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com
# debug2: compression ctos: none,zlib@openssh.com
# debug2: compression stoc: none,zlib@openssh.com
```

> [!info] Notation
> 
> - **ctos** = Client To Server (client → serveur)
> - **stoc** = Server To Client (serveur → client)
> 
> Les algorithmes peuvent être différents dans chaque direction.

**Configuration pour forcer une négociation stricte :**

```bash
# Dans ~/.ssh/config
Host secure-server
    HostName server.example.com
    User admin
    # Uniquement les algorithmes les plus sécurisés
    Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
    MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
    KexAlgorithms curve25519-sha256,diffie-hellman-group-exchange-sha256
    HostKeyAlgorithms ssh-ed25519,rsa-sha2-512,rsa-sha2-256
```

> [!warning] Échec de négociation Si aucun algorithme commun n'est trouvé, la connexion échoue :
> 
> ```
> Unable to negotiate with server: no matching cipher found.
> Their offer: aes128-cbc,3des-cbc
> ```
> 
> Solution : Assouplir la configuration ou mettre à jour le serveur/client.

### Renouvellement des clés

Pour renforcer la sécurité, SSH **renouvelle périodiquement** les clés de session.

**Pourquoi renouveler les clés ?**

```
Sans renouvellement :
├─ Plus de données chiffrées = plus de matériel pour cryptanalyse
├─ Compromission d'une clé = toute la session compromise
└─ Attaques statistiques facilitées sur longue durée

Avec renouvellement :
├─ Limitation de l'exposition de chaque clé
├─ Compromission d'une clé = seulement une partie compromise
└─ Protection contre l'accumulation d'informations pour attaques
```

**Déclencheurs du renouvellement :**

1. **Basé sur le temps**
2. **Basé sur la quantité de données**

**Configuration du renouvellement :**

```bash
# Dans /etc/ssh/sshd_config (serveur)

# Renouvellement après 1 heure (défaut : 1h)
RekeyLimit default 1h

# Renouvellement après 1 GB de données (défaut : aucune limite)
RekeyLimit 1G none

# Renouvellement après 500 MB OU 30 minutes
RekeyLimit 500M 30m

# Désactiver le renouvellement basé sur la quantité
RekeyLimit default none

# Désactiver le renouvellement basé sur le temps
RekeyLimit 1G none
```

> [!tip] Valeurs recommandées
> 
> - **Serveurs à haute activité** : `RekeyLimit 1G 1h`
> - **Usage normal** : `RekeyLimit default 1h` (défaut)
> - **Sécurité maximale** : `RekeyLimit 500M 30m`
> - **Performances critiques** : `RekeyLimit default none` (désactivé)

**Syntaxe de RekeyLimit :**

```
RekeyLimit <quantité_données> <durée>

Quantité de données :
  - default : valeur par défaut (illimité)
  - none : pas de limite
  - Nombre + K/M/G : par exemple 500M, 2G

Durée :
  - default : valeur par défaut (1h)
  - none : pas de limite
  - Nombre + s/m/h/d/w : par exemple 30m, 2h, 1d
```

**Visualiser un renouvellement de clés :**

```bash
# Connexion avec logs de debug
ssh -vvv user@server.example.com

# Pendant la session, on verra des messages comme :
# debug1: SSH2_MSG_NEWKEYS sent
# debug1: expecting SSH2_MSG_NEWKEYS
# debug1: SSH2_MSG_NEWKEYS received
# debug1: rekeying
```

> [!info] Impact du renouvellement
> 
> - **Latence minimale** : quelques millisecondes
> - **Transparent** : aucune interruption de la session
> - **Automatique** : aucune action utilisateur requise

**Coût du renouvellement :**

|Aspect|Impact|
|---|---|
|**CPU**|Faible (négligeable sur matériel moderne)|
|**Latence**|10-50 ms pendant le renouvellement|
|**Bande passante**|Quelques KB pour l'échange|
|**Continuité**|Aucune interruption des données|

**Cas particuliers et pièges :**

```bash
# ❌ INCORRECT : Conflit de paramètres
RekeyLimit 1G 1h      # Définit les deux
RekeyLimit default none  # Écrase la ligne précédente (seule cette ligne compte)

# ✅ CORRECT : Une seule directive RekeyLimit
RekeyLimit 1G 1h

# Pour des hôtes spécifiques (côté client)
# Dans ~/.ssh/config
Host data-transfer-server
    RekeyLimit 5G 2h  # Plus permissif pour transferts massifs

Host high-security-server
    RekeyLimit 100M 10m  # Très strict
```

> [!warning] Compatibilité Le renouvellement de clés est supporté par toutes les versions modernes d'OpenSSH. Les très vieux clients/serveurs (< OpenSSH 4.0, 2005) peuvent ne pas le supporter.

---

## 📊 Vue d'ensemble : Les 4 piliers en action

**Chronologie d'une connexion SSH complète :**

```
┌─────────────────────────────────────────────────────────────┐
│ Phase 1 : Établissement de la connexion TCP                 │
├─────────────────────────────────────────────────────────────┤
│ Client → Serveur : SYN                                       │
│ Serveur → Client : SYN-ACK                                   │
│ Client → Serveur : ACK                                       │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ Phase 2 : 🖥️ AUTHENTIFICATION DU SERVEUR                    │
├─────────────────────────────────────────────────────────────┤
│ 1. Serveur envoie sa clé publique d'hôte                    │
│ 2. Client vérifie dans ~/.ssh/known_hosts                   │
│ 3. Si nouvelle : demande confirmation utilisateur            │
│ 4. Serveur prouve possession de la clé privée               │
│ → Client sait qu'il parle au bon serveur                    │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ Phase 3 : Échange de clés (KEX - Key Exchange)              │
├─────────────────────────────────────────────────────────────┤
│ Négociation des algorithmes :                               │
│ - Échange de clés : curve25519-sha256                       │
│ - Chiffrement : chacha20-poly1305@openssh.com               │
│ - MAC : hmac-sha2-256-etm@openssh.com                       │
│ → Génération d'une clé de session partagée                  │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ Phase 4 : 👤 AUTHENTIFICATION DU CLIENT                     │
├─────────────────────────────────────────────────────────────┤
│ Méthode : Clé publique                                       │
│ 1. Client envoie sa clé publique                            │
│ 2. Serveur vérifie dans ~/.ssh/authorized_keys              │
│ 3. Serveur envoie un challenge chiffré                      │
│ 4. Client signe avec sa clé privée                          │
│ 5. Serveur vérifie la signature                             │
│ → Serveur sait qui est le client                            │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ Phase 5 : Session sécurisée active                          │
├─────────────────────────────────────────────────────────────┤
│ Pour chaque paquet envoyé :                                  │
│                                                              │
│ 🔒 CONFIDENTIALITÉ :                                         │
│    Message → Chiffrement ChaCha20 → Message chiffré         │
│                                                              │
│ 🛡️ INTÉGRITÉ :                                              │
│    Message chiffré → Calcul MAC → Message + MAC             │
│                                                              │
│ À réception :                                                │
│    1. Vérification MAC (intégrité)                          │
│    2. Si OK : déchiffrement (confidentialité)               │
│    3. Si NOK : paquet rejeté                                │
│                                                              │
│ Renouvellement automatique des clés toutes les heures       │
└─────────────────────────────────────────────────────────────┘
```

**Tableau récapitulatif des mécanismes :**

|Mécanisme|Objectif|Technologie|Moment d'application|
|---|---|---|---|
|**Authentification serveur**|Prouver l'identité du serveur|Clés d'hôte asymétriques|Début de connexion|
|**Authentification client**|Prouver l'identité du client|Clés SSH / Mot de passe|Après auth. serveur|
|**Intégrité**|Détecter les modifications|MAC (HMAC-SHA2)|Chaque paquet|
|**Confidentialité**|Empêcher la lecture|Chiffrement symétrique (AES/ChaCha20)|Chaque paquet|

---

## 🎯 Bonnes pratiques de sécurité

### Configuration sécurisée recommandée

**Côté serveur (`/etc/ssh/sshd_config`) :**

```bash
# === AUTHENTIFICATION ===
# Désactiver l'authentification par mot de passe
PasswordAuthentication no

# Désactiver l'authentification root par mot de passe
PermitRootLogin prohibit-password

# Autoriser uniquement les clés publiques
PubkeyAuthentication yes

# Désactiver les méthodes faibles
ChallengeResponseAuthentication no
KerberosAuthentication no
GSSAPIAuthentication no

# === ALGORITHMES CRYPTOGRAPHIQUES ===
# Clés d'hôte (ordre de préférence)
HostKey /etc/ssh/ssh_host_ed25519_key
HostKey /etc/ssh/ssh_host_rsa_key

# Algorithmes de clé d'hôte acceptés
HostKeyAlgorithms ssh-ed25519,rsa-sha2-512,rsa-sha2-256

# Échange de clés (KEX)
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group-exchange-sha256

# Chiffrements
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr

# MACs
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256

# === RENOUVELLEMENT DES CLÉS ===
RekeyLimit 1G 1h

# === SÉCURITÉ ADDITIONNELLE ===
# Limiter les tentatives d'authentification
MaxAuthTries 3

# Timeout de connexion
LoginGraceTime 30

# Désactiver les fonctionnalités non nécessaires
X11Forwarding no
AllowTcpForwarding no
AllowAgentForwarding no
PermitTunnel no

# Utiliser uniquement le protocole SSH v2
Protocol 2
```

**Côté client (`~/.ssh/config`) :**

```bash
# Configuration globale pour tous les hôtes
Host *
    # Vérification stricte des clés d'hôte
    StrictHostKeyChecking ask
    
    # Hasher les noms d'hôtes dans known_hosts
    HashKnownHosts yes
    
    # Algorithmes modernes uniquement
    HostKeyAlgorithms ssh-ed25519,rsa-sha2-512,rsa-sha2-256
    KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org
    Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
    MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
    
    # Préférer IPv4 (ou IPv6 selon votre réseau)
    AddressFamily inet
    
    # Timeout de connexion
    ConnectTimeout 30
    ServerAliveInterval 60
    ServerAliveCountMax 3

# Configuration spécifique pour serveurs de production
Host prod-*
    User admin
    IdentityFile ~/.ssh/id_ed25519_production
    StrictHostKeyChecking yes  # Refuser si clé inconnue
```

### Pièges courants à éviter

> [!warning] ❌ À NE JAMAIS FAIRE

**1. Désactiver la vérification des clés d'hôte**

```bash
# ❌ DANGEREUX : Vulnérable aux attaques MITM
StrictHostKeyChecking no
UserKnownHostsFile /dev/null
```

**2. Utiliser des algorithmes faibles**

```bash
# ❌ DANGEREUX : Algorithmes obsolètes
Ciphers aes128-cbc,3des-cbc
MACs hmac-sha1,hmac-md5
```

**3. Clé privée sans protection**

```bash
# ❌ DANGEREUX : Pas de passphrase
ssh-keygen -t rsa -N ""

# ❌ DANGEREUX : Permissions trop permissives
chmod 644 ~/.ssh/id_ed25519  # Doit être 600
```

**4. Autoriser root avec mot de passe**

```bash
# ❌ DANGEREUX dans /etc/ssh/sshd_config
PermitRootLogin yes
PasswordAuthentication yes
```

**5. Accepter aveuglément les nouvelles clés**

```bash
# ❌ DANGEREUX : Accepter sans vérifier l'empreinte
ssh user@new-server
# "yes" sans vérifier le fingerprint
```

### Audit de sécurité

**Tester la configuration SSH :**

```bash
# Tester la configuration du serveur
sudo sshd -t
# Sortie : rien si OK, erreurs sinon

# Tester avec détails
sudo sshd -T

# Voir uniquement certains paramètres
sudo sshd -T | grep -E "passwordauthentication|permitrootlogin|ciphers"

# Simuler une connexion sans se connecter
ssh -v -o PreferredAuthentications=none user@server 2>&1 | grep "Authentications that can continue"
```

**Scanner les algorithmes supportés par un serveur distant :**

```bash
# Avec nmap (si installé)
nmap --script ssh2-enum-algos server.example.com

# Méthode manuelle
ssh -v user@server 2>&1 | grep "kex algorithms"
```

**Vérifier les permissions critiques :**

```bash
# Script de vérification automatique
check_ssh_permissions() {
    echo "Vérification des permissions SSH..."
    
    # Répertoire .ssh
    local perms=$(stat -c %a ~/.ssh 2>/dev/null)
    if [ "$perms" != "700" ]; then
        echo "❌ ~/.ssh a les permissions $perms (doit être 700)"
    else
        echo "✅ ~/.ssh : OK"
    fi
    
    # Clés privées
    for key in ~/.ssh/id_*; do
        if [[ "$key" != *.pub ]]; then
            perms=$(stat -c %a "$key" 2>/dev/null)
            if [ "$perms" != "600" ]; then
                echo "❌ $key a les permissions $perms (doit être 600)"
            else
                echo "✅ $key : OK"
            fi
        fi
    done
    
    # known_hosts
    if [ -f ~/.ssh/known_hosts ]; then
        perms=$(stat -c %a ~/.ssh/known_hosts)
        if [ "$perms" != "600" ] && [ "$perms" != "644" ]; then
            echo "⚠️  ~/.ssh/known_hosts a les permissions $perms (recommandé : 600)"
        else
            echo "✅ known_hosts : OK"
        fi
    fi
}

check_ssh_permissions
```

---

## 🔍 Cas d'usage pratiques

### Scénario 1 : Configuration d'un nouveau serveur

```bash
# 1. Générer de nouvelles clés d'hôte (si nécessaire)
sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
sudo ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ""

# 2. Configurer sshd_config selon les bonnes pratiques
sudo nano /etc/ssh/sshd_config
# (Appliquer la configuration sécurisée ci-dessus)

# 3. Tester la configuration
sudo sshd -t

# 4. Redémarrer SSH
sudo systemctl restart sshd

# 5. Obtenir les empreintes à communiquer
ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

### Scénario 2 : Migration vers authentification par clés

```bash
# 1. Générer une paire de clés sur le client
ssh-keygen -t ed25519 -C "migration-vers-cles"

# 2. Copier la clé publique sur le serveur (nécessite mot de passe une dernière fois)
ssh-copy-id user@server.example.com

# 3. Tester la connexion avec la clé
ssh user@server.example.com
# Doit fonctionner sans demander de mot de passe

# 4. Désactiver l'authentification par mot de passe sur le serveur
# Dans /etc/ssh/sshd_config
# PasswordAuthentication no
sudo systemctl restart sshd
```

### Scénario 3 : Connexion multi-serveurs avec différentes clés

```bash
# Structure des clés
~/.ssh/
├── id_ed25519_work       # Clé pour serveurs professionnels
├── id_ed25519_work.pub
├── id_ed25519_personal   # Clé pour serveurs personnels
├── id_ed25519_personal.pub
└── config

# Configuration dans ~/.ssh/config
Host work-*
    User admin
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes

Host personal-*
    User myuser
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes

# Utilisation
ssh work-server1        # Utilise automatiquement id_ed25519_work
ssh personal-server1    # Utilise automatiquement id_ed25519_personal
```

---

## 📝 Résumé des commandes essentielles

```bash
# === AUTHENTIFICATION SERVEUR ===
# Voir les clés d'hôte publiques
ssh-keygen -l -f /etc/ssh/ssh_host_ed25519_key.pub

# Ajouter un serveur à known_hosts
ssh-keyscan server.example.com >> ~/.ssh/known_hosts

# Supprimer une entrée de known_hosts
ssh-keygen -R server.example.com

# === AUTHENTIFICATION CLIENT ===
# Générer une paire de clés
ssh-keygen -t ed25519 -C "commentaire"

# Copier la clé publique sur un serveur
ssh-copy-id user@server.example.com

# Gérer ssh-agent
eval $(ssh-agent)
ssh-add ~/.ssh/id_ed25519
ssh-add -l  # Lister les clés chargées

# === DIAGNOSTIC ===
# Connexion avec logs verbeux
ssh -vvv user@server.example.com

# Voir les algorithmes négociés
ssh -v user@server 2>&1 | grep -E "kex:|cipher:|MAC:"

# Lister les algorithmes supportés
ssh -Q cipher
ssh -Q mac
ssh -Q kex

# Forcer un algorithme spécifique
ssh -c chacha20-poly1305@openssh.com user@server

# === CONFIGURATION ===
# Tester la config serveur
sudo sshd -t
sudo sshd -T  # Afficher config complète

# Vérifier permissions
ls -la ~/.ssh/
stat -c %a ~/.ssh/id_ed25519
```

---

## 💡 Points clés à retenir

> [!tip] Les 4 piliers de la sécurité SSH
> 
> 1. **🖥️ Authentification du serveur** : Vérifier qu'on parle au bon serveur (clés d'hôte)
> 2. **👤 Authentification du client** : Prouver son identité (clés SSH > mots de passe)
> 3. **🛡️ Intégrité des données** : Détecter toute modification (MAC)
> 4. **🔒 Confidentialité** : Empêcher l'interception (chiffrement symétrique)

> [!warning] Sécurité avant tout
> 
> - Ne JAMAIS désactiver `StrictHostKeyChecking` en production
> - Ne JAMAIS utiliser de clés privées sans passphrase en production
> - Ne JAMAIS accepter une nouvelle clé d'hôte sans vérifier son empreinte
> - Toujours préférer les clés SSH aux mots de passe
> - Utiliser uniquement des algorithmes modernes (Ed25519, ChaCha20, SHA-2)

> [!example] Configuration recommandée minimaliste **Serveur :**
> 
> ```bash
> PasswordAuthentication no
> PermitRootLogin prohibit-password
> PubkeyAuthentication yes
> ```
> 
> **Client :**
> 
> ```bash
> ssh-keygen -t ed25519
> ssh-copy-id user@server
> ```