## Vocabulaire clé

| Terme            | Définition                                                      |
| ---------------- | --------------------------------------------------------------- |
| Chiffrer         | Produire un message chiffré à partir du clair + une clé         |
| Déchiffrer       | Retrouver le clair à partir du chiffré **avec** la clé          |
| Décrypter        | Retrouver le clair **sans** la clé (cryptanalyse)               |
| Clé              | Secret utilisé pour chiffrer / déchiffrer                       |
| Hash / Empreinte | Condensat de taille fixe produit par une fonction à sens unique |
| Nonce            | Nombre arbitraire utilisé une seule fois                        |
| Collision        | Deux messages différents produisant la même empreinte           |

---

## 1. Cryptographie symétrique (clé secrète)

- **1 seule clé** partagée pour chiffrer et déchiffrer
- Rapide → utilisée pour le trafic réseau (clés de session)
- Problème principal : **comment partager la clé de façon sécurisée ?** → Diffie-Hellman

### Modes de chiffrement par blocs

|Mode|Description|
|---|---|
|ECB|Blocs indépendants — **non recommandé**|
|CBC|Chaque bloc dépend du précédent + vecteur d'initialisation (IV)|
|GCM|CBC + authentification intégrée — **recommandé**|
|CTR, CFB, OFB|Autres modes courants|

### Algorithmes

|Type|Algorithme|Clé|Statut|
|---|---|---|---|
|Bloc|**AES** (Rijndael)|128 / 192 / 256 bits|✅ Recommandé|
|Bloc|Twofish, Serpent|—|✅ OK|
|Bloc|DES, 3DES, Blowfish|—|❌ Obsolète|
|Flux|**ChaCha20**|256 bits|✅ Recommandé|
|Flux|RC4 (Arcfour)|—|❌ Obsolète|

---

## 2. Cryptographie asymétrique (clé publique)

- **2 clés liées** : clé publique (partageable) + clé privée (secrète)
- Plus lente que le symétrique → utilisée pour l'échange de clé ou la signature
- Vulnérable aux ordinateurs quantiques → cryptographie post-quantique (Shor, Grover)

### Usages

|Objectif|Clé utilisée pour chiffrer|Clé utilisée pour déchiffrer|
|---|---|---|
|**Confidentialité**|Clé publique du destinataire|Clé privée du destinataire|
|**Authentification / Signature**|Clé privée de l'émetteur|Clé publique de l'émetteur|

### Algorithmes

|Algorithme|Taille de clé|Base mathématique|
|---|---|---|
|**RSA**|≥ 3072 bits (recommandé)|Factorisation de grands nombres premiers|
|**ECC** (Curve25519, Ed25519, NIST P-256)|256 – 512 bits|Courbes elliptiques|
|ElGamal|—|Logarithme discret|

### Échange de clés — Diffie-Hellman

- Construction d'un **secret partagé** sur un canal non sécurisé
- Variantes : DH classique (logarithme discret) ou **ECDH** (courbes elliptiques)
- → Génère des **clés de session** (symétriques, à usage unique)

---

## 3. Fonctions de hachage

- Entrée : séquence binaire quelconque → Sortie : empreinte de **taille fixe**
- Sens unique : message → empreinte facile, inverse **impossible en pratique**
- Utilisations : contrôle d'intégrité, stockage de mots de passe, signature numérique

|Algorithme|Taille|Statut|
|---|---|---|
|**SHA-256 / SHA-512** (SHA-2)|256 / 512 bits|✅ Recommandé|
|**SHA-3** (Keccak)|variable|✅ Recommandé|
|**Argon2**|—|✅ Mots de passe (vainqueur PHC)|
|**Bcrypt**|—|✅ Mots de passe|
|Yescrypt|—|✅ Défaut sur Debian|
|MD5, SHA-1|—|❌ Obsolète|

> **Stockage des mots de passe** : toujours stocker l'empreinte, jamais le mot de passe en clair. Utiliser le **salage** (salt) pour éviter les rainbow tables.

---

## 4. Authentification cryptographique

### HMAC (symétrique)

- Hash + secret partagé → **intégrité + authentification**
- Envoi : `HMAC = hash(message + clé)` → transmission message + HMAC
- Réception : recalcul du HMAC et comparaison

### Signature numérique (asymétrique)

- Hash + clé privée → **intégrité + authentification de l'émetteur**
- Envoi : `signature = chiffrement(hash(message), clé_privée)`
- Réception : déchiffrement de la signature avec la clé publique et comparaison

|Algorithme de signature|Statut|
|---|---|
|RSA-PSS / RSA-PKCS|✅|
|**ECDSA** (courbes NIST)|✅|
|**EdDSA** (Ed25519)|✅ Recommandé|
|DSA|❌ Obsolète|

### Chiffrement authentifié (AEAD)

- Combine confidentialité + authentification + intégrité en une seule opération
- Modes : **AES-GCM**, AES-CCM, ChaCha20-Poly1305

---

## 5. Certificats

- Lien entre une **clé publique** et une **identité**, signé par un tiers de confiance (CA)
- Contient : clé publique, identité, dates de validité, signature du CA

### Formats

|Format|Modèle de confiance|Implémentation|
|---|---|---|
|**X.509**|Autorité de certification (CA) hiérarchique|TLS/HTTPS, S/MIME, OpenVPN|
|**OpenPGP**|Toile de confiance (décentralisé)|GPG / PGP/MIME|

### Cycle de vie

1. Générer une paire de clés → créer un **CSR** (Certificate Signing Request)
2. Envoyer le CSR à un CA → vérification d'identité → certificat signé
3. En cas de compromission : **révocation** via CRL ou **OCSP**

### Protocoles et ports

|Protocole / Usage|Port|Remarque|
|---|---|---|
|**HTTPS / TLS**|443|Confidentialité + authentification serveur + intégrité|
|**SMTPS**|465|Email chiffré (TLS)|
|**IMAPS**|993|Lecture email chiffrée|
|**OpenVPN**|1194 (UDP/TCP)|VPN avec certificats X.509|
|**IPsec (IKE)**|500 / 4500 (UDP)|VPN|
|**SSH**|22|Authentification par clé publique|
|OCSP|80|Vérification de révocation en ligne|
|ACME (Let's Encrypt)|80 / 443|Automatisation de l'émission de certificats|

---

## Récapitulatif — Quelle crypto pour quel besoin ?

|Besoin|Solution|
|---|---|
|Chiffrer du trafic réseau|AES-GCM + échange Diffie-Hellman (TLS)|
|Chiffrer des fichiers|AES (coffre-fort logiciel)|
|Vérifier l'intégrité|SHA-256 / SHA-3|
|Authentifier un message (secret partagé)|HMAC|
|Authentifier l'émetteur (signature)|EdDSA / ECDSA|
|Stocker un mot de passe|Argon2 / Bcrypt (avec salage)|
|Identifier un serveur web|Certificat X.509 (TLS/HTTPS)|
|Email chiffré et signé|S/MIME (X.509) ou PGP/MIME (OpenPGP)|