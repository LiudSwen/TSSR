## ⚡ L'essentiel en 5 minutes - Cryptographie

### 📌 C'est quoi en 2 lignes ?

La cryptographie protège les données par chiffrement (confidentialité), signature (authenticité) et empreintes (intégrité). Elle repose sur 3 piliers : **cryptographie symétrique** (1 clé partagée, rapide), **asymétrique** (paire clé publique/privée, lente) et **fonctions de hachage** (empreintes unidirectionnelles).

---

### 💡 Concepts clés à retenir :

- **Chiffrer** : Produire un message chiffré avec une clé (réversible)
- **Déchiffrer** : Retrouver le message clair avec la clé légitime
- **Décrypter** : Retrouver le message clair SANS la clé (attaque)
- **Hash/Empreinte** : Condensat d'un message, impossible à inverser
- **Signature numérique** : Hash chiffré avec clé privée pour authentifier l'émetteur
- **Certificat** : Clé publique + identité + signature d'un tiers de confiance (CA)
- **HMAC** : Hash combiné à une clé secrète pour authentifier ET vérifier l'intégrité
- **Clé de session** : Clé symétrique temporaire échangée via asymétrique
- **Salage** : Ajout aléatoire aux mots de passe avant hash (évite rainbow tables)

---

### 💻 Commandes essentielles :

```bash
# 🔐 OpenSSL (manipulation clés/certificats)
openssl genrsa -out private.key 4096              # Générer clé RSA privée
openssl rsa -in private.key -pubout -out pub.key  # Extraire clé publique
openssl req -new -key private.key -out req.csr    # Créer CSR
openssl x509 -in cert.pem -text -noout            # Lire certificat
```

```bash
# 🔑 GPG (chiffrement/signature fichiers)
gpg --gen-key                                     # Générer paire de clés
gpg --encrypt --recipient user@mail.com file.txt  # Chiffrer pour destinataire
gpg --decrypt file.txt.gpg                        # Déchiffrer
gpg --sign --armor file.txt                       # Signer un fichier
```

```bash
# 📝 Hash (vérifier intégrité)
sha256sum fichier.iso                             # Calculer hash SHA-256
echo "texte" | sha256sum                          # Hash d'une chaîne
```

```bash
# 🌐 Certbot (Let's Encrypt)
certbot certonly --standalone -d domaine.fr       # Obtenir certificat HTTPS
certbot renew                                     # Renouveler certificats
```

---

### 📐 Algorithmes à connaître :

**Symétrique (1 clé partagée) :**

- **AES-256-GCM** : Standard actuel (chiffrement authentifié)
- **ChaCha20-Poly1305** : Alternative rapide (mobile)
- ❌ **DES, 3DES, RC4** : Obsolètes

**Asymétrique (clé publique/privée) :**

- **RSA ≥3072 bits** : Standard actuel (lourd)
- **Ed25519** : Courbe elliptique moderne (rapide, clé 256 bits)
- **ECDH** : Échange de clés Diffie-Hellman sur courbes elliptiques
- ❌ **DSA** : Obsolète

**Hash (empreintes) :**

- **SHA-256/SHA-512** : Standard actuel
- **SHA-3** : Remplaçant de SHA-2
- **Argon2, Bcrypt** : Pour mots de passe (lents = résistants brute force)
- ❌ **MD5, SHA-1** : Cassés (collisions possibles)

**Signatures :**

- **RSA-PSS** : Signature RSA moderne
- **EdDSA (Ed25519)** : Signature sur courbes elliptiques

---

### ⚠️ Pièges à éviter :

- ❌ **Mode ECB (Electronic Codebook)** : Même clair → même chiffré (motifs visibles, JAMAIS utiliser)
- ❌ **Réutiliser un vecteur d'initialisation (IV)** : Compromet la sécurité (doit être aléatoire et unique)
- ❌ **Stocker mots de passe en clair ou hash simple** : Utiliser Argon2/Bcrypt + salage
- ❌ **Clés RSA < 3072 bits** : Vulnérable aux attaques modernes
- ❌ **Ne pas vérifier les certificats** : Risque d'attaque MITM (man-in-the-middle)
- ❌ **Confondre chiffrement et hachage** : Hash est unidirectionnel (pas de déchiffrement)
- ❌ **Utiliser son propre algorithme crypto** : Utiliser standards éprouvés (AES, RSA, SHA-2)

---

### ✅ Bonnes pratiques :

- ✅ **Hybride symétrique + asymétrique** : Échanger clé de session (asymétrique), chiffrer données (symétrique)
- ✅ **Chiffrement authentifié (AEAD)** : Modes GCM, CCM (confidentialité + intégrité en une passe)
- ✅ **Clés de session éphémères** : Renouveler régulièrement (Forward Secrecy)
- ✅ **Vérifier chaîne de certificats** : Jusqu'à CA racine connue
- ✅ **Diffie-Hellman pour partage de clé** : Permet accord de clé sur canal non sécurisé
- ✅ **HMAC pour intégrité + authentification** : Hash + clé secrète (clé différente du chiffrement)
- ✅ **Salage obligatoire pour mots de passe** : Hash(mdp + sel aléatoire) stocké

---

### 📚 Vocabulaire technique :

|Terme|Définition courte|
|---|---|
|**Clé symétrique**|Même clé pour chiffrer et déchiffrer (rapide, nécessite partage sécurisé)|
|**Clé publique**|Partie publique d'une paire asymétrique (chiffrement, vérification signature)|
|**Clé privée**|Partie secrète d'une paire asymétrique (déchiffrement, signature)|
|**CSR**|Certificate Signing Request : demande de certificat avec clé publique + identité|
|**CA**|Certificate Authority : Autorité de certification émettant des certificats X.509|
|**PKI**|Public Key Infrastructure : Infrastructure pour gérer certificats (CA + matériel + procédures)|
|**TLS**|Transport Layer Security : Protocole sécurisant HTTPS (chiffrement + authentification)|
|**HMAC**|Hash-based Message Authentication Code : Hash + clé secrète pour authentifier|
|**Nonce**|Number used ONCE : Nombre aléatoire à usage unique (empêche rejeu)|
|**Forward Secrecy**|Compromission clé n'expose pas sessions passées (clés éphémères)|
|**Rainbow Table**|Table précalculée hash → mot de passe (contré par salage)|
|**OCSP**|Online Certificate Status Protocol : Vérification révocation certificat en temps réel|

---

### 🎯 À retenir ABSOLUMENT (3 points max) :

1. 💡 **Théorique** : Crypto hybride = échange clé avec asymétrique (RSA/ECDH), chiffrement données avec symétrique (AES-GCM). Signatures = hash + clé privée.
    
2. 💻 **Pratique** : HTTPS = TLS avec certificats X.509. Let's Encrypt = CA gratuite (ACME automatise renouvellement). GPG = chiffrement/signature fichiers et emails.
    
3. ⚠️ **Piège** : Ne JAMAIS utiliser ECB, MD5, SHA-1, DES. Toujours vérifier certificats (chaîne + révocation). Stocker mots de passe avec Argon2/Bcrypt + salage unique.