

---

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

## 🔄 Chiffrement symétrique

### Qu'est-ce que c'est ?

Le chiffrement symétrique utilise **une seule clé** pour chiffrer et déchiffrer les données. Cette même clé doit être connue par l'émetteur et le récepteur.

> [!info] Analogie Imaginez un coffre-fort avec une seule clé. Vous utilisez cette même clé pour le verrouiller et le déverrouiller.

### Pourquoi c'est important dans SSH ?

Une fois la connexion SSH établie, **toutes les données échangées** (commandes, résultats, transferts de fichiers) sont chiffrées avec un algorithme symétrique. C'est le chiffrement symétrique qui assure la **confidentialité** de la session SSH après l'authentification.

> [!tip] Performance Le chiffrement symétrique est **beaucoup plus rapide** que l'asymétrique, c'est pourquoi SSH l'utilise pour chiffrer les données de session.

### Algorithmes utilisés dans SSH

|Algorithme|Taille de clé|Usage dans SSH|Sécurité|
|---|---|---|---|
|**AES** (Advanced Encryption Standard)|128, 192, 256 bits|Standard actuel|Très élevée|
|**ChaCha20**|256 bits|Alternative moderne à AES|Très élevée|
|**3DES**|168 bits|Obsolète, déprécié|Faible (à éviter)|
|**Blowfish**|Variable (32-448 bits)|Ancien, encore supporté|Moyenne|

### Comment ça fonctionne dans SSH ?

```
Client SSH                                    Serveur SSH
    |                                              |
    |  1. Négociation de l'algorithme symétrique   |
    |<-------------------------------------------->|
    |                                              |
    |  2. Génération d'une clé de session          |
    |     (via Diffie-Hellman)                     |
    |<-------------------------------------------->|
    |                                              |
    |  3. Toutes les données sont chiffrées        |
    |     avec cette clé de session                |
    |<=============================================>|
```

> [!example] Exemple concret Quand vous tapez `ls -la` dans une session SSH, cette commande est chiffrée avec AES-256 (par exemple) avant d'être envoyée au serveur. Le serveur la déchiffre avec la même clé, l'exécute, puis chiffre le résultat avant de vous le renvoyer.

### Configuration dans SSH

Les algorithmes de chiffrement symétrique disponibles sont listés dans la configuration SSH :

```bash
# Voir les algorithmes de chiffrement supportés
ssh -Q cipher

# Forcer l'utilisation d'un algorithme spécifique
ssh -c aes256-gcm@openssh.com user@host

# Spécifier une liste d'algorithmes préférés
ssh -o Ciphers=aes256-gcm@openssh.com,chacha20-poly1305@openssh.com user@host
```

Configuration dans `/etc/ssh/sshd_config` (serveur) ou `~/.ssh/config` (client) :

```bash
# Définir les algorithmes d'échange de clés autorisés
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521

# Interdire les algorithmes faibles
# KexAlgorithms -diffie-hellman-group1-sha1
```

### Processus détaillé de l'échange DH dans SSH

#### Étape 1 : Négociation des algorithmes

Le client et le serveur se mettent d'accord sur :

- L'algorithme d'échange de clés (ex: curve25519-sha256)
- L'algorithme de chiffrement symétrique (ex: aes256-gcm)
- L'algorithme MAC (ex: hmac-sha2-512)
- L'algorithme de compression (ex: none, zlib)

```bash
# Voir la négociation en détail
ssh -vv user@host 2>&1 | grep "kex:"
```

#### Étape 2 : Génération et échange des clés publiques DH

Chaque partie génère :

- Un nombre secret aléatoire (éphémère)
- Une clé publique DH calculée à partir de ce secret

Ces clés publiques sont échangées. **Important** : Les secrets ne sont jamais transmis !

#### Étape 3 : Authentification de l'échange

Le serveur **signe** l'échange DH avec sa clé privée (host key). Cela prouve :

- Que le serveur possède bien la clé privée correspondant à la host key
- Que l'échange n'a pas été intercepté (protection contre man-in-the-middle)

```
Hash(clé_publique_client_DH + clé_publique_serveur_DH + autres_params)
      ↓
   Signature avec la clé privée du serveur
      ↓
   Vérification par le client avec la clé publique du serveur
```

#### Étape 4 : Calcul du secret partagé

Client et serveur calculent indépendamment le **même secret partagé** :

- Client : `secret = serveur_public_DH^client_secret_DH`
- Serveur : `secret = client_public_DH^serveur_secret_DH`

Résultat : Même secret des deux côtés, mais jamais transmis sur le réseau !

#### Étape 5 : Dérivation des clés de session

À partir du secret partagé, SSH dérive plusieurs clés en utilisant des fonctions de hachage :

```
Secret partagé DH + Hash des paramètres d'échange
      ↓
   SHA-256 ou SHA-512
      ↓
- Clé de chiffrement client → serveur
- Clé de chiffrement serveur → client
- Clé MAC client → serveur
- Clé MAC serveur → client
- Vecteur d'initialisation client → serveur
- Vecteur d'initialisation serveur → client
```

