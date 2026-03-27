

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

## Introduction

Le cycle de vie d'un certificat numérique décrit l'ensemble des étapes par lesquelles passe un certificat, depuis sa création jusqu'à sa fin de validité. Comprendre ce cycle est essentiel pour gérer efficacement une infrastructure PKI et assurer la sécurité des communications.

> [!info] Durée de vie typique Les certificats ont généralement une durée de validité de 1 à 2 ans pour les certificats SSL/TLS, et peuvent aller jusqu'à 5 ans pour certains certificats internes. Cette limitation temporelle est une mesure de sécurité importante.

---

## 1. Demande de certificat (CSR)

### 📝 Qu'est-ce qu'un CSR ?

Le **Certificate Signing Request (CSR)** est un fichier contenant les informations nécessaires pour créer un certificat. C'est la première étape du cycle de vie : le demandeur génère une paire de clés (privée/publique) et crée un CSR contenant sa clé publique et ses informations d'identité.

> [!tip] Point clé La clé privée reste **toujours** sur le système du demandeur et n'est jamais transmise à l'autorité de certification. Seul le CSR (contenant la clé publique) est envoyé.

### 🔧 Contenu d'un CSR

Un CSR contient plusieurs champs standardisés :

|Champ|Nom complet|Description|Exemple|
|---|---|---|---|
|CN|Common Name|Nom principal (domaine ou nom complet)|`www.example.com` ou `Jean Dupont`|
|O|Organization|Nom de l'organisation|`Example Corp`|
|OU|Organizational Unit|Département ou division|`IT Department`|
|L|Locality|Ville|`Paris`|
|ST|State/Province|Région ou État|`Île-de-France`|
|C|Country|Code pays (2 lettres)|`FR`|
|emailAddress|Email Address|Adresse email|`admin@example.com`|

### 💻 Génération d'un CSR

**Avec OpenSSL (méthode standard) :**

```bash
# Générer une clé privée ET un CSR en une commande
openssl req -new -newkey rsa:2048 -nodes \
  -keyout server.key \
  -out server.csr \
  -subj "/C=FR/ST=Ile-de-France/L=Paris/O=Example Corp/OU=IT/CN=www.example.com"

# Options expliquées :
# -new           : créer un nouveau CSR
# -newkey rsa:2048 : générer une nouvelle clé RSA de 2048 bits
# -nodes         : ne pas chiffrer la clé privée (no DES)
# -keyout        : fichier de sortie pour la clé privée
# -out           : fichier de sortie pour le CSR
# -subj          : informations du certificat
```

**Mode interactif (pour renseigner les champs manuellement) :**

```bash
openssl req -new -newkey rsa:2048 -nodes \
  -keyout server.key \
  -out server.csr

# OpenSSL posera ensuite des questions interactives
```

**À partir d'une clé privée existante :**

```bash
# Si vous avez déjà une clé privée
openssl req -new -key existing-key.key -out server.csr
```

### 🔍 Vérification d'un CSR

```bash
# Afficher le contenu d'un CSR
openssl req -text -noout -in server.csr

# Vérifier que le CSR correspond à la clé privée
openssl req -noout -modulus -in server.csr | openssl md5
openssl rsa -noout -modulus -in server.key | openssl md5
# Les deux hash MD5 doivent être identiques
```

> [!example] Exemple de sortie CSR
> 
> ```
> Certificate Request:
>     Subject: C=FR, ST=Ile-de-France, L=Paris, O=Example Corp, CN=www.example.com
>     Public Key Algorithm: rsaEncryption
>         Public-Key: (2048 bit)
> ```

> [!warning] Sécurité de la clé privée
> 
> - La clé privée (`server.key`) doit être protégée avec des permissions strictes : `chmod 600 server.key`
> - Ne jamais la transmettre par email ou canaux non sécurisés
> - Faire des sauvegardes chiffrées dans un endroit sécurisé
> - En cas de compromission suspectée, révoquer immédiatement le certificat

### 🎯 Cas d'usage spécifiques

**CSR avec SAN (Subject Alternative Names) :**

Les certificats modernes nécessitent souvent plusieurs domaines (SAN). Il faut créer un fichier de configuration :

```bash
# Créer un fichier san.cnf
cat > san.cnf << EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req

[req_distinguished_name]
CN = www.example.com

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = www.example.com
DNS.2 = example.com
DNS.3 = mail.example.com
IP.1 = 192.168.1.100
EOF

# Générer le CSR avec SAN
openssl req -new -newkey rsa:2048 -nodes \
  -keyout server.key \
  -out server.csr \
  -config san.cnf \
  -subj "/C=FR/O=Example Corp/CN=www.example.com"
```

> [!tip] Bonnes pratiques CSR
> 
> - Utiliser au minimum des clés RSA 2048 bits (4096 bits pour haute sécurité)
> - Privilégier les algorithmes modernes (RSA, ECDSA avec courbes P-256 ou P-384)
> - Toujours vérifier le contenu du CSR avant de l'envoyer
> - Conserver une copie du CSR et de la clé privée de manière sécurisée
> - Documenter quel CSR correspond à quel certificat

---

## 2. Validation de l'identité

### 🔐 Pourquoi valider l'identité ?

La validation d'identité est l'étape cruciale où l'Autorité de Certification (CA) vérifie que le demandeur du certificat est bien celui qu'il prétend être. Cette étape garantit la confiance dans le certificat émis.

> [!info] Rôle de la CA L'Autorité de Certification agit comme un tiers de confiance. Sa réputation dépend de la rigueur de ses processus de validation.

### 📊 Types de validation

Il existe trois niveaux principaux de validation, par ordre croissant de rigueur :

#### 1️⃣ **DV - Domain Validation (Validation de domaine)**

**Niveau le plus basique** : vérifie uniquement que le demandeur contrôle le domaine.

|Aspect|Description|
|---|---|
|**Vérification**|Contrôle du domaine uniquement|
|**Durée**|Quelques minutes à quelques heures|
|**Coût**|Gratuit à faible coût|
|**Méthodes**|Email, DNS, fichier HTTP|
|**Usage**|Sites web standards, blogs, applications internes|

**Méthodes de validation DV :**

```bash
# Méthode 1 : Validation par Email
# La CA envoie un email à : admin@example.com, webmaster@example.com, etc.
# Le demandeur clique sur un lien de validation

# Méthode 2 : Validation DNS (défi DNS)
# Ajouter un enregistrement TXT au DNS
_acme-challenge.example.com.  IN  TXT  "validation-token-123456"

# Méthode 3 : Validation HTTP (fichier sur le serveur web)
# Créer un fichier accessible publiquement
http://example.com/.well-known/acme-challenge/token-file
# Contenu : validation-token-123456
```

> [!example] Exemple pratique : Let's Encrypt Let's Encrypt utilise exclusivement la validation DV automatisée via le protocole ACME, permettant des certificats gratuits en quelques secondes.

#### 2️⃣ **OV - Organization Validation (Validation d'organisation)**

**Niveau intermédiaire** : vérifie le domaine ET l'existence légale de l'organisation.

|Aspect|Description|
|---|---|
|**Vérification**|Domaine + existence légale de l'entreprise|
|**Durée**|1 à 3 jours ouvrés|
|**Coût**|Modéré (100-300€/an)|
|**Documents**|Extraits du registre du commerce, documents légaux|
|**Usage**|Sites d'entreprises, intranets, applications professionnelles|

**Processus de validation OV :**

