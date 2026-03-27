

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

## 🎯 Définition et rôle d'un certificat numérique

### Qu'est-ce qu'un certificat numérique ?

Un **certificat numérique** est un document électronique qui permet de lier une identité (personne, organisation, serveur) à une **clé publique**. Il fonctionne comme une carte d'identité numérique qui atteste de l'authenticité d'une entité sur Internet.

> [!info] Analogie Imaginez un passeport : il contient votre identité, votre photo, et la signature d'une autorité gouvernementale qui atteste que ces informations sont authentiques. Un certificat numérique fonctionne de la même manière dans le monde numérique.

### Rôle principal

Le certificat numérique permet de répondre à trois besoins essentiels :

1. **Authentification** : Prouver l'identité d'une entité (exemple : vérifier qu'un site web est bien celui qu'il prétend être)
2. **Chiffrement** : Permettre le chiffrement des communications en fournissant une clé publique
3. **Intégrité** : Garantir que les données n'ont pas été modifiées grâce aux signatures numériques

> [!example] Cas d'usage courants
> 
> - **HTTPS** : Certificat SSL/TLS pour sécuriser les sites web
> - **Email** : Signature et chiffrement des emails (S/MIME)
> - **Code signing** : Signature de logiciels pour garantir leur provenance
> - **VPN** : Authentification des clients et serveurs
> - **Authentification** : Connexion sécurisée aux systèmes d'entreprise

### Comment fonctionne la confiance ?

Un certificat est **signé numériquement** par une **Autorité de Certification (CA)** de confiance. Cette signature garantit que :

- L'identité a été vérifiée
- Le certificat n'a pas été altéré
- La clé publique appartient bien à l'entité mentionnée

> [!tip] Point clé La confiance repose sur une **chaîne de certification** : votre navigateur ou système d'exploitation fait confiance à certaines CA racines, qui à leur tour signent d'autres certificats.

---

## 📋 Structure d'un certificat X.509

### Le standard X.509

**X.509** est le standard international qui définit le format des certificats numériques. Créé par l'ITU-T (Union internationale des télécommunications), il est utilisé dans pratiquement tous les protocoles modernes (TLS/SSL, S/MIME, IPsec, etc.).

> [!info] Version actuelle La version la plus courante est **X.509 v3**, qui ajoute le support des **extensions** par rapport aux versions précédentes.

### Anatomie d'un certificat X.509

Un certificat X.509 est structuré en trois grandes parties :

```
┌─────────────────────────────────────┐
│      CERTIFICAT X.509 v3            │
├─────────────────────────────────────┤
│  1. Données du certificat (TBS)     │
│     - Version                       │
│     - Numéro de série               │
│     - Algorithme de signature       │
│     - Émetteur (Issuer)             │
│     - Validité                      │
│     - Sujet (Subject)               │
│     - Clé publique                  │
│     - Extensions (v3)               │
├─────────────────────────────────────┤
│  2. Algorithme de signature         │
├─────────────────────────────────────┤
│  3. Signature numérique             │
└─────────────────────────────────────┘
```

> [!info] TBS Certificate TBS signifie "To Be Signed" (à signer). C'est la partie du certificat qui sera signée par la CA. La signature porte sur un hash de ces données.

### Visualiser un certificat

Vous pouvez examiner le contenu d'un certificat avec OpenSSL :

```bash
# Afficher le contenu d'un certificat au format texte
openssl x509 -in certificat.crt -text -noout

# Afficher uniquement certaines informations
openssl x509 -in certificat.crt -subject -issuer -dates -noout
```