> [!info] Clés bidirectionnelles SSH utilise des clés différentes pour chaque direction de communication. Cela améliore la sécurité en isolant les flux de données.

#### Étape 6 : Activation du chiffrement

Une fois les clés dérivées, le chiffrement symétrique est activé et **toutes les communications suivantes** sont chiffrées et authentifiées.

### Rekey (Re-négociation des clés)

SSH re-négocie périodiquement de nouvelles clés pour renforcer la sécurité :

```bash
# Configuration dans sshd_config ou ssh_config
RekeyLimit 1G 1h
# Signification : Re-négocier après 1 Go de données OU après 1 heure
```

> [!tip] Pourquoi le rekey ?
> 
> - Limite l'exposition si une clé de session est compromise
> - Réduit le risque d'analyse cryptographique sur de grandes quantités de données
> - Maintient le Perfect Forward Secrecy même pendant une longue session

### Voir l'échange de clés en action

```bash
# Mode verbeux pour voir l'échange DH
ssh -vv user@host

# Sortie exemple :
# debug2: KEX algorithms: curve25519-sha256,...
# debug1: kex: algorithm: curve25519-sha256
# debug1: expecting SSH2_MSG_KEX_ECDH_REPLY
# debug1: Server host key: ssh-ed25519 SHA256:xxxxx
# debug1: SSH2_MSG_NEWKEYS sent
# debug1: expecting SSH2_MSG_NEWKEYS
# debug1: SSH2_MSG_NEWKEYS received
```

### Pièges courants

❌ **Confondre l'échange DH avec l'authentification** : DH établit un canal sécurisé, mais n'authentifie pas l'utilisateur. L'authentification vient après.

❌ **Penser que DH transmet une clé** : DH ne transmet JAMAIS le secret partagé. Chaque partie le calcule indépendamment.

❌ **Utiliser des groupes DH faibles** : Les groupes DH de moins de 2048 bits (comme diffie-hellman-group1-sha1) sont vulnérables. Utilisez au minimum group14 ou, mieux, ECDH.

❌ **Ne pas activer le Perfect Forward Secrecy** : Si vous désactivez les algorithmes éphémères (avec DH), vous perdez le PFS.

❌ **Ignorer les avertissements de host key** : Si SSH vous avertit que la clé du serveur a changé, c'est peut-être une attaque man-in-the-middle ! Vérifiez avant de continuer.

```
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
```

### Astuces

💡 **Curve25519 : le meilleur choix** : Plus rapide, plus sûr, et plus simple que les courbes NIST.

```bash
# Forcer Curve25519
Host *
    KexAlgorithms curve25519-sha256@libssh.org,curve25519-sha256
```

💡 **Tester la négociation** : Utilisez `ssh -vv` pour comprendre quels algorithmes sont choisis et pourquoi.

```bash
ssh -vv user@host 2>&1 | grep -E "kex:|cipher:|MAC:"
```

💡 **Perfect Forward Secrecy vérifié** : Tous les algorithmes DH/ECDH modernes fournissent le PFS. Vérifiez que votre configuration ne contient pas d'algorithmes statiques.

💡 **Comprendre le MITM** : Lors de la première connexion, notez l'empreinte du serveur et vérifiez-la via un canal sécurisé (téléphone, documentation officielle).

```bash
# Voir l'empreinte lors de la connexion
ssh -o VisualHostKey=yes user@host
```

💡 **Régénérer les host keys du serveur** : Si vous pensez qu'elles ont été compromises.

```bash
# Sur le serveur
sudo rm /etc/ssh/ssh_host_*
sudo ssh-keygen -A
sudo systemctl restart sshd

# Les clients devront accepter les nouvelles clés
```

💡 **dhGEX (Group Exchange)** : Certains algorithmes DH permettent au client de demander des tailles de groupe spécifiques.

```bash
# Configuration serveur pour dhGEX
# /etc/ssh/moduli contient les groupes DH prégénérés
```

💡 **Désactiver les algorithmes faibles globalement** : Dans votre configuration SSH système.

```bash
# /etc/ssh/ssh_config.d/99-custom.conf
Host *
    KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256
    Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
    MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256
```

### Visualisation complète du processus SSH

