

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

## 🎯 Introduction à la hiérarchie de certification {#introduction}

La **hiérarchie de certification** est l'organisation structurée des autorités de certification (CA) qui permet d'établir et de maintenir la confiance dans un système PKI. Cette hiérarchie pyramidale garantit que les certificats numériques peuvent être vérifiés de manière sécurisée et traçable.

> [!info] Pourquoi une hiérarchie ? Plutôt que d'avoir une seule CA qui signe tous les certificats (ce qui serait un point de défaillance unique), on crée plusieurs niveaux de CA. Cela permet de :
> 
> - **Isoler** la CA racine (la plus critique) et la garder hors ligne
> - **Déléguer** la signature de certificats à des CA intermédiaires
> - **Révoquer** facilement une CA compromise sans tout reconstruire
> - **Organiser** les certificats par domaine, géographie ou usage

### Principe fondamental

La confiance se propage **du haut vers le bas** : si vous faites confiance à une CA racine, vous faites automatiquement confiance à toutes les CA qu'elle a signées, et ainsi de suite.

---

## 🌳 CA Racine (Root CA) {#ca-racine}

### Définition

La **CA racine** (Root Certificate Authority) est le sommet de la hiérarchie PKI. C'est l'autorité de certification suprême qui signe son propre certificat (certificat auto-signé) et qui signe les certificats des CA intermédiaires.

> [!warning] Criticité maximale La CA racine est l'élément le plus critique de toute l'infrastructure PKI. Si sa clé privée est compromise, **toute la hiérarchie est compromise**. C'est pourquoi elle doit être protégée avec le plus haut niveau de sécurité.

### Caractéristiques principales

|Caractéristique|Description|
|---|---|
|**Auto-signé**|Le certificat racine est signé par sa propre clé privée|
|**Durée de vie**|Très longue (10 à 30 ans) pour minimiser les renouvellements|
|**Utilisation**|Ne signe QUE des certificats de CA intermédiaires, jamais de certificats finaux|
|**Stockage**|Hors ligne (air-gapped) dans un environnement hautement sécurisé|
|**Révocation**|Très rare et catastrophique (nécessite la reconstruction de toute la PKI)|

### Fonctionnement

```bash
# Structure d'un certificat racine
Subject: CN=Ma CA Racine, O=MonEntreprise, C=FR
Issuer: CN=Ma CA Racine, O=MonEntreprise, C=FR  # Auto-signé !
Validity: 20 ans
Key Usage: Certificate Sign, CRL Sign
Basic Constraints: CA:TRUE, pathlen:2  # Peut signer des CA intermédiaires
```

> [!tip] Pathlen expliqué Le paramètre `pathlen` limite la profondeur de la chaîne de certification :
> 
> - `pathlen:2` = la racine peut signer des CA qui peuvent elles-mêmes signer d'autres CA (3 niveaux au total)
> - `pathlen:1` = la racine peut signer des CA qui signent uniquement des certificats finaux
> - `pathlen:0` = la racine peut signer uniquement des certificats finaux (rare pour une racine)

### Sécurisation de la CA racine

> [!warning] Mesures de protection essentielles
> 
> 1. **Stockage hors ligne** : La clé privée doit être sur un système déconnecté du réseau
> 2. **HSM (Hardware Security Module)** : Utiliser un module matériel dédié, certifié FIPS 140-2 niveau 3 ou 4
> 3. **Salle sécurisée** : Accès physique restreint avec contrôle biométrique
> 4. **Cérémonie de clés** : Procédure formelle avec plusieurs personnes pour toute opération
> 5. **Backup chiffré** : Copies sécurisées dans plusieurs sites géographiques
> 6. **Audit trail** : Journalisation complète de toutes les opérations

### Cycle de vie d'une CA racine

```bash
# 1. Génération de la clé privée racine (opération CRITIQUE)
openssl genrsa -aes256 -out root-ca.key 4096
# ⚠️ Cette commande ne devrait être exécutée que dans un environnement sécurisé

# 2. Création du certificat auto-signé
openssl req -x509 -new -nodes -key root-ca.key \
  -sha256 -days 7300 \  # 20 ans
  -out root-ca.crt \
  -subj "/C=FR/O=MonEntreprise/CN=Ma CA Racine"

# 3. Vérification du certificat
openssl x509 -in root-ca.crt -text -noout
```

### Distribution de la CA racine

Une fois créée, la CA racine doit être **distribuée et installée** sur tous les systèmes qui lui feront confiance :

- **Windows** : Certificate Manager → Trusted Root Certification Authorities
- **Linux** : `/etc/ssl/certs/` ou `/usr/local/share/ca-certificates/`
- **macOS** : Keychain Access → System → Certificates
- **Navigateurs** : Magasins de certificats intégrés ou hérités de l'OS

---

## 🔗 CA Intermédiaire (Subordinate CA) {#ca-intermediaire}

### Définition

Une **CA intermédiaire** (aussi appelée Subordinate CA ou Issuing CA) est une autorité de certification dont le certificat est signé par une CA racine (ou une autre CA intermédiaire). Elle se situe entre la CA racine et les certificats finaux.

> [!info] Rôle principal Les CA intermédiaires sont utilisées pour signer les certificats des entités finales (serveurs, utilisateurs, appareils). Elles protègent la CA racine en la gardant hors ligne.

### Pourquoi utiliser des CA intermédiaires ?