> [!example] Exemple de sortie
> 
> ```
> Certificate:
>     Data:
>         Version: 3 (0x2)
>         Serial Number:
>             04:00:00:00:00:01:44:4e:f0:42:47
>         Signature Algorithm: sha256WithRSAEncryption
>         Issuer: C=US, O=DigiCert Inc, CN=DigiCert Global Root CA
>         Validity
>             Not Before: Nov 10 00:00:00 2006 GMT
>             Not After : Nov 10 00:00:00 2031 GMT
>         Subject: C=US, O=DigiCert Inc, CN=DigiCert Global Root CA
>         Subject Public Key Info:
>             Public Key Algorithm: rsaEncryption
>                 RSA Public-Key: (2048 bit)
> ```

---

## 🔑 Champs principaux du certificat

### Subject (Sujet)

Le champ **Subject** identifie l'**entité à qui le certificat est délivré**. Il contient le **Distinguished Name (DN)** qui décrit l'identité du propriétaire.

#### Structure du DN

Le Distinguished Name est composé de plusieurs attributs :

|Attribut|Nom complet|Description|Exemple|
|---|---|---|---|
|**CN**|Common Name|Nom de l'entité (domaine, personne)|`www.example.com`|
|**O**|Organization|Nom de l'organisation|`Example Corp`|
|**OU**|Organizational Unit|Département ou division|`IT Department`|
|**C**|Country|Code pays (ISO 3166)|`FR`|
|**ST**|State/Province|État ou région|`Île-de-France`|
|**L**|Locality|Ville|`Paris`|
|**E**|Email|Adresse email|`admin@example.com`|

> [!example] Exemple de Subject
> 
> ```
> Subject: C=FR, ST=Île-de-France, L=Paris, O=Example Corp, OU=IT, CN=www.example.com
> ```

> [!warning] Common Name vs SAN Pour les certificats web modernes, le **CN** est déprécié. On utilise désormais l'extension **Subject Alternative Name (SAN)** pour spécifier les domaines. Le CN reste présent pour la compatibilité.

#### Visualiser le Subject

```bash
# Afficher uniquement le Subject
openssl x509 -in certificat.crt -subject -noout

# Sortie : subject=C=FR, O=Example Corp, CN=www.example.com
```

---

### Issuer (Émetteur)

Le champ **Issuer** identifie l'**Autorité de Certification (CA)** qui a émis et signé le certificat. Il utilise également le format Distinguished Name.

#### Différence entre Subject et Issuer

|Aspect|Subject|Issuer|
|---|---|---|
|**Représente**|Le propriétaire du certificat|L'autorité qui a signé le certificat|
|**Auto-signé**|Subject = Issuer|Subject = Issuer|
|**Signé par CA**|Identité du propriétaire|Identité de la CA|

> [!info] Certificats auto-signés Quand **Subject = Issuer**, le certificat est **auto-signé**. Utile pour les tests, mais non recommandé en production car il n'y a pas de tiers de confiance.

> [!example] Exemple d'Issuer
> 
> ```
> Issuer: C=US, O=Let's Encrypt, CN=R3
> ```
> 
> Ce certificat a été émis par l'autorité intermédiaire "R3" de Let's Encrypt.

#### Vérifier l'émetteur

```bash
# Afficher l'émetteur
openssl x509 -in certificat.crt -issuer -noout

# Sortie : issuer=C=US, O=Let's Encrypt, CN=R3
```

---

### Validity (Validité)

Le champ **Validity** définit la **période de validité** du certificat avec deux dates :

- **Not Before** : Date à partir de laquelle le certificat est valide
- **Not After** : Date d'expiration du certificat

> [!warning] Importance de la validité
> 
> - Un certificat expiré ne sera **pas accepté** par les navigateurs et systèmes
> - Les certificats avec une validité trop longue sont considérés comme moins sûrs
> - Les navigateurs modernes limitent la durée maximale (398 jours pour les certificats web)

#### Format des dates

Les dates sont au format **ASN.1 UTCTime** ou **GeneralizedTime** :

```
Not Before: Jan 15 08:30:00 2024 GMT
Not After : Apr 15 08:30:00 2024 GMT
```