```
┌─────────────────────────────────────────────────────────────────┐
│                    ÉTABLISSEMENT D'UNE SESSION SSH              │
└─────────────────────────────────────────────────────────────────┘

1. NÉGOCIATION DES ALGORITHMES
   ┌──────────┐                              ┌──────────┐
   │  Client  │────── Algorithmes supportés──→│ Serveur  │
   │          │←───── Choix des algorithmes ──│          │
   └──────────┘                              └──────────┘

2. ÉCHANGE DE CLÉS DIFFIE-HELLMAN
   ┌──────────┐                              ┌──────────┐
   │  Client  │                              │ Serveur  │
   │ secret_c │                              │ secret_s │
   │    ↓     │                              │    ↓     │
   │ public_c │──────── Échange DH ─────────→│ public_s │
   │          │←───────────────────────────→│          │
   │          │                              │          │
   │ Calcul : │                              │ Calcul : │
   │ secret = │                              │ secret = │
   │ public_s │                              │ public_c │
   │ ^ secret_c                              │ ^ secret_s
   └──────────┘                              └──────────┘
        ↓                                          ↓
    MÊME SECRET PARTAGÉ (jamais transmis !)

3. AUTHENTIFICATION DU SERVEUR
   ┌──────────┐                              ┌──────────┐
   │  Client  │←── Signature de l'échange ───│ Serveur  │
   │ Vérifie  │    avec la host key          │          │
   │ signature│                              │          │
   └──────────┘                              └──────────┘

4. DÉRIVATION DES CLÉS DE SESSION
   Secret partagé + Hash(paramètres)
              ↓
        SHA-256/SHA-512
              ↓
   ┌─────────────────────────┐
   │ Clé chiffrement C→S     │
   │ Clé chiffrement S→C     │
   │ Clé MAC C→S             │
   │ Clé MAC S→C             │
   │ IV C→S                  │
   │ IV S→C                  │
   └─────────────────────────┘

5. CHIFFREMENT ACTIVÉ
   ┌──────────┐                              ┌──────────┐
   │  Client  │═══════ Canal sécurisé ══════│ Serveur  │
   │          │      (AES-256 + HMAC)        │          │
   └──────────┘                              └──────────┘

6. AUTHENTIFICATION DE L'UTILISATEUR
   (Par mot de passe ou clé publique)

7. SESSION SSH ÉTABLIE
   ┌──────────┐                              ┌──────────┐
   │  Client  │═══════════════════════════════│ Serveur  │
   │          │  Commandes, fichiers, etc.    │          │
   └──────────┘                              └──────────┘
```

---

## 🎯 Synthèse : Comment tout s'articule dans SSH

### Le problème de départ

Comment établir une communication sécurisée entre un client et un serveur sur Internet (réseau non sécurisé) ?

### La solution en 4 étapes cryptographiques

|Étape|Technologie|Rôle|Avantage|
|---|---|---|---|
|**1. Échange de clés**|Diffie-Hellman (ECDH)|Créer un secret partagé sans le transmettre|Pas d'interception possible|
|**2. Authentification**|Chiffrement asymétrique (Ed25519, RSA)|Prouver l'identité du serveur et du client|Protection contre l'usurpation|
|**3. Confidentialité**|Chiffrement symétrique (AES, ChaCha20)|Chiffrer toutes les données échangées|Performance + sécurité|
|**4. Intégrité**|Fonctions de hachage (SHA-256, HMAC)|Vérifier que les données ne sont pas modifiées|Détection de manipulation|

### Déroulement chronologique d'une connexion SSH

```
Temps  │ Action                           │ Technologie utilisée
───────┼──────────────────────────────────┼────────────────────────────
  0s   │ Connexion TCP                    │ Réseau (port 22)
       │                                  │
  1s   │ Négociation des algorithmes      │ Protocol SSH
       │                                  │
  2s   │ Échange de clés                  │ Diffie-Hellman (ECDH)
       │ → Secret partagé créé            │
       │                                  │
  3s   │ Signature de l'échange           │ Chiffrement asymétrique
       │ → Serveur authentifié            │ (Host key)
       │                                  │
  4s   │ Dérivation des clés de session   │ Fonctions de hachage
       │ → AES, HMAC, IV générés          │ (SHA-256/512)
       │                                  │
  5s   │ Activation du chiffrement        │ Chiffrement symétrique
       │ → Canal sécurisé établi          │ (AES-256-GCM)
       │                                  │
  6s   │ Authentification utilisateur     │ Chiffrement asymétrique
       │ → Client authentifié             │ (Clé publique/privée)
       │                                  │
  7s+  │ Session SSH active               │ AES + HMAC
       │ → Commandes, transferts, etc.    │ (Confidentialité + Intégrité)
```

### Récapitulatif des algorithmes recommandés en 2024

> [!tip] Configuration optimale

**Échange de clés** :

```bash
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp521
```

**Chiffrement symétrique** :

```bash
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
```

**Intégrité (MAC)** :

```bash
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
```

**Authentification** :

```bash
PubkeyAcceptedKeyTypes ssh-ed25519,rsa-sha2-512,rsa-sha2-256
HostKeyAlgorithms ssh-ed25519,rsa-sha2-512,rsa-sha2-256
```

### Les 3 propriétés de sécurité garanties

1. **Confidentialité** : Les données ne peuvent pas être lues par un tiers
    
    - Assuré par : Chiffrement symétrique (AES, ChaCha20)
2. **Intégrité** : Les données ne peuvent pas être modifiées sans détection
    
    - Assuré par : Fonctions de hachage (HMAC-SHA2)