1. Vérification du domaine (comme DV)
2. Vérification de l'existence légale de l'organisation (registre du commerce)
3. Appel téléphonique de confirmation à l'organisation
4. Vérification que le demandeur est autorisé à représenter l'organisation

> [!info] Affichage Les certificats OV affichent le nom de l'organisation dans les détails du certificat (mais pas dans la barre d'adresse du navigateur).

#### 3️⃣ **EV - Extended Validation (Validation étendue)**

**Niveau le plus élevé** : processus de vérification rigoureux et standardisé selon les guidelines CA/Browser Forum.

|Aspect|Description|
|---|---|
|**Vérification**|Complète : domaine, organisation, existence légale, adresse physique, demandeur|
|**Durée**|3 à 7 jours ouvrés|
|**Coût**|Élevé (300-1500€/an)|
|**Documents**|Nombreux : KBIS, statuts, preuves d'adresse, autorisation signée|
|**Usage**|Sites e-commerce, banques, plateformes de paiement|

**Exigences supplémentaires EV :**

- Vérification de l'adresse physique de l'organisation (visite ou documents officiels)
- Vérification de l'existence de l'organisation depuis au moins 3 ans
- Vérification de l'autorité du demandeur via des documents légaux
- Vérification du numéro de téléphone professionnel (dans les annuaires publics)
- Conformité aux standards CA/Browser Forum EV Guidelines

> [!tip] Évolution de l'affichage EV Historiquement, les certificats EV affichaient le nom de l'organisation en vert dans la barre d'adresse. Depuis 2019, la plupart des navigateurs ont supprimé cet indicateur visuel, réduisant l'intérêt commercial des certificats EV.

### 🔄 Processus de validation type

```
┌─────────────────┐
│   Réception     │
│   du CSR        │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Vérification   │
│  du domaine     │  ◄── DV s'arrête ici
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Vérification   │
│  organisation   │  ◄── OV s'arrête ici
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Vérification   │
│  étendue (EV)   │  ◄── EV complète tout
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Émission du   │
│   certificat    │
└─────────────────┘
```

### ⚙️ Validation automatisée vs manuelle

**Validation automatisée (DV) :**

- Protocoles : ACME (Automatic Certificate Management Environment)
- Avantages : rapide, gratuit, renouvelable automatiquement
- Inconvénients : aucune vérification d'identité réelle

**Validation manuelle (OV/EV) :**

- Processus : intervention humaine, vérification de documents
- Avantages : forte assurance d'identité
- Inconvénients : lent, coûteux, renouvellement manuel

> [!warning] Pièges courants
> 
> - **Emails de validation expirés** : les liens de validation DV expirent généralement sous 24-72h
> - **Informations WHOIS privées** : peuvent bloquer la validation par email
> - **Documents périmés** : les extraits du registre du commerce doivent être récents (< 3 mois)
> - **Incohérences** : le nom dans le CSR doit correspondre exactement aux documents légaux
> - **Domaines internationaux** : peuvent nécessiter des validations spécifiques (IDN)

### 🎯 Choix du niveau de validation

**Utilisez DV si :**

- Besoin de certificats rapidement
- Budget limité ou certificats gratuits souhaités
- Site web standard sans transactions financières
- Environnement de test/développement

**Utilisez OV si :**

- Site d'entreprise professionnelle
- Besoin de montrer la légitimité de l'organisation
- Applications internes critiques
- Exigences de conformité modérées

**Utilisez EV si :**

- Site e-commerce avec paiements en ligne
- Institutions financières ou bancaires
- Applications traitant des données très sensibles
- Exigences réglementaires strictes (PCI-DSS, etc.)

---

## 3. Émission du certificat

### ✅ Processus d'émission

Une fois la validation terminée, l'Autorité de Certification génère le certificat numérique signé. C'est l'étape où la CA appose sa signature cryptographique sur le certificat, garantissant son authenticité.

> [!info] Signature de la CA La CA utilise sa propre clé privée pour signer le certificat. Cette signature peut ensuite être vérifiée par n'importe qui possédant la clé publique de la CA (présente dans le certificat racine).

### 🔨 Génération du certificat

**Côté CA, le processus est le suivant :**

```bash
# La CA génère le certificat à partir du CSR
openssl x509 -req \
  -in server.csr \
  -CA ca-cert.pem \
  -CAkey ca-key.pem \
  -CAcreateserial \
  -out server.crt \
  -days 365 \
  -sha256

# Options expliquées :
# -req           : indique qu'on traite un CSR
# -in            : fichier CSR en entrée
# -CA            : certificat de la CA (clé publique)
# -CAkey         : clé privée de la CA pour signer
# -CAcreateserial : créer un numéro de série unique
# -out           : certificat signé en sortie
# -days          : durée de validité
# -sha256        : algorithme de hachage (SHA-256)
```

> [!warning] Réduction des durées de validité Depuis septembre 2020, les navigateurs limitent la durée maximale des certificats SSL/TLS à **398 jours** (environ 13 mois). Les certificats émis pour des durées plus longues seront rejetés.

### 📄 Structure du certificat émis

Un certificat X.509 contient plusieurs sections importantes :

**Informations de base :**

- **Numéro de série** : identifiant unique du certificat
- **Émetteur (Issuer)** : informations sur la CA qui a signé
- **Sujet (Subject)** : informations sur l'entité certifiée (celles du CSR)
- **Clé publique** : la clé publique extraite du CSR
- **Dates de validité** : début et fin de validité

**Exemple de lecture d'un certificat :**

```bash
# Afficher le contenu d'un certificat
openssl x509 -in server.crt -text -noout

# Extraire des informations spécifiques
openssl x509 -in server.crt -noout -subject
openssl x509 -in server.crt -noout -issuer
openssl x509 -in server.crt -noout -dates
openssl x509 -in server.crt -noout -serial
```

> [!example] Sortie type
> 
> ```
> Certificate:
>     Serial Number: 4096 (0x1000)
>     Issuer: C=FR, O=Example CA, CN=Example Root CA
>     Validity
>         Not Before: Dec 29 10:00:00 2024 GMT
>         Not After : Dec 29 10:00:00 2025 GMT
>     Subject: C=FR, O=Example Corp, CN=www.example.com
>     Subject Public Key Info:
>         Public Key Algorithm: rsaEncryption
>             Public-Key: (2048 bit)
>     X509v3 extensions:
>         X509v3 Key Usage: critical
>             Digital Signature, Key Encipherment
>         X509v3 Extended Key Usage:
>             TLS Web Server Authentication
>         X509v3 Subject Alternative Name:
>             DNS:www.example.com, DNS:example.com
> ```

### 🔗 Chaîne de certification

Le certificat émis fait partie d'une **chaîne de confiance** :

```
┌─────────────────────┐
│  Certificat Racine  │  ◄── Pré-installé dans les navigateurs
│   (Root CA)         │      Auto-signé
└──────────┬──────────┘
           │ signe
           ▼
┌─────────────────────┐
│  Certificat         │  ◄── Émis par la racine
│  Intermédiaire      │      Utilisé pour signer les certificats finaux
│  (Intermediate CA)  │
└──────────┬──────────┘
           │ signe
           ▼
┌─────────────────────┐
│  Certificat Final   │  ◄── Certificat du serveur/utilisateur
│  (End Entity)       │      Celui reçu après émission
└─────────────────────┘
```

