

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

## 🎯 Introduction

Les certificats numériques sont des outils polyvalents qui répondent à plusieurs besoins fondamentaux en sécurité informatique. Chaque cas d'usage exploite différemment les propriétés cryptographiques des certificats pour résoudre des problèmes spécifiques d'authentification, de confidentialité ou d'intégrité.

> [!info] Les trois piliers de la sécurité Les certificats numériques permettent d'assurer :
> 
> - **L'authentification** : vérifier l'identité d'une entité
> - **L'intégrité** : garantir que les données n'ont pas été modifiées
> - **La confidentialité** : protéger les données contre la lecture non autorisée

---

## 🌐 Authentification de serveurs web (HTTPS)

### Principe et objectif

L'authentification de serveurs web via HTTPS est le cas d'usage le plus répandu des certificats numériques. Son objectif principal est de garantir à l'utilisateur qu'il communique bien avec le serveur légitime et que la communication est chiffrée.

> [!example] Exemple concret Lorsque vous vous connectez à `https://banque.fr`, le certificat permet de vérifier que vous êtes bien connecté au site de votre banque et non à un site malveillant qui usurperait son identité.

### Comment ça fonctionne

Le processus se déroule lors de l'établissement de la connexion TLS/SSL :

1. **Le client initie la connexion** en contactant le serveur sur le port 443 (HTTPS)
2. **Le serveur présente son certificat** contenant sa clé publique et son identité
3. **Le client vérifie le certificat** en contrôlant :
    - La signature de l'autorité de certification (CA)
    - La validité des dates (début et expiration)
    - La correspondance entre le nom de domaine et le certificat
    - Le statut de révocation (via OCSP ou CRL)
4. **Une clé de session est négociée** de manière sécurisée
5. **La communication chiffrée démarre** avec cette clé de session

```bash
# Visualiser le certificat d'un serveur web
openssl s_client -connect exemple.com:443 -showcerts

# Extraire uniquement les informations du certificat
openssl s_client -connect exemple.com:443 2>/dev/null | openssl x509 -noout -text

# Vérifier la date d'expiration
openssl s_client -connect exemple.com:443 2>/dev/null | openssl x509 -noout -dates
```

### Types de certificats HTTPS

|Type|Validation|Usage typique|Prix|
|---|---|---|---|
|**DV (Domain Validated)**|Propriété du domaine uniquement|Blogs, sites personnels|Gratuit - €|
|**OV (Organization Validated)**|Identité de l'organisation|Sites commerciaux|€€|
|**EV (Extended Validation)**|Validation juridique complète|Banques, e-commerce sensible|€€€|

> [!tip] Certificats gratuits avec Let's Encrypt Let's Encrypt fournit des certificats DV gratuits et automatisables. C'est devenu le standard pour la majorité des sites web.
> 
> ```bash
> # Installation avec certbot
> sudo certbot --nginx -d exemple.com -d www.exemple.com
> 
> # Renouvellement automatique
> sudo certbot renew --dry-run
> ```

### Éléments vérifiés dans le certificat

Le navigateur vérifie plusieurs champs critiques :

- **Subject** : L'identité du serveur (Common Name ou Subject Alternative Names)
- **Issuer** : L'autorité qui a émis le certificat
- **Validity Period** : Les dates de début et fin de validité
- **Key Usage** : Les usages autorisés (ex: Digital Signature, Key Encipherment)
- **Extended Key Usage** : Spécifiquement "Server Authentication" pour HTTPS

```bash
# Examiner les champs importants d'un certificat
openssl x509 -in certificat.crt -noout -subject -issuer -dates -ext keyUsage,extendedKeyUsage,subjectAltName
```

> [!warning] Pièges courants
> 
> - **Certificats auto-signés** : Le navigateur affichera une erreur car l'autorité n'est pas reconnue
> - **Nom de domaine non correspondant** : Le certificat pour `exemple.com` ne fonctionne pas pour `www.exemple.com` (sauf wildcard `*.exemple.com`)
> - **Certificat expiré** : Le navigateur refusera la connexion même si le certificat est valide techniquement
> - **Chaîne de certification incomplète** : Le serveur doit envoyer les certificats intermédiaires