3. **Authentification** : Les parties peuvent prouver leur identité
    
    - Assuré par : Chiffrement asymétrique (Ed25519, RSA)

> [!info] Bonus : Perfect Forward Secrecy Grâce à Diffie-Hellman éphémère, même si les clés privées sont compromises plus tard, les sessions passées restent sécurisées.

### Points clés à retenir

✅ **Chiffrement symétrique** = Rapide, pour les données de session (AES, ChaCha20)

✅ **Chiffrement asymétrique** = Authentification, échange de clés (Ed25519, RSA)

✅ **Fonctions de hachage** = Intégrité, signatures, empreintes (SHA-256, HMAC)

✅ **Diffie-Hellman** = Création sécurisée d'un secret partagé (Curve25519)

✅ **SSH combine les 4** pour créer un canal de communication totalement sécurisé

---

## 🔒 Bonnes pratiques de sécurité

### Pour les clés

- ✅ Utilisez Ed25519 pour vos nouvelles clés
- ✅ Protégez vos clés privées avec une passphrase forte
- ✅ Permissions correctes : `chmod 600` pour les clés privées
- ✅ Utilisez `ssh-agent` pour gérer vos passphrases
- ✅ Créez des clés différentes par usage (GitHub, serveurs prod, etc.)
- ❌ Ne partagez JAMAIS votre clé privée
- ❌ N'utilisez plus RSA < 2048 bits ou DSA

### Pour la configuration SSH

- ✅ Désactivez les algorithmes faibles (MD5, SHA-1, 3DES)
- ✅ Activez uniquement les algorithmes modernes et sûrs
- ✅ Vérifiez toujours les empreintes de host key lors de la première connexion
- ✅ Mettez à jour régulièrement votre version d'OpenSSH
- ✅ Configurez le rekey (RekeyLimit) pour les sessions longues
- ❌ N'acceptez pas aveuglément les changements de host key
- ❌ Ne désactivez pas la vérification des host keys (StrictHostKeyChecking)

### Pour l'authentification

- ✅ Privilégiez l'authentification par clé publique
- ✅ Désactivez l'authentification par mot de passe quand possible
- ✅ Utilisez `PasswordAuthentication no` sur les serveurs critiques
- ✅ Limitez les utilisateurs autorisés (AllowUsers, AllowGroups)
- ❌ Ne réutilisez pas les mêmes clés partout
- ❌ Ne stockez pas les clés privées sur des serveurs distants

---

**📚 Fin du cours sur les Principes Cryptographiques de SSH** les algorithmes de chiffrement autorisés Ciphers aes256-gcm@openssh.com,chacha20-poly1305@openssh.com,aes256-ctr

````

> [!warning] Sécurité
> Évitez les algorithmes obsolètes comme 3DES ou arcfour. Privilégiez AES-GCM, ChaCha20-Poly1305 ou AES-CTR.

### Pièges courants

❌ **Ne pas mettre à jour les algorithmes** : Les anciennes versions de SSH utilisent parfois des algorithmes faibles par défaut.

❌ **Confondre la clé de session avec la clé d'authentification** : La clé de session (symétrique) est temporaire et différente de votre clé privée SSH (asymétrique).

❌ **Penser que le chiffrement symétrique suffit** : Sans l'échange de clés sécurisé (Diffie-Hellman) et l'authentification (asymétrique), le chiffrement symétrique seul est vulnérable.

### Astuces

💡 **AES-GCM vs AES-CTR** : AES-GCM inclut l'authentification des données (intégrité) en plus du chiffrement, c'est un "AEAD" (Authenticated Encryption with Associated Data).

💡 **ChaCha20-Poly1305** : Excellent choix pour les environnements où AES n'est pas accéléré matériellement (certains processeurs ARM, mobiles).

💡 **Vérifier les algorithmes négociés** : Utilisez `ssh -v` pour voir quel algorithme de chiffrement a été négocié lors de la connexion.