> [!tip] Pourquoi des certificats intermédiaires ?
> 
> - **Sécurité** : la clé privée racine est conservée hors ligne, ultra-sécurisée
> - **Révocation** : plus facile de révoquer un intermédiaire que la racine
> - **Flexibilité** : permet d'avoir plusieurs intermédiaires pour différents usages

### 📦 Formats de certificats

Le certificat peut être fourni dans différents formats :

|Format|Extension|Description|Usage|
|---|---|---|---|
|**PEM**|`.pem`, `.crt`, `.cer`|Base64, lisible texte, délimité par `-----BEGIN CERTIFICATE-----`|Linux, Apache, NGINX|
|**DER**|`.der`, `.cer`|Binaire, non lisible|Windows, Java|
|**PKCS#7**|`.p7b`, `.p7c`|Conteneur de certificats (peut inclure la chaîne)|Windows, Tomcat|
|**PKCS#12**|`.pfx`, `.p12`|Archive incluant certificat + clé privée (protégée par mot de passe)|Windows, échange sécurisé|

**Conversions entre formats :**

```bash
# PEM vers DER
openssl x509 -in cert.pem -outform DER -out cert.der

# DER vers PEM
openssl x509 -in cert.der -inform DER -out cert.pem

# PEM vers PKCS#12 (avec clé privée)
openssl pkcs12 -export \
  -out certificate.pfx \
  -inkey private.key \
  -in certificate.crt \
  -certfile ca-chain.crt

# PKCS#12 vers PEM
openssl pkcs12 -in certificate.pfx -out certificate.pem -nodes
```

### 🎫 Numéro de série et identifiant

Chaque certificat possède :

**Numéro de série :**

- Unique pour chaque certificat émis par une CA
- Utilisé pour identifier le certificat lors de la révocation
- Généralement un grand nombre hexadécimal (ex: `04:5B:7C:...`)

```bash
# Extraire le numéro de série
openssl x509 -in server.crt -noout -serial
```

**Empreinte (Fingerprint) :**

- Hash cryptographique du certificat complet
- Utilisé pour vérifier l'intégrité et l'authenticité
- Calculé avec SHA-1 ou SHA-256

```bash
# Calculer l'empreinte SHA-256
openssl x509 -in server.crt -noout -fingerprint -sha256

# Calculer l'empreinte SHA-1
openssl x509 -in server.crt -noout -fingerprint -sha1
```

> [!example] Empreinte type
> 
> ```
> SHA256 Fingerprint=
> A1:B2:C3:D4:E5:F6:01:23:45:67:89:AB:CD:EF:01:23:45:67:89:AB:CD:EF:01:23:45:67:89:AB:CD:EF:01:23
> ```

### ✔️ Vérifications post-émission

Avant d'utiliser le certificat, effectuer plusieurs vérifications :

```bash
# 1. Vérifier que le certificat correspond à la clé privée
openssl x509 -noout -modulus -in server.crt | openssl md5
openssl rsa -noout -modulus -in server.key | openssl md5
# Les deux hash doivent être identiques

# 2. Vérifier la chaîne de certification
openssl verify -CAfile ca-bundle.crt server.crt

# 3. Vérifier les dates de validité
openssl x509 -in server.crt -noout -dates

# 4. Vérifier que le CN et les SAN sont corrects
openssl x509 -in server.crt -noout -subject -ext subjectAltName

# 5. Tester la connexion SSL (pour un certificat serveur)
openssl s_client -connect www.example.com:443 -servername www.example.com
```

> [!warning] Erreurs courantes
> 
> - **Certificat et clé privée non-concordants** : erreur de démarrage du serveur web
> - **Chaîne de certification incomplète** : erreurs de validation dans les navigateurs
> - **Dates de validité incorrectes** : certificat rejeté si la date système est en dehors de la période
> - **CN ou SAN manquants** : erreur "Name mismatch" dans les navigateurs
> - **Extensions manquantes** : certains serveurs/clients requièrent des extensions spécifiques (Key Usage, Extended Key Usage)

### 🚀 Automatisation de l'émission

Pour les environnements avec de nombreux certificats :

```bash
# Exemple avec certbot (Let's Encrypt)
certbot certonly \
  --standalone \
  -d www.example.com \
  -d example.com \
  --email admin@example.com \
  --agree-tos \
  --non-interactive

# Script d'automatisation interne
#!/bin/bash
# Génération, signature et vérification automatiques
openssl req -new -newkey rsa:2048 -nodes \
  -keyout "$HOSTNAME.key" \
  -out "$HOSTNAME.csr" \
  -subj "/CN=$HOSTNAME"

# Soumettre le CSR à la CA interne
curl -X POST https://ca.internal/api/sign \
  -F "csr=@$HOSTNAME.csr" \
  -o "$HOSTNAME.crt"

# Vérifier automatiquement
openssl verify -CAfile ca-bundle.crt "$HOSTNAME.crt" || exit 1
```

---

## 4. Publication et distribution

### 📢 Pourquoi publier les certificats ?

Une fois émis, les certificats doivent être rendus accessibles pour permettre leur utilisation et leur vérification. La publication assure la disponibilité des certificats pour les systèmes qui en ont besoin.

> [!info] Différence avec l'installation La **publication** rend le certificat disponible (dans des répertoires, bases de données), tandis que l'**installation** consiste à le configurer sur un système spécifique (serveur web, messagerie, etc.).

### 🗂️ Méthodes de publication

#### 1️⃣ **Dépôt de certificats (Certificate Repository)**

Certaines CA maintiennent des dépôts publics où les certificats sont accessibles :

- **Répertoires LDAP** : protocole standardisé pour accéder aux certificats
- **Serveurs HTTP** : téléchargement via URL publique
- **Bases de données internes** : pour les PKI d'entreprise

```bash
# Exemple : télécharger un certificat depuis un dépôt HTTP
wget https://ca.example.com/certs/server-cert.crt

# Rechercher un certificat dans un annuaire LDAP
ldapsearch -x -H ldap://ldap.example.com \
  -b "ou=certificates,dc=example,dc=com" \
  "(cn=www.example.com)"
```

#### 2️⃣ **Distribution directe**

Le certificat est transmis directement au demandeur :

**Par email sécurisé :**

- Fichier joint (généralement en PEM)
- Lien de téléchargement sécurisé
- Protection par mot de passe ou chiffrement

**Via interface web :**

- Portail de la CA
- Téléchargement après authentification
- Récupération de la chaîne complète

**Par API :**

- Automatisation via scripts
- Récupération programmatique
- Intégration dans des workflows CI/CD

```bash
# Exemple : récupération via API
curl -X GET https://ca.example.com/api/certificates/12345 \
  -H "Authorization: Bearer $API_TOKEN" \
  -o server.crt
```

### 🔗 Chaîne de certification complète

Pour une vérification réussie, les clients doivent avoir accès à toute la chaîne :

**Composition de la chaîne :**

```bash
# Créer un fichier bundle contenant la chaîne complète
cat server.crt intermediate.crt root.crt > fullchain.pem

# Ou seulement certificat + intermédiaire (la racine est pré-installée)
cat server.crt intermediate.crt > chain.pem
```

**Structure du bundle :**

```
-----BEGIN CERTIFICATE-----
[Certificat du serveur]
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
[Certificat intermédiaire]
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
[Certificat racine - optionnel]
-----END CERTIFICATE-----
```

> [!tip] Ordre des certificats L'ordre est crucial : du certificat final vers la racine. Un ordre incorrect causera des erreurs de validation.

### ⚙️ Installation sur les serveurs

