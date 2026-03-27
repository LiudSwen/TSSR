
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

## 🔄 Cryptographie symétrique vs asymétrique

### 📘 Cryptographie symétrique

La cryptographie symétrique utilise **une seule clé** pour chiffrer et déchiffrer les données. C'est comme utiliser la même clé pour verrouiller et déverrouiller un coffre-fort.

> [!info] Principe fondamental **Émetteur et récepteur partagent la même clé secrète**. Cette clé doit être transmise de manière sécurisée avant toute communication.

#### Caractéristiques principales

|Aspect|Description|
|---|---|
|**Vitesse**|Très rapide, idéal pour chiffrer de grandes quantités de données|
|**Complexité**|Algorithmes simples et efficaces|
|**Gestion des clés**|Problématique : nécessite une clé unique par paire de communicants|
|**Sécurité**|Dépend entièrement du secret de la clé partagée|

#### Algorithmes courants

- **AES** (Advanced Encryption Standard) : Standard actuel, très sécurisé
- **DES/3DES** : Anciens standards, obsolètes
- **ChaCha20** : Alternative moderne à AES

> [!example] Cas d'usage typique Le chiffrement de fichiers sur un disque dur utilise la cryptographie symétrique car une seule personne (vous) a besoin d'accéder aux données.

> [!warning] Le problème de distribution des clés Comment transmettre la clé secrète de manière sécurisée ? Si quelqu'un intercepte la clé pendant la transmission, toute la sécurité est compromise. C'est le **problème fondamental** de la cryptographie symétrique.

---

### 🔑 Cryptographie asymétrique

La cryptographie asymétrique utilise **une paire de clés** : une clé publique et une clé privée. Ces deux clés sont mathématiquement liées mais il est impossible (en pratique) de déduire l'une à partir de l'autre.

> [!info] Principe fondamental Ce qui est chiffré avec la **clé publique** ne peut être déchiffré qu'avec la **clé privée** correspondante, et vice versa.

#### Caractéristiques principales

|Aspect|Description|
|---|---|
|**Vitesse**|Beaucoup plus lent que la cryptographie symétrique|
|**Complexité**|Algorithmes mathématiques complexes (exponentiation modulaire, courbes elliptiques)|
|**Gestion des clés**|Simplifiée : la clé publique peut être diffusée librement|
|**Sécurité**|Basée sur des problèmes mathématiques difficiles à résoudre|

#### Algorithmes courants

- **RSA** : Le plus répandu, basé sur la factorisation de grands nombres
- **ECDSA** (Elliptic Curve Digital Signature Algorithm) : Plus efficace, clés plus courtes
- **Ed25519** : Variante moderne d'ECDSA, très rapide

> [!example] Cas d'usage typique HTTPS utilise la cryptographie asymétrique pour échanger de manière sécurisée une clé symétrique, qui sera ensuite utilisée pour chiffrer les données de la session.

---

### 🔀 Comparaison et utilisation combinée

> [!tip] La meilleure des deux approches Dans la pratique, on combine les deux types de cryptographie :
> 
> - **Asymétrique** : pour échanger de manière sécurisée une clé symétrique
> - **Symétrique** : pour chiffrer les données volumineuses avec cette clé

**Exemple concret avec HTTPS :**

1. Le serveur envoie sa clé publique au client
2. Le client génère une clé symétrique aléatoire
3. Le client chiffre cette clé avec la clé publique du serveur
4. Le serveur déchiffre avec sa clé privée pour obtenir la clé symétrique
5. Les deux parties utilisent maintenant cette clé symétrique pour communiquer rapidement

|Critère|Symétrique|Asymétrique|
|---|---|---|
|**Vitesse d'exécution**|⚡ Très rapide|🐢 Lent (100 à 1000x plus lent)|
|**Taille des clés**|128-256 bits|2048-4096 bits (RSA) ou 256 bits (ECDSA)|
|**Distribution des clés**|❌ Problématique|✅ Facile (clé publique diffusable)|
|**Usage principal**|Chiffrement de données volumineuses|Échange de clés, signatures numériques|
|**Nombre de clés nécessaires**|n(n-1)/2 pour n utilisateurs|2n pour n utilisateurs (une paire par utilisateur)|

---

## 🔐 Concept de clé publique et clé privée

### 🎯 Principe fondamental

Une **paire de clés asymétrique** est composée de deux clés mathématiquement liées mais distinctes :

- **Clé privée** : Gardée secrète, ne doit jamais être partagée
- **Clé publique** : Peut être diffusée librement à tout le monde

> [!info] Relation mathématique Les clés sont générées ensemble par un algorithme qui garantit une propriété cruciale : ce qui est chiffré avec l'une ne peut être déchiffré qu'avec l'autre.

---

### 🔓 Clé publique

**Rôle :** Accessible à tous, utilisée pour :

- **Chiffrer** des messages destinés au propriétaire de la clé privée
- **Vérifier** les signatures numériques créées avec la clé privée