```bash
ssh -v user@host 2>&1 | grep "cipher:"
# Sortie exemple : debug1: kex: server->client cipher: aes256-gcm@openssh.com
````

---

## 🔑 Chiffrement asymétrique

### Qu'est-ce que c'est ?

Le chiffrement asymétrique utilise **deux clés mathématiquement liées** :

- **Clé publique** : Peut être partagée librement, sert à chiffrer les données
- **Clé privée** : Doit rester secrète, sert à déchiffrer les données

> [!info] Analogie Imaginez une boîte aux lettres publique : tout le monde peut y déposer un message (chiffrer avec la clé publique), mais seul le propriétaire possède la clé pour l'ouvrir (déchiffrer avec la clé privée).

### Pourquoi c'est important dans SSH ?

Le chiffrement asymétrique dans SSH sert principalement à **l'authentification** :

1. **Authentification du serveur** : Le serveur prouve son identité au client
2. **Authentification du client** : Le client prouve son identité au serveur (authentification par clé publique)

> [!warning] Précision importante Contrairement à une idée reçue, SSH n'utilise **pas** le chiffrement asymétrique pour chiffrer les données de session (trop lent). Il l'utilise pour l'authentification et participe à l'établissement de la clé symétrique.

### Algorithmes utilisés dans SSH

|Algorithme|Taille de clé recommandée|Usage principal|Sécurité|
|---|---|---|---|
|**RSA**|2048 bits minimum, 4096 bits recommandé|Authentification|Élevée (si clé >= 2048 bits)|
|**Ed25519**|256 bits (fixe)|Authentification|Très élevée|
|**ECDSA**|256, 384, 521 bits|Authentification|Élevée|
|**DSA**|1024 bits|Obsolète|Faible (à éviter)|

> [!tip] Recommandation actuelle **Ed25519** est le meilleur choix en 2024 : plus rapide, plus sûr, et avec des clés plus petites que RSA.

### Comment ça fonctionne dans SSH ?

#### 1. Authentification du serveur

```
Client SSH                                    Serveur SSH
    |                                              |
    |  1. Demande de connexion                     |
    |--------------------------------------------->|
    |                                              |
    |  2. Le serveur envoie sa clé publique        |
    |     (host key)                               |
    |<---------------------------------------------|
    |                                              |
    |  3. Le serveur prouve qu'il possède la       |
    |     clé privée correspondante (signature)    |
    |<---------------------------------------------|
    |                                              |
    |  4. Le client vérifie la signature avec      |
    |     la clé publique                          |
    |  (Vérification dans ~/.ssh/known_hosts)      |
    |                                              |
```

Lors de la première connexion, vous voyez ce message :

```
The authenticity of host 'example.com (192.168.1.10)' can't be established.
ED25519 key fingerprint is SHA256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.
Are you sure you want to continue connecting (yes/no)?
```

C'est le moment où vous acceptez la clé publique du serveur.

#### 2. Authentification du client par clé publique

```
Client SSH                                    Serveur SSH
    |                                              |
    |  1. Le client propose d'utiliser une clé     |
    |--------------------------------------------->|
    |                                              |
    |  2. Le serveur vérifie si la clé publique    |
    |     est autorisée (~/.ssh/authorized_keys)   |
    |<---------------------------------------------|
    |                                              |
    |  3. Le serveur envoie un challenge           |
    |<---------------------------------------------|
    |                                              |
    |  4. Le client signe le challenge avec        |
    |     sa clé privée                            |
    |--------------------------------------------->|
    |                                              |
    |  5. Le serveur vérifie la signature avec     |
    |     la clé publique                          |
    |  → Authentification réussie !                |
    |                                              |
```

### Génération de paires de clés

```bash
# Générer une paire de clés Ed25519 (recommandé)
ssh-keygen -t ed25519 -C "votre_email@example.com"

# Générer une paire de clés RSA 4096 bits
ssh-keygen -t rsa -b 4096 -C "votre_email@example.com"

# Générer une paire de clés ECDSA
ssh-keygen -t ecdsa -b 521 -C "votre_email@example.com"

# Spécifier un nom de fichier personnalisé
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_github -C "github_account"
```

> [!example] Résultat de la génération Deux fichiers sont créés :
> 
> - `~/.ssh/id_ed25519` : **Clé privée** (à garder secrète !)
> - `~/.ssh/id_ed25519.pub` : **Clé publique** (à copier sur les serveurs)

### Installation de la clé publique sur un serveur

```bash
# Méthode 1 : Avec ssh-copy-id (recommandé)
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@host

# Méthode 2 : Manuellement
cat ~/.ssh/id_ed25519.pub | ssh user@host "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

# Méthode 3 : Copie manuelle complète
# Sur votre machine :
cat ~/.ssh/id_ed25519.pub
# Copiez la sortie, puis sur le serveur :
mkdir -p ~/.ssh
echo "COLLEZ_LA_CLÉ_PUBLIQUE_ICI" >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

### Configuration de l'authentification par clé

Dans `~/.ssh/config` (client) :

```bash
Host monserveur
    HostName example.com
    User username
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
```

Dans `/etc/ssh/sshd_config` (serveur) :

```bash
# Autoriser l'authentification par clé publique
PubkeyAuthentication yes

# Fichier contenant les clés autorisées
AuthorizedKeysFile .ssh/authorized_keys

# (Optionnel) Désactiver l'authentification par mot de passe
PasswordAuthentication no

# Spécifier les algorithmes de clé acceptés
PubkeyAcceptedKeyTypes ssh-ed25519,rsa-sha2-512,rsa-sha2-256
```

### Pièges courants

❌ **Partager sa clé privée** : La clé privée doit **TOUJOURS** rester secrète. Ne la copiez jamais sur un serveur, ne l'envoyez jamais par email.

❌ **Mauvaises permissions sur les fichiers** :