Une fois le certificat reçu, il doit être installé sur les systèmes :

#### **Serveur web Apache**

```bash
# Configuration SSL dans Apache
<VirtualHost *:443>
    ServerName www.example.com
    
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/server.crt
    SSLCertificateKeyFile /etc/ssl/private/server.key
    SSLCertificateChainFile /etc/ssl/certs/intermediate.crt
    
    # Ou utiliser un bundle complet
    # SSLCertificateFile /etc/ssl/certs/fullchain.pem
</VirtualHost>

# Vérifier la configuration
apachectl configtest

# Recharger Apache
systemctl reload apache2
```

#### **Serveur web NGINX**

```bash
# Configuration SSL dans NGINX
server {
    listen 443 ssl;
    server_name www.example.com;
    
    # NGINX nécessite certificat + chaîne dans le même fichier
    ssl_certificate /etc/ssl/certs/fullchain.pem;
    ssl_certificate_key /etc/ssl/private/server.key;
    
    # Protocoles et ciphers recommandés
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
}

# Vérifier la configuration
nginx -t

# Recharger NGINX
systemctl reload nginx
```

#### **Serveur mail (Postfix)**

```bash
# Configuration dans /etc/postfix/main.cf
smtpd_tls_cert_file = /etc/ssl/certs/mail.crt
smtpd_tls_key_file = /etc/ssl/private/mail.key
smtpd_tls_CAfile = /etc/ssl/certs/ca-bundle.crt

# Recharger Postfix
systemctl reload postfix
```

#### **Applications Java**

```bash
# Import dans un keystore Java
keytool -import \
  -alias server-cert \
  -file server.crt \
  -keystore /path/to/keystore.jks \
  -storepass changeit

# Import de la chaîne complète
keytool -importcert \
  -alias intermediate \
  -file intermediate.crt \
  -keystore /path/to/keystore.jks
```

### 🔒 Sécurisation de la distribution

**Permissions des fichiers :**

```bash
# Clé privée : accessible uniquement par le propriétaire
chmod 600 /etc/ssl/private/server.key
chown root:root /etc/ssl/private/server.key

# Certificats : lisibles par tous (publics)
chmod 644 /etc/ssl/certs/server.crt
chmod 644 /etc/ssl/certs/fullchain.pem

# Répertoire des clés privées : accès restreint
chmod 700 /etc/ssl/private/
```

> [!warning] Sécurité critique
> 
> - **Jamais de clé privée dans les certificats publiés** : seul le certificat (clé publique) est distribué
> - **Protection des clés privées** : permissions strictes, chiffrement au repos
> - **Séparation des privilèges** : seuls les comptes de service nécessaires doivent accéder aux clés
> - **Logs d'accès** : tracer qui accède aux certificats et clés privées

### 📱 Distribution aux clients

Pour que les clients puissent valider les certificats, ils doivent avoir :

**Certificats racine de confiance :**

- Pré-installés dans les navigateurs, OS, applications
- Mis à jour régulièrement par les éditeurs
- Les CA racines publiques sont dans les "trust stores"

**Certificats intermédiaires :**

- Fournis par le serveur lors de la connexion SSL/TLS
- Peuvent être téléchargés depuis le site de la CA
- Nécessaires si la racine seule ne suffit pas

```bash
# Vérifier les certificats racines sur Linux
ls -l /etc/ssl/certs/
cat /etc/ssl/certs/ca-certificates.crt

# Sur Windows : Gestionnaire de certificats
certmgr.msc

# Sur macOS : Trousseau d'accès
/Applications/Utilities/Keychain Access.app
```

### 🌐 Transparence des certificats (Certificate Transparency)

Depuis 2018, les navigateurs exigent que les certificats SSL/TLS publics soient enregistrés dans des journaux CT :

**Qu'est-ce que CT ?**

- Journaux publics et infalsifiables de tous les certificats émis
- Permet de détecter les certificats frauduleux ou mal émis
- Requis par Chrome, Safari, Firefox pour les certificats publics

**Vérification CT :**

```bash
# Vérifier si un certificat a des SCT (Signed Certificate Timestamps)
openssl x509 -in server.crt -noout -text | grep -A 10 "CT Precertificate SCTs"
```

**Recherche dans les logs CT :**

```bash
# Via crt.sh (interface web des logs CT)
curl "https://crt.sh/?q=example.com&output=json"

# Rechercher tous les certificats pour un domaine
curl "https://crt.sh/?q=%.example.com&output=json"
```

> [!tip] Avantages de CT
> 
> - **Détection de certificats non autorisés** : surveiller les certificats émis pour vos domaines
> - **Audit public** : transparence totale sur l'émission de certificats
> - **Prévention de la fraude** : difficile d'émettre un certificat malveillant sans être détecté

### 📊 Documentation de la distribution

Pour une gestion efficace, documenter :

|Élément|Information à enregistrer|
|---|---|
|**Certificat**|Numéro de série, empreinte SHA-256, dates de validité|
|**Serveur/système**|Où le certificat est installé|
|**Responsable**|Qui gère ce certificat|
|**Renouvellement**|Date de prochain renouvellement|
|**Chaîne**|Certificats intermédiaires utilisés|
|**Procédure**|Documentation d'installation spécifique|

```bash
# Exemple de fichier de suivi (certificates.csv)
Serial,Domain,Server,Installed,Expires,Responsible
1234ABCD,www.example.com,web01.internal,2024-12-29,2025-12-29,admin@example.com
5678EFGH,mail.example.com,mail01.internal,2024-11-15,2025-11-15,postmaster@example.com
```

> [!example] Automatisation du suivi Des outils comme Certbot, cert-manager (Kubernetes), ou des scripts personnalisés peuvent automatiser le suivi et le renouvellement des certificats.

---

## 5. Renouvellement

### 🔄 Pourquoi renouveler ?

Les certificats ont une durée de vie limitée pour des raisons de sécurité. Le renouvellement consiste à obtenir un nouveau certificat avant l'expiration de l'ancien.

> [!info] Limites de durée
> 
> - **Certificats SSL/TLS publics** : maximum 398 jours (13 mois)
> - **Certificats internes** : variable selon la politique (1-5 ans)
> - **Certificats code signing** : généralement 1-3 ans

### ⏰ Quand renouveler ?

**Recommandations temporelles :**

|Durée totale|Début du renouvellement|Raison|
|---|---|---|
|90 jours|30 jours avant|Let's Encrypt standard|
|1 an|60-90 jours avant|Marge pour les imprévus|
|2+ ans|90-120 jours avant|Temps pour validation OV/EV|

> [!warning] Jamais attendre l'expiration Un certificat expiré provoque :
> 
> - Interruption de service (sites inaccessibles)
> - Alertes de sécurité pour les utilisateurs
> - Perte de confiance
> - Problème de conformité

### 🔁 Processus de renouvellement

Le renouvellement suit généralement le même cycle que l'émission initiale :

**Étapes du renouvellement :**

1. **Génération d'un nouveau CSR** (recommandé : nouvelle paire de clés)
2. **Soumission à la CA**
3. **Validation** (simplifiée si renouvellement avec la même CA)
4. **Émission du nouveau certificat**
5. **Installation** (en parallèle ou remplacement)
6. **Vérification**
7. **Révocation de l'ancien** (optionnel, si compromis)