> [!example] Analogie avec une boîte aux lettres La clé publique est comme une fente de boîte aux lettres : tout le monde peut y déposer un message, mais seul le propriétaire (avec la clé privée) peut ouvrir la boîte et lire les messages.

**Caractéristiques :**

- Peut être publiée sur un serveur de clés
- Peut être envoyée par email sans risque
- Identifie mathématiquement son propriétaire
- Ne compromet pas la sécurité si elle est interceptée

---

### 🔒 Clé privée

**Rôle :** Strictement confidentielle, utilisée pour :

- **Déchiffrer** des messages chiffrés avec la clé publique correspondante
- **Signer** des documents pour prouver l'authenticité et l'intégrité

> [!warning] Sécurité critique **La clé privée ne doit JAMAIS être partagée, transmise ou stockée sans protection.** Si elle est compromise, toute la sécurité est perdue.

**Bonnes pratiques de protection :**

- Protégée par un mot de passe fort (passphrase)
- Stockée dans un emplacement sécurisé
- Sauvegardée de manière chiffrée
- Jamais copiée sur des systèmes non sécurisés
- Révoquée immédiatement en cas de suspicion de compromission

---

### 🔄 Les deux usages de la paire de clés

#### 1️⃣ Chiffrement (confidentialité)

**Flux de chiffrement :**

```
Alice veut envoyer un message confidentiel à Bob

1. Alice obtient la clé publique de Bob
2. Alice chiffre le message avec cette clé publique
3. Alice envoie le message chiffré (peut être intercepté sans risque)
4. Bob déchiffre avec sa clé privée
5. Bob est le SEUL à pouvoir lire le message
```

> [!tip] Garantie Ce mécanisme assure la **confidentialité** : seul le destinataire peut lire le message.

#### 2️⃣ Signature (authenticité et intégrité)

**Flux de signature :**

```
Bob veut prouver qu'il est l'auteur d'un document

1. Bob crée un condensé (hash) du document
2. Bob chiffre ce condensé avec sa clé privée = SIGNATURE
3. Bob envoie le document + la signature
4. Alice obtient la clé publique de Bob
5. Alice vérifie la signature avec cette clé publique
6. Si la vérification réussit : le document vient bien de Bob et n'a pas été modifié
```

> [!tip] Garanties Ce mécanisme assure :
> 
> - **Authenticité** : la signature prouve l'identité de l'émetteur
> - **Intégrité** : toute modification du document invalide la signature
> - **Non-répudiation** : Bob ne peut pas nier avoir signé le document

---

### 🛠️ Génération d'une paire de clés

> [!example] Exemple avec OpenSSL (RSA 4096 bits)
> 
> ```bash
> # Générer une clé privée RSA de 4096 bits, protégée par AES-256
> openssl genrsa -aes256 -out private_key.pem 4096
> 
> # Extraire la clé publique correspondante
> openssl rsa -in private_key.pem -pubout -out public_key.pem
> 
> # Afficher les détails de la clé privée
> openssl rsa -in private_key.pem -text -noout
> ```

> [!example] Exemple avec OpenSSL (ECDSA - courbes elliptiques)
> 
> ```bash
> # Générer une clé privée ECDSA (courbe prime256v1)
> openssl ecparam -name prime256v1 -genkey -noout -out private_key_ec.pem
> 
> # Protéger la clé avec un mot de passe
> openssl ec -in private_key_ec.pem -aes256 -out private_key_ec_encrypted.pem
> 
> # Extraire la clé publique
> openssl ec -in private_key_ec.pem -pubout -out public_key_ec.pem
> ```

---

### 📊 Formats de clés

|Format|Extension|Usage|Caractéristiques|
|---|---|---|---|
|**PEM**|.pem, .crt, .key|Le plus courant|Base64, lisible texte, délimité par BEGIN/END|
|**DER**|.der, .cer|Binaire|Format binaire compact, utilisé par Java|
|**PKCS#12**|.p12, .pfx|Conteneur|Inclut clé privée + certificat + chaîne, protégé par mot de passe|
|**OpenSSH**|.pub|Clés SSH|Format spécifique pour SSH (ssh-rsa, ssh-ed25519)|

> [!info] Format PEM (Privacy Enhanced Mail) C'est le format le plus répandu. Une clé PEM ressemble à :
> 
> ```
> -----BEGIN PRIVATE KEY-----
> MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC7...
> -----END PRIVATE KEY-----
> ```

---

### ⚠️ Pièges courants

> [!warning] Confusions fréquentes
> 
> - **❌ Erreur** : Envoyer sa clé privée pour qu'on puisse la "déchiffrer"
>     - **✅ Correct** : Seule la clé publique doit être envoyée
> - **❌ Erreur** : Penser que chiffrer avec la clé privée garantit la confidentialité
>     - **✅ Correct** : Chiffrer avec la clé privée = signer (tout le monde peut vérifier avec la clé publique)
> - **❌ Erreur** : Stocker la clé privée en clair sans protection
>     - **✅ Correct** : Toujours protéger avec un mot de passe fort