```bash
# Permissions correctes
chmod 700 ~/.ssh                    # Répertoire
chmod 600 ~/.ssh/id_ed25519        # Clé privée
chmod 644 ~/.ssh/id_ed25519.pub    # Clé publique
chmod 600 ~/.ssh/authorized_keys   # Sur le serveur
```

❌ **Utiliser des clés RSA trop courtes** : Une clé RSA de 1024 bits est considérée comme non sécurisée. Minimum 2048 bits, recommandé 4096 bits.

❌ **Ne pas protéger la clé privée par une passphrase** : Toujours définir une passphrase lors de la génération de la clé (vous pouvez utiliser `ssh-agent` pour ne pas avoir à la retaper constamment).

❌ **Confondre .pub** : Le fichier `.pub` contient la clé **publique** (à partager), le fichier sans extension contient la clé **privée** (à garder secrète).

### Astuces

💡 **Utiliser ssh-agent** : Chargez vos clés dans l'agent SSH pour ne pas avoir à retaper la passphrase à chaque connexion.

```bash
# Démarrer l'agent
eval "$(ssh-agent -s)"

# Ajouter votre clé
ssh-add ~/.ssh/id_ed25519

# Lister les clés chargées
ssh-add -l
```

💡 **Clés spécifiques par service** : Créez des clés différentes pour GitHub, GitLab, vos serveurs, etc.

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_github -C "github"
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_prod -C "production_servers"
```

💡 **Vérifier quelle clé est utilisée** : Utilisez `ssh -v` pour voir quelle clé a été acceptée lors de l'authentification.

```bash
ssh -v user@host 2>&1 | grep "Offering\|Authentications"
```

💡 **Visualiser l'empreinte d'une clé** : Utile pour vérifier l'identité d'un serveur.

```bash
# Empreinte de votre clé publique
ssh-keygen -lf ~/.ssh/id_ed25519.pub

# Empreinte d'une clé de serveur
ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

💡 **Format visuel de l'empreinte** : SSH peut afficher une "randomart" visuelle de la clé.

```bash
ssh-keygen -lvf ~/.ssh/id_ed25519.pub
```

---

## #️⃣ Fonctions de hachage

### Qu'est-ce que c'est ?

Une fonction de hachage cryptographique transforme des données de **taille arbitraire** en une **empreinte de taille fixe** (le hash ou condensat). C'est une fonction à **sens unique** : facile à calculer, impossible à inverser.

> [!info] Analogie C'est comme prendre les empreintes digitales d'un document : elles identifient de manière unique le document, mais vous ne pouvez pas reconstruire le document à partir des empreintes.

### Propriétés essentielles

Une bonne fonction de hachage cryptographique doit être :

1. **Déterministe** : La même entrée produit toujours le même hash
2. **Rapide à calculer** : Le hash peut être calculé efficacement
3. **Résistante aux collisions** : Trouver deux entrées différentes qui produisent le même hash doit être quasi impossible
4. **À sens unique** : Impossible de retrouver l'entrée à partir du hash
5. **Effet avalanche** : Un petit changement dans l'entrée change complètement le hash

```bash
# Exemple avec SHA-256
echo "Bonjour" | sha256sum
# Résultat : 8df3a89fa4627b2b947868e984f5e3a2fc74b4cc7a8d3f3d2c03e4e2f4c5f3a1

echo "Bonjour!" | sha256sum  # Juste un "!" ajouté
# Résultat : complètement différent !
```

### Pourquoi c'est important dans SSH ?

Les fonctions de hachage dans SSH sont utilisées pour :

1. **Vérifier l'intégrité des données** : S'assurer que les données n'ont pas été modifiées en transit
2. **Créer des signatures numériques** : Signer les messages d'authentification
3. **Dériver des clés** : Générer des clés de session à partir du secret partagé (Diffie-Hellman)
4. **HMAC (Hash-based Message Authentication Code)** : Authentifier les messages

> [!tip] Intégrité vs Confidentialité Le hachage garantit l'**intégrité** (les données n'ont pas été modifiées), pas la **confidentialité** (les données ne sont pas lisibles). Pour la confidentialité, on utilise le chiffrement.

### Algorithmes utilisés dans SSH

|Algorithme|Taille du hash|Usage dans SSH|Sécurité|
|---|---|---|---|
|**SHA-256**|256 bits|HMAC, signatures, dérivation de clés|Très élevée|
|**SHA-512**|512 bits|HMAC, signatures, dérivation de clés|Très élevée|
|**SHA-1**|160 bits|Obsolète dans SSH moderne|Faible (collisions trouvées)|
|**MD5**|128 bits|Obsolète, interdit|Très faible (à éviter)|

> [!warning] SHA-1 et MD5 Ces algorithmes ne doivent plus être utilisés pour la sécurité. SSH moderne les a désactivés par défaut.

### Comment ça fonctionne dans SSH ?

#### 1. HMAC pour l'intégrité des messages