```bash
# Renouvellement standard : générer nouveau CSR
openssl req -new -newkey rsa:2048 -nodes \
  -keyout server-new.key \
  -out server-new.csr \
  -subj "/C=FR/O=Example Corp/CN=www.example.com"

# Alternative : réutiliser la clé privée existante (moins recommandé)
openssl req -new \
  -key server.key \
  -out server-renewal.csr \
  -subj "/C=FR/O=Example Corp/CN=www.example.com"
```

> [!tip] Nouvelle clé vs réutilisation **Recommandé** : générer une nouvelle paire de clés à chaque renouvellement
> 
> - Limite l'exposition en cas de compromission
> - Meilleure pratique de sécurité (rotation des clés)
> 
> **Acceptable** : réutiliser la clé existante
> 
> - Plus simple administrativement
> - Évite de mettre à jour tous les systèmes
> - Risque : si la clé est compromise, tous les certificats (ancien et nouveau) le sont

### 🤖 Renouvellement automatique

**Avec Let's Encrypt (Certbot) :**

```bash
# Renouvellement manuel
certbot renew

# Tester le renouvellement (dry-run)
certbot renew --dry-run

# Configuration du renouvellement automatique (cron/systemd timer)
# Certbot installe automatiquement un timer systemd ou cron

# Vérifier le timer systemd
systemctl status certbot.timer
systemctl list-timers certbot

# Exemple de cron (ancienne méthode)
0 3 * * * certbot renew --quiet --post-hook "systemctl reload nginx"
```

**Script personnalisé pour PKI interne :**

```bash
#!/bin/bash
# renew-certificate.sh

CERT_FILE="/etc/ssl/certs/server.crt"
DAYS_BEFORE_EXPIRY=30

# Vérifier la date d'expiration
EXPIRY_DATE=$(openssl x509 -in "$CERT_FILE" -noout -enddate | cut -d= -f2)
EXPIRY_EPOCH=$(date -d "$EXPIRY_DATE" +%s)
TODAY_EPOCH=$(date +%s)
DAYS_LEFT=$(( ($EXPIRY_EPOCH - $TODAY_EPOCH) / 86400 ))

if [ $DAYS_LEFT -lt $DAYS_BEFORE_EXPIRY ]; then
    echo "Certificat expire dans $DAYS_LEFT jours. Renouvellement..."
    
    # Générer nouveau CSR
    openssl req -new -key /etc/ssl/private/server.key \
      -out /tmp/renewal.csr \
      -subj "/C=FR/O=Example/CN=$(hostname)"
    
    # Soumettre à la CA interne
    curl -X POST https://ca.internal/api/renew \
      -F "csr=@/tmp/renewal.csr" \
      -o /tmp/new-cert.crt
    
    # Vérifier le nouveau certificat
    if openssl verify -CAfile /etc/ssl/certs/ca-bundle.crt /tmp/new-cert.crt; then
        # Backup de l'ancien
        cp "$CERT_FILE" "$CERT_FILE.bak.$(date +%Y%m%d)"
        
        # Installer le nouveau
        mv /tmp/new-cert.crt "$CERT_FILE"
        
        # Recharger les services
        systemctl reload nginx
        echo "Certificat renouvelé avec succès"
    else
        echo "ERREUR : validation du nouveau certificat échouée"
        exit 1
    fi
else
    echo "Certificat valide encore $DAYS_LEFT jours"
fi
```

### 📊 Monitoring des expirations

**Outils de surveillance :**

```bash
# Script simple de vérification
#!/bin/bash
# check-cert-expiry.sh

DOMAIN="www.example.com"
DAYS_WARNING=30
DAYS_CRITICAL=7

# Récupérer la date d'expiration
EXPIRY=$(echo | openssl s_client -servername $DOMAIN \
  -connect $DOMAIN:443 2>/dev/null \
  | openssl x509 -noout -enddate | cut -d= -f2)

EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s)
TODAY_EPOCH=$(date +%s)
DAYS_LEFT=$(( ($EXPIRY_EPOCH - $TODAY_EPOCH) / 86400 ))

if [ $DAYS_LEFT -lt $DAYS_CRITICAL ]; then
    echo "CRITICAL: Certificat $DOMAIN expire dans $DAYS_LEFT jours!"
    exit 2
elif [ $DAYS_LEFT -lt $DAYS_WARNING ]; then
    echo "WARNING: Certificat $DOMAIN expire dans $DAYS_LEFT jours"
    exit 1
else
    echo "OK: Certificat $DOMAIN valide encore $DAYS_LEFT jours"
    exit 0
fi
```

**Outils professionnels :**

- **Nagios/Icinga** : plugins `check_ssl_cert`
- **Prometheus + Grafana** : exporteur SSL/TLS
- **SSL monitoring SaaS** : SSL Labs, Qualys, etc.
- **Cert-manager (Kubernetes)** : renouvellement automatique

```bash
# Monitoring avec Prometheus (exemple de configuration)
# blackbox_exporter pour vérifier les certificats SSL
scrape_configs:
  - job_name: 'ssl_expiry'
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
        - https://www.example.com
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: blackbox-exporter:9115
```

### 🎯 Stratégies de renouvellement

**Renouvellement sans interruption :**

```bash
# 1. Obtenir le nouveau certificat
# 2. Installer en parallèle avec l'ancien

# Configuration NGINX avec basculement progressif
server {
    listen 443 ssl;
    server_name www.example.com;
    
    # Nouveau certificat
    ssl_certificate /etc/ssl/certs/server-new.crt;
    ssl_certificate_key /etc/ssl/private/server-new.key;
    
    # Tester la configuration
    # nginx -t
    
    # Rechargement sans interruption
    # nginx -s reload
}
```

**Renouvellement par roulement (pour clusters) :**

```bash
# 1. Renouveler sur serveur 1, retirer du load balancer
# 2. Tester
# 3. Remettre en production
# 4. Répéter pour les autres serveurs

# Exemple avec HAProxy
echo "disable server backend/web01" | socat stdio /var/run/haproxy.sock
# ... renouveler le certificat sur web01 ...
echo "enable server backend/web01" | socat stdio /var/run/haproxy.sock
```

### 📝 Checklist de renouvellement

- [ ] Vérifier la date d'expiration actuelle
- [ ] Générer un nouveau CSR (idéalement avec nouvelle clé)
- [ ] Soumettre le CSR à la CA
- [ ] Attendre la validation et l'émission
- [ ] Télécharger le nouveau certificat et la chaîne
- [ ] Vérifier le certificat (dates, CN, SAN)
- [ ] Tester la correspondance clé/certificat
- [ ] Sauvegarder l'ancien certificat
- [ ] Installer le nouveau certificat
- [ ] Tester la configuration (serveur web, application)
- [ ] Recharger/redémarrer les services concernés
- [ ] Vérifier la connexion SSL/TLS
- [ ] Mettre à jour la documentation
- [ ] Planifier le prochain renouvellement

> [!warning] Erreurs fréquentes lors du renouvellement
> 
> - **Oublier de renouveler** : mettre en place des alertes automatiques
> - **Renouveler trop tard** : validation OV/EV peut prendre plusieurs jours
> - **Ne pas tester** : toujours vérifier en pré-production
> - **Mauvaise chaîne de certificats** : inclure les certificats intermédiaires
> - **Oublier des serveurs** : inventaire à jour de tous les certificats
> - **Cache DNS/CDN** : peut retarder la propagation du nouveau certificat

---

## 6. Révocation

### 🚫 Qu'est-ce que la révocation ?