---

## #️⃣ Fonction de hachage

### 🎯 Définition et principe

Une **fonction de hachage cryptographique** est une fonction mathématique qui transforme des données de taille arbitraire en une empreinte (hash/condensé) de taille fixe.

> [!info] Propriétés fondamentales Une bonne fonction de hachage cryptographique doit être :
> 
> 1. **Déterministe** : même entrée → toujours même sortie
> 2. **À sens unique** : impossible de retrouver l'entrée à partir du hash
> 3. **Résistante aux collisions** : pratiquement impossible de trouver deux entrées différentes donnant le même hash
> 4. **Effet avalanche** : un changement minime dans l'entrée change radicalement le hash

---

### 🔍 Caractéristiques techniques

#### Taille fixe du hash

Peu importe la taille du fichier d'entrée (1 Ko ou 1 Go), le hash a toujours la même longueur :

|Algorithme|Taille du hash|Usage actuel|
|---|---|---|
|**MD5**|128 bits (32 caractères hexa)|❌ Obsolète, compromis|
|**SHA-1**|160 bits (40 caractères hexa)|⚠️ Déconseillé depuis 2017|
|**SHA-256**|256 bits (64 caractères hexa)|✅ Standard actuel|
|**SHA-512**|512 bits (128 caractères hexa)|✅ Très sécurisé|
|**SHA-3**|Variable (224, 256, 384, 512 bits)|✅ Standard moderne|

> [!example] Exemple concret
> 
> ```bash
> # Hash SHA-256 d'un texte simple
> echo "Bonjour" | sha256sum
> # Résultat : 4eb50ab1417c1a8f0e8a7f0e5c8f3c9d...
> 
> # Hash SHA-256 d'un fichier entier
> sha256sum fichier.iso
> # Résultat : 8f434346648f6b96df89dda901c5176b...
> ```

---

### 🎯 Usages des fonctions de hachage

#### 1️⃣ Vérification d'intégrité

**Scénario :** Vérifier qu'un fichier téléchargé n'a pas été corrompu ou modifié.

```bash
# Le site web publie le hash du fichier
SHA256: a3b5c8d9e1f2a3b4c5d6e7f8a9b0c1d2...

# Après téléchargement, vous calculez le hash
sha256sum ubuntu-22.04.iso

# Si les hash correspondent → fichier intègre
# Si différents → fichier corrompu ou modifié
```

> [!tip] Garantie d'intégrité Même un seul bit modifié dans le fichier produit un hash complètement différent grâce à l'effet avalanche.

---

#### 2️⃣ Stockage sécurisé des mots de passe

**Problème :** Comment stocker les mots de passe sans les conserver en clair ?

**Solution :** Stocker le hash du mot de passe.

```
Utilisateur crée un compte avec le mot de passe "MonMotDePasse123"
↓
Serveur calcule : hash = SHA-256("MonMotDePasse123")
↓
Serveur stocke uniquement le hash (pas le mot de passe)
↓
Lors de la connexion, le serveur compare :
SHA-256(mot de passe saisi) == hash stocké ?
```

> [!warning] Problème des rainbow tables Des attaquants peuvent précalculer les hash de millions de mots de passe courants (rainbow tables). Solution : utiliser un **sel (salt)** unique par utilisateur.

**Avec sel :**

```
hash = SHA-256(mot_de_passe + sel_aléatoire)
```

> [!tip] Fonctions modernes pour les mots de passe Pour les mots de passe, on utilise des fonctions spécialisées plus lentes intentionnellement :
> 
> - **bcrypt** : Standard actuel
> - **Argon2** : Gagnant du Password Hashing Competition (2015)
> - **scrypt** : Résistant aux attaques matérielles

---

#### 3️⃣ Signatures numériques

Les fonctions de hachage sont essentielles pour les signatures numériques (voir section suivante).

**Processus :**

1. Calculer le hash du document (rapide même pour un gros fichier)
2. Chiffrer ce hash avec la clé privée (signature)
3. Joindre la signature au document

> [!info] Pourquoi hacher avant de signer ?
> 
> - **Performance** : chiffrer un hash de 256 bits est beaucoup plus rapide que chiffrer un document de plusieurs Mo
> - **Taille** : la signature a une taille fixe quelle que soit la taille du document

---

#### 4️⃣ Proof of Work (blockchain)

Les blockchains comme Bitcoin utilisent les fonctions de hachage pour le consensus.

**Principe :**

- Trouver un nombre (nonce) tel que le hash du bloc commence par un certain nombre de zéros
- Cela nécessite des milliards de tentatives (travail computationnel)
- La vérification est instantanée

---

### 🛠️ Utilisation pratique

