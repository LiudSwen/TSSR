

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

La validation de certificats est un processus critique dans une infrastructure PKI. Elle garantit qu'un certificat présenté est authentique, valide et digne de confiance avant d'établir une connexion sécurisée ou d'effectuer une opération cryptographique.

> [!info] Pourquoi valider un certificat ? Un certificat peut être techniquement correct mais ne plus être fiable (révoqué, expiré, usurpé). La validation permet de s'assurer que le certificat respecte toutes les conditions de sécurité nécessaires avant de lui faire confiance.

La validation d'un certificat comporte quatre vérifications essentielles qui doivent toutes réussir :

1. **Chaîne de confiance** : Le certificat est-il signé par une autorité reconnue ?
2. **Statut de révocation** : Le certificat a-t-il été révoqué ?
3. **Période de validité** : Le certificat est-il encore valide temporellement ?
4. **Usage** : Le certificat est-il utilisé conformément à sa destination ?

---

## 1. Vérification de la chaîne de confiance

### 📖 Concept

La chaîne de confiance (ou _chain of trust_) est la séquence de certificats qui relie un certificat d'entité finale à une autorité de certification racine de confiance. Cette chaîne permet de vérifier l'authenticité d'un certificat en remontant jusqu'à une racine reconnue.

> [!info] Structure de la chaîne **Certificat d'entité** ← signé par ← **CA intermédiaire(s)** ← signé par ← **CA racine** (présente dans le trust store)

### 🎯 Pourquoi c'est important

Sans vérification de la chaîne de confiance, un attaquant pourrait créer son propre certificat auto-signé et se faire passer pour n'importe quelle entité. La chaîne de confiance garantit que seules les CA reconnues peuvent émettre des certificats valides.

### 🔧 Processus de vérification

La vérification de la chaîne de confiance suit ces étapes :

1. **Extraction du certificat émetteur** : Identifier la CA qui a signé le certificat
2. **Récupération du certificat de la CA** : Obtenir le certificat public de l'émetteur
3. **Vérification de la signature** : Valider que la signature du certificat correspond à la clé publique de l'émetteur
4. **Remontée de la chaîne** : Répéter le processus jusqu'à atteindre une CA racine de confiance
5. **Vérification de la racine** : S'assurer que la CA racine est présente dans le trust store

```bash
# Vérifier la chaîne de confiance d'un certificat avec OpenSSL
openssl verify -CAfile ca-bundle.crt -untrusted intermediate-ca.crt server.crt

# Afficher la chaîne de confiance complète d'un site web
openssl s_client -connect example.com:443 -showcerts

# Vérifier avec un répertoire de CA de confiance
openssl verify -CApath /etc/ssl/certs/ server.crt

# Vérifier en construisant explicitement la chaîne
openssl verify -CAfile root-ca.crt -untrusted intermediate-ca.crt entity.crt
```

### 📊 Composants de la chaîne

|Composant|Rôle|Caractéristiques|
|---|---|---|
|**CA Racine**|Ancre de confiance|Auto-signé, durée de vie longue (20-30 ans)|
|**CA Intermédiaire**|Signer les certificats d'entités|Signé par la racine, durée de vie moyenne (5-10 ans)|
|**Certificat d'entité**|Identifier l'entité finale|Signé par une CA intermédiaire, durée courte (1-2 ans)|

> [!warning] Trust Store Le trust store est la collection de certificats racine de confiance installés sur un système. La sécurité de toute la PKI repose sur l'intégrité de ce trust store. Un certificat racine compromis dans le trust store compromet toute la sécurité.

### 🔍 Vérification technique

```bash
# Extraire l'émetteur d'un certificat
openssl x509 -in server.crt -noout -issuer
# Résultat : issuer=C=US, O=Example CA, CN=Example Intermediate CA

# Extraire le sujet (qui possède ce certificat)
openssl x509 -in server.crt -noout -subject
# Résultat : subject=C=US, ST=California, O=Example Corp, CN=www.example.com

# Vérifier si la signature est valide
openssl verify -verbose -CAfile ca-chain.crt server.crt

# Afficher toute la chaîne lors d'une connexion TLS
openssl s_client -connect www.example.com:443 -showcerts </dev/null 2>/dev/null | \
  openssl x509 -text -noout
```

### ⚠️ Erreurs courantes

**Erreur : "unable to get local issuer certificate"**

```bash
# Problème : Le certificat de la CA émettrice n'est pas trouvé
# Solution : Fournir le bundle de CA complet
openssl verify -CAfile complete-ca-bundle.crt server.crt
```

**Erreur : "certificate signature failure"**

```bash
# Problème : La signature ne correspond pas
# Causes possibles : certificat corrompu, mauvaise CA, attaque
# Vérification : Comparer les empreintes
openssl x509 -in server.crt -noout -fingerprint
```

> [!tip] Astuce : Ordre des certificats Dans un fichier contenant plusieurs certificats pour une chaîne, l'ordre est important : certificat d'entité en premier, puis intermédiaires, puis racine (optionnelle car déjà dans le trust store).

### 🛠️ Construction d'une chaîne complète

```bash
# Créer un fichier de chaîne complète (pour serveur web)
cat server.crt intermediate-ca.crt > server-chain.crt

# Vérifier que la chaîne est complète
openssl verify -CAfile root-ca.crt server-chain.crt

# Tester la chaîne sur un serveur
openssl s_client -connect localhost:443 -CAfile root-ca.crt
```