La révocation est l'action d'invalider un certificat avant sa date d'expiration normale. Un certificat révoqué ne doit plus être considéré comme valide, même s'il n'a pas encore expiré.

> [!info] Distinction importante
> 
> - **Expiration** : fin naturelle de la durée de validité (date prévue)
> - **Révocation** : invalidation anticipée et délibérée du certificat

### ⚠️ Raisons de révoquer un certificat

**Raisons critiques (révocation immédiate) :**

|Raison|Code CRL|Description|
|---|---|---|
|Clé compromise|`keyCompromise (1)`|La clé privée a été exposée ou volée|
|CA compromise|`cACompromise (2)`|L'autorité de certification elle-même est compromise|
|Changement d'affiliation|`affiliationChanged (3)`|L'entité certifiée change d'organisation|
|Certificat remplacé|`superseded (4)`|Remplacé par un nouveau certificat|
|Cessation d'activité|`cessationOfOperation (5)`|Le service/serveur n'est plus en service|
|Suspension|`certificateHold (6)`|Suspension temporaire (peut être levée)|
|Retrait du privilège|`removeFromCRL (8)`|Annulation d'une suspension|
|Informations invalides|`privilegeWithdrawn (9)`|Informations du certificat incorrectes|
|Attributs altérés|`aACompromise (10)`|Attributs du certificat modifiés|

**Exemples concrets nécessitant révocation :**

- Clé privée trouvée dans un dépôt Git public
- Serveur compromis lors d'une intrusion
- Employé quittant l'entreprise (certificat personnel)
- Erreur dans les informations du certificat (mauvais nom de domaine)
- Migration vers un nouveau certificat avec algorithme plus robuste
- Vente ou transfert d'un nom de domaine

> [!warning] Urgence de la révocation En cas de compromission de clé privée, la révocation doit être **immédiate** (minutes, pas heures). Chaque minute compte.

### 🔐 Mécanismes de révocation

Il existe deux méthodes principales pour vérifier si un certificat est révoqué :

#### 1️⃣ **CRL - Certificate Revocation List**

Une **liste noire** de certificats révoqués, publiée périodiquement par la CA.

**Caractéristiques :**

- Fichier téléchargeable contenant tous les numéros de série révoqués
- Mis à jour périodiquement (heures ou jours)
- Peut devenir très volumineux (centaines de Mo)
- Approche traditionnelle, mais moins efficace

```bash
# Télécharger une CRL
wget http://crl.example.com/ca.crl

# Examiner une CRL
openssl crl -in ca.crl -inform DER -text -noout

# Vérifier si un certificat est dans la CRL
openssl verify -crl_check -CRLfile ca.crl -CAfile ca-cert.pem server.crt
```

**Exemple de sortie CRL :**

```
Certificate Revocation List (CRL):
    Issuer: C=FR, O=Example CA, CN=Example Root CA
    Last Update: Dec 29 10:00:00 2024 GMT
    Next Update: Dec 30 10:00:00 2025 GMT
Revoked Certificates:
    Serial Number: 1234ABCD
        Revocation Date: Dec 28 15:30:00 2024 GMT
        CRL Reason Code: Key Compromise
    Serial Number: 5678EFGH
        Revocation Date: Dec 25 09:00:00 2024 GMT
        CRL Reason Code: Superseded
```

**Limites des CRL :**

- ❌ Taille croissante au fil du temps
- ❌ Délai de mise à jour (fenêtre de vulnérabilité)
- ❌ Bande passante importante pour télécharger
- ❌ Peu adapté aux certificats courte durée

#### 2️⃣ **OCSP - Online Certificate Status Protocol**

Protocole en temps réel pour vérifier le statut d'un certificat spécifique.

**Caractéristiques :**

- Requête en ligne pour un certificat donné
- Réponse en temps réel (secondes)
- Léger (seulement le certificat concerné)
- Approche moderne et efficace

```bash
# Extraire l'URL OCSP d'un certificat
openssl x509 -in server.crt -noout -ocsp_uri

# Effectuer une vérification OCSP manuelle
openssl ocsp \
  -issuer ca-cert.pem \
  -cert server.crt \
  -url http://ocsp.example.com \
  -CAfile ca-cert.pem

# Réponse possible :
# Response verify OK
# server.crt: good
#     This Update: Dec 29 10:00:00 2024 GMT
#     Next Update: Dec 30 10:00:00 2025 GMT
```

**Statuts OCSP possibles :**

- `good` : certificat valide, non révoqué
- `revoked` : certificat révoqué
- `unknown` : la CA ne connaît pas ce certificat

> [!tip] OCSP Stapling Technique où le serveur demande la réponse OCSP et la "agrafe" (staple) à la connexion TLS, évitant au client de contacter directement le serveur OCSP. Améliore :
> 
> - Performance (pas de requête supplémentaire du client)
> - Confidentialité (la CA ne voit pas les requêtes des clients)
> - Fiabilité (fonctionne même si OCSP est indisponible)

```bash
# Configuration NGINX avec OCSP Stapling
ssl_stapling on;
ssl_stapling_verify on;
ssl_trusted_certificate /etc/ssl/certs/ca-bundle.pem;

# Vérifier si OCSP Stapling fonctionne
openssl s_client -connect www.example.com:443 \
  -servername www.example.com \
  -status | grep "OCSP"
```

**Problème : OCSP Soft Fail**

- Si le serveur OCSP est indisponible, les navigateurs acceptent souvent le certificat par défaut
- Crée une fenêtre de vulnérabilité
- OCSP Must-Staple (extension) peut forcer une vérification stricte

### 📝 Processus de révocation

**Étapes pour révoquer un certificat :**