> [!example] Calculer des hash avec OpenSSL
> 
> ```bash
> # Hash SHA-256 d'un fichier
> openssl dgst -sha256 fichier.pdf
> 
> # Hash SHA-512 d'un texte
> echo -n "Mon message" | openssl dgst -sha512
> 
> # Hash MD5 (pour compatibilité ancienne uniquement)
> openssl dgst -md5 fichier.zip
> 
> # Vérifier l'intégrité d'un fichier
> echo "hash_attendu  fichier.iso" | sha256sum --check
> ```

> [!example] Avec les outils système
> 
> ```bash
> # Linux/macOS
> sha256sum fichier.tar.gz
> sha512sum document.pdf
> md5sum image.jpg
> 
> # macOS uniquement
> shasum -a 256 fichier.dmg
> 
> # Vérification automatique
> sha256sum -c checksums.txt
> ```

---

### ⚙️ Propriétés détaillées

#### Effet avalanche

Un changement infime dans l'entrée modifie radicalement le hash :

```bash
echo -n "bonjour" | sha256sum
# c66166...(reste du hash)

echo -n "Bonjour" | sha256sum  # Juste une majuscule
# 4eb50a...(complètement différent)
```

> [!info] Importance Cette propriété permet de détecter la moindre altération d'un fichier ou d'un message.

#### Résistance aux collisions

**Collision :** deux entrées différentes produisant le même hash.

- **MD5** : collisions trouvées en 2004 (❌ compromis)
- **SHA-1** : première collision pratique en 2017 (⚠️ obsolète)
- **SHA-256/SHA-3** : aucune collision connue (✅ sûr)

> [!tip] Paradoxe des anniversaires Avec SHA-256 (2^256 possibilités), il faudrait calculer environ 2^128 hash pour avoir 50% de chance de trouver une collision par hasard. C'est computationnellement impossible avec la technologie actuelle.

---

### ⚠️ Pièges et erreurs courantes

> [!warning] Erreurs à éviter
> 
> - **❌** Utiliser MD5 ou SHA-1 pour la sécurité (seulement acceptable pour checksum non-critique)
> - **❌** Confondre hachage et chiffrement (le hachage est irréversible)
> - **❌** Hacher des mots de passe avec SHA-256 simple (utiliser bcrypt/Argon2)
> - **❌** Penser qu'un hash long = plus sécurisé nécessairement (SHA-512 vs SHA-256)

> [!tip] Bonnes pratiques
> 
> - ✅ Utiliser SHA-256 minimum pour la sécurité
> - ✅ Ajouter un sel aléatoire pour les mots de passe
> - ✅ Utiliser des fonctions spécialisées (bcrypt, Argon2) pour les mots de passe
> - ✅ Vérifier systématiquement les hash des fichiers téléchargés

---

## ✍️ Signature numérique

### 🎯 Définition et principe

Une **signature numérique** est l'équivalent électronique d'une signature manuscrite ou d'un sceau. Elle permet de :

- **Authentifier** l'auteur du document
- **Garantir l'intégrité** du document (détection de toute modification)
- **Assurer la non-répudiation** (l'auteur ne peut nier avoir signé)

> [!info] Principe fondamental Une signature numérique est créée en chiffrant le **hash d'un document** avec la **clé privée** de l'émetteur. N'importe qui peut vérifier la signature avec la clé publique correspondante.

---

### 🔄 Processus de signature et vérification

#### 📝 Création d'une signature

```
1. Alice a un document à signer
   ↓
2. Calcul du hash du document (SHA-256)
   Document → [Fonction de hachage] → Hash (256 bits)
   ↓
3. Chiffrement du hash avec la clé privée d'Alice
   Hash → [Clé privée d'Alice] → SIGNATURE
   ↓
4. La signature est jointe au document
   Document + Signature → Envoyé à Bob
```

#### ✅ Vérification d'une signature

```
1. Bob reçoit le document + signature
   ↓
2. Extraction de la signature et déchiffrement avec la clé publique d'Alice
   Signature → [Clé publique d'Alice] → Hash_déchiffré
   ↓
3. Calcul du hash du document reçu
   Document → [Fonction de hachage] → Hash_calculé
   ↓
4. Comparaison des deux hash
   Si Hash_déchiffré == Hash_calculé → ✅ Signature valide
   Si différents → ❌ Signature invalide ou document modifié
```

> [!tip] Ce que garantit une signature valide
> 
> - ✅ Le document provient bien d'Alice (authenticité)
> - ✅ Le document n'a pas été modifié (intégrité)
> - ✅ Alice ne peut pas nier avoir signé (non-répudiation)

---

### 🔐 Propriétés cryptographiques

#### Authenticité

La signature prouve l'identité du signataire car :

- Seul le possesseur de la clé privée peut créer la signature
- La clé publique identifie de manière unique le signataire

> [!example] Analogie Comme une signature manuscrite, mais impossible à falsifier mathématiquement.

#### Intégrité

La moindre modification du document invalide la signature :

```bash
# Document original
echo "Contrat : Je paie 1000€" > contrat.txt
openssl dgst -sha256 -sign private_key.pem -out signature.bin contrat.txt

# Modification du document
echo "Contrat : Je paie 10000€" > contrat.txt

# Vérification
openssl dgst -sha256 -verify public_key.pem -signature signature.bin contrat.txt
# Résultat : Verification Failure (❌)
```

> [!info] Effet avalanche appliqué Grâce à la fonction de hachage, modifier un seul caractère change complètement le hash, rendant la signature invalide.

#### Non-répudiation

Une fois qu'un document est signé :

- Le signataire ne peut pas prétendre ne pas l'avoir signé
- Comparable à une signature devant notaire dans le monde physique

> [!warning] Condition critique La non-répudiation n'est garantie que si la clé privée n'a pas été compromise. D'où l'importance de protéger rigoureusement sa clé privée.

---

### 🛠️ Mise en pratique

#### Signer un document avec OpenSSL

> [!example] Signature RSA
> 
> ```bash
> # 1. Générer une paire de clés (si pas déjà fait)
> openssl genrsa -out private_key.pem 4096
> openssl rsa -in private_key.pem -pubout -out public_key.pem
> 
> # 2. Créer le document
> echo "Contrat important" > document.txt
> 
> # 3. Signer le document (SHA-256 + RSA)
> openssl dgst -sha256 -sign private_key.pem \
>   -out document.sig document.txt
> 
> # 4. Vérifier la signature
> openssl dgst -sha256 -verify public_key.pem \
>   -signature document.sig document.txt
> # Résultat : Verified OK (✅)
> ```

> [!example] Signature avec courbes elliptiques (ECDSA)
> 
> ```bash
> # 1. Générer une paire de clés ECDSA
> openssl ecparam -name prime256v1 -genkey -noout -out ec_private.pem
> openssl ec -in ec_private.pem -pubout -out ec_public.pem
> 
> # 2. Signer
> openssl dgst -sha256 -sign ec_private.pem \
>   -out document_ec.sig document.txt
> 
> # 3. Vérifier
> openssl dgst -sha256 -verify ec_public.pem \
>   -signature document_ec.sig document.txt
> ```

---

#### Formats de signature

|Format|Description|Usage|
|---|---|---|
|**PKCS#7**|Format conteneur (signature + certificats)|Signatures S/MIME email|
|**CMS**|Cryptographic Message Syntax|Standard moderne, emails signés|
|**PGP**|Pretty Good Privacy|Signatures de fichiers, emails|
|**XMLDSig**|XML Digital Signature|Documents XML, SOAP|
|**JWS**|JSON Web Signature|API REST, JWT tokens|

---

### 📧 Cas d'usage : Email signé

**Protocole S/MIME** (Secure/Multipurpose Internet Mail Extensions)

```
1. Alice compose un email
   ↓
2. Son client email calcule le hash du message
   ↓
3. Le hash est signé avec la clé privée d'Alice
   ↓
4. Email + Signature + Certificat d'Alice → Envoyé à Bob
   ↓
5. Le client de Bob vérifie la signature avec le certificat d'Alice
   ↓
6. Bob voit un indicateur ✅ prouvant que l'email vient bien d'Alice
```

> [!tip] Avantages
> 
> - Protection contre le phishing (usurpation d'identité)
> - Garantie que l'email n'a pas été modifié en transit
> - Possible de répondre de manière chiffrée

---

### 📄 Cas d'usage : Signature de code

**Code Signing** : signer des logiciels, pilotes, scripts

**Pourquoi ?**

- Assurer que le logiciel provient de l'éditeur légitime
- Garantir qu'il n'a pas été modifié par un malware
- Requis par les systèmes d'exploitation modernes (Windows, macOS, Android)

```bash
# Exemple : Signer un binaire Windows
signtool sign /f certificat.pfx /p motdepasse \
  /t http://timestamp.server.com /v application.exe

# Vérifier la signature
signtool verify /pa /v application.exe
```

> [!info] Timestamp Un horodatage cryptographique prouve que la signature a été créée à un moment donné, même si le certificat expire plus tard.

---

### 🔍 Différence signature vs chiffrement

> [!warning] Confusion fréquente Signer ≠ Chiffrer. Ce sont deux opérations distinctes avec des objectifs différents.

|Aspect|Signature|Chiffrement|
|---|---|---|
|**Objectif**|Authenticité + Intégrité|Confidentialité|
|**Clé utilisée**|Clé privée pour signer|Clé publique pour chiffrer|
|**Qui peut vérifier/lire**|Tout le monde (clé publique)|Seulement le destinataire (clé privée)|
|**Document lisible**|✅ Oui, en clair|❌ Non, chiffré|
|**Protection contre**|Modification, usurpation|Interception, lecture|

**Combinaison possible :**

```
1. Alice chiffre le document avec la clé publique de Bob (confidentialité)
2. Alice signe le document chiffré avec sa clé privée (authenticité)
3. Bob déchiffre avec sa clé privée (lecture)
4. Bob vérifie la signature avec la clé publique d'Alice (authentification)
```

---

### 🎨 Schéma récapitulatif

```
SIGNATURE NUMÉRIQUE
===================

CRÉATION (Alice signe) :
Document → Hash (SHA-256) → Chiffrement (Clé privée Alice) → Signature
                ↓
           256 bits
                ↓
        [Document + Signature] → Envoi à Bob


VÉRIFICATION (Bob vérifie) :
Document reçu → Hash (SHA-256) → Hash_calculé
                                      ↓
Signature → Déchiffrement (Clé publique Alice) → Hash_déchiffré
                                      ↓
              Hash_calculé == Hash_déchiffré ?
                    ↓                    ↓
                  OUI ✅               NON ❌
            Signature valide      Signature invalide
```

---

### ⚙️ Standards et algorithmes

#### Algorithmes de signature courants

|Algorithme|Basé sur|Taille clé|Taille signature|Usage actuel|
|---|---|---|---|---|
|**RSA**|Factorisation|2048-4096 bits|256-512 octets|✅ Très répandu|
|**ECDSA**|Courbes elliptiques|256-384 bits|64-96 octets|✅ Standard moderne|
|**Ed25519**|Courbes elliptiques (EdDSA)|256 bits|64 octets|✅ Haute performance|
|**DSA**|Logarithme discret|2048-3072 bits|320-512 octets|⚠️ En déclin|

> [!tip] Tendance actuelle Les algorithmes basés sur les courbes elliptiques (ECDSA, Ed25519) sont de plus en plus privilégiés car ils offrent le même niveau de sécurité avec des clés beaucoup plus courtes, donc des signatures plus petites et des calculs plus rapides.

#### Fonctions de hachage utilisées

Pour la signature, on combine l'algorithme de signature avec une fonction de hachage :

- **RSA-SHA256** : RSA avec hachage SHA-256
- **ECDSA-SHA384** : ECDSA avec hachage SHA-384
- **Ed25519** : Utilise SHA-512 en interne (pas besoin de spécifier)

> [!warning] Obsolescence
> 
> - **RSA-MD5** : ❌ Complètement compromis
> - **RSA-SHA1** : ❌ Obsolète depuis 2017
> - **DSA** : ⚠️ Déconseillé, utiliser ECDSA à la place

---

### 🔬 Exemples pratiques avancés

#### Signature et vérification d'un fichier PDF

> [!example] Workflow complet
> 
> ```bash
> # 1. Créer une signature détachée du PDF
> openssl dgst -sha256 -sign private_key.pem \
>   -out document.pdf.sig document.pdf
> 
> # 2. Encoder la signature en base64 (pour transmission email)
> base64 document.pdf.sig > document.pdf.sig.b64
> 
> # 3. Le destinataire décode la signature
> base64 -d document.pdf.sig.b64 > document.pdf.sig
> 
> # 4. Vérification
> openssl dgst -sha256 -verify public_key.pem \
>   -signature document.pdf.sig document.pdf
> ```

#### Signature de multiples fichiers

> [!example] Signer un ensemble de fichiers
> 
> ```bash
> # Créer un fichier de checksums
> sha256sum *.txt > checksums.txt
> 
> # Signer le fichier de checksums
> openssl dgst -sha256 -sign private_key.pem \
>   -out checksums.txt.sig checksums.txt
> 
> # Distribution : envoyer tous les .txt + checksums.txt + checksums.txt.sig
> 
> # Vérification côté destinataire
> # 1. Vérifier la signature du fichier checksums
> openssl dgst -sha256 -verify public_key.pem \
>   -signature checksums.txt.sig checksums.txt
> 
> # 2. Vérifier l'intégrité de chaque fichier
> sha256sum -c checksums.txt
> ```

---

### 📊 Comparaison signature manuscrite vs numérique

|Critère|Signature manuscrite|Signature numérique|
|---|---|---|
|**Falsification**|Possible avec habileté|Mathématiquement impossible|
|**Vérification**|Requiert expert en graphologie|Automatique et instantanée|
|**Intégrité du document**|Non garantie|Garantie (toute modification détectée)|
|**Copie**|L'original se distingue de la copie|Pas de différence (tout est numérique)|
|**Portée**|Locale (sur papier)|Globale (transmission électronique)|
|**Validité juridique**|Reconnue partout|Reconnue (eIDAS en EU, ESIGN aux USA)|

---

### 🎯 Scénarios d'utilisation

#### 1. Contrats électroniques

```
Cas d'usage : Signature d'un contrat de travail

1. RH prépare le contrat (PDF)
2. RH signe le contrat avec son certificat d'entreprise
3. Contrat envoyé au candidat
4. Candidat vérifie la signature (authenticité de l'entreprise)
5. Candidat signe à son tour avec son certificat personnel
6. Double signature → Contrat juridiquement valable
```

> [!info] Avantages
> 
> - Pas d'impression/scan nécessaire
> - Traçabilité complète (horodatage)
> - Archivage électronique sécurisé
> - Valeur légale équivalente au papier (UE : eIDAS, USA : ESIGN Act)

#### 2. Mise à jour logicielle

```
Cas d'usage : Distribution d'une mise à jour système

1. Éditeur compile la nouvelle version
2. Éditeur signe le binaire avec sa clé de code signing
3. Utilisateur télécharge la mise à jour
4. Système vérifie automatiquement la signature
5. Si signature invalide → Installation bloquée (protection malware)
6. Si signature valide → Installation autorisée
```

> [!tip] Sécurité renforcée Tous les systèmes modernes (Windows, macOS, Linux, Android, iOS) vérifient les signatures avant d'exécuter du code système.

#### 3. Git commits signés

```bash
# Configurer Git pour signer automatiquement
git config --global user.signingkey VOTRE_CLE_GPG
git config --global commit.gpgsign true

# Créer un commit signé
git commit -S -m "Fix security vulnerability"

# Vérifier les signatures
git log --show-signature

# Résultat :
# commit a3b5c7d9...
# gpg: Signature made 2025-12-29
# gpg: Good signature from "Alice <alice@example.com>"
```

> [!info] Pourquoi signer ses commits ?
> 
> - Prouve que le code vient bien de vous
> - Empêche l'usurpation d'identité (quelqu'un qui commiterait en votre nom)
> - Requis dans de nombreux projets open-source critiques (Linux, Kubernetes, etc.)

---

### ⚠️ Pièges et erreurs courantes

> [!warning] Erreurs fréquentes
> 
> **1. Confondre signature et chiffrement**
> 
> - ❌ "Je vais signer ce document pour que personne ne puisse le lire"
> - ✅ La signature n'apporte pas de confidentialité, le document reste lisible
> 
> **2. Penser que la signature protège le document**
> 
> - ❌ "Mon document est sécurisé car il est signé"
> - ✅ La signature détecte les modifications, elle ne les empêche pas
> 
> **3. Négliger la protection de la clé privée**
> 
> - ❌ Stocker la clé privée en clair sur un serveur partagé
> - ✅ Clé privée = votre identité numérique, protégez-la comme votre carte bancaire
> 
> **4. Oublier l'horodatage**
> 
> - ❌ Signer sans timestamp
> - ✅ Inclure un horodatage certifié pour prouver la date de signature
> 
> **5. Utiliser des algorithmes obsolètes**
> 
> - ❌ RSA-SHA1, DSA, MD5
> - ✅ RSA-SHA256 minimum, ou ECDSA/Ed25519

---

### 🎓 Bonnes pratiques

> [!tip] Recommandations essentielles
> 
> **Protection de la clé privée**
> 
> - ✅ Utilisez une passphrase forte (20+ caractères)
> - ✅ Stockez sur un support chiffré (HSM, TPM, ou au minimum clé chiffrée)
> - ✅ Ne partagez JAMAIS votre clé privée
> - ✅ Révoquez immédiatement en cas de compromission
> 
> **Choix des algorithmes**
> 
> - ✅ Privilégiez ECDSA ou Ed25519 pour les nouvelles implémentations
> - ✅ RSA 4096 bits minimum si RSA requis
> - ✅ SHA-256 ou SHA-384 pour le hachage
> - ✅ Évitez SHA-1, MD5, DSA
> 
> **Processus de signature**
> 
> - ✅ Incluez toujours un horodatage (TSA - Time Stamping Authority)
> - ✅ Utilisez des certificats valides et à jour
> - ✅ Documentez qui a signé quoi et quand
> - ✅ Conservez les preuves de signature (logs, certificats)
> 
> **Vérification**
> 
> - ✅ Vérifiez TOUJOURS les signatures reçues
> - ✅ Vérifiez la validité du certificat (non révoqué, dans les dates)
> - ✅ Vérifiez la chaîne de confiance complète
> - ✅ Méfiez-vous des certificats auto-signés (sauf contexte connu)

---

### 🔐 Signature vs MAC (Message Authentication Code)

> [!info] Différence importante Il existe une autre technique d'authentification : le **MAC** (HMAC notamment)

|Critère|Signature numérique|MAC (HMAC)|
|---|---|---|
|**Cryptographie**|Asymétrique (paire de clés)|Symétrique (clé partagée)|
|**Vérification**|Tout le monde (clé publique)|Seulement qui a la clé secrète|
|**Non-répudiation**|✅ Oui|❌ Non|
|**Performance**|Lent|Très rapide|
|**Usage typique**|Documents officiels, code|Sessions réseau, API|

**Exemple de MAC :**

```bash
# Créer un HMAC-SHA256
echo "message" | openssl dgst -sha256 -hmac "clé_secrète_partagée"

# Les deux parties peuvent calculer le même HMAC
# → Authentification mais pas de non-répudiation
```

> [!tip] Quand utiliser quoi ?
> 
> - **Signature** : Quand vous avez besoin de non-répudiation (contrats, code, emails officiels)
> - **MAC** : Quand seule l'authentification est nécessaire et que la performance compte (API, sessions, communications internes)

---

### 📚 Résumé de la section

> [!example] Points clés à retenir
> 
> **Définition**
> 
> - Signature = Hash du document chiffré avec la clé privée
> - Vérification = Déchiffrement avec la clé publique + comparaison des hash
> 
> **Garanties**
> 
> - ✅ **Authenticité** : prouve l'identité du signataire
> - ✅ **Intégrité** : détecte toute modification
> - ✅ **Non-répudiation** : le signataire ne peut nier
> 
> **Ne garantit PAS**
> 
> - ❌ Confidentialité (document lisible par tous)
> - ❌ Protection contre la copie
> - ❌ Empêche la modification (seulement la détecte)
> 
> **Algorithmes recommandés**
> 
> - ECDSA ou Ed25519 (moderne, efficace)
> - RSA 4096 (si compatibilité requise)
> - SHA-256 ou SHA-384 pour le hachage
> 
> **Usages principaux**
> 
> - Contrats et documents juridiques
> - Signature de code (logiciels, mises à jour)
> - Emails sécurisés (S/MIME, PGP)
> - Commits Git
> - Transactions blockchain

---

## 🎯 Synthèse générale du cours

### 🔗 Liens entre les concepts

```
                    CRYPTOGRAPHIE
                         |
        +----------------+----------------+
        |                                 |
   SYMÉTRIQUE                      ASYMÉTRIQUE
   (AES, ChaCha20)                (RSA, ECDSA)
        |                                 |
        |                         +-------+-------+
        |                         |               |
   Chiffrement              Clé Publique    Clé Privée
   de données                    |               |
   volumineuses              Chiffrer       Déchiffrer
        |                    Vérifier         Signer
        |                         |               |
        |                         +-------+-------+
        |                                 |
        +----------------+----------------+
                         |
                   UTILISATION
                   COMBINÉE
                         |
        +----------------+----------------+
        |                                 |
   FONCTION DE                    SIGNATURE
     HACHAGE                      NUMÉRIQUE
   (SHA-256)                            |
        |                    +---------+----------+
        |                    |                    |
   Intégrité          Authenticité +        Documents
   Stockage MdP     Intégrité +        Code
   PoW              Non-répudiation     Emails
```

---

### 📊 Tableau récapitulatif des usages

|Besoin|Solution|Technique utilisée|
|---|---|---|
|**Confidentialité** (personne ne peut lire)|Chiffrement asymétrique + symétrique|Clé publique du destinataire|
|**Authenticité** (prouver l'identité)|Signature numérique|Clé privée de l'émetteur|
|**Intégrité** (détecter modification)|Hash ou Signature|SHA-256 ou signature complète|
|**Non-répudiation** (prouver engagement)|Signature numérique|Signature avec certificat|
|**Stockage de mots de passe**|Hash avec sel|bcrypt, Argon2|
|**Vérification de téléchargement**|Hash public|SHA-256 checksum|
|**Échange de clés sécurisé**|Cryptographie asymétrique|Diffie-Hellman, RSA|

---

### 🎓 Ce qu'il faut absolument retenir

> [!tip] Les 10 points essentiels
> 
> 1. **Symétrique** = une seule clé (rapide, problème de distribution)
> 2. **Asymétrique** = paire de clés (lent, résout la distribution)
> 3. **Clé publique** = diffusable librement (chiffrer, vérifier)
> 4. **Clé privée** = secrète absolu (déchiffrer, signer)
> 5. **Hash** = empreinte irréversible et unique (intégrité)
> 6. **Signature** = hash chiffré avec clé privée (authenticité + intégrité)
> 7. **SHA-256 minimum** pour toute application sécurisée
> 8. **RSA 4096** ou **ECDSA/Ed25519** pour les signatures
> 9. **Ne jamais partager la clé privée** = compromission totale
> 10. **Combiner les techniques** = solution optimale (asymétrique pour l'échange, symétrique pour les données)

---

### 🚀 Préparation pour la suite

Ce cours constitue les **fondations** nécessaires pour comprendre :

- **Certificats X.509** : comment les clés publiques sont certifiées
- **PKI (Public Key Infrastructure)** : système de gestion des certificats
- **Autorités de certification** : qui valide les clés publiques
- **Chaînes de confiance** : comment vérifier un certificat
- **Révocation de certificats** : que faire si une clé est compromise
- **Protocoles SSL/TLS** : application pratique de tous ces concepts

> [!info] Prochaine étape Maintenant que vous maîtrisez les concepts cryptographiques fondamentaux, vous êtes prêt à comprendre comment ces techniques sont utilisées dans les **certificats numériques** et l'infrastructure PKI qui les gère.

---

**Fin du cours : Introduction à la cryptographie et aux certificats numériques** ✅