|Avantage|Explication|
|---|---|
|**Protection de la racine**|La CA racine reste hors ligne et n'est utilisée que pour signer les CA intermédiaires|
|**Isolation des risques**|Si une CA intermédiaire est compromise, on la révoque sans toucher à la racine|
|**Organisation**|Créer des CA par département, région, ou type d'usage|
|**Performance**|Distribuer la charge de signature sur plusieurs CA|
|**Flexibilité**|Renouveler ou changer les CA intermédiaires sans impacter la confiance|

### Architecture typique

```
🌳 CA Racine (offline, 20 ans)
    |
    ├── 🔗 CA Intermédiaire "Serveurs Web" (online, 5 ans)
    │       ├── 📄 *.example.com (1 an)
    │       ├── 📄 mail.example.com (1 an)
    │       └── 📄 api.example.com (1 an)
    |
    ├── 🔗 CA Intermédiaire "Utilisateurs" (online, 5 ans)
    │       ├── 📄 Certificat de Jean Dupont
    │       └── 📄 Certificat de Marie Martin
    |
    └── 🔗 CA Intermédiaire "Code Signing" (online, 3 ans)
            ├── 📄 Certificat dev team A
            └── 📄 Certificat dev team B
```

### Création d'une CA intermédiaire

```bash
# 1. Générer la clé privée de la CA intermédiaire
openssl genrsa -aes256 -out intermediate-ca.key 4096

# 2. Créer une demande de signature de certificat (CSR)
openssl req -new -key intermediate-ca.key \
  -out intermediate-ca.csr \
  -subj "/C=FR/O=MonEntreprise/CN=Ma CA Intermédiaire Serveurs Web"

# 3. Signer le CSR avec la CA racine (opération hors ligne)
openssl x509 -req -in intermediate-ca.csr \
  -CA root-ca.crt \
  -CAkey root-ca.key \
  -CAcreateserial \
  -out intermediate-ca.crt \
  -days 1825 \  # 5 ans
  -sha256 \
  -extfile <(cat <<EOF
basicConstraints = CA:TRUE, pathlen:0
keyUsage = critical, digitalSignature, keyCertSign, cRLSign
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
EOF
)

# 4. Vérifier la signature
openssl verify -CAfile root-ca.crt intermediate-ca.crt
```