Chaque message SSH est accompagné d'un HMAC (Message Authentication Code basé sur un hash) :

```
Message original + Clé secrète → Fonction de hachage → HMAC
```

Le destinataire recalcule le HMAC avec sa clé et le compare. Si les HMAC correspondent, le message n'a pas été altéré.

```
Client SSH                                    Serveur SSH
    |                                              |
    |  Message + HMAC(message, clé_session)        |
    |--------------------------------------------->|
    |                                              |
    |  Le serveur recalcule le HMAC                |
    |  et vérifie qu'il correspond                 |
    |  → Intégrité confirmée                       |
    |                                              |
```

#### 2. Empreintes de clés (fingerprints)

Les clés SSH sont longues. Pour les vérifier facilement, on utilise leur empreinte (hash de la clé) :

```bash
# Afficher l'empreinte d'une clé
ssh-keygen -lf ~/.ssh/id_ed25519.pub
# Sortie : 256 SHA256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx user@host (ED25519)
```

Cette empreinte est affichée lors de la première connexion à un serveur.

#### 3. Dérivation de clés

SSH utilise des fonctions de hachage (via HMAC) pour dériver plusieurs clés à partir du secret partagé obtenu par Diffie-Hellman :

```
Secret partagé DH → SHA-256/SHA-512 → Clés de chiffrement
                                   → Clés d'intégrité (HMAC)
                                   → Vecteurs d'initialisation
```

### Configuration dans SSH

Les algorithmes HMAC disponibles sont listés dans la configuration SSH :

```bash
# Voir les algorithmes MAC supportés
ssh -Q mac

# Forcer l'utilisation d'un MAC spécifique
ssh -o MACs=hmac-sha2-512 user@host
```

Configuration dans `/etc/ssh/sshd_config` (serveur) ou `~/.ssh/config` (client) :

```bash
# Définir les algorithmes MAC autorisés
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256
```

> [!info] ETM (Encrypt-Then-Mac) Les algorithmes avec le suffixe `@openssh.com` ou `-etm` utilisent le mode "Encrypt-Then-Mac", qui est plus sûr que "Mac-Then-Encrypt". Le MAC est calculé sur le texte chiffré, pas le texte clair.

### Exemple pratique : Vérifier l'intégrité d'une clé

```bash
# Calculer l'empreinte SHA-256 d'une clé publique
ssh-keygen -lf ~/.ssh/id_ed25519.pub -E sha256

# Calculer l'empreinte MD5 (ancien format, pour compatibilité)
ssh-keygen -lf ~/.ssh/id_ed25519.pub -E md5

# Comparer avec l'empreinte affichée sur GitHub, GitLab, etc.
```

### Pièges courants

❌ **Confondre hash et chiffrement** : Le hachage est à sens unique (irréversible), le chiffrement est réversible (avec la clé).

❌ **Utiliser MD5 ou SHA-1** : Ces algorithmes sont obsolètes et vulnérables. Utilisez au minimum SHA-256.

❌ **Ne pas vérifier les empreintes** : Lors de la première connexion, vérifiez toujours l'empreinte du serveur (si possible via un canal sécurisé séparé).

❌ **Penser que le HMAC seul suffit** : Le HMAC garantit l'intégrité, mais pas la confidentialité. Il faut également du chiffrement.

### Astuces

💡 **Visualiser le hash d'une clé** : Pour vérifier visuellement si deux clés sont identiques.

```bash
# Empreinte textuelle
ssh-keygen -lf ~/.ssh/id_ed25519.pub

# Empreinte visuelle (randomart)
ssh-keygen -lvf ~/.ssh/id_ed25519.pub
```

💡 **HMAC-SHA2-512-ETM** : C'est le meilleur choix actuel pour l'intégrité des messages SSH.

💡 **Vérifier quel MAC est utilisé** : Utilisez `ssh -v` pour voir l'algorithme MAC négocié.

```bash
ssh -v user@host 2>&1 | grep "MAC:"
```

💡 **Hacher des fichiers localement** : Pour vérifier qu'un fichier n'a pas été modifié.

```bash
# Calculer le hash SHA-256 d'un fichier
sha256sum fichier.txt

# Vérifier avec un hash connu
echo "hash_connu  fichier.txt" | sha256sum -c
```

💡 **known_hosts et hashes** : Le fichier `~/.ssh/known_hosts` peut stocker les hôtes de manière hachée pour plus de confidentialité.

```bash
# Activer le hachage des noms d'hôtes dans known_hosts
ssh-keygen -H -f ~/.ssh/known_hosts

# Rechercher un hôte dans known_hosts haché
ssh-keygen -F example.com
```

---

## 🔀 Échange de clés Diffie-Hellman

### Qu'est-ce que c'est ?

Diffie-Hellman (DH) est un **protocole d'échange de clés** qui permet à deux parties de créer un **secret partagé** sur un canal non sécurisé, sans jamais transmettre ce secret directement.