1. **Demande de révocation**
    - Authentification du demandeur (prouvé qu'il est le propriétaire)
    - Indication de la raison de révocation
    - Généralement via portail web de la CA

```bash
# Exemple avec Certbot (Let's Encrypt)
certbot revoke --cert-path /etc/letsencrypt/live/example.com/cert.pem

# Avec raison spécifique
certbot revoke --cert-path /etc/letsencrypt/live/example.com/cert.pem \
  --reason keycompromise
```

2. **Traitement par la CA**
    
    - Vérification de l'authenticité de la demande
    - Ajout du certificat à la CRL
    - Mise à jour du répondeur OCSP
    - Notification (optionnelle)
3. **Publication de la révocation**
    
    - Nouvelle CRL publiée
    - OCSP répond "revoked" pour ce certificat
    - Propagation à travers l'infrastructure
4. **Vérification**
    
    - Confirmer que le certificat apparaît comme révoqué
    - Tester avec navigateurs et outils

```bash
# Vérifier qu'un certificat est bien révoqué
openssl verify -crl_check_all \
  -CRLfile combined.crl \
  -CAfile ca-cert.pem \
  server.crt

# Devrait retourner :
# error 23 at 0 depth lookup:certificate revoked
```

### ⚡ Révocation d'urgence

En cas de compromission critique :

**Checklist d'urgence :**

1. ✅ **Isoler immédiatement** : déconnecter le serveur/système compromis
2. ✅ **Demander la révocation** : contacter la CA en urgence
3. ✅ **Générer nouvelles clés** : créer une nouvelle paire de clés
4. ✅ **Obtenir nouveau certificat** : demande en urgence ou utiliser un certificat temporaire
5. ✅ **Installer le nouveau** : sur tous les systèmes concernés
6. ✅ **Vérifier la révocation** : confirmer via CRL/OCSP
7. ✅ **Investigation** : déterminer comment la compromission s'est produite
8. ✅ **Documentation** : enregistrer l'incident pour audit

```bash
# Script d'urgence pour révocation et renouvellement
#!/bin/bash
# emergency-revoke-renew.sh

DOMAIN="www.example.com"

echo "=== RÉVOCATION D'URGENCE ==="

# 1. Révoquer l'ancien certificat
certbot revoke \
  --cert-path /etc/letsencrypt/live/$DOMAIN/cert.pem \
  --reason keycompromise \
  --non-interactive

# 2. Supprimer les anciennes clés
rm -rf /etc/letsencrypt/live/$DOMAIN/
rm -rf /etc/letsencrypt/archive/$DOMAIN/
rm -rf /etc/letsencrypt/renewal/$DOMAIN.conf

# 3. Obtenir un nouveau certificat (nouvelles clés)
certbot certonly \
  --nginx \
  -d $DOMAIN \
  --non-interactive \
  --agree-tos \
  --email admin@example.com

# 4. Recharger NGINX
nginx -t && systemctl reload nginx

# 5. Vérifier le nouveau certificat
openssl s_client -connect $DOMAIN:443 -servername $DOMAIN </dev/null 2>/dev/null \
  | openssl x509 -noout -serial -dates

echo "=== RÉVOCATION ET RENOUVELLEMENT TERMINÉS ==="
```

### 🎯 Bonnes pratiques de révocation

> [!tip] Recommandations
> 
> - **Documenter les procédures** : avoir un plan de révocation d'urgence
> - **Contacts d'urgence** : connaître comment contacter la CA 24/7
> - **Automatisation** : scripts prêts pour révocation et remplacement rapides
> - **Tests réguliers** : exercices de révocation en environnement de test
> - **Monitoring post-révocation** : vérifier que l'ancien certificat n'est plus utilisé
> - **Communication** : informer les parties prenantes en cas de révocation majeure

### 📊 Impact de la révocation

**Conséquences d'un certificat révoqué :**

- ❌ **Navigateurs** : avertissement de sécurité, connexion bloquée
- ❌ **APIs** : échec de validation SSL/TLS
- ❌ **Applications** : refus de connexion
- ❌ **Clients email** : impossible d'envoyer/recevoir
- ❌ **Réputation** : impact sur la confiance des utilisateurs

> [!warning] Fenêtre de vulnérabilité Entre la compromission et la révocation effective, le certificat peut être utilisé malicieusement. C'est pourquoi la révocation doit être **immédiate** dès qu'une compromission est détectée.

### 🔄 Cycle complet : de la révocation au remplacement

```
┌──────────────────┐
│   Compromission  │
│     détectée     │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│   Révocation     │  ◄── IMMÉDIAT (minutes)
│   du certificat  │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│   Génération     │
│   nouvelles clés │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│   Demande et     │  ◄── Processus accéléré si urgent
│   émission       │
│   nouveau cert   │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│   Installation   │
│   et tests       │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│   Vérification   │
│   révocation     │
│   effective      │
└──────────────────┘
```

---

## 🎓 Récapitulatif du cycle de vie

Le cycle de vie complet d'un certificat numérique suit ces étapes essentielles :

### 📋 Vue d'ensemble

```
1. DEMANDE (CSR)
   ↓ Génération clé privée/publique
   ↓ Création du CSR avec informations

2. VALIDATION
   ↓ DV / OV / EV selon le niveau
   ↓ Vérification identité

3. ÉMISSION
   ↓ Signature par la CA
   ↓ Génération certificat X.509

4. PUBLICATION
   ↓ Distribution au demandeur
   ↓ Installation sur systèmes

5. UTILISATION
   ↓ Période de validité active
   ↓ Monitoring continu

6. RENOUVELLEMENT
   ↓ Avant expiration
   ↓ Nouveau cycle commence

OU

6. RÉVOCATION
   ↓ En cas de compromission
   ↓ Fin anticipée
```

### ⏱️ Chronologie type (certificat 1 an)

|Période|Étape|Actions|
|---|---|---|
|**J-7 à J-1**|Préparation|Génération CSR, validation identité|
|**J0**|Émission|Certificat signé et délivré|
|**J0 à J+30**|Déploiement|Installation, tests, mise en production|
|**J+30 à J+300**|Utilisation normale|Monitoring, surveillance expiration|
|**J+300 à J+330**|Pré-renouvellement|Alerte, planification renouvellement|
|**J+330 à J+365**|Renouvellement|Nouveau CSR, nouvelle émission|
|**J+365**|Expiration|L'ancien certificat expire naturellement|

> [!info] Superposition des certificats Lors du renouvellement, il est courant d'avoir une période où l'ancien et le nouveau certificat coexistent, permettant une transition en douceur.

### ✅ Points de contrôle essentiels

À chaque étape, des vérifications sont nécessaires :

**Lors de l'émission :**

- ✓ Signature de la CA valide
- ✓ Dates de validité correctes
- ✓ Correspondance clé privée/certificat
- ✓ Chaîne de certification complète

**Lors de l'installation :**

- ✓ Permissions fichiers appropriées
- ✓ Configuration serveur correcte
- ✓ Tests de connexion réussis
- ✓ Validation par navigateurs/clients

**Pendant l'utilisation :**

- ✓ Surveillance expiration
- ✓ Monitoring des alertes
- ✓ Vérification révocation (CRL/OCSP)
- ✓ Audit régulier

**Lors du renouvellement :**

- ✓ Planification anticipée
- ✓ Tests en pré-production
- ✓ Sauvegarde ancien certificat
- ✓ Validation post-installation

### 🔄 Meilleures pratiques globales

> [!tip] Gestion optimale du cycle de vie
> 
> **Automatisation maximale :**
> 
> - Utiliser des outils comme Certbot, cert-manager (Kubernetes)
> - Scripter les tâches répétitives
> - Intégrer dans les pipelines CI/CD
> 
> **Documentation rigoureuse :**
> 
> - Inventaire centralisé de tous les certificats
> - Procédures documentées et à jour
> - Historique des opérations (émissions, renouvellements, révocations)
> 
> **Monitoring proactif :**
> 
> - Alertes 60, 30, 15, 7 jours avant expiration
> - Vérification quotidienne des certificats critiques
> - Dashboards de visualisation
> 
> **Sécurité renforcée :**
> 
> - Clés privées chiffrées au repos
> - Permissions strictes (chmod 600)
> - Rotation régulière des clés
> - Procédures de révocation d'urgence testées
> 
> **Conformité et audit :**
> 
> - Logs de toutes les opérations
> - Revues périodiques de l'inventaire
> - Conformité aux politiques de sécurité
> - Préparation aux audits externes

### 🛠️ Outils de gestion du cycle de vie

**Outils en ligne de commande :**

- `openssl` : couteau suisse pour tout ce qui touche aux certificats
- `certbot` : automatisation Let's Encrypt
- `cfssl` : PKI de CloudFlare (génération et gestion)
- `step-ca` : CA interne moderne (Smallstep)

**Outils d'entreprise :**

- `cert-manager` : gestion automatique dans Kubernetes
- `Venafi` : plateforme commerciale de gestion PKI
- `HashiCorp Vault` : gestion de secrets avec PKI intégrée
- `Microsoft PKI` : solution Windows Server

**Monitoring et alertes :**

- `Nagios/Icinga` + plugins SSL
- `Prometheus` + exporteurs SSL
- `Zabbix` avec templates certificats
- Services SaaS : SSL Labs, Qualys

### 📊 Tableau récapitulatif des durées

|Événement|Timing recommandé|Raison|
|---|---|---|
|**Début renouvellement**|60-90 jours avant expiration|Marge pour validation et imprévus|
|**Alerte critique**|30 jours avant expiration|Dernière chance pour renouveler|
|**Alerte urgente**|7 jours avant expiration|Risque d'interruption de service|
|**Révocation d'urgence**|< 1 heure|Compromission détectée|
|**Mise à jour CRL**|Toutes les 24h (typique)|Équilibre fraîcheur/charge|
|**Réponse OCSP**|Temps réel|Vérification immédiate|
|**Durée max SSL/TLS public**|398 jours|Limitation des navigateurs|
|**Durée recommandée interne**|1-2 ans|Balance sécurité/administration|

### 🎯 Erreurs courantes à éviter

> [!warning] Pièges fréquents
> 
> **❌ Oubli de renouvellement**
> 
> - Solution : alertes automatiques multiples
> - Conséquence : interruption de service
> 
> **❌ Clé privée non protégée**
> 
> - Solution : permissions 600, chiffrement
> - Conséquence : compromission possible
> 
> **❌ Chaîne de certification incomplète**
> 
> - Solution : toujours inclure les intermédiaires
> - Conséquence : erreurs de validation client
> 
> **❌ Pas d'inventaire centralisé**
> 
> - Solution : base de données ou outil de gestion
> - Conséquence : perte de contrôle, certificats oubliés
> 
> **❌ Réutilisation excessive des clés**
> 
> - Solution : générer nouvelle paire à chaque renouvellement
> - Conséquence : compromission d'une clé affecte tous les certificats
> 
> **❌ Tests insuffisants**
> 
> - Solution : environnement de pré-production
> - Conséquence : problèmes en production
> 
> **❌ Pas de plan de révocation**
> 
> - Solution : procédures documentées et testées
> - Conséquence : panique et lenteur en cas d'incident
> 
> **❌ Ignorer les alertes de révocation**
> 
> - Solution : vérification CRL/OCSP active
> - Conséquence : acceptation de certificats révoqués

### 🔐 Checklist complète du cycle de vie

**Phase 1 - Préparation et demande**

- [ ] Définir les besoins (type de certificat, domaines, durée)
- [ ] Choisir la CA appropriée (publique vs interne)
- [ ] Générer une paire de clés (taille et algorithme appropriés)
- [ ] Créer le CSR avec toutes les informations correctes
- [ ] Vérifier le contenu du CSR
- [ ] Protéger la clé privée (permissions, backup chiffré)

**Phase 2 - Validation et émission**

- [ ] Soumettre le CSR à la CA
- [ ] Compléter le processus de validation (DV/OV/EV)
- [ ] Vérifier l'email/DNS/documents selon la méthode
- [ ] Attendre l'émission du certificat
- [ ] Télécharger le certificat et la chaîne complète
- [ ] Vérifier le certificat émis (dates, CN, SAN, empreinte)
- [ ] Confirmer la correspondance clé/certificat

**Phase 3 - Déploiement**

- [ ] Sauvegarder l'ancien certificat (si remplacement)
- [ ] Installer le nouveau certificat sur le(s) serveur(s)
- [ ] Configurer la chaîne de certification
- [ ] Tester en environnement de pré-production
- [ ] Vérifier la configuration (syntax check)
- [ ] Recharger/redémarrer les services
- [ ] Tester les connexions SSL/TLS
- [ ] Vérifier avec différents clients/navigateurs

**Phase 4 - Exploitation**

- [ ] Documenter dans l'inventaire centralisé
- [ ] Configurer le monitoring et les alertes
- [ ] Mettre en place la surveillance d'expiration
- [ ] Activer OCSP Stapling si possible
- [ ] Vérifier périodiquement le statut (non révoqué)
- [ ] Surveiller les logs d'erreur SSL/TLS
- [ ] Maintenir la documentation à jour

**Phase 5 - Renouvellement**

- [ ] Recevoir l'alerte de pré-expiration (60-90j)
- [ ] Planifier le renouvellement
- [ ] Générer nouveau CSR (idéalement nouvelles clés)
- [ ] Soumettre à la CA
- [ ] Suivre le processus de validation
- [ ] Récupérer le nouveau certificat
- [ ] Tester en pré-production
- [ ] Déployer en production
- [ ] Mettre à jour l'inventaire

**Phase 6 - Révocation (si nécessaire)**

- [ ] Identifier la raison de révocation
- [ ] Isoler le système compromis (si applicable)
- [ ] Demander la révocation à la CA immédiatement
- [ ] Générer de nouvelles clés
- [ ] Obtenir un nouveau certificat en urgence
- [ ] Déployer le nouveau certificat
- [ ] Vérifier que l'ancien est révoqué (CRL/OCSP)
- [ ] Investiguer la cause de compromission
- [ ] Documenter l'incident
- [ ] Revoir les procédures de sécurité

### 📈 Métriques de performance

Pour mesurer l'efficacité de la gestion du cycle de vie :

|Métrique|Objectif|Indicateur de|
|---|---|---|
|**Certificats expirés**|0|Qualité du monitoring|
|**Temps moyen de renouvellement**|< 1 heure|Efficacité des processus|
|**Certificats renouvelés à temps**|100%|Proactivité|
|**Temps de révocation d'urgence**|< 30 min|Réactivité incident|
|**Couverture du monitoring**|100%|Visibilité|
|**Incidents liés aux certificats**|0/mois|Maturité globale|
|**Taux d'automatisation**|> 80%|Modernité infrastructure|

### 🎓 Conclusion

Le cycle de vie d'un certificat numérique est un processus continu qui nécessite :

**Rigueur :**

- Procédures documentées et suivies
- Vérifications à chaque étape
- Discipline dans l'exécution

**Automatisation :**

- Réduction des erreurs humaines
- Gain de temps considérable
- Scalabilité améliorée

**Vigilance :**

- Monitoring permanent
- Alertes proactives
- Réactivité aux incidents

**Organisation :**

- Inventaire centralisé et à jour
- Responsabilités claires
- Documentation accessible

> [!tip] Philosophie de gestion Un certificat n'est jamais "installé et oublié". C'est un composant actif de votre infrastructure de sécurité qui nécessite une attention continue tout au long de son cycle de vie. L'objectif est d'atteindre un niveau de maturité où :
> 
> - Les renouvellements sont automatiques et transparents
> - Les expirations inattendues sont impossibles
> - Les révocations d'urgence sont rapides et maîtrisées
> - L'audit et la conformité sont facilités par une documentation exhaustive

Maîtriser ce cycle de vie permet de garantir la sécurité, la disponibilité et la conformité de votre infrastructure PKI, tout en minimisant les risques d'interruption de service et les incidents de sécurité.

---

**🔗 Liens avec les autres parties du cours :**

- La **structure des certificats** (X.509, extensions) est définie lors de l'émission
- Les **autorités de certification** gèrent l'ensemble du cycle (validation, émission, révocation)
- Les **protocoles de confiance** (CRL, OCSP) sont utilisés pour vérifier le statut
- Les **usages des certificats** (SSL/TLS, email, code signing) influencent les choix du cycle de vie la demande :**
- ✓ Informations correctes dans le CSR
- ✓ Algorithme et taille de clé appropriés
- ✓ Extensions nécessaires (SAN, Key Usage)

**Lors de