### Bonnes pratiques

1. **Utiliser des certificats récents** : Privilégier des algorithmes modernes (RSA 2048+ bits ou ECDSA)
2. **Configurer le renouvellement automatique** : Les certificats expirent (90 jours pour Let's Encrypt)
3. **Inclure tous les domaines nécessaires** : Utiliser les SAN (Subject Alternative Names) pour couvrir www, api, etc.
4. **Forcer HTTPS** : Rediriger automatiquement HTTP vers HTTPS
5. **Implémenter HSTS** : Header HTTP Strict Transport Security pour éviter les downgrade attacks

```bash
# Tester la configuration SSL/TLS d'un serveur
# (outil externe recommandé : testssl.sh)
./testssl.sh https://exemple.com

# Vérifier si le certificat couvre plusieurs domaines
openssl x509 -in certificat.crt -noout -text | grep -A1 "Subject Alternative Name"
```

---

## ✍️ Signature de documents

### Principe et objectif

La signature numérique de documents permet de garantir l'authenticité et l'intégrité d'un fichier. Elle répond à la question : "Ce document a-t-il bien été créé par cette personne et n'a-t-il pas été modifié depuis ?"

> [!info] Valeur juridique Dans de nombreux pays, la signature électronique qualifiée a la même valeur légale qu'une signature manuscrite (régulation eIDAS en Europe, ESIGN Act aux USA).

### Comment ça fonctionne

Le processus de signature numérique repose sur la cryptographie asymétrique :

1. **Calcul de l'empreinte** : Un hash cryptographique du document est généré (SHA-256, SHA-512)
2. **Chiffrement de l'empreinte** : Cette empreinte est chiffrée avec la clé privée du signataire
3. **Attachement de la signature** : La signature chiffrée et le certificat sont joints au document
4. **Vérification** : Le destinataire déchiffre la signature avec la clé publique du certificat et compare l'empreinte

```bash
# Signer un document PDF avec openssl
openssl dgst -sha256 -sign cle_privee.pem -out signature.bin document.pdf

# Vérifier la signature
openssl dgst -sha256 -verify cle_publique.pem -signature signature.bin document.pdf

# Signer avec un certificat complet (format PKCS#7)
openssl smime -sign -in document.txt -out document_signe.p7s \
  -signer certificat.crt -inkey cle_privee.pem -text
```

### Types de signatures

|Type|Description|Cas d'usage|
|---|---|---|
|**Signature simple**|Empreinte + certificat|Documents internes|
|**Signature avec horodatage**|Inclut un timestamp certifié|Preuves légales|
|**Signature qualifiée**|Certificat qualifié + dispositif sécurisé|Contrats, actes officiels|
|**Signature visible**|Apparaît visuellement dans le PDF|Documents destinés à l'impression|

### Formats de signature

Les formats de signature varient selon le type de document :

**Pour les documents PDF :**

- **PAdES** (PDF Advanced Electronic Signatures) : Standard pour les PDF, intégré au fichier
- Niveaux : PAdES-B (basique), PAdES-T (avec horodatage), PAdES-LT (avec validation à long terme)

**Pour les documents génériques :**

- **CAdES** (CMS Advanced Electronic Signatures) : Basé sur PKCS#7, fichier .p7s séparé ou intégré
- **XAdES** (XML Advanced Electronic Signatures) : Pour les documents XML

```bash
# Exemple avec pdfsig (poppler-utils)
# Lister les signatures d'un PDF
pdfsig document.pdf

# Signer un PDF (nécessite un certificat PKCS#12)
# Avec des outils comme Adobe Acrobat, LibreOffice, ou des bibliothèques spécialisées
```

> [!tip] Outils de signature courants
> 
> - **Adobe Acrobat** : Signature de PDF avec interface graphique
> - **LibreOffice** : Signature de documents Office et PDF
> - **DocuSign, Adobe Sign** : Solutions cloud professionnelles
> - **Bibliothèques** : iText (Java), PyPDF2/pypdf (Python), PDFBox (Java)

### Éléments inclus dans la signature

Une signature numérique complète contient :

- **L'empreinte du document** (hash cryptographique)
- **Le certificat du signataire** (avec sa clé publique)
- **La chaîne de certification** (certificats intermédiaires)
- **L'horodatage** (optionnel mais recommandé)
- **Les attributs signés** (date de signature, lieu, raison)

> [!warning] Limitations importantes
> 
> - **La signature ne chiffre pas** : Le document reste lisible par tous
> - **Modification impossible** : Toute modification invalide la signature
> - **Dépendance à la PKI** : La validation nécessite que la CA soit de confiance
> - **Expiration du certificat** : Une signature peut devenir invalide après expiration (d'où l'importance de l'horodatage)

### Bonnes pratiques

1. **Utiliser l'horodatage qualifié** : Permet de prouver que le document existait à une date donnée
2. **Archiver les certificats** : Conserver la chaîne complète pour validation future
3. **Format LTV (Long Term Validation)** : Inclure les informations de révocation dans la signature
4. **Signer en dernier** : Ne plus modifier le document après signature
5. **Vérifier systématiquement** : Toujours valider les signatures avant d'accepter un document

```bash
# Créer une signature détachée (le document original reste intact)
openssl cms -sign -in document.pdf -out signature.p7s \
  -signer certificat.pem -inkey cle.pem -binary -outform DER

# Vérifier une signature détachée
openssl cms -verify -in signature.p7s -content document.pdf \
  -CAfile ca_chain.pem -inform DER
```

### Cas d'usage professionnels

- **Contrats commerciaux** : Signature bilatérale avec valeur légale
- **Factures électroniques** : Conformité réglementaire (facturation électronique obligatoire)
- **Bulletins de paie** : Garantie d'authenticité pour l'employé
- **Documents administratifs** : Dématérialisation des procédures
- **Code logiciel** : Signature de binaires, drivers, applications mobiles

---

## 📧 Chiffrement d'emails

### Principe et objectif

Le chiffrement d'emails protège le contenu des messages contre l'interception et la lecture par des tiers. Contrairement à la signature qui garantit l'authenticité, le chiffrement garantit la confidentialité.

> [!info] Différence avec la signature
> 
> - **Signature** : Prouve l'identité de l'expéditeur (clé privée de l'émetteur)
> - **Chiffrement** : Protège le contenu du message (clé publique du destinataire)
> 
> Les deux peuvent être combinés pour un email signé ET chiffré.

### Protocoles principaux

**S/MIME (Secure/Multipurpose Internet Mail Extensions)**

- Standard industriel supporté nativement par la plupart des clients email
- Utilise des certificats X.509 émis par des CA
- Intégré dans Outlook, Apple Mail, Thunderbird, etc.
- Nécessite un certificat par utilisateur

**OpenPGP (Pretty Good Privacy)**

- Standard ouvert basé sur un réseau de confiance
- Ne nécessite pas de CA centralisée
- Utilisé avec GPG (GNU Privacy Guard)
- Plus flexible mais moins transparent pour l'utilisateur

|Critère|S/MIME|OpenPGP/GPG|
|---|---|---|
|**Infrastructure**|PKI centralisée (CA)|Web of Trust ou CA optionnelle|
|**Intégration**|Native dans la plupart des clients|Plugin requis (généralement)|
|**Entreprise**|Préféré (contrôle centralisé)|Moins courant|
|**Open Source**|Implémentations variées|GPG (standard de facto)|
|**Coût**|Certificats payants ou via CA interne|Gratuit|

### Chiffrement avec S/MIME

Le processus de chiffrement S/MIME :

1. **L'expéditeur obtient la clé publique du destinataire** (via leur certificat)
2. **Le message est chiffré** avec cette clé publique
3. **Le destinataire déchiffre** avec sa clé privée correspondante

```bash
# Générer un certificat S/MIME auto-signé pour test
openssl req -x509 -newkey rsa:4096 -keyout cle_privee.pem \
  -out certificat.pem -days 365 -nodes \
  -subj "/CN=utilisateur@exemple.com/emailAddress=utilisateur@exemple.com"

# Chiffrer un email
openssl smime -encrypt -in message.txt -out message_chiffre.eml \
  -from expediteur@exemple.com -to destinataire@exemple.com \
  -subject "Message confidentiel" certificat_destinataire.pem

# Déchiffrer un email reçu
openssl smime -decrypt -in message_chiffre.eml -out message_clair.txt \
  -inkey ma_cle_privee.pem -recip mon_certificat.pem
```

> [!example] Workflow typique en entreprise
> 
> 1. L'entreprise déploie une CA interne
> 2. Chaque employé reçoit un certificat S/MIME
> 3. Les certificats sont publiés dans l'annuaire LDAP/Active Directory
> 4. Les clients email récupèrent automatiquement les certificats publics
> 5. Les emails sensibles sont automatiquement chiffrés selon des règles

### Chiffrement avec OpenPGP/GPG

Le processus avec GPG :

1. **Chaque utilisateur génère une paire de clés** GPG
2. **Les clés publiques sont échangées** (serveur de clés, email, site web)
3. **Le message est chiffré** avec la clé publique du destinataire
4. **Le destinataire déchiffre** avec sa clé privée

```bash
# Générer une paire de clés GPG
gpg --full-generate-key
# Choisir : (1) RSA et RSA, 4096 bits, validité 2 ans

# Lister les clés
gpg --list-keys

# Exporter sa clé publique
gpg --armor --export utilisateur@exemple.com > ma_cle_publique.asc

# Importer la clé publique d'un correspondant
gpg --import cle_publique_destinataire.asc

# Chiffrer un message
gpg --encrypt --recipient destinataire@exemple.com message.txt
# Crée message.txt.gpg

# Déchiffrer un message reçu
gpg --decrypt message.txt.gpg > message_clair.txt

# Chiffrer ET signer
gpg --encrypt --sign --recipient destinataire@exemple.com message.txt
```

### Intégration dans les clients email

**Thunderbird avec Enigmail/OpenPGP**

```bash
# Thunderbird intègre nativement OpenPGP depuis la version 78
# Configuration : Paramètres > Chiffrement de bout en bout
# Générer ou importer une clé, puis activer le chiffrement par défaut
```

**Outlook avec S/MIME**

```bash
# Configuration S/MIME dans Outlook
# 1. Fichier > Options > Centre de gestion de la confidentialité
# 2. Paramètres du Centre de gestion de la confidentialité
# 3. Sécurité du courrier électronique
# 4. Importer le certificat (fichier .p12 ou .pfx)
# 5. Activer "Chiffrer le contenu et les pièces jointes"
```

> [!tip] Distribution des clés publiques **Pour S/MIME :**
> 
> - Publier le certificat dans un annuaire LDAP d'entreprise
> - Envoyer un email signé (le certificat est inclus automatiquement)
> 
> **Pour OpenPGP :**
> 
> - Publier sur un serveur de clés : `gpg --keyserver keys.openpgp.org --send-keys KEY_ID`
> - Publier sur son site web ou dans sa signature email
> - Vérifier l'empreinte par un canal secondaire (téléphone, vidéo)

### Gestion des certificats/clés

**Obtenir un certificat S/MIME :**

- **Gratuit** : Actalis, Comodo (limité), Let's Encrypt (expérimental)
- **Payant** : DigiCert, GlobalSign, Sectigo
- **Entreprise** : CA interne (Active Directory Certificate Services)

**Stocker les clés privées :**

- Fichier PKCS#12 (.p12, .pfx) protégé par mot de passe fort
- Hardware Security Module (HSM) pour environnements sensibles
- Carte à puce ou token USB (YubiKey, Nitrokey)

```bash
# Créer un fichier PKCS#12 (contient clé privée + certificat)
openssl pkcs12 -export -out certificat.p12 \
  -inkey cle_privee.pem -in certificat.pem \
  -certfile ca_chain.pem -name "Mon Certificat Email"

# Extraire le certificat d'un PKCS#12
openssl pkcs12 -in certificat.p12 -nokeys -out certificat.pem

# Extraire la clé privée d'un PKCS#12
openssl pkcs12 -in certificat.p12 -nocerts -out cle_privee.pem
```

> [!warning] Limitations et pièges
> 
> - **Compatibilité** : Les deux correspondants doivent utiliser le même protocole (S/MIME ou PGP)
> - **Clé perdue = données perdues** : Sans la clé privée, impossible de déchiffrer les anciens emails
> - **Pièces jointes volumineuses** : Le chiffrement augmente légèrement la taille
> - **Mobile** : Support limité sur certains clients mobiles
> - **Révocation** : Si la clé privée est compromise, révoquer immédiatement le certificat/clé

### Bonnes pratiques

1. **Sauvegarder les clés privées** : Stocker dans un coffre-fort numérique chiffré (KeePass, Bitwarden)
2. **Utiliser un mot de passe fort** : Pour protéger la clé privée (min. 16 caractères)
3. **Séparer les usages** : Clé différente pour signature et chiffrement si possible
4. **Renouveler régulièrement** : Changer de clés tous les 2-3 ans
5. **Vérifier les empreintes** : Confirmer l'identité du destinataire avant d'envoyer des infos sensibles
6. **Chiffrer localement** : Ne jamais envoyer la clé privée par email

```bash
# Afficher l'empreinte d'un certificat S/MIME
openssl x509 -in certificat.pem -noout -fingerprint -sha256

# Afficher l'empreinte d'une clé GPG
gpg --fingerprint utilisateur@exemple.com
```

### Cas d'usage professionnels

- **Secteur médical** : Protection des données de santé (RGPD, HIPAA)
- **Juridique** : Confidentialité avocat-client
- **Finance** : Transmission sécurisée de documents financiers
- **Gouvernement** : Communications classifiées
- **RH** : Bulletins de paie, données personnelles sensibles

---

## 👤 Authentification utilisateur

### Principe et objectif

L'authentification utilisateur par certificat permet de vérifier l'identité d'une personne sans utiliser de mot de passe traditionnel. Le certificat agit comme une identité numérique forte, souvent stockée sur un support physique sécurisé.

> [!info] Avantages sur les mots de passe
> 
> - **Résistant au phishing** : Le certificat ne peut pas être "donné" à un attaquant
> - **Multi-facteur natif** : Possession (certificat) + connaissance (PIN) + optionnel biométrie
> - **Non rejouable** : Chaque authentification utilise un challenge cryptographique unique
> - **Centralisé** : Révocation instantanée en cas de compromission

### Mécanismes d'authentification

**Authentification TLS mutuelle (mTLS)**

- Le client ET le serveur présentent un certificat
- Utilisé pour les API machine-to-machine
- Courant dans les architectures zero-trust

**Authentification par carte à puce**

- Certificat stocké sur une carte à puce (PIV, CAC, CNI électronique)
- Lecteur de carte requis
- Standard dans les administrations et grandes entreprises

**Authentification par token USB**

- Certificat sur une clé USB sécurisée (YubiKey, Nitrokey)
- Support FIDO2, U2F, PIV
- Plus pratique qu'une carte à puce

### Authentification mTLS client-serveur

Configuration côté serveur (exemple avec Nginx) :

```bash
# Configuration Nginx pour authentification client
server {
    listen 443 ssl;
    server_name secure.exemple.com;

    # Certificat du serveur
    ssl_certificate /etc/nginx/ssl/serveur.crt;
    ssl_certificate_key /etc/nginx/ssl/serveur.key;

    # Demander le certificat client
    ssl_client_certificate /etc/nginx/ssl/ca_clients.crt;
    ssl_verify_client on;  # ou "optional" pour rendre facultatif
    ssl_verify_depth 2;    # Profondeur de la chaîne de certification

    location / {
        # Le sujet du certificat client est disponible dans $ssl_client_s_dn
        proxy_set_header X-SSL-Client-DN $ssl_client_s_dn;
        proxy_set_header X-SSL-Client-Verify $ssl_client_verify;
        proxy_pass http://backend;
    }
}
```

Test avec curl :

```bash
# Tester l'authentification client avec un certificat
curl --cert certificat_client.pem --key cle_client.pem \
  --cacert ca_serveur.crt https://secure.exemple.com

# Avec un fichier PKCS#12
curl --cert-type P12 --cert certificat_client.p12:motdepasse \
  https://secure.exemple.com
```

### Authentification avec carte à puce / token USB

**Configurer un token USB (exemple YubiKey)** :

```bash
# Installer les outils nécessaires
sudo apt install opensc pcscd pcsc-tools

# Lister les lecteurs détectés
pcsc_scan

# Lister les certificats sur la carte
pkcs11-tool --module /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so --list-objects

# Tester l'authentification
pkcs11-tool --module /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so --login --test
```

**Utiliser le certificat pour SSH** :

```bash
# Extraire la clé publique du certificat
ssh-keygen -D /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so

# Configurer SSH pour utiliser le module PKCS#11
# Dans ~/.ssh/config :
Host serveur-securise
    HostName 192.168.1.100
    PKCS11Provider /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so
    # Un PIN sera demandé à chaque connexion
```

**Utiliser le certificat pour l'authentification web** :

Les navigateurs modernes supportent nativement les certificats clients :

1. Importer le certificat dans le navigateur (ou utiliser la carte/token)
2. Le site web demande le certificat lors de la connexion TLS
3. L'utilisateur sélectionne son certificat et entre le PIN si nécessaire
4. Le serveur vérifie le certificat et autorise l'accès

> [!example] Cas d'usage : Accès VPN Beaucoup de solutions VPN (OpenVPN, WireGuard, IPSec) supportent l'authentification par certificat :
> 
> ```bash
> # Configuration OpenVPN avec certificat client
> client
> dev tun
> proto udp
> remote vpn.exemple.com 1194
> 
> # Certificats
> ca ca.crt
> cert client.crt
> key client.key
> 
> # Options de sécurité
> remote-cert-tls server
> cipher AES-256-GCM
> auth SHA256
> ```

### Flux d'authentification typique

1. **L'utilisateur se connecte au service** (web, VPN, SSH)
2. **Le serveur demande un certificat client** lors du handshake TLS
3. **Le client présente son certificat** depuis sa carte/token
4. **Le PIN est demandé** pour déverrouiller la clé privée
5. **Le serveur vérifie le certificat** :
    - Signature de la CA
    - Dates de validité
    - Révocation (CRL/OCSP)
    - Attributs spécifiques (usage, organisation)
6. **L'authentification réussit** et une session est créée

### Gestion des certificats utilisateurs

**Émission de certificats** :

En entreprise, les certificats utilisateurs sont généralement émis par une CA interne :

```bash
# Créer une demande de certificat (CSR) pour un utilisateur
openssl req -new -newkey rsa:4096 -keyout utilisateur.key \
  -out utilisateur.csr -nodes \
  -subj "/C=FR/O=Entreprise/CN=Jean Dupont/emailAddress=jean.dupont@exemple.com"

# Signer le CSR avec la CA (côté administrateur)
openssl x509 -req -in utilisateur.csr -CA ca.crt -CAkey ca.key \
  -CAcreateserial -out utilisateur.crt -days 365 \
  -extfile <(printf "extendedKeyUsage=clientAuth\nkeyUsage=digitalSignature,keyEncipherment")

# Créer un fichier PKCS#12 pour l'utilisateur
openssl pkcs12 -export -out utilisateur.p12 \
  -inkey utilisateur.key -in utilisateur.crt -certfile ca.crt \
  -name "Certificat Jean Dupont"
```

**Déploiement sur carte à puce** :

```bash
# Importer le certificat et la clé sur une YubiKey
yubico-piv-tool -s 9a -a import-certificate -i utilisateur.crt
yubico-piv-tool -s 9a -a import-key -i utilisateur.key

# Définir un PIN pour protéger la clé
yubico-piv-tool -a change-pin
```

> [!tip] Intégration avec Active Directory Dans un environnement Windows/AD, les certificats peuvent être déployés automatiquement :
> 
> - **Auto-enrollment** : Les utilisateurs reçoivent automatiquement leurs certificats
> - **Group Policy** : Distribution des certificats via GPO
> - **Certificate Templates** : Modèles personnalisés selon les rôles
> - **Smart Card Logon** : Authentification Windows avec carte à puce

### Attributs spécifiques pour l'authentification

Les certificats d'authentification utilisateur contiennent des extensions spécifiques :

- **Extended Key Usage** : `clientAuth` (1.3.6.1.5.5.7.3.2)
- **Key Usage** : `digitalSignature`, `keyEncipherment`
- **Subject Alternative Name** : UPN (User Principal Name) pour Windows
- **Custom OID** : Attributs métier (département, niveau d'habilitation)

```bash
# Créer un certificat avec des attributs personnalisés
openssl x509 -req -in utilisateur.csr -CA ca.crt -CAkey ca.key \
  -out utilisateur.crt -days 365 -extfile <(cat <<EOF
extendedKeyUsage=clientAuth
keyUsage=critical,digitalSignature,keyEncipherment
subjectAltName=otherName:1.3.6.1.4.1.311.20.2.3;UTF8:jean.dupont@exemple.com
1.2.3.4.5.1=ASN1:UTF8String:Departement RH
EOF
)
```

> [!warning] Sécurité et révocation **Protéger les clés privées** :
> 
> - Ne JAMAIS stocker sur le disque dur en clair
> - Utiliser des supports physiques (carte, token USB)
> - Chiffrer les sauvegardes avec un mot de passe très fort
> 
> **Révocation rapide** :
> 
> - Publier les CRL (Certificate Revocation Lists) régulièrement
> - Implémenter OCSP (Online Certificate Status Protocol) pour vérification en temps réel
> - En cas de vol/perte : révoquer immédiatement le certificat
> - Notifier les utilisateurs de renouveler leur certificat avant expiration

### Avantages et inconvénients

**Avantages** :

|Avantage|Description|
|---|---|
|**Sécurité renforcée**|Résistant au phishing, brute force, credential stuffing|
|**Authentification forte**|Cryptographie asymétrique, impossible à deviner|
|**Traçabilité**|Chaque certificat est unique et identifiable|
|**Révocation centralisée**|Désactivation instantanée en cas de compromission|
|**Sans mot de passe**|Pas de risque de mot de passe faible ou réutilisé|

**Inconvénients** :

|Inconvénient|Description|
|---|---|
|**Complexité initiale**|Déploiement et gestion d'une PKI|
|**Coût matériel**|Cartes à puce, lecteurs, tokens USB|
|**Perte physique**|Si le support est perdu, l'accès est bloqué|
|**Compatibilité**|Tous les systèmes ne supportent pas les certificats clients|
|**Formation requise**|Les utilisateurs doivent comprendre le concept et l'utilisation|

### Bonnes pratiques

1. **Combiner avec d'autres facteurs** : Certificat (possession) + PIN (connaissance) + biométrie (inhérence)
2. **Politique de révocation claire** : Procédure rapide en cas de perte/vol
3. **Durée de vie limitée** : Renouveler les certificats tous les 1-2 ans
4. **Backup sécurisé** : Conserver une copie chiffrée de la clé privée dans un coffre-fort physique
5. **Monitoring** : Logger toutes les authentifications pour détecter les anomalies
6. **Support utilisateur** : Hotline dédiée pour les problèmes de certificat

```bash
# Script de vérification automatique des certificats expirés
#!/bin/bash
# check_cert_expiry.sh

CERT_DIR="/etc/ssl/users"
DAYS_WARNING=30

for cert in "$CERT_DIR"/*.crt; do
    if [ -f "$cert" ]; then
        # Récupérer la date d'expiration
        expiry=$(openssl x509 -in "$cert" -noout -enddate | cut -d= -f2)
        expiry_epoch=$(date -d "$expiry" +%s)
        now_epoch=$(date +%s)
        days_remaining=$(( ($expiry_epoch - $now_epoch) / 86400 ))
        
        if [ $days_remaining -lt $DAYS_WARNING ]; then
            user=$(openssl x509 -in "$cert" -noout -subject | sed 's/.*CN=\([^,]*\).*/\1/')
            echo "ALERTE : Le certificat de $user expire dans $days_remaining jours"
        fi
    fi
done
```

### Cas d'usage professionnels

- **Accès administrateur** : Authentification privilégiée pour les admins système
- **Postes de travail** : Authentification Windows avec smart card logon
- **VPN d'entreprise** : Accès réseau sécurisé pour les télétravailleurs
- **Applications métier** : ERP, CRM nécessitant une authentification forte
- **API B2B** : Authentification machine-to-machine entre partenaires
- **IoT industriel** : Authentification des équipements sur le réseau
- **Signature électronique** : Identification certaine du signataire

> [!tip] Transition vers FIDO2/WebAuthn Les standards modernes comme FIDO2 et WebAuthn représentent l'évolution de l'authentification par certificat :
> 
> - **Plus simple** : Enregistrement et utilisation transparents
> - **Universel** : Support natif dans tous les navigateurs modernes
> - **Phishing-proof** : Lié au domaine du site web
> - **Compatible** : Fonctionne avec les YubiKey, Windows Hello, Touch ID
> 
> Cependant, les certificats X.509 restent essentiels pour les infrastructures d'entreprise établies et offrent plus de flexibilité pour les cas d'usage complexes.

---

## 🎓 Synthèse comparative

|Cas d'usage|Objectif principal|Propriété cryptographique|Format typique|
|---|---|---|---|
|**HTTPS**|Authentifier le serveur + chiffrer la connexion|Authentification serveur + échange de clés|X.509 avec EKU serverAuth|
|**Signature documents**|Prouver l'authenticité et l'intégrité|Signature numérique (clé privée)|PAdES, CAdES, XAdES|
|**Chiffrement email**|Protéger la confidentialité du contenu|Chiffrement asymétrique (clé publique)|S/MIME (X.509) ou OpenPGP|
|**Authentification utilisateur**|Vérifier l'identité sans mot de passe|Authentification mutuelle|X.509 avec EKU clientAuth|

> [!info] Complémentarité des cas d'usage Dans la pratique, ces cas d'usage sont souvent combinés :
> 
> - Un email peut être **signé ET chiffré**
> - Un serveur HTTPS peut demander **l'authentification client** (mTLS)
> - Un document peut être **signé par plusieurs personnes** avec horodatage
> - Une application peut utiliser des certificats pour **authentification ET API sécurisée**

---

## 🔑 Points clés à retenir

1. **HTTPS** : Le cas d'usage le plus répandu, essentiel pour la sécurité web moderne
2. **Signature** : Garantit l'authenticité et l'intégrité, avec valeur légale dans de nombreux pays
3. **Chiffrement email** : Deux protocoles (S/MIME et OpenPGP), chacun avec ses avantages
4. **Authentification utilisateur** : Alternative robuste aux mots de passe, nécessite une infrastructure PKI
5. **Tous partagent** : La confiance dans la PKI, la gestion du cycle de vie, et l'importance de la révocation

> [!tip] Choisir le bon cas d'usage
> 
> - **Besoin de confidentialité** → Chiffrement
> - **Besoin d'authenticité** → Signature
> - **Besoin d'identité forte** → Authentification par certificat
> - **Site web public** → HTTPS avec certificat serveur
> - **Application critique** → Combiner plusieurs cas d'usage

---

_Ce cours fait partie du module **Introduction à la cryptographie et aux certificats numériques**_