> [!example] Exemple pratique : Chaîne Let's Encrypt Pour un certificat Let's Encrypt :
> 
> 1. **Certificat d'entité** : votre-domaine.com
> 2. **CA Intermédiaire** : R10 ou R11 (Let's Encrypt Authority)
> 3. **CA Racine** : ISRG Root X1 (présent dans les navigateurs)

---

## 2. Vérification du statut de révocation

### 📖 Concept

La vérification du statut de révocation permet de s'assurer qu'un certificat n'a pas été révoqué avant son expiration naturelle. Un certificat peut être révoqué pour diverses raisons : compromission de clé privée, changement d'informations, cessation d'activité, etc.

> [!warning] Importance critique Un certificat techniquement valide peut avoir été révoqué. Ne pas vérifier le statut de révocation expose à des risques majeurs de sécurité, notamment l'utilisation de certificats compromis.

### 🔧 Méthodes de vérification

Il existe deux mécanismes principaux pour vérifier la révocation :

#### A. CRL (Certificate Revocation List)

La CRL est une liste noire publiée périodiquement par la CA contenant tous les certificats révoqués.

```bash
# Télécharger une CRL depuis un certificat
openssl x509 -in server.crt -noout -text | grep -A 4 'CRL Distribution'

# Exemple de résultat :
# X509v3 CRL Distribution Points:
#     Full Name:
#       URI:http://crl.example.com/ca.crl

# Télécharger la CRL
wget http://crl.example.com/ca.crt

# Convertir la CRL en format lisible
openssl crl -in ca.crl -inform DER -text -noout

# Vérifier si un certificat est dans la CRL
openssl crl -in ca.crl -inform DER -text -noout | grep -A 2 "Serial Number"
```

**Structure d'une CRL :**

|Champ|Description|
|---|---|
|**Issuer**|CA qui a publié la CRL|
|**Last Update**|Date de publication|
|**Next Update**|Date de la prochaine CRL|
|**Revoked Certificates**|Liste des numéros de série révoqués avec raison et date|

> [!info] Avantages et inconvénients des CRL **✅ Avantages :**
> 
> - Simple à implémenter
> - Fonctionne hors ligne une fois téléchargée
> - Standard bien établi
> 
> **❌ Inconvénients :**
> 
> - Taille croissante avec le nombre de certificats révoqués
> - Pas de statut en temps réel (délai jusqu'à Next Update)
> - Bande passante importante pour télécharger la liste complète

#### B. OCSP (Online Certificate Status Protocol)

OCSP permet de vérifier le statut d'un certificat spécifique en temps réel via une requête à un répondeur OCSP.

```bash
# Extraire l'URL du répondeur OCSP d'un certificat
openssl x509 -in server.crt -noout -ocsp_uri
# Résultat : http://ocsp.example.com

# Vérifier le statut OCSP d'un certificat
openssl ocsp \
  -issuer intermediate-ca.crt \
  -cert server.crt \
  -url http://ocsp.example.com \
  -CAfile root-ca.crt

# Résultat possible :
# Response verify OK
# server.crt: good
#     This Update: Dec 30 10:00:00 2025 GMT
#     Next Update: Jan  6 10:00:00 2026 GMT

# Vérifier avec un serveur OCSP automatiquement détecté
openssl ocsp -issuer ca.crt -cert server.crt -text -url $(openssl x509 -in server.crt -noout -ocsp_uri)
```

**Réponses OCSP possibles :**

|Statut|Signification|Action|
|---|---|---|
|**good**|Certificat valide et non révoqué|✅ Accepter|
|**revoked**|Certificat révoqué|❌ Rejeter|
|**unknown**|CA ne connaît pas ce certificat|❌ Rejeter (suspect)|

> [!tip] OCSP Stapling L'OCSP Stapling permet au serveur de joindre une réponse OCSP signée à son certificat lors de l'établissement TLS. Cela améliore les performances (pas de requête supplémentaire du client) et la confidentialité (le client n'interroge pas directement l'OCSP).
> 
> ```bash
> # Vérifier si un serveur supporte OCSP Stapling
> openssl s_client -connect example.com:443 -status -tlsextdebug
> ```

#### C. OCSP Must-Staple

Extension qui oblige le serveur à fournir une réponse OCSP stapled. Si le serveur ne peut pas fournir de preuve OCSP, la connexion est rejetée.

```bash
# Vérifier si un certificat a l'extension Must-Staple
openssl x509 -in server.crt -noout -text | grep -A 1 "TLS Feature"
# Résultat : TLS Feature: status_request
```

> [!warning] Must-Staple : Attention aux pannes Avec Must-Staple, si le répondeur OCSP est en panne, le serveur ne peut plus établir de connexions TLS. C'est un compromis entre sécurité et disponibilité.

### 🔍 Comparaison CRL vs OCSP

|Critère|CRL|OCSP|
|---|---|---|
|**Temps réel**|❌ Non (périodique)|✅ Oui|
|**Bande passante**|❌ Élevée (liste complète)|✅ Faible (par certificat)|
|**Confidentialité**|✅ Bonne (pas de requête individuelle)|⚠️ Moyenne (révèle les sites visités)|
|**Disponibilité**|✅ Cache local possible|❌ Dépend du répondeur|
|**Scalabilité**|❌ Problématique pour grandes PKI|✅ Bonne|

### ⚙️ Configuration dans les applications

```bash
# Apache : Activer la vérification CRL
SSLCARevocationCheck chain
SSLCARevocationFile /path/to/crl.pem

# Apache : Activer OCSP Stapling
SSLUseStapling on
SSLStaplingCache "shmcb:logs/ssl_stapling(32768)"

# Nginx : Activer OCSP Stapling
ssl_stapling on;
ssl_stapling_verify on;
ssl_trusted_certificate /path/to/ca-chain.crt;

# Test d'une validation complète avec curl
curl --cacert ca-bundle.crt --cert-status https://example.com
```

> [!example] Exemple pratique : Vérifier un certificat révoqué
> 
> ```bash
> # 1. Télécharger le certificat d'un site
> echo | openssl s_client -connect example.com:443 2>/dev/null | \
>   openssl x509 > site.crt
> 
> # 2. Extraire l'URL OCSP
> OCSP_URL=$(openssl x509 -in site.crt -noout -ocsp_uri)
> 
> # 3. Obtenir le certificat de la CA émettrice
> echo | openssl s_client -connect example.com:443 -showcerts 2>/dev/null | \
>   sed -n '/BEGIN CERTIFICATE/,/END CERTIFICATE/p' | \
>   sed '1,/END CERTIFICATE/d' > issuer.crt
> 
> # 4. Vérifier le statut OCSP
> openssl ocsp -issuer issuer.crt -cert site.crt -url $OCSP_URL
> ```

### 🛡️ Bonnes pratiques

> [!tip] Recommandations
> 
> - **Toujours vérifier la révocation** dans les environnements de production
> - **Préférer OCSP à CRL** pour les nouvelles implémentations
> - **Activer OCSP Stapling** sur vos serveurs web pour améliorer les performances
> - **Mettre en cache les réponses** OCSP/CRL avec respect des durées de validité
> - **Avoir un plan de secours** si le service OCSP est indisponible (soft-fail vs hard-fail)

### ⚠️ Piège : Soft-fail vs Hard-fail

```bash
# Comportement Soft-fail (par défaut dans beaucoup de navigateurs)
# Si OCSP échoue (serveur inaccessible), la validation continue
# ⚠️ Risque : un attaquant peut bloquer OCSP pour utiliser un certificat révoqué

# Comportement Hard-fail (plus sécurisé)
# Si OCSP échoue, la connexion est rejetée
# ⚠️ Risque : panne du service OCSP = indisponibilité totale
```

---

## 3. Vérification de la période de validité

### 📖 Concept

Chaque certificat possède une période de validité définie par deux dates : **Not Before** (début de validité) et **Not After** (fin de validité). La vérification de la période de validité s'assure que le certificat est utilisé dans sa fenêtre temporelle autorisée.

> [!info] Pourquoi limiter la durée ? Les certificats ont une durée limitée pour plusieurs raisons :
> 
> - Limiter l'exposition en cas de compromission
> - Forcer le renouvellement régulier des clés
> - Permettre l'évolution des algorithmes cryptographiques
> - Réduire l'impact d'une révocation manquée

### 🔧 Extraction et vérification des dates

```bash
# Afficher les dates de validité d'un certificat
openssl x509 -in server.crt -noout -dates

# Résultat :
# notBefore=Dec 15 00:00:00 2024 GMT
# notAfter=Dec 15 23:59:59 2025 GMT

# Afficher en format lisible
openssl x509 -in server.crt -noout -startdate -enddate

# Vérifier si un certificat est actuellement valide (dates + signature)
openssl verify -CAfile ca-bundle.crt server.crt

# Extraire uniquement la date d'expiration
openssl x509 -in server.crt -noout -enddate | cut -d= -f2
```

### 📊 Durées de validité recommandées

|Type de certificat|Durée recommandée|Justification|
|---|---|---|
|**CA Racine**|20-30 ans|Stabilité maximale, changement coûteux|
|**CA Intermédiaire**|5-10 ans|Équilibre entre sécurité et gestion|
|**Certificat serveur**|1-2 ans (max 398 jours depuis 2020)|Sécurité et conformité|
|**Certificat utilisateur**|1-3 ans|Mobilité et renouvellement|
|**Certificat code signing**|1-3 ans|Traçabilité et sécurité|

> [!warning] Limite de 398 jours Depuis septembre 2020, les navigateurs (Chrome, Firefox, Safari) rejettent les certificats TLS avec une durée de validité supérieure à 398 jours (environ 13 mois). Cette règle est imposée par le CA/Browser Forum pour améliorer la sécurité.

### 🕐 Vérification programmatique

```bash
# Script pour vérifier la validité temporelle
#!/bin/bash

CERT="server.crt"
NOW=$(date +%s)

# Extraire les dates et les convertir en timestamps
NOT_BEFORE=$(openssl x509 -in $CERT -noout -startdate | cut -d= -f2)
NOT_AFTER=$(openssl x509 -in $CERT -noout -enddate | cut -d= -f2)

BEFORE_TS=$(date -d "$NOT_BEFORE" +%s)
AFTER_TS=$(date -d "$NOT_AFTER" +%s)

# Vérifier
if [ $NOW -lt $BEFORE_TS ]; then
    echo "❌ Certificat pas encore valide"
    exit 1
elif [ $NOW -gt $AFTER_TS ]; then
    echo "❌ Certificat expiré"
    exit 1
else
    echo "✅ Certificat valide"
    
    # Calculer les jours restants
    DAYS_LEFT=$(( ($AFTER_TS - $NOW) / 86400 ))
    echo "📅 Expire dans $DAYS_LEFT jours"
fi
```

### 📨 Alertes d'expiration

> [!tip] Planifier les renouvellements
> 
> - **90 jours avant expiration** : Première alerte, préparation du renouvellement
> - **60 jours avant expiration** : Seconde alerte, processus de renouvellement
> - **30 jours avant expiration** : Alerte critique, renouvellement urgent
> - **7 jours avant expiration** : Dernière chance, intervention manuelle

```bash
# Script d'alerte d'expiration
#!/bin/bash

CERT="$1"
THRESHOLD_DAYS="${2:-30}"  # Par défaut 30 jours

if [ ! -f "$CERT" ]; then
    echo "Fichier certificat non trouvé"
    exit 1
fi

EXPIRY_DATE=$(openssl x509 -in "$CERT" -noout -enddate | cut -d= -f2)
EXPIRY_TS=$(date -d "$EXPIRY_DATE" +%s)
NOW_TS=$(date +%s)
DAYS_LEFT=$(( ($EXPIRY_TS - $NOW_TS) / 86400 ))

echo "Certificat : $CERT"
echo "Expire le : $EXPIRY_DATE"
echo "Jours restants : $DAYS_LEFT"

if [ $DAYS_LEFT -lt 0 ]; then
    echo "🔴 EXPIRÉ depuis $((-$DAYS_LEFT)) jours !"
    exit 2
elif [ $DAYS_LEFT -lt $THRESHOLD_DAYS ]; then
    echo "🟠 ATTENTION : Expiration dans moins de $THRESHOLD_DAYS jours"
    exit 1
else
    echo "🟢 OK"
    exit 0
fi
```

### 🌐 Vérification pour sites web

```bash
# Vérifier l'expiration d'un site distant
echo | openssl s_client -connect example.com:443 -servername example.com 2>/dev/null | \
  openssl x509 -noout -dates

# Vérification avec alertes
HOST="example.com"
PORT="443"

EXPIRY=$(echo | openssl s_client -connect $HOST:$PORT -servername $HOST 2>/dev/null | \
  openssl x509 -noout -enddate | cut -d= -f2)

echo "Le certificat de $HOST expire le : $EXPIRY"

# Script de monitoring pour plusieurs sites
for HOST in site1.com site2.com site3.com; do
    echo "=== Vérification de $HOST ==="
    echo | timeout 5 openssl s_client -connect $HOST:443 -servername $HOST 2>/dev/null | \
      openssl x509 -noout -subject -dates
    echo ""
done
```

> [!example] Automatisation avec cron
> 
> ```bash
> # Ajouter dans crontab pour vérifier quotidiennement
> 0 9 * * * /usr/local/bin/check-cert-expiry.sh /etc/ssl/certs/server.crt 30 | \
>   mail -s "Alerte certificat" admin@example.com
> ```

### ⚠️ Erreurs courantes

**Certificat expiré :**

```bash
# Erreur OpenSSL
certificate has expired

# Dans les navigateurs
NET::ERR_CERT_DATE_INVALID
```

**Certificat pas encore valide :**

```bash
# Erreur OpenSSL
certificate is not yet valid

# Cause : Horloge système désynchronisée ou certificat créé avec date future
```

> [!warning] Synchronisation horaire Une horloge système mal configurée peut causer des erreurs de validation temporelle. Assurez-vous que NTP est correctement configuré sur vos serveurs :
> 
> ```bash
> # Vérifier la synchronisation NTP
> timedatectl status
> 
> # Synchroniser manuellement si nécessaire
> sudo ntpdate pool.ntp.org
> ```

### 🛡️ Bonnes pratiques

> [!tip] Gestion des certificats
> 
> - **Automatiser les renouvellements** (Let's Encrypt avec certbot, ACME)
> - **Monitorer activement** les dates d'expiration
> - **Prévoir du temps** pour les processus de renouvellement (validations, déploiements)
> - **Documenter les procédures** de renouvellement d'urgence
> - **Avoir des certificats de secours** pour les services critiques
> - **Renouveler avant** 30 jours de l'expiration (marge de sécurité)

### 🔄 Renouvellement automatique avec certbot (Let's Encrypt)

```bash
# Installation de certbot
sudo apt install certbot python3-certbot-nginx

# Obtenir un certificat et configurer automatiquement Nginx
sudo certbot --nginx -d example.com -d www.example.com

# Renouvellement automatique (déjà configuré par défaut)
# Vérifier le timer systemd
systemctl status certbot.timer

# Tester le renouvellement (dry-run)
sudo certbot renew --dry-run

# Forcer un renouvellement
sudo certbot renew --force-renewal
```

---

## 4. Vérification de l'usage

### 📖 Concept

La vérification de l'usage s'assure qu'un certificat est utilisé conformément à sa destination prévue. Les certificats contiennent des extensions qui définissent précisément comment ils peuvent être utilisés. Utiliser un certificat en dehors de son usage autorisé constitue une violation de sécurité.

> [!info] Principe du moindre privilège Un certificat doit avoir uniquement les droits nécessaires à sa fonction. Un certificat serveur ne doit pas pouvoir signer d'autres certificats, et un certificat client ne doit pas pouvoir être utilisé pour un serveur web.

### 🔑 Extensions d'usage principales

#### A. Key Usage (Utilisation de la clé)

Définit les opérations cryptographiques autorisées avec la clé publique du certificat.

```bash
# Afficher le Key Usage d'un certificat
openssl x509 -in server.crt -noout -text | grep -A 1 "Key Usage"

# Résultat possible :
# X509v3 Key Usage: critical
#     Digital Signature, Key Encipherment
```

|Valeur|Usage|Type de certificat|
|---|---|---|
|**Digital Signature**|Signatures numériques (messages, code)|Client, Code signing|
|**Non Repudiation**|Signature avec non-répudiation|Documents officiels|
|**Key Encipherment**|Chiffrement de clés symétriques|Serveur TLS|
|**Data Encipherment**|Chiffrement de données|Chiffrement de fichiers|
|**Key Agreement**|Échange de clés (ECDH)|Serveur TLS moderne|
|**Certificate Signing**|Signature de certificats|CA uniquement|
|**CRL Signing**|Signature de CRL|CA uniquement|
|**Encipher Only**|Chiffrement uniquement (avec Key Agreement)|Spécialisé|
|**Decipher Only**|Déchiffrement uniquement (avec Key Agreement)|Spécialisé|

> [!warning] Extension critique Quand **Key Usage** est marqué "critical", le certificat DOIT être rejeté s'il est utilisé pour une opération non autorisée. Si non critique, c'est une recommandation mais pas une obligation stricte.

#### B. Extended Key Usage (Usage étendu)

Définit les applications spécifiques pour lesquelles le certificat peut être utilisé.

```bash
# Afficher l'Extended Key Usage
openssl x509 -in server.crt -noout -text | grep -A 3 "Extended Key Usage"

# Résultat possible :
# X509v3 Extended Key Usage:
#     TLS Web Server Authentication, TLS Web Client Authentication
```

|Valeur|OID|Usage|
|---|---|---|
|**TLS Web Server Authentication**|1.3.6.1.5.5.7.3.1|Serveur HTTPS|
|**TLS Web Client Authentication**|1.3.6.1.5.5.7.3.2|Authentification client TLS|
|**Code Signing**|1.3.6.1.5.5.7.3.3|Signature de code/logiciels|
|**Email Protection**|1.3.6.1.5.5.7.3.4|S/MIME (email chiffré)|
|**Time Stamping**|1.3.6.1.5.5.7.3.8|Horodatage|
|**OCSP Signing**|1.3.6.1.5.5.7.3.9|Signature réponses OCSP|

```bash
# Exemple complet d'affichage des usages
openssl x509 -in certificate.crt -noout -text | grep -E "(Key Usage|Extended Key Usage)" -A 2

# Vérifier si un certificat a un usage spécifique
openssl x509 -in cert.crt -noout -text | grep "TLS Web Server Authentication"
```

#### C. Basic Constraints (Contraintes de base)

Indique si le certificat est une CA et peut signer d'autres certificats.

```bash
# Afficher les Basic Constraints
openssl x509 -in cert.crt -noout -text | grep -A 2 "Basic Constraints"

# Pour une CA :
# X509v3 Basic Constraints: critical
#     CA:TRUE, pathlen:0

# Pour un certificat d'entité :
# X509v3 Basic Constraints: critical
#     CA:FALSE
```

|Paramètre|Signification|
|---|---|
|**CA:TRUE**|Ce certificat peut signer d'autres certificats (est une CA)|
|**CA:FALSE**|Certificat d'entité finale, ne peut pas signer de certificats|
|**pathlen:n**|Nombre maximum de CA intermédiaires dans la chaîne sous cette CA|

> [!warning] Basic Constraints critique Cette extension DOIT TOUJOURS être marquée "critical" pour les CA. Si un certificat avec CA:FALSE tente de signer un autre certificat, il doit être rejeté immédiatement.

**Exemple de pathlen :**

- CA Racine : `CA:TRUE` (pas de limite)
- CA Intermédiaire niveau 1 : `CA:TRUE, pathlen:1` (peut créer 1 niveau de CA sous elle)
- CA Intermédiaire niveau 2 : `CA:TRUE, pathlen:0` (peut signer des entités mais pas créer de CA)
- Certificat serveur : `CA:FALSE` (ne peut rien signer)

### 🔍 Vérification des usages

```bash
# Créer un script de vérification complète des usages
#!/bin/bash

CERT="$1"

echo "=== Analyse des usages du certificat ==="
echo ""

# Basic Constraints
echo "📋 Basic Constraints:"
openssl x509 -in "$CERT" -noout -text | grep -A 2 "Basic Constraints"
echo ""

# Key Usage
echo "🔑 Key Usage:"
openssl x509 -in "$CERT" -noout -text | grep -A 1 "Key Usage"
echo ""

# Extended Key Usage
echo "🔐 Extended Key Usage:"
openssl x509 -in "$CERT" -noout -text | grep -A 3 "Extended Key Usage"
echo ""

# Subject Alternative Name (pour les certificats serveur)
echo "🌐 Subject Alternative Name:"
openssl x509 -in "$CERT" -noout -text | grep -A 5 "Subject Alternative Name"
```

### 📊 Configurations typiques par type de certificat

#### Certificat serveur web (HTTPS)

```bash
# Configuration typique
X509v3 Basic Constraints: critical
    CA:FALSE

X509v3 Key Usage: critical
    Digital Signature, Key Encipherment

X509v3 Extended Key Usage:
    TLS Web Server Authentication

X509v3 Subject Alternative Name:
    DNS:example.com, DNS:www.example.com
```

#### Certificat client (authentification mutuelle TLS)

```bash
X509v3 Basic Constraints: critical
    CA:FALSE

X509v3 Key Usage: critical
    Digital Signature, Key Agreement

X509v3 Extended Key Usage:
    TLS Web Client Authentication
```

#### Certificat de signature de code

```bash
X509v3 Basic Constraints: critical
    CA:FALSE

X509v3 Key Usage: critical
    Digital Signature

X509v3 Extended Key Usage:
    Code Signing
```

#### Certificat CA intermédiaire

```bash
X509v3 Basic Constraints: critical
    CA:TRUE, pathlen:0

X509v3 Key Usage: critical
    Certificate Signing, CRL Signing
```

#### Certificat email (S/MIME)

```bash
X509v3 Basic Constraints: critical
    CA:FALSE

X509v3 Key Usage: critical
    Digital Signature, Key Encipherment

X509v3 Extended Key Usage:
    Email Protection
```

### 🎯 Validation applicative

Lors de la validation, l'application doit vérifier que le certificat correspond à l'usage prévu :

```bash
# Pour un serveur HTTPS
# Vérifier que le certificat a "TLS Web Server Authentication"
openssl x509 -in server.crt -noout -text | \
  grep "TLS Web Server Authentication" > /dev/null

if [ $? -eq 0 ]; then
    echo "✅ Certificat approprié pour serveur web"
else
    echo "❌ Certificat non valide pour serveur web"
fi

# Vérifier le nom de domaine (Subject Alternative Name)
openssl x509 -in server.crt -noout -text | \
  grep -A 5 "Subject Alternative Name" | grep "DNS:example.com"
```

### ⚠️ Erreurs courantes

**Erreur : Certificat utilisé hors de son usage**

```bash
# Exemple : Utiliser un certificat client comme certificat serveur
# Erreur dans les logs du serveur web :
# SSL: error:14094410:SSL routines:ssl3_read_bytes:
# sslv3 alert handshake failure

# Vérification
openssl x509 -in cert.crt -noout -text | grep "Extended Key Usage"
# Si on voit seulement "TLS Web Client Authentication" 
# mais pas "TLS Web Server Authentication", le certificat 
# ne peut pas être utilisé comme certificat serveur
```

**Erreur : Nom de domaine non correspondant**

```bash
# Connexion à example.com avec un certificat pour autre-domaine.com
# Erreur navigateur : NET::ERR_CERT_COMMON_NAME_INVALID

# Vérifier les domaines autorisés
openssl x509 -in cert.crt -noout -text | grep -A 10 "Subject Alternative Name"

# Le domaine demandé doit être dans la liste :
# DNS:example.com, DNS:*.example.com, DNS:www.example.com
```

**Erreur : Certificat tentant de signer d'autres certificats**

```bash
# Un certificat avec CA:FALSE ne peut pas signer
# Erreur OpenSSL lors de la vérification :
# error 24: invalid CA certificate

# Vérification
openssl x509 -in cert.crt -noout -text | grep "CA:TRUE"
# Si absent ou CA:FALSE, ce certificat ne peut pas signer
```

### 🌐 Subject Alternative Name (SAN)

Le SAN est crucial pour les certificats serveur modernes. Il définit tous les noms de domaine pour lesquels le certificat est valide.

```bash
# Afficher les SAN d'un certificat
openssl x509 -in server.crt -noout -text | grep -A 5 "Subject Alternative Name"

# Résultat possible :
# X509v3 Subject Alternative Name:
#     DNS:example.com, 
#     DNS:www.example.com, 
#     DNS:mail.example.com,
#     IP Address:192.168.1.10

# Extraire uniquement les DNS
openssl x509 -in server.crt -noout -ext subjectAltName

# Vérifier si un domaine spécifique est présent
openssl x509 -in server.crt -noout -text | \
  grep -A 10 "Subject Alternative Name" | grep "DNS:www.example.com"
```

> [!info] Wildcard dans SAN Un certificat avec `DNS:*.example.com` couvre :
> 
> - ✅ `www.example.com`
> - ✅ `mail.example.com`
> - ✅ `api.example.com`
> 
> Mais ne couvre PAS :
> 
> - ❌ `example.com` (domaine racine)
> - ❌ `sub.api.example.com` (sous-domaine de niveau 2)

### 🛡️ Bonnes pratiques

> [!tip] Recommandations pour les usages
> 
> - **Toujours marquer Key Usage et Basic Constraints comme "critical"** pour les certificats de production
> - **Utiliser Extended Key Usage** pour spécifier précisément l'application
> - **Vérifier le SAN** lors de la validation, pas seulement le Common Name (CN) qui est déprécié
> - **Ne jamais réutiliser** un certificat d'un type pour un autre usage
> - **Limiter les usages** au strict nécessaire (principe du moindre privilège)
> - **Pour les certificats serveur**, toujours inclure tous les noms de domaine dans le SAN
> - **Documenter les usages** de chaque certificat dans votre inventaire PKI

### 🔧 Validation programmatique en Python

```python
from cryptography import x509
from cryptography.hazmat.backends import default_backend
from cryptography.x509.oid import ExtensionOID, ExtendedKeyUsageOID

def verify_certificate_usage(cert_path, expected_usage):
    """Vérifie qu'un certificat a l'usage attendu"""
    
    with open(cert_path, 'rb') as f:
        cert = x509.load_pem_x509_certificate(f.read(), default_backend())
    
    # Vérifier Extended Key Usage
    try:
        ext_key_usage = cert.extensions.get_extension_for_oid(
            ExtensionOID.EXTENDED_KEY_USAGE
        ).value
        
        if expected_usage == 'server':
            if ExtendedKeyUsageOID.SERVER_AUTH in ext_key_usage:
                print("✅ Certificat valide pour serveur web")
                return True
        
        elif expected_usage == 'client':
            if ExtendedKeyUsageOID.CLIENT_AUTH in ext_key_usage:
                print("✅ Certificat valide pour client")
                return True
        
        elif expected_usage == 'code_signing':
            if ExtendedKeyUsageOID.CODE_SIGNING in ext_key_usage:
                print("✅ Certificat valide pour signature de code")
                return True
        
        print("❌ Usage non autorisé")
        return False
        
    except x509.ExtensionNotFound:
        print("⚠️ Extension Extended Key Usage absente")
        return False

# Utilisation
verify_certificate_usage('server.crt', 'server')
```

---

## 5. Processus complet de validation

### 📖 Vue d'ensemble

La validation complète d'un certificat combine les quatre vérifications précédentes dans un ordre logique et optimisé. Chaque étape peut échouer et arrêter le processus.

> [!info] Ordre des vérifications L'ordre est important pour optimiser les performances : on vérifie d'abord les opérations rapides et locales (validité temporelle, usage) avant les opérations coûteuses (révocation, chaîne de confiance).

### 🔄 Algorithme de validation

```
1. Vérification de la période de validité (RAPIDE - LOCAL)
   └─ Si expiré ou pas encore valide → REJET
   
2. Vérification de l'usage (RAPIDE - LOCAL)
   └─ Si usage inapproprié → REJET
   
3. Vérification de la chaîne de confiance (MOYEN - LOCAL puis RÉSEAU)
   └─ Si chaîne invalide → REJET
   
4. Vérification du statut de révocation (LENT - RÉSEAU)
   └─ Si révoqué → REJET
   
5. Validation réussie → ACCEPTATION
```

### 🔧 Script de validation complète

```bash
#!/bin/bash
# Script complet de validation de certificat

CERT="$1"
CA_BUNDLE="$2"
HOSTNAME="$3"

echo "🔍 Validation complète du certificat : $CERT"
echo "================================================"
echo ""

# Fonction pour afficher les résultats
pass() { echo "✅ $1"; }
fail() { echo "❌ $1"; exit 1; }
warn() { echo "⚠️  $1"; }

# ============================================
# 1. VÉRIFICATION DE LA PÉRIODE DE VALIDITÉ
# ============================================
echo "📅 Étape 1/4 : Période de validité"

NOT_BEFORE=$(openssl x509 -in "$CERT" -noout -startdate | cut -d= -f2)
NOT_AFTER=$(openssl x509 -in "$CERT" -noout -enddate | cut -d= -f2)

BEFORE_TS=$(date -d "$NOT_BEFORE" +%s 2>/dev/null)
AFTER_TS=$(date -d "$NOT_AFTER" +%s 2>/dev/null)
NOW_TS=$(date +%s)

if [ $NOW_TS -lt $BEFORE_TS ]; then
    fail "Certificat pas encore valide (débute le $NOT_BEFORE)"
elif [ $NOW_TS -gt $AFTER_TS ]; then
    fail "Certificat expiré (depuis le $NOT_AFTER)"
else
    DAYS_LEFT=$(( ($AFTER_TS - $NOW_TS) / 86400 ))
    pass "Période de validité OK (expire dans $DAYS_LEFT jours)"
    
    if [ $DAYS_LEFT -lt 30 ]; then
        warn "Attention : Expiration proche (moins de 30 jours)"
    fi
fi
echo ""

# ============================================
# 2. VÉRIFICATION DE L'USAGE
# ============================================
echo "🔑 Étape 2/4 : Usage du certificat"

# Vérifier que ce n'est pas une CA si utilisé comme certificat serveur
IS_CA=$(openssl x509 -in "$CERT" -noout -text | grep "CA:TRUE")
if [ -n "$IS_CA" ]; then
    fail "Ce certificat est une CA, ne peut pas être utilisé comme certificat d'entité"
fi

# Vérifier l'Extended Key Usage pour serveur web (si hostname fourni)
if [ -n "$HOSTNAME" ]; then
    HAS_SERVER_AUTH=$(openssl x509 -in "$CERT" -noout -text | \
        grep "TLS Web Server Authentication")
    
    if [ -z "$HAS_SERVER_AUTH" ]; then
        fail "Certificat sans 'TLS Web Server Authentication'"
    fi
    
    # Vérifier le SAN
    HAS_HOSTNAME=$(openssl x509 -in "$CERT" -noout -text | \
        grep -A 10 "Subject Alternative Name" | grep "DNS:$HOSTNAME")
    
    if [ -z "$HAS_HOSTNAME" ]; then
        fail "Le nom d'hôte '$HOSTNAME' n'est pas dans le SAN"
    fi
    
    pass "Usage approprié pour serveur web ($HOSTNAME)"
else
    pass "Extensions d'usage présentes"
fi
echo ""

# ============================================
# 3. VÉRIFICATION DE LA CHAÎNE DE CONFIANCE
# ============================================
echo "🔗 Étape 3/4 : Chaîne de confiance"

if [ -z "$CA_BUNDLE" ]; then
    warn "Pas de bundle CA fourni, vérification partielle"
else
    VERIFY_OUTPUT=$(openssl verify -CAfile "$CA_BUNDLE" "$CERT" 2>&1)
    VERIFY_RESULT=$?
    
    if [ $VERIFY_RESULT -eq 0 ]; then
        pass "Chaîne de confiance valide"
    else
        fail "Chaîne de confiance invalide : $VERIFY_OUTPUT"
    fi
fi
echo ""

# ============================================
# 4. VÉRIFICATION DU STATUT DE RÉVOCATION
# ============================================
echo "🚫 Étape 4/4 : Statut de révocation"

# Extraire l'URL OCSP
OCSP_URL=$(openssl x509 -in "$CERT" -noout -ocsp_uri 2>/dev/null)

if [ -z "$OCSP_URL" ]; then
    warn "Pas d'URL OCSP dans le certificat"
    
    # Chercher une CRL
    CRL_URL=$(openssl x509 -in "$CERT" -noout -text | \
        grep -A 4 'CRL Distribution' | grep URI | cut -d: -f2,3)
    
    if [ -n "$CRL_URL" ]; then
        warn "CRL trouvée : $CRL_URL (vérification manuelle recommandée)"
    else
        warn "Aucun mécanisme de révocation disponible"
    fi
else
    echo "📡 URL OCSP : $OCSP_URL"
    
    # Extraire le certificat émetteur
    ISSUER_HASH=$(openssl x509 -in "$CERT" -noout -issuer_hash)
    
    # Tenter la vérification OCSP (nécessite le certificat de l'émetteur)
    if [ -n "$CA_BUNDLE" ]; then
        OCSP_CHECK=$(timeout 5 openssl ocsp \
            -issuer "$CA_BUNDLE" \
            -cert "$CERT" \
            -url "$OCSP_URL" \
            -CAfile "$CA_BUNDLE" 2>&1)
        
        if echo "$OCSP_CHECK" | grep -q "good"; then
            pass "Statut OCSP : Certificat non révoqué"
        elif echo "$OCSP_CHECK" | grep -q "revoked"; then
            fail "Statut OCSP : Certificat RÉVOQUÉ !"
        else
            warn "Impossible de vérifier OCSP (timeout ou erreur)"
        fi
    else
        warn "Bundle CA nécessaire pour vérification OCSP"
    fi
fi
echo ""

# ============================================
# RÉSULTAT FINAL
# ============================================
echo "================================================"
echo "🎉 VALIDATION RÉUSSIE"
echo "================================================"
echo ""
echo "Résumé du certificat :"
openssl x509 -in "$CERT" -noout -subject -issuer -dates
echo ""

exit 0
```

### 📝 Utilisation du script

```bash
# Validation complète
./validate_cert.sh server.crt ca-bundle.crt example.com

# Sans vérification de nom d'hôte
./validate_cert.sh server.crt ca-bundle.crt

# Validation minimale (sans CA bundle)
./validate_cert.sh server.crt
```

### 🌐 Validation dans les applications

#### Configuration Apache

```bash
# /etc/apache2/sites-available/ssl.conf

<VirtualHost *:443>
    ServerName example.com
    
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/server.crt
    SSLCertificateKeyFile /etc/ssl/private/server.key
    SSLCertificateChainFile /etc/ssl/certs/intermediate.crt
    
    # Vérification de la chaîne de confiance
    SSLCACertificateFile /etc/ssl/certs/ca-bundle.crt
    
    # Vérification de révocation via CRL
    SSLCARevocationCheck chain
    SSLCARevocationFile /etc/ssl/crl/ca-crl.pem
    
    # OCSP Stapling (vérification de révocation optimisée)
    SSLUseStapling on
    SSLStaplingCache "shmcb:logs/ssl_stapling(32768)"
    
    # Authentification client (optionnel)
    SSLVerifyClient optional
    SSLVerifyDepth 3
</VirtualHost>

# Configuration globale OCSP
SSLStaplingStandardCacheTimeout 3600
SSLStaplingReturnResponderErrors off
```

#### Configuration Nginx

```nginx
# /etc/nginx/sites-available/ssl.conf

server {
    listen 443 ssl;
    server_name example.com;
    
    # Certificats
    ssl_certificate /etc/ssl/certs/server-chain.crt;
    ssl_certificate_key /etc/ssl/private/server.key;
    
    # Vérification de la chaîne pour les clients
    ssl_client_certificate /etc/ssl/certs/ca-bundle.crt;
    ssl_verify_client optional;
    ssl_verify_depth 3;
    
    # OCSP Stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_trusted_certificate /etc/ssl/certs/ca-bundle.crt;
    resolver 8.8.8.8 8.8.4.4 valid=300s;
    resolver_timeout 5s;
    
    # Sécurité supplémentaire
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
}
```

#### Validation en Python

```python
import ssl
import socket
from datetime import datetime
from cryptography import x509
from cryptography.hazmat.backends import default_backend

def validate_certificate_complete(hostname, port=443):
    """Validation complète d'un certificat serveur"""
    
    print(f"🔍 Validation du certificat pour {hostname}:{port}")
    print("=" * 60)
    
    try:
        # Connexion SSL
        context = ssl.create_default_context()
        
        with socket.create_connection((hostname, port), timeout=10) as sock:
            with context.wrap_socket(sock, server_hostname=hostname) as ssock:
                
                # Récupérer le certificat
                cert_der = ssock.getpeercert(binary_form=True)
                cert = x509.load_der_x509_certificate(cert_der, default_backend())
                
                # 1. Vérification de la validité temporelle
                print("\n📅 1. Période de validité")
                now = datetime.utcnow()
                
                if now < cert.not_valid_before:
                    print(f"❌ Certificat pas encore valide")
                    return False
                elif now > cert.not_valid_after:
                    print(f"❌ Certificat expiré")
                    return False
                else:
                    days_left = (cert.not_valid_after - now).days
                    print(f"✅ Valide (expire dans {days_left} jours)")
                
                # 2. Vérification du nom d'hôte
                print("\n🌐 2. Vérification du nom d'hôte")
                san_ext = cert.extensions.get_extension_for_oid(
                    x509.oid.ExtensionOID.SUBJECT_ALTERNATIVE_NAME
                )
                san_names = san_ext.value.get_values_for_type(x509.DNSName)
                
                if hostname in san_names:
                    print(f"✅ Nom d'hôte '{hostname}' trouvé dans le SAN")
                else:
                    print(f"❌ Nom d'hôte '{hostname}' non trouvé")
                    print(f"   SAN disponibles : {', '.join(san_names)}")
                    return False
                
                # 3. Vérification de la chaîne (gérée par ssl.create_default_context)
                print("\n🔗 3. Chaîne de confiance")
                print("✅ Chaîne validée par le contexte SSL Python")
                
                # 4. Vérification OCSP (simplifié - nécessiterait une bibliothèque spécialisée)
                print("\n🚫 4. Statut de révocation")
                print("ℹ️  Vérification OCSP : géré automatiquement si OCSP Stapling actif")
                
                print("\n" + "=" * 60)
                print("🎉 VALIDATION RÉUSSIE")
                return True
                
    except ssl.SSLError as e:
        print(f"\n❌ Erreur SSL : {e}")
        return False
    except Exception as e:
        print(f"\n❌ Erreur : {e}")
        return False

# Utilisation
validate_certificate_complete("example.com")
```

### 📊 Tableau récapitulatif des validations

|Vérification|Coût|Échec fréquent ?|Impact|
|---|---|---|---|
|**Période de validité**|🟢 Très faible|⚠️ Moyen|🔴 Critique|
|**Usage approprié**|🟢 Très faible|🟡 Faible|🔴 Critique|
|**Chaîne de confiance**|🟡 Moyen|🟡 Faible|🔴 Critique|
|**Statut de révocation**|🔴 Élevé|⚠️ Moyen (réseau)|🔴 Critique|

### ⚠️ Gestion des erreurs

```bash
# Certificat expiré
error:14090086:SSL routines:ssl3_get_server_certificate:certificate verify failed

# Chaîne de confiance invalide
error:20:unable to get local issuer certificate

# Nom d'hôte incorrect
error:14090086:hostname mismatch

# Certificat révoqué
error:23:certificate revoked

# Usage inapproprié
error:26:unsupported certificate purpose
```

### 🛡️ Bonnes pratiques globales

> [!tip] Recommandations essentielles
> 
> - **Automatiser les validations** dans vos pipelines CI/CD
> - **Monitorer en continu** les certificats en production
> - **Logger toutes les erreurs** de validation pour l'audit
> - **Implémenter des alertes** sur les échecs de validation
> - **Tester régulièrement** les scénarios de révocation
> - **Documenter les exceptions** si vous devez désactiver certaines vérifications
> - **Avoir un plan de réponse** aux incidents de certificats compromis
> - **Former les équipes** aux bonnes pratiques de validation

### 🔄 Processus de validation en production

```bash
# Monitoring quotidien des certificats
#!/bin/bash

CERT_DIR="/etc/ssl/certs"
ALERT_EMAIL="admin@example.com"
ALERT_DAYS=30

for CERT in $CERT_DIR/*.crt; do
    echo "Vérification de $CERT"
    
    # Validation complète
    ./validate_cert.sh "$CERT" "$CERT_DIR/ca-bundle.crt" >> /var/log/cert-validation.log 2>&1
    
    if [ $? -ne 0 ]; then
        echo "ALERTE : Échec de validation pour $CERT" | \
            mail -s "Alerte Certificat" "$ALERT_EMAIL"
    fi
done
```

### 📈 Métriques de validation

Métriques à surveiller dans vos systèmes :

- **Taux de réussite de validation** : doit être > 99.9%
- **Temps moyen de validation** : < 500ms (avec OCSP)
- **Taux d'échec OCSP** : indicateur de disponibilité du répondeur
- **Certificats proches de l'expiration** : < 30 jours
- **Certificats avec chaîne invalide** : doit être 0

> [!example] Dashboard de monitoring Créez un tableau de bord avec :
> 
> - Nombre de certificats actifs
> - Distribution des dates d'expiration
> - Historique des échecs de validation
> - Disponibilité des services OCSP/CRL
> - Temps de réponse des validations

---

## 🎓 Conclusion

La validation de certificats est un processus en quatre étapes qui garantit la sécurité des communications :

1. ✅ **Période de validité** : Le certificat est-il temporellement valide ?
2. ✅ **Usage** : Le certificat est-il utilisé pour sa fonction prévue ?
3. ✅ **Chaîne de confiance** : Le certificat est-il signé par une CA de confiance ?
4. ✅ **Statut de révocation** : Le certificat n'a-t-il pas été révoqué ?

**Toutes ces vérifications doivent réussir pour qu'un certificat soit considéré comme valide et digne de confiance.**

> [!warning] Rappel de sécurité Ne jamais contourner les vérifications de validation en production. Chaque étape protège contre des vecteurs d'attaque spécifiques. Une validation incomplète expose votre infrastructure à des risques critiques.