> [!tip] PathLen pour les CA intermédiaires
> 
> - `pathlen:0` → Cette CA intermédiaire peut signer UNIQUEMENT des certificats finaux (pas d'autres CA)
> - `pathlen:1` → Cette CA intermédiaire peut signer des certificats finaux ET d'autres CA intermédiaires

### Types de CA intermédiaires

#### 1. CA intermédiaire par usage

```
CA Racine
  ├── CA Web Servers (pour SSL/TLS)
  ├── CA Email (pour S/MIME)
  ├── CA Code Signing (pour signer du code)
  └── CA VPN (pour authentification VPN)
```

#### 2. CA intermédiaire par organisation

```
CA Racine Entreprise
  ├── CA Division Europe
  ├── CA Division Amérique
  └── CA Division Asie
```

#### 3. CA intermédiaire par niveau de sécurité

```
CA Racine
  ├── CA Standard (certificats 1 an, validation standard)
  ├── CA Extended Validation (certificats EV, validation stricte)
  └── CA Internal (usage interne uniquement)
```

### Révocation d'une CA intermédiaire

> [!warning] Scénario de compromission Si la clé privée d'une CA intermédiaire est compromise :

```bash
# 1. Révoquer immédiatement le certificat de la CA intermédiaire
openssl ca -revoke intermediate-ca.crt \
  -keyfile root-ca.key \
  -cert root-ca.crt

# 2. Publier une CRL (Certificate Revocation List) mise à jour
openssl ca -gencrl \
  -keyfile root-ca.key \
  -cert root-ca.crt \
  -out root-ca.crl

# 3. Tous les certificats signés par cette CA sont invalidés
# 4. Créer une nouvelle CA intermédiaire
# 5. Réémettre tous les certificats nécessaires
```

---

## 🔐 Chaîne de confiance {#chaine-confiance}

### Concept fondamental

La **chaîne de confiance** (trust chain ou certificate chain) est la séquence de certificats qui relie un certificat final à une CA racine de confiance. Chaque certificat de la chaîne est signé par le certificat qui le précède.

> [!info] Principe de vérification Pour valider un certificat, on remonte la chaîne :
> 
> 1. Le certificat final est signé par la CA intermédiaire
> 2. La CA intermédiaire est signée par la CA racine
> 3. La CA racine est auto-signée et de confiance
> 
> Si toutes les signatures sont valides et que la CA racine est de confiance, alors le certificat final est de confiance.

### Structure d'une chaîne de confiance

```
┌─────────────────────────────┐
│  🌳 CA Racine               │  ← Auto-signée, dans le magasin de confiance
│  Subject: CN=Root CA        │
│  Issuer: CN=Root CA         │
└──────────────┬──────────────┘
               │ signe
               ↓
┌─────────────────────────────┐
│  🔗 CA Intermédiaire        │  ← Signée par la racine
│  Subject: CN=Intermediate   │
│  Issuer: CN=Root CA         │
└──────────────┬──────────────┘
               │ signe
               ↓
┌─────────────────────────────┐
│  📄 Certificat final        │  ← Signé par l'intermédiaire
│  Subject: CN=www.example.com│
│  Issuer: CN=Intermediate    │
└─────────────────────────────┘
```

### Vérification de la chaîne de confiance

```bash
# Créer un fichier bundle contenant la chaîne complète
cat intermediate-ca.crt root-ca.crt > ca-chain.crt

# Vérifier un certificat final contre la chaîne
openssl verify -CAfile ca-chain.crt server-cert.crt

# Sortie attendue si valide:
# server-cert.crt: OK

# Afficher la chaîne complète d'un certificat
openssl s_client -connect www.example.com:443 -showcerts

# Vérifier la chaîne d'un site web
openssl s_client -connect www.example.com:443 -CAfile ca-chain.crt
```

### Problèmes courants de chaîne de confiance

> [!warning] Erreurs fréquentes

#### 1. Chaîne incomplète

```bash
# ❌ Erreur: unable to get local issuer certificate
# Cause: La CA intermédiaire n'est pas fournie

# ✅ Solution: Fournir le certificat intermédiaire
# Dans la configuration serveur (ex: Apache)
SSLCertificateFile /path/to/server-cert.crt
SSLCertificateChainFile /path/to/intermediate-ca.crt
SSLCACertificateFile /path/to/root-ca.crt
```

#### 2. Ordre incorrect

```bash
# ❌ Mauvais ordre dans le bundle
cat root-ca.crt intermediate-ca.crt server-cert.crt > bundle.crt

# ✅ Ordre correct (du plus spécifique au plus général)
cat server-cert.crt intermediate-ca.crt root-ca.crt > bundle.crt
```

#### 3. Certificat expiré dans la chaîne

```bash
# Vérifier les dates d'expiration de toute la chaîne
openssl storeutl -noout -text -certs ca-chain.crt | grep -A 2 "Validity"
```

### Bundle de certificats

Un **certificate bundle** est un fichier contenant plusieurs certificats dans l'ordre de la chaîne de confiance.

```bash
# Créer un bundle complet (format PEM)
cat server-cert.crt intermediate-ca.crt root-ca.crt > full-chain.pem

# Vérifier le contenu du bundle
openssl crl2pkcs7 -nocrl -certfile full-chain.pem | \
  openssl pkcs7 -print_certs -text -noout
```

> [!tip] Formats de bundle
> 
> - **PEM** : Fichiers texte base64, un certificat après l'autre
> - **PKCS#7** : Format binaire ou base64 pour plusieurs certificats
> - **PKCS#12** : Format contenant certificats ET clé privée (avec mot de passe)

### Path Building

Certains clients (navigateurs, applications) peuvent **construire automatiquement** la chaîne de confiance en utilisant :

- **AIA (Authority Information Access)** : Extension du certificat indiquant où télécharger le certificat de l'émetteur
- **Cache local** : Certificats intermédiaires déjà rencontrés
- **Heuristiques** : Deviner la chaîne possible

```bash
# Exemple d'extension AIA dans un certificat
X509v3 Authority Information Access:
    CA Issuers - URI:http://ca.example.com/intermediate-ca.crt
    OCSP - URI:http://ocsp.example.com
```

> [!info] Bonne pratique Même si le path building existe, il est recommandé de **toujours fournir la chaîne complète** pour :
> 
> - Éviter les échecs si l'AIA n'est pas accessible
> - Améliorer les performances (pas de téléchargement supplémentaire)
> - Garantir la compatibilité avec tous les clients

---

## 🏢 CA publiques vs CA privées {#ca-publiques-privees}

### CA publiques (Public Certificate Authorities)

#### Définition

Les **CA publiques** sont des autorités de certification commerciales reconnues mondialement, dont les certificats racine sont pré-installés dans les navigateurs et systèmes d'exploitation. Elles émettent des certificats de confiance pour Internet.

#### Exemples de CA publiques majeures

- **DigiCert** (anciennement Symantec, Thawte, GeoTrust)
- **Let's Encrypt** (CA gratuite et automatisée)
- **GlobalSign**
- **Sectigo** (anciennement Comodo)
- **Entrust**
- **IdenTrust**

> [!info] Programme Root Store Les CA publiques doivent être acceptées dans les "root programs" des navigateurs et OS :
> 
> - **Mozilla Root Program** (Firefox)
> - **Microsoft Trusted Root Program** (Windows, Edge)
> - **Apple Root Program** (macOS, iOS, Safari)
> - **Google Chrome** (utilise généralement celui de l'OS)

#### Caractéristiques des CA publiques

|Aspect|Description|
|---|---|
|**Confiance universelle**|Certificats reconnus par défaut sur Internet|
|**Validation stricte**|Processus de vérification selon CA/Browser Forum Baseline Requirements|
|**Coût**|Gratuit (Let's Encrypt) à plusieurs milliers d'euros par an (EV)|
|**Audit**|Audits WebTrust ou ETSI réguliers obligatoires|
|**Révocation**|CRL et OCSP publics obligatoires|
|**Transparence**|Certificate Transparency (CT) obligatoire|

#### Types de certificats publics

```bash
# 1. Domain Validation (DV) - Validation de domaine uniquement
# Vérification: Prouver le contrôle du domaine (email, DNS, HTTP)
# Durée: Quelques minutes
# Usage: Sites web basiques, blogs, sites personnels

# 2. Organization Validation (OV) - Validation de l'organisation
# Vérification: DV + vérification de l'existence légale de l'entreprise
# Durée: 1 à 3 jours
# Usage: Sites d'entreprise, intranets accessibles publiquement

# 3. Extended Validation (EV) - Validation étendue
# Vérification: OV + vérification approfondie (statut légal, adresse physique, etc.)
# Durée: 3 à 7 jours
# Usage: Banques, e-commerce, sites nécessitant haute confiance
# Affichage: Barre d'adresse verte (historiquement), nom de l'organisation visible
```

#### Processus d'obtention d'un certificat public

```bash
# 1. Générer une clé privée et un CSR
openssl req -new -newkey rsa:2048 -nodes \
  -keyout www.example.com.key \
  -out www.example.com.csr \
  -subj "/C=FR/ST=Île-de-France/L=Paris/O=MonEntreprise/CN=www.example.com"

# 2. Soumettre le CSR à la CA publique via leur portail web

# 3. Valider le domaine (méthodes courantes):
#    - Email: Recevoir un email à admin@example.com et cliquer sur le lien
#    - HTTP: Placer un fichier à http://example.com/.well-known/pki-validation/
#    - DNS: Créer un enregistrement TXT avec un token fourni

# 4. La CA émet le certificat (+ bundle de CA intermédiaires)

# 5. Installer le certificat sur votre serveur
```

> [!tip] Let's Encrypt - Automatisation Let's Encrypt permet l'automatisation complète via le protocole ACME :
> 
> ```bash
> # Installation avec Certbot
> certbot --nginx -d www.example.com -d example.com
> 
> # Renouvellement automatique (cron)
> certbot renew --quiet
> ```

#### Avantages des CA publiques

✅ **Confiance immédiate** : Pas besoin de distribuer la CA racine ✅ **Compatibilité universelle** : Fonctionne sur tous les navigateurs et OS ✅ **Maintenance professionnelle** : Révocation, OCSP, CT gérés par la CA ✅ **Conformité** : Respect des standards CA/Browser Forum

#### Inconvénients des CA publiques

❌ **Coût** : Certificats OV/EV peuvent être chers (sauf Let's Encrypt gratuit) ❌ **Processus de validation** : Peut prendre du temps (notamment EV) ❌ **Dépendance externe** : Vous dépendez de la CA pour l'émission et la révocation ❌ **Limitations d'usage** : Pas pour les réseaux internes ou les tests

---

### CA privées (Private Certificate Authorities)

#### Définition

Les **CA privées** (ou CA internes) sont des autorités de certification créées et gérées par une organisation pour ses propres besoins internes. Leurs certificats ne sont pas reconnus publiquement sur Internet.

> [!info] Cas d'usage typiques
> 
> - **Intranet** : Sites web internes de l'entreprise
> - **Authentification** : Certificats utilisateurs pour VPN, WiFi, email
> - **IoT/M2M** : Authentification entre machines et objets connectés
> - **Code signing interne** : Signer les applications internes
> - **Tests et développement** : Environnements de staging/dev

#### Caractéristiques des CA privées

|Aspect|Description|
|---|---|
|**Contrôle total**|L'organisation gère l'ensemble du cycle de vie|
|**Coût**|Pas de frais récurrents par certificat|
|**Flexibilité**|Émission rapide, durées personnalisées, usages spécifiques|
|**Distribution manuelle**|Nécessite de distribuer la CA racine sur tous les clients|
|**Maintenance interne**|L'organisation doit gérer infrastructure, révocation, sécurité|

#### Mise en place d'une CA privée

##### Option 1 : OpenSSL (manuel)

```bash
# Configuration d'une PKI complète avec OpenSSL

# 1. Créer la structure de répertoires
mkdir -p /root/ca/{certs,crl,newcerts,private,csr}
touch /root/ca/index.txt
echo 1000 > /root/ca/serial

# 2. Fichier de configuration OpenSSL
cat > /root/ca/openssl.cnf << 'EOF'
[ ca ]
default_ca = CA_default

[ CA_default ]
dir               = /root/ca
certs             = $dir/certs
crl_dir           = $dir/crl
new_certs_dir     = $dir/newcerts
database          = $dir/index.txt
serial            = $dir/serial
private_key       = $dir/private/ca.key
certificate       = $dir/certs/ca.crt
crl               = $dir/crl/ca.crl
crlnumber         = $dir/crlnumber
default_md        = sha256
name_opt          = ca_default
cert_opt          = ca_default
default_days      = 365
preserve          = no
policy            = policy_loose

[ policy_loose ]
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional
EOF

# 3. Créer la CA racine
openssl genrsa -aes256 -out /root/ca/private/ca.key 4096
openssl req -config /root/ca/openssl.cnf -key /root/ca/private/ca.key \
  -new -x509 -days 7300 -sha256 -extensions v3_ca \
  -out /root/ca/certs/ca.crt

# 4. Émettre un certificat serveur
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr
openssl ca -config /root/ca/openssl.cnf -extensions server_cert \
  -days 375 -notext -md sha256 -in server.csr -out server.crt
```

##### Option 2 : Easy-RSA (simplifié)

```bash
# Installation d'Easy-RSA
git clone https://github.com/OpenVPN/easy-rsa.git
cd easy-rsa/easyrsa3

# Initialisation de la PKI
./easyrsa init-pki

# Création de la CA
./easyrsa build-ca

# Génération d'un certificat serveur
./easyrsa gen-req server nopass
./easyrsa sign-req server server

# Génération d'un certificat client
./easyrsa gen-req client1 nopass
./easyrsa sign-req client client1
```

##### Option 3 : Microsoft ADCS (Active Directory Certificate Services)

```powershell
# Installation du rôle ADCS sur Windows Server
Install-WindowsFeature -Name ADCS-Cert-Authority -IncludeManagementTools

# Configuration de la CA d'entreprise
Install-AdcsCertificationAuthority -CAType EnterpriseRootCA `
  -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" `
  -KeyLength 4096 `
  -HashAlgorithmName SHA256 `
  -ValidityPeriod Years `
  -ValidityPeriodUnits 10

# Déploiement automatique via GPO pour distribuer la CA racine
```

##### Option 4 : Solutions open-source avancées

```bash
# CFSSL (CloudFlare SSL)
# Idéal pour l'automatisation et les API

# Installation
go get -u github.com/cloudflare/cfssl/cmd/cfssl
go get -u github.com/cloudflare/cfssl/cmd/cfssljson

# Configuration JSON pour la CA
cat > ca-config.json << 'EOF'
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "server": {
        "usages": ["signing", "key encipherment", "server auth"],
        "expiry": "8760h"
      },
      "client": {
        "usages": ["signing", "key encipherment", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF

# Création de la CA
cfssl gencert -initca ca-csr.json | cfssljson -bare ca

# Émission d'un certificat
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem \
  -config=ca-config.json -profile=server \
  server-csr.json | cfssljson -bare server
```

#### Distribution de la CA racine privée

> [!warning] Étape critique Pour que les certificats émis par votre CA privée soient acceptés, vous devez installer le certificat racine sur tous les clients.

##### Windows

```powershell
# Méthode 1: Via GPO (domaine Active Directory)
# Computer Configuration → Policies → Windows Settings → Security Settings
# → Public Key Policies → Trusted Root Certification Authorities

# Méthode 2: Ligne de commande
certutil -addstore -f "ROOT" ca.crt

# Méthode 3: Interface graphique
# Win+R → certmgr.msc → Trusted Root Certification Authorities
# → Certificates → Import
```

##### Linux (Debian/Ubuntu)

```bash
# Copier le certificat
sudo cp ca.crt /usr/local/share/ca-certificates/mon-ca.crt

# Mettre à jour le magasin de certificats
sudo update-ca-certificates

# Vérification
openssl verify server.crt
```

##### Linux (RHEL/CentOS)

```bash
# Copier le certificat
sudo cp ca.crt /etc/pki/ca-trust/source/anchors/

# Mettre à jour le magasin
sudo update-ca-trust
```

##### macOS

```bash
# Ligne de commande
sudo security add-trusted-cert -d -r trustRoot \
  -k /Library/Keychains/System.keychain ca.crt

# Interface graphique
# Keychain Access → System → Drag & Drop ca.crt
# Double-clic → Trust → Always Trust
```

##### Firefox (indépendant de l'OS)

```
# Firefox a son propre magasin de certificats
# Preferences → Privacy & Security → Certificates → View Certificates
# → Authorities → Import → Sélectionner ca.crt
# → Trust this CA to identify websites
```

#### Avantages des CA privées

✅ **Contrôle total** : Vous gérez tous les aspects de la PKI ✅ **Gratuité** : Pas de coûts par certificat ✅ **Rapidité** : Émission instantanée sans validation externe ✅ **Flexibilité** : Durées de validité personnalisées, usages spécifiques ✅ **Sécurité** : Données sensibles restent internes ✅ **Scalabilité** : Milliers de certificats sans surcoût

#### Inconvénients des CA privées

❌ **Distribution manuelle** : Nécessite de déployer la CA racine partout ❌ **Maintenance** : Infrastructure et sécurité à gérer en interne ❌ **Compétences requises** : Expertise PKI nécessaire ❌ **Pas de confiance publique** : Ne fonctionne pas pour les sites web publics ❌ **Responsabilité** : Vous êtes responsables des failles de sécurité ❌ **Pas d'audit externe** : Pas de validation tierce des pratiques

---

### Comparaison détaillée CA publiques vs CA privées

|Critère|CA Publique|CA Privée|
|---|---|---|
|**Confiance**|Universelle (pré-installée)|Limitée (distribution manuelle)|
|**Coût initial**|Faible à moyen|Élevé (infrastructure)|
|**Coût par certificat**|Variable (0€ à 1000€+/an)|Nul après mise en place|
|**Temps d'émission**|Minutes à jours (selon validation)|Immédiat|
|**Durée de validité**|Max 398 jours (navigateurs)|Illimitée (flexible)|
|**Usage**|Internet public|Réseau interne, IoT, dev/test|
|**Révocation**|CRL/OCSP publics obligatoires|Selon vos besoins|
|**Audit/Conformité**|WebTrust/ETSI obligatoire|Optionnel|
|**Expertise requise**|Minimale (processus guidé)|Élevée (gestion complète)|
|**Scalabilité**|Excellente (infrastructure CA)|Selon votre infrastructure|
|**Sécurité**|Professionnelle (standards stricts)|À votre charge|
|**Flexibilité**|Limitée (politiques CA)|Totale|

### Cas d'usage recommandés

> [!example] Quand utiliser une CA publique

**Sites web publics**

```bash
# ✅ Utilisez Let's Encrypt ou une CA commerciale
# Exemple: Site vitrine, blog, e-commerce accessible sur Internet
certbot --nginx -d www.example.com
```

**Applications mobiles publiques**

```bash
# ✅ Utilisez une CA publique pour l'API backend
# Les apps iOS/Android font confiance aux CA publiques par défaut
```

**Services SaaS**

```bash
# ✅ Toute application accessible publiquement
# Exemples: API publique, webhook endpoints, services cloud
```

> [!example] Quand utiliser une CA privée

**Réseau interne d'entreprise**

```bash
# ✅ Intranet, SharePoint, applications métier internes
# Exemple: https://intranet.entreprise.local
./easyrsa build-server-full intranet.entreprise.local nopass
```

**Authentification utilisateur**

```bash
# ✅ Certificats pour VPN, WiFi WPA2-Enterprise, S/MIME
# Exemple: Certificat personnel pour Jean Dupont
./easyrsa build-client-full jean.dupont nopass
```

**Infrastructure IoT/M2M**

```bash
# ✅ Authentification mutuelle entre appareils
# Exemple: Capteurs industriels, caméras de surveillance
# Des milliers de certificats nécessaires → CA privée économique
```

**Environnements de développement**

```bash
# ✅ Tests locaux avec HTTPS
# Exemple: https://localhost, https://dev.local
mkcert localhost 127.0.0.1 ::1
```

**Signature de code interne**

```bash
# ✅ Signer les applications internes de l'entreprise
# Évite les coûts d'un certificat code signing commercial
```

### Approche hybride

Beaucoup d'organisations utilisent **les deux types** de CA :

```
🏢 Infrastructure PKI Entreprise

├── 🌐 CA Publique (DigiCert)
│   ├── www.example.com (site web public)
│   ├── api.example.com (API publique)
│   └── mail.example.com (serveur email externe)
│
└── 🔒 CA Privée Interne
    ├── intranet.corp (portail interne)
    ├── Certificats utilisateurs (VPN, WiFi)
    ├── Certificats IoT (1000+ appareils)
    └── Environnements dev/test
```

> [!tip] Bonne pratique hybride
> 
> - **Public** pour tout ce qui est exposé sur Internet
> - **Privé** pour tout ce qui est interne à l'organisation
> - Séparez clairement les deux infrastructures
> - Documentez quelle CA utiliser pour chaque cas d'usage

---

## 🎓 Concepts avancés de hiérarchie

### Hiérarchies multi-niveaux

Certaines grandes organisations utilisent des hiérarchies à 3 niveaux ou plus :

```
🌳 CA Racine (offline, 30 ans)
    |
    ├── 🔗 CA Intermédiaire Politique A (offline, 10 ans)
    │       ├── 🔗 CA Émettrice Serveurs (online, 5 ans)
    │       └── 🔗 CA Émettrice Utilisateurs (online, 5 ans)
    |
    └── 🔗 CA Intermédiaire Politique B (offline, 10 ans)
            ├── 🔗 CA Émettrice Code (online, 3 ans)
            └── 🔗 CA Émettrice IoT (online, 5 ans)
```

**Avantages** :

- Isolation encore plus forte (CA intermédiaires aussi hors ligne)
- Politiques de sécurité différentes par branche
- Révocation granulaire (toute une branche)

**Inconvénients** :

- Complexité accrue
- Chaînes de confiance plus longues (impact performance)
- Gestion plus lourde

### Cross-certification

Permet à deux hiérarchies PKI distinctes de se faire confiance mutuellement :

```
🌳 CA Racine Entreprise A          🌳 CA Racine Entreprise B
    |                    ⟷              |
    ├── CA Int. A1      cross-sign      ├── CA Int. B1
    └── CA Int. A2                      └── CA Int. B2
```

> [!info] Cas d'usage
> 
> - Fusion/acquisition d'entreprises
> - Partenariats entre organisations
> - Fédération d'identités

```bash
# Entreprise A signe le certificat de la CA racine B
openssl x509 -req -in ca-root-b.csr \
  -CA ca-root-a.crt -CAkey ca-root-a.key \
  -out ca-root-b-signed-by-a.crt

# Et réciproquement
openssl x509 -req -in ca-root-a.csr \
  -CA ca-root-b.crt -CAkey ca-root-b.key \
  -out ca-root-a-signed-by-b.crt
```

### Bridge CA

Une **Bridge CA** est une CA spéciale qui interconnecte plusieurs hiérarchies PKI :

```
        🌉 Bridge CA
           /  |  \
          /   |   \
    🌳 CA-A  🌳 CA-B  🌳 CA-C
```

Utilisée notamment dans les environnements gouvernementaux (ex: Federal PKI Bridge aux USA).

### Durées de validité optimales

> [!tip] Recommandations selon le niveau

|Niveau|Durée recommandée|Justification|
|---|---|---|
|**CA Racine**|20-30 ans|Minimiser les renouvellements critiques|
|**CA Intermédiaire**|5-10 ans|Équilibre entre sécurité et gestion|
|**Certificats serveurs**|1 an (max 398 jours)|Limite imposée par les navigateurs|
|**Certificats utilisateurs**|1-3 ans|Facilite la gestion des départs|
|**Certificats IoT/M2M**|3-5 ans|Réduit la maintenance sur appareils contraints|
|**Certificats code signing**|1-3 ans|Équilibre sécurité/coût|

### Gestion de la fin de vie d'une CA

Quand une CA racine arrive en fin de vie, un processus de migration est nécessaire :

```bash
# 1. Créer une nouvelle CA racine
openssl genrsa -aes256 -out new-root-ca.key 4096
openssl req -x509 -new -nodes -key new-root-ca.key \
  -sha256 -days 7300 -out new-root-ca.crt

# 2. Cross-signer l'ancienne CA avec la nouvelle (transition)
openssl x509 -req -in old-root-ca.csr \
  -CA new-root-ca.crt -CAkey new-root-ca.key \
  -out old-root-signed-by-new.crt

# 3. Période de transition (1-2 ans)
#    - Distribuer la nouvelle CA racine
#    - Émettre les nouveaux certificats avec la nouvelle CA
#    - Maintenir les deux CA en parallèle

# 4. Décommissionnement de l'ancienne CA
#    - Arrêter d'émettre de nouveaux certificats
#    - Attendre l'expiration de tous les anciens certificats
#    - Révoquer formellement l'ancienne CA racine
#    - Détruire les clés privées de manière sécurisée
```

> [!warning] Destruction sécurisée des clés Lors du décommissionnement d'une CA :
> 
> ```bash
> # 1. Archiver les logs et audits (conformité légale)
> 
> # 2. Révoquer tous les certificats actifs
> 
> # 3. Détruire les clés privées
> # Si sur HSM: commande de destruction du HSM
> # Si sur fichier: multiple overwrites
> shred -vfz -n 10 old-ca-private-key.pem
> 
> # 4. Détruire les supports physiques (si applicable)
> # Broyage de disques durs, destruction de HSM
> 
> # 5. Documenter le processus (audit trail)
> ```

---

## 🛡️ Sécurité de la hiérarchie PKI

### Principe de défense en profondeur

Une PKI sécurisée applique plusieurs couches de protection :

#### 1. Sécurité physique

```
🔒 CA Racine
├── Salle sécurisée (badge + biométrie)
├── Cage grillagée avec serrure
├── Caméras de surveillance 24/7
├── Système anti-incendie
└── Alimentation redondante
```

#### 2. Sécurité logique

```bash
# Contrôle d'accès basé sur les rôles (RBAC)
CA Administrator (peut tout faire)
├── Security Officer (gestion des politiques)
├── Certificate Manager (émission/révocation)
├── Auditor (lecture seule des logs)
└── Backup Operator (sauvegarde uniquement)
```

#### 3. Sécurité cryptographique

```bash
# Utilisation de HSM (Hardware Security Module)
# Les clés privées ne sortent JAMAIS du HSM

# Algorithmes recommandés en 2025
- RSA: Minimum 2048 bits (4096 bits pour CA racine)
- ECDSA: Minimum P-256 (P-384 recommandé pour CA racine)
- Hash: SHA-256 minimum (SHA-384/512 pour CA racine)
```

> [!warning] Algorithmes dépréciés ❌ MD5 (cassé depuis 2004) ❌ SHA-1 (déprécié depuis 2017) ❌ RSA 1024 bits (insuffisant) ❌ DES/3DES (obsolètes)

#### 4. Séparation des privilèges

```bash
# Cérémonie de clés: Opération critique nécessitant plusieurs personnes

# Exemple: Génération de la clé racine
Personne A: Possède 1/3 de la passphrase
Personne B: Possède 1/3 de la passphrase  
Personne C: Possède 1/3 de la passphrase
Security Officer: Supervise l'opération
Auditor: Enregistre et vérifie le processus

# Les 3 personnes doivent être présentes simultanément
# Principe de "dual control" ou "split knowledge"
```

### Monitoring et audit

```bash
# Logs essentiels à surveiller

# 1. Émission de certificats
[2025-12-29 10:23:45] CERT_ISSUED: CN=server.example.com, Serial=1A2B3C

# 2. Révocations
[2025-12-29 11:30:12] CERT_REVOKED: Serial=1A2B3C, Reason=keyCompromise

# 3. Accès à la CA
[2025-12-29 09:15:33] CA_ACCESS: User=admin@example.com, Action=sign_cert

# 4. Modifications de configuration
[2025-12-29 08:45:21] CONFIG_CHANGE: Policy updated by admin@example.com

# 5. Tentatives d'accès non autorisées
[2025-12-29 12:05:47] ACCESS_DENIED: User=unknown, IP=192.168.1.50
```

> [!tip] Alertes automatiques Configurez des alertes pour :
> 
> - Échecs d'authentification répétés
> - Révocations multiples en peu de temps
> - Émission de certificats en dehors des heures ouvrables
> - Modifications de la configuration de la CA
> - Accès aux clés privées (lecture HSM)

### Plan de réponse aux incidents

> [!warning] Scénarios de compromission

#### Scénario 1 : Compromission d'un certificat final

```bash
# Impact: Faible (un seul certificat)
# Réponse:
1. Révoquer immédiatement le certificat compromis
2. Émettre un nouveau certificat avec une nouvelle clé
3. Publier CRL mise à jour / invalider via OCSP
4. Investiguer la cause de la compromission
5. Renforcer les contrôles si nécessaire
```

#### Scénario 2 : Compromission d'une CA intermédiaire

```bash
# Impact: Moyen à élevé (tous les certificats de cette CA)
# Réponse:
1. URGENCE: Déconnecter la CA du réseau
2. Révoquer le certificat de la CA intermédiaire via la CA racine
3. Publier immédiatement une CRL mise à jour
4. Notifier tous les utilisateurs affectés
5. Créer une nouvelle CA intermédiaire
6. Réémettre tous les certificats nécessaires
7. Audit complet de sécurité
8. Rapport d'incident détaillé

# Timeline: 1-4 heures pour la révocation
#           1-7 jours pour la récupération complète
```

#### Scénario 3 : Compromission de la CA racine

```bash
# Impact: CATASTROPHIQUE (toute la PKI)
# Réponse:
1. ALERTE MAXIMALE: Déclencher le plan de continuité d'activité
2. Isoler immédiatement la CA racine
3. Notifier TOUS les utilisateurs et systèmes
4. Publier une annonce publique (si CA publique)
5. Décommissionner complètement l'ancienne PKI
6. Créer une nouvelle PKI de zéro
7. Réémettre TOUS les certificats
8. Audit légal et technique complet
9. Potentielles poursuites légales

# Timeline: Plusieurs semaines à plusieurs mois
# Coût: Potentiellement millions d'euros
```

> [!info] Prévention critique La compromission d'une CA racine est un événement si grave que toute l'énergie doit être mise dans sa **prévention** :
> 
> - CA racine hors ligne (air-gapped)
> - HSM certifié FIPS 140-2 niveau 3+
> - Cérémonie de clés avec témoin
> - Salle sécurisée avec accès ultra-restreint
> - Audit de sécurité régulier
> - Tests de pénétration annuels

---

## 📊 Récapitulatif et bonnes pratiques

### Checklist de déploiement PKI

> [!tip] Avant de déployer votre PKI

**Phase de conception**

- [ ] Définir les cas d'usage (serveurs, utilisateurs, IoT, etc.)
- [ ] Choisir entre CA publique, privée, ou hybride
- [ ] Concevoir la hiérarchie (2 ou 3 niveaux)
- [ ] Définir les politiques de sécurité (CP/CPS)
- [ ] Planifier les durées de validité
- [ ] Prévoir la scalabilité (combien de certificats ?)

**Phase de sécurisation**

- [ ] Sécuriser physiquement la CA racine
- [ ] Acquérir un HSM pour les clés critiques
- [ ] Mettre en place la séparation des privilèges
- [ ] Configurer la journalisation complète
- [ ] Planifier les sauvegardes (clés, configuration, base de données)
- [ ] Tester le plan de reprise après sinistre

**Phase de déploiement**

- [ ] Créer la CA racine (cérémonie de clés)
- [ ] Créer les CA intermédiaires
- [ ] Distribuer la CA racine sur tous les clients
- [ ] Configurer la révocation (CRL, OCSP)
- [ ] Former les administrateurs
- [ ] Documenter tous les processus

**Phase opérationnelle**

- [ ] Monitorer les logs en continu
- [ ] Renouveler les certificats avant expiration
- [ ] Maintenir les CRL à jour
- [ ] Audit de sécurité régulier
- [ ] Exercices de réponse aux incidents
- [ ] Veille sur les vulnérabilités

### Erreurs courantes à éviter

> [!warning] Top 10 des erreurs PKI

1. **CA racine en ligne** 🚫
    
    - Ne jamais laisser la CA racine connectée au réseau
2. **Clés privées non protégées** 🚫
    
    - Toujours chiffrer les clés privées (AES-256)
    - Utiliser un HSM pour les CA critiques
3. **Pas de backup** 🚫
    
    - Perdre les clés privées = perte totale de la PKI
    - Backups chiffrés, multiple sites
4. **Oublier la révocation** 🚫
    
    - Toujours configurer CRL ou OCSP
    - Tester la révocation régulièrement
5. **Durées de validité excessives** 🚫
    
    - Respecter les limites des navigateurs (398 jours max)
    - Plus court = plus sécurisé
6. **Chaîne de confiance incomplète** 🚫
    
    - Toujours fournir les certificats intermédiaires
    - Tester avec différents clients
7. **Pas de monitoring** 🚫
    
    - Les logs sont essentiels pour détecter les anomalies
    - Alertes automatiques configurées
8. **Algorithmes faibles** 🚫
    
    - Pas de SHA-1, pas de RSA 1024
    - Minimum RSA 2048 ou ECDSA P-256
9. **Pas de plan d'incident** 🚫
    
    - Préparer les procédures de réponse
    - Exercices réguliers
10. **Distribution manuelle non planifiée** 🚫
    
    - Pour les CA privées, automatiser via GPO/MDM
    - Documenter le processus pour les nouveaux clients

### Ressources et standards

**Standards à connaître**

- **RFC 5280** : Profil de certificat X.509 et CRL
- **RFC 6960** : OCSP (Online Certificate Status Protocol)
- **CA/Browser Forum Baseline Requirements** : Standards pour les CA publiques
- **FIPS 140-2** : Standard de sécurité cryptographique (HSM)
- **WebTrust** : Audit des CA publiques

**Outils recommandés**

- **OpenSSL** : Outil CLI universel pour la PKI
- **Easy-RSA** : Simplification pour OpenVPN et usage général
- **CFSSL** : CA moderne avec API (CloudFlare)
- **Step CA** : CA moderne avec ACME support (Smallstep)
- **XCA** : Interface graphique pour gérer une PKI
- **Microsoft ADCS** : Solution Windows intégrée AD

---

## 🎯 Points clés à retenir

> [!info] Synthèse de la hiérarchie PKI

1. **CA Racine** = Sommet de la confiance, protégée au maximum, hors ligne, durée de vie très longue
    
2. **CA Intermédiaires** = Opérationnelles, signent les certificats finaux, protègent la racine
    
3. **Chaîne de confiance** = Séquence de signatures reliant un certificat à une racine de confiance
    
4. **CA publiques** = Pour Internet public, confiance universelle, processus de validation strict
    
5. **CA privées** = Pour usage interne, contrôle total, nécessite distribution manuelle
    
6. **Sécurité = Priorité absolue** = Une PKI compromise est une catastrophe organisationnelle
    
7. **Automatisation intelligente** = Automatiser l'émission et le renouvellement, mais garder le contrôle sur les opérations critiques
    

---

_Fin du cours - Hiérarchie de certification_