> [!tip] Durée de validité recommandée
> 
> - **Certificats serveur web** : 90 jours (Let's Encrypt) ou 1 an maximum
> - **Certificats internes** : 1 à 2 ans
> - **Certificats racine CA** : 10 à 25 ans

#### Vérifier la validité

```bash
# Afficher les dates de validité
openssl x509 -in certificat.crt -dates -noout

# Sortie :
# notBefore=Jan 15 08:30:00 2024 GMT
# notAfter=Apr 15 08:30:00 2024 GMT

# Vérifier si un certificat est expiré
openssl x509 -in certificat.crt -checkend 0
# Retourne 0 si valide, 1 si expiré

# Vérifier si le certificat expire dans 30 jours
openssl x509 -in certificat.crt -checkend 2592000
```

> [!example] Monitoring de l'expiration
> 
> ```bash
> #!/bin/bash
> # Script pour vérifier l'expiration d'un certificat
> CERT="/path/to/cert.crt"
> DAYS=30
> SECONDS=$((DAYS * 86400))
> 
> if ! openssl x509 -in "$CERT" -checkend $SECONDS > /dev/null; then
>     echo "⚠️  Le certificat expire dans moins de $DAYS jours!"
> fi
> ```

---

### Public Key (Clé publique)

Le champ **Subject Public Key Info** contient la **clé publique** du propriétaire du certificat et les informations sur l'algorithme utilisé.

#### Structure

```
Subject Public Key Info:
    Public Key Algorithm: rsaEncryption
        RSA Public-Key: (2048 bit)
        Modulus:
            00:b4:31:98:0a:c4:bc:62:c1:88:aa:dc:b0:c8:bb:
            33:35:19:d5:0c:64:b9:3d:41:b2:96:fc:f3:31:e1:
            [...]
        Exponent: 65537 (0x10001)
```

#### Algorithmes supportés

|Algorithme|Taille typique|Usage|Recommandation|
|---|---|---|---|
|**RSA**|2048, 3072, 4096 bits|Universel|✅ 2048+ bits|
|**ECDSA**|256, 384 bits|Moderne, performant|✅ P-256, P-384|
|**Ed25519**|256 bits|Très moderne|✅ Si supporté|
|**DSA**|1024, 2048 bits|Ancien|❌ Déprécié|

> [!info] RSA vs ECDSA
> 
> - **RSA 2048 bits** ≈ **ECDSA 256 bits** en termes de sécurité
> - ECDSA est plus rapide et génère des signatures plus petites
> - RSA est plus universel et compatible avec les anciens systèmes

> [!warning] Taille minimale
> 
> - **RSA** : Minimum 2048 bits (4096 bits pour haute sécurité)
> - Les clés RSA 1024 bits sont considérées comme **non sécurisées** depuis 2010

#### Extraire la clé publique

```bash
# Extraire la clé publique d'un certificat
openssl x509 -in certificat.crt -pubkey -noout > public.key

# Afficher les détails de la clé publique
openssl x509 -in certificat.crt -text -noout | grep -A 10 "Public Key"

# Pour une clé RSA, afficher le modulus
openssl x509 -in certificat.crt -modulus -noout

# Vérifier le type et la taille de la clé
openssl x509 -in certificat.crt -text -noout | grep "Public Key"
# Sortie : RSA Public-Key: (2048 bit)
```

> [!tip] Correspondance clé privée/publique Pour vérifier qu'une clé privée correspond à un certificat, comparez leurs modulus :
> 
> ```bash
> # Hash du modulus du certificat
> openssl x509 -in cert.crt -modulus -noout | openssl md5
> 
> # Hash du modulus de la clé privée
> openssl rsa -in private.key -modulus -noout | openssl md5
> 
> # Les deux hashs doivent être identiques
> ```

---

## 📦 Formats des certificats

Les certificats peuvent être encodés dans différents formats selon leur usage et leur compatibilité avec les systèmes.

### Comparaison des formats

|Format|Extension|Encodage|Contenu|Usage principal|
|---|---|---|---|---|
|**PEM**|.pem, .crt, .cer, .key|Base64 (ASCII)|Certificat seul ou avec clé|Linux, Apache, Nginx|
|**DER**|.der, .cer|Binaire|Certificat seul|Java, Windows|
|**PFX/P12**|.pfx, .p12|Binaire|Certificat + clé privée + chaîne|Windows, export/import|

---

### Format PEM

**PEM** (Privacy Enhanced Mail) est le format le plus courant sous Linux/Unix. C'est un encodage **Base64** du certificat, encadré par des balises textuelles.

#### Caractéristiques

- ✅ **Lisible en texte** (peut être ouvert dans un éditeur)
- ✅ **Compatible email** (peut être copié-collé)
- ✅ **Universel** (supporté par la plupart des outils)
- 📝 **Extensions** : `.pem`, `.crt`, `.cer`, `.key`

#### Structure

```
-----BEGIN CERTIFICATE-----
MIIDXTCCAkWgAwIBAgIJAKL0UG+mRKSzMA0GCSqGSIb3DQEBCwUAMEUxCzAJBgNV
BAYTAkZSMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBX
aWRnaXRzIFB0eSBMdGQwHhcNMjQwMTE1MDgzMDAwWhcNMjUwMTE1MDgzMDAwWjBF
[... plus de lignes en Base64 ...]
-----END CERTIFICATE-----
```

> [!info] Fichiers séparés ou combinés Un fichier PEM peut contenir :
> 
> - Un seul certificat
> - Plusieurs certificats (chaîne complète)
> - Un certificat + sa clé privée
> - Uniquement une clé privée (avec `BEGIN PRIVATE KEY`)

#### Exemples de manipulation

```bash
# Afficher un certificat PEM
cat certificat.pem

# Vérifier qu'un fichier est bien au format PEM
head -n 1 certificat.pem
# Doit afficher : -----BEGIN CERTIFICATE-----

# Afficher le contenu décodé
openssl x509 -in certificat.pem -text -noout

# Vérifier la validité d'un certificat PEM
openssl x509 -in certificat.pem -noout
# Aucune erreur = certificat valide
```

#### Clé privée en PEM

```
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDO7YBVTgZENxmM
[...]
-----END PRIVATE KEY-----
```

Ou avec l'ancien format RSA :

```
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAzp7IhW2W3QEk3GFWQW7lL8qUfbkQqG8x5x5+5x5+5x5+5x5+
[...]
-----END RSA PRIVATE KEY-----
```

> [!warning] Sécurité des clés privées
> 
> - Les fichiers contenant des clés privées doivent être **protégés** (chmod 600)
> - Ne jamais partager ou envoyer une clé privée non chiffrée
> - Utilisez `openssl rsa -aes256` pour chiffrer une clé privée

---

### Format DER

**DER** (Distinguished Encoding Rules) est le format **binaire** du certificat, non lisible par un humain.

#### Caractéristiques

- ⚡ **Compact** (plus petit que PEM)
- 🔒 **Binaire** (non lisible en texte)
- ☕ **Java** (format par défaut pour les keystores)
- 🪟 **Windows** (reconnu nativement)
- 📝 **Extensions** : `.der`, `.cer`

> [!info] DER vs PEM DER est simplement la version **binaire** de PEM sans l'encodage Base64 et sans les balises BEGIN/END.

#### Conversion entre PEM et DER

```bash
# Convertir PEM vers DER
openssl x509 -in certificat.pem -outform DER -out certificat.der

# Convertir DER vers PEM
openssl x509 -in certificat.der -inform DER -outform PEM -out certificat.pem

# Afficher un certificat DER (doit spécifier -inform DER)
openssl x509 -in certificat.der -inform DER -text -noout
```

> [!tip] Détecter le format
> 
> ```bash
> # Si le fichier commence par "-----BEGIN", c'est du PEM
> # Sinon, c'est probablement du DER
> 
> file certificat.crt
> # PEM: "PEM certificate"
> # DER: "data" ou "DER encoded certificate"
> ```

#### Clé privée en DER

```bash
# Convertir une clé privée PEM vers DER
openssl rsa -in private.pem -outform DER -out private.der

# Convertir une clé privée DER vers PEM
openssl rsa -in private.der -inform DER -outform PEM -out private.pem
```

---

### Format PFX/P12

**PFX** (Personal Information Exchange) ou **PKCS#12** est un format **conteneur** qui regroupe le certificat, la clé privée, et éventuellement toute la chaîne de certification dans un seul fichier binaire **protégé par mot de passe**.

#### Caractéristiques

- 🔐 **Protégé par mot de passe**
- 📦 **Tout-en-un** (certificat + clé + chaîne)
- 🪟 **Windows** (import/export facile)
- 🔄 **Portable** (transport sécurisé)
- 📝 **Extensions** : `.pfx`, `.p12`

> [!warning] Différence PFX vs P12 Il n'y a **aucune différence technique** entre .pfx et .p12. Ce sont deux noms pour le même format PKCS#12. Microsoft utilise `.pfx`, tandis que d'autres systèmes préfèrent `.p12`.

#### Contenu typique d'un fichier P12

```
┌──────────────────────────────┐
│    Fichier .pfx/.p12         │
│   (protégé par password)     │
├──────────────────────────────┤
│  • Certificat de l'entité    │
│  • Clé privée associée       │
│  • Certificats intermédiaires│
│  • Certificat racine CA      │
└──────────────────────────────┘
```

#### Créer un fichier P12

```bash
# Créer un .p12 à partir d'un certificat et d'une clé privée
openssl pkcs12 -export \
  -in certificat.crt \
  -inkey private.key \
  -out certificat.p12 \
  -name "Mon Certificat" \
  -passout pass:MotDePasse123

# Inclure la chaîne complète de certification
openssl pkcs12 -export \
  -in certificat.crt \
  -inkey private.key \
  -certfile chaine-ca.crt \
  -out certificat.p12 \
  -name "Mon Certificat avec chaîne" \
  -passout pass:MotDePasse123
```

> [!tip] Option -name L'option `-name` définit le "friendly name" du certificat, utile pour l'identifier facilement dans Windows ou les outils de gestion.

#### Extraire le contenu d'un P12

```bash
# Afficher le contenu sans extraire
openssl pkcs12 -in certificat.p12 -info -noout -passin pass:MotDePasse123

# Extraire le certificat seul
openssl pkcs12 -in certificat.p12 -clcerts -nokeys -out certificat.pem -passin pass:MotDePasse123

# Extraire la clé privée (chiffrée)
openssl pkcs12 -in certificat.p12 -nocerts -out private-encrypted.key -passin pass:MotDePasse123

# Extraire la clé privée (déchiffrée)
openssl pkcs12 -in certificat.p12 -nocerts -nodes -out private.key -passin pass:MotDePasse123

# Extraire la chaîne de CA
openssl pkcs12 -in certificat.p12 -cacerts -nokeys -out ca-chain.pem -passin pass:MotDePasse123

# Extraire tout dans des fichiers séparés
openssl pkcs12 -in certificat.p12 -out all.pem -passin pass:MotDePasse123
```

> [!warning] Option -nodes `-nodes` signifie "NO DES" (pas de chiffrement DES). Elle permet d'extraire la clé privée **sans protection**. À utiliser avec précaution !

#### Cas d'usage du P12

|Scénario|Avantage|
|---|---|
|**Export Windows**|Double-clic pour installer certificat + clé|
|**Migration serveur**|Tout dans un fichier protégé|
|**Backup sécurisé**|Archivage avec mot de passe|
|**Distribution**|Partage sécurisé des credentials|

> [!example] Import dans Windows Sous Windows, double-cliquez sur un fichier `.pfx` :
> 
> 1. L'assistant d'import s'ouvre
> 2. Entrez le mot de passe
> 3. Choisissez le magasin (Personal, Trusted Root, etc.)
> 4. Le certificat et la clé sont installés automatiquement

---

### 🔄 Tableau de conversion des formats

```bash
# PEM → DER
openssl x509 -in cert.pem -outform DER -out cert.der

# DER → PEM
openssl x509 -in cert.der -inform DER -outform PEM -out cert.pem

# PEM → P12 (nécessite la clé privée)
openssl pkcs12 -export -in cert.pem -inkey private.key -out cert.p12

# P12 → PEM (certificat)
openssl pkcs12 -in cert.p12 -clcerts -nokeys -out cert.pem

# P12 → PEM (clé privée)
openssl pkcs12 -in cert.p12 -nocerts -nodes -out private.key

# DER → P12
openssl x509 -in cert.der -inform DER -out cert.pem
openssl pkcs12 -export -in cert.pem -inkey private.key -out cert.p12
```

> [!tip] Astuce pour identifier le format
> 
> ```bash
> # Commande universelle pour identifier
> file certificat.*
> 
> # Ou essayez d'ouvrir avec cat
> cat certificat.crt
> # Si vous voyez "-----BEGIN CERTIFICATE-----" → PEM
> # Si vous voyez du binaire illisible → DER ou P12
> 
> # Pour distinguer DER et P12
> openssl x509 -in fichier -inform DER -noout 2>/dev/null && echo "DER"
> openssl pkcs12 -in fichier -info -noout 2>/dev/null && echo "P12"
> ```

---

## 🎯 Récapitulatif

### Points clés à retenir

> [!tip] Certificat numérique
> 
> - Lie une **identité** à une **clé publique**
> - Signé par une **Autorité de Certification** de confiance
> - Utilisé pour l'authentification, le chiffrement et la signature

> [!tip] X.509
> 
> - Standard universel pour les certificats (version 3 courante)
> - Structure : Données (TBS) + Algorithme + Signature
> - Permet les **extensions** pour ajouter des fonctionnalités

> [!tip] Champs essentiels
> 
> - **Subject** : Identité du propriétaire (DN)
> - **Issuer** : Autorité de certification émettrice
> - **Validity** : Période de validité (Not Before / Not After)
> - **Public Key** : Clé publique + algorithme (RSA, ECDSA, etc.)

> [!tip] Formats de certificats
> 
> - **PEM** : Texte Base64, universel, Linux/Apache (.pem, .crt)
> - **DER** : Binaire compact, Java/Windows (.der, .cer)
> - **P12/PFX** : Conteneur tout-en-un protégé, Windows (.pfx, .p12)

### Commandes essentielles

```bash
# Examiner un certificat
openssl x509 -in cert.crt -text -noout

# Vérifier la validité
openssl x509 -in cert.crt -noout

# Afficher les dates
openssl x509 -in cert.crt -dates -noout

# Extraire la clé publique
openssl x509 -in cert.crt -pubkey -noout

# Convertir PEM ↔ DER
openssl x509 -in cert.pem -outform DER -out cert.der
openssl x509 -in cert.der -inform DER -outform PEM -out cert.pem

# Créer/extraire P12
openssl pkcs12 -export -in cert.pem -inkey key.pem -out cert.p12
openssl pkcs12 -in cert.p12 -clcerts -nokeys -out cert.pem
```

---

> [!success] Compétences acquises ✅ Comprendre le rôle et la structure d'un certificat X.509  
> ✅ Identifier et interpréter les champs Subject, Issuer, Validity, Public Key  
> ✅ Distinguer et convertir entre les formats PEM, DER et P12  
> ✅ Utiliser OpenSSL pour examiner et manipuler des certificats