> [!info] Analogie des couleurs Imaginez que vous et votre interlocuteur choisissez chacun une couleur secrète. Vous mélangez votre couleur avec une couleur publique commune (visible par tous), puis vous échangez les résultats. En mélangeant ce que vous recevez avec votre couleur secrète initiale, vous obtenez tous les deux la même couleur finale, mais personne d'autre ne peut la reconstruire.

### Pourquoi c'est important dans SSH ?

L'échange de clés Diffie-Hellman résout **le problème fondamental de la cryptographie symétrique** : comment partager une clé secrète de manière sécurisée ?

Dans SSH, DH permet de :

1. **Générer une clé de session partagée** entre le client et le serveur
2. **Assurer le Perfect Forward Secrecy (PFS)** : Même si la clé privée du serveur est compromise plus tard, les sessions passées restent sécurisées
3. **Établir un canal sécurisé** avant même l'authentification

> [!tip] Perfect Forward Secrecy Avec DH, chaque session SSH utilise une clé de session unique et temporaire. Même si un attaquant enregistre le trafic et obtient plus tard les clés privées, il ne pourra pas déchiffrer les anciennes sessions.

### Principe mathématique simplifié

Diffie-Hellman repose sur l'exponentiation modulaire, un problème mathématique difficile à inverser :

```
1. Alice et Bob se mettent d'accord publiquement sur :
   - Un grand nombre premier p (modulo)
   - Un générateur g

2. Alice choisit un nombre secret a
   → Calcule A = g^a mod p
   → Envoie A à Bob (public)

3. Bob choisit un nombre secret b
   → Calcule B = g^b mod p
   → Envoie B à Alice (public)

4. Alice calcule : secret = B^a mod p = (g^b)^a mod p = g^(ab) mod p
   Bob calcule : secret = A^b mod p = (g^a)^b mod p = g^(ab) mod p

5. Alice et Bob ont le même secret partagé : g^(ab) mod p
   Un espion qui voit g, p, A et B ne peut pas retrouver ce secret
```

> [!warning] En pratique SSH utilise des variantes modernes de DH plus performantes et sûres, notamment ECDH (Elliptic Curve Diffie-Hellman) et Curve25519.

### Comment ça fonctionne dans SSH ?

```
Client SSH                                    Serveur SSH
    |                                              |
    |  1. Négociation de l'algorithme DH           |
    |     (ex: curve25519-sha256)                  |
    |<-------------------------------------------->|
    |                                              |
    |  2. Le client génère un nombre secret        |
    |     et calcule sa clé publique DH            |
    |                                              |
    |  3. Le serveur génère un nombre secret       |
    |     et calcule sa clé publique DH            |
    |                                              |
    |  4. Échange des clés publiques DH            |
    |<-------------------------------------------->|
    |                                              |
    |  5. Le serveur signe l'échange avec          |
    |     sa clé privée (host key)                 |
    |<---------------------------------------------|
    |                                              |
    |  6. Chacun calcule le secret partagé         |
    |     (sans jamais le transmettre !)           |
    |                                              |
    |  7. Dérivation de la clé de session          |
    |     symétrique à partir du secret            |
    |                                              |
    |  8. Activation du chiffrement symétrique     |
    |<=============================================>|
```

> [!example] Visualisation C'est comme si le client et le serveur construisaient chacun la moitié d'un pont depuis leur rive. Les deux moitiés se rejoignent au milieu pour former un passage sécurisé, sans qu'aucune moitié complète n'ait jamais traversé la rivière.

### Algorithmes d'échange de clés dans SSH

|Algorithme|Type|Sécurité|Performance|Recommandation|
|---|---|---|---|---|
|**curve25519-sha256**|ECDH|Très élevée|Excellente|✅ Premier choix|
|**ecdh-sha2-nistp256**|ECDH|Élevée|Très bonne|✅ Bon choix|
|**ecdh-sha2-nistp384**|ECDH|Très élevée|Bonne|✅ Bon choix|
|**ecdh-sha2-nistp521**|ECDH|Très élevée|Bonne|✅ Bon choix|
|**diffie-hellman-group16-sha512**|DH classique|Élevée|Moyenne|⚠️ Acceptable|
|**diffie-hellman-group14-sha256**|DH classique|Moyenne|Moyenne|⚠️ Acceptable|
|**diffie-hellman-group1-sha1**|DH classique|Faible|Moyenne|❌ Obsolète|

> [!tip] Curve25519 **curve25519-sha256@libssh.org** est l'algorithme d'échange de clés le plus recommandé en 2024 : rapide, sûr, et résistant à de nombreuses attaques.

### Configuration dans SSH

```bash
# Voir les algorithmes d'échange de clés supportés
ssh -Q kex

# Forcer l'utilisation d'un algorithme spécifique
ssh -o KexAlgorithms=curve25519-sha256 user@host
```

Configuration dans `/etc/ssh/sshd_config` (serveur) ou `~/.ssh/config` (client) :

```bash
# Définir
```