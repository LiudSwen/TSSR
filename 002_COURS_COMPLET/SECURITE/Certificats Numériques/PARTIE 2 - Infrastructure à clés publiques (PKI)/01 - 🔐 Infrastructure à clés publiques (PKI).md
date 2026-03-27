

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

## 🌐 Introduction à la PKI

Une **Public Key Infrastructure (PKI)** est un ensemble de rôles, politiques, matériels, logiciels et procédures nécessaires pour créer, gérer, distribuer, utiliser, stocker et révoquer des certificats numériques et gérer le chiffrement à clé publique.

> [!info] Pourquoi une PKI ? La PKI résout le problème fondamental de la confiance dans les communications numériques : comment être sûr qu'une clé publique appartient réellement à la personne ou l'entité revendiquée ? La PKI apporte cette confiance via un tiers de confiance : l'autorité de certification.

### Objectifs principaux d'une PKI

- **Authentification** : Vérifier l'identité des entités communicantes
- **Intégrité** : Garantir que les données n'ont pas été modifiées
- **Confidentialité** : Chiffrer les communications
- **Non-répudiation** : Empêcher qu'une partie nie avoir effectué une action
- **Gestion du cycle de vie** : Création, distribution, révocation et renouvellement des certificats

---

## 🏛️ Autorité de certification (CA)

L'**Autorité de Certification** (Certificate Authority - CA) est le composant central et le plus critique d'une PKI. C'est l'entité de confiance qui émet et signe numériquement les certificats.

### Rôle et responsabilités

La CA a plusieurs missions essentielles :

1. **Émission de certificats** : Créer et signer numériquement les certificats après vérification de l'identité du demandeur
2. **Publication de certificats** : Rendre les certificats accessibles aux utilisateurs qui en ont besoin
3. **Révocation de certificats** : Invalider des certificats compromis ou obsolètes
4. **Publication des CRL** : Maintenir et publier les listes de certificats révoqués
5. **Gestion de sa propre clé privée** : Protéger jalousement sa clé privée qui signe tous les certificats

> [!warning] Sécurité critique La compromission de la clé privée d'une CA est catastrophique car elle permet de générer des certificats frauduleux reconnus comme légitimes. La clé privée d'une CA racine est souvent stockée hors ligne dans des HSM (Hardware Security Modules) dans des environnements hautement sécurisés.

### Hiérarchie des CA

Les PKI peuvent avoir différentes architectures :

#### CA racine (Root CA)

- **Sommet de la hiérarchie de confiance**
- Auto-signée (son certificat est signé par sa propre clé privée)
- Généralement maintenue hors ligne pour maximiser la sécurité
- Sa clé privée a une durée de vie très longue (10-20 ans)
- Utilisée uniquement pour signer les certificats des CA intermédiaires

#### CA intermédiaire (Intermediate CA)

- Signée par la CA racine ou une autre CA intermédiaire
- Opérationnelle en ligne
- Émet les certificats pour les utilisateurs finaux
- Permet de compartimenter les risques
- Peut être révoquée sans compromettre toute la PKI

#### CA subordonnée

- Terme générique pour toute CA non-racine
- Peut avoir plusieurs niveaux de subordination

```
Root CA (hors ligne)
    │
    ├─── Intermediate CA 1 (en ligne)
    │       ├─── Certificat utilisateur A
    │       ├─── Certificat serveur B
    │       └─── Certificat utilisateur C
    │
    └─── Intermediate CA 2 (en ligne)
            ├─── Certificat application D
            └─── Certificat serveur E
```

> [!tip] Bonnes pratiques hiérarchiques Une architecture à plusieurs niveaux permet de limiter l'impact d'une compromission. Si une CA intermédiaire est compromise, seule cette branche doit être révoquée, pas toute la PKI.

### Types de CA selon le déploiement

|Type|Description|Cas d'usage|
|---|---|---|
|**CA publique**|Exploitée par des organisations tierces (DigiCert, Let's Encrypt, GlobalSign)|Sites web publics, applications grand public|
|**CA privée**|Déployée et gérée en interne par une organisation|Réseaux d'entreprise, applications internes|
|**CA communautaire**|Partagée entre plusieurs organisations d'un même secteur|Secteur bancaire, santé, gouvernement|

### Processus d'émission d'un certificat par la CA

1. **Réception de la CSR** : La CA reçoit une demande de signature de certificat (Certificate Signing Request)
2. **Vérification d'identité** : Validation de l'identité du demandeur selon les politiques
3. **Vérification des attributs** : Contrôle des informations demandées (nom, organisation, domaine, etc.)
4. **Génération du certificat** : Création du certificat avec les attributs validés
5. **Signature numérique** : Signature du certificat avec la clé privée de la CA
6. **Publication** : Mise à disposition du certificat dans le repository
7. **Notification** : Information du demandeur que son certificat est prêt

> [!example] Exemple de politique de validation Pour un certificat SSL/TLS Extended Validation (EV), la CA doit :
> 
> - Vérifier l'existence légale de l'organisation
> - Confirmer l'identité physique et opérationnelle
> - Vérifier l'autorité du demandeur
> - Valider le contrôle du nom de domaine
> - Effectuer un appel téléphonique de confirmation

### Protection de la clé privée de la CA

La sécurité d'une CA repose sur plusieurs mécanismes :

- **HSM (Hardware Security Module)** : Dispositif matériel certifié pour protéger les clés
- **Contrôle d'accès strict** : Authentification multi-facteurs pour accéder aux systèmes
- **Cérémonie de clé** : Procédures formelles pour générer/utiliser la clé privée
- **Dual control** : Nécessité de plusieurs personnes pour les opérations critiques
- **Audit logging** : Journalisation exhaustive de toutes les opérations
- **Environnement physique sécurisé** : Salles blindées, vidéosurveillance, contrôle d'accès biométrique

---

## 📝 Autorité d'enregistrement (RA)

L'**Autorité d'Enregistrement** (Registration Authority - RA) fait le lien entre les utilisateurs et la CA. Elle décharge la CA des tâches administratives liées à la vérification d'identité.

### Rôle et responsabilités

La RA ne signe pas les certificats mais gère les aspects suivants :

1. **Vérification d'identité** : Authentifier les demandeurs selon les politiques définies
2. **Validation des demandes** : S'assurer que les informations de la CSR sont correctes et complètes
3. **Approbation ou rejet** : Décider si une demande doit être transmise à la CA
4. **Gestion des demandes de révocation** : Recevoir et valider les demandes de révocation
5. **Génération de clés (optionnel)** : Peut générer des paires de clés pour les utilisateurs
6. **Distribution de certificats** : Remettre les certificats aux utilisateurs autorisés

> [!info] Séparation des préoccupations La séparation CA/RA permet une meilleure distribution géographique et organisationnelle. Une grande entreprise peut avoir une seule CA centrale mais plusieurs RA dans différentes filiales ou pays.

### Processus typique avec une RA

```
Utilisateur final
    │
    │ 1. Demande de certificat (CSR)
    ▼
Autorité d'Enregistrement (RA)
    │
    │ 2. Vérification identité
    │ 3. Validation des informations
    │ 4. Approbation
    ▼
Autorité de Certification (CA)
    │
    │ 5. Génération et signature du certificat
    ▼
Repository de certificats
    │
    │ 6. Publication
    ▼
Utilisateur final (récupération)
```

### Modèles de déploiement

#### RA locale

- Située dans les bureaux locaux d'une organisation
- Personnel dédié pour la vérification en personne
- Utilisée pour l'enrôlement initial fort

#### RA en ligne

- Système automatisé pour la validation
- Utilise des méthodes de vérification électroniques
- Challenge/réponse, validation par email, etc.

#### RA déléguée

- Organisations partenaires agissant comme RA
- Utile dans les fédérations ou consortiums
- Exemple : plusieurs universités partageant une PKI

> [!warning] Point critique de sécurité La RA doit être aussi bien protégée que la CA elle-même. Une RA compromise peut approuver des certificats frauduleux, même si la CA fonctionne correctement. Les contrôles d'accès et l'audit sont essentiels.

### Méthodes de vérification d'identité

La RA peut utiliser différentes méthodes selon le niveau d'assurance requis :

|Niveau|Méthode|Exemple|
|---|---|---|
|**Faible**|Validation par email|Envoi d'un lien de confirmation|
|**Moyen**|Documents numériques|Scan de pièce d'identité + selfie|
|**Élevé**|Présence physique|Vérification en personne avec documents originaux|
|**Très élevé**|Processus formel|Notaire, témoin, procédure juridique|

---

## ✅ Autorité de validation (VA)

L'**Autorité de Validation** (Validation Authority - VA) fournit des services de vérification en temps réel du statut des certificats.

### Rôle et responsabilités

La VA permet de vérifier si un certificat est toujours valide sans télécharger l'intégralité des CRL :

1. **Répondre aux requêtes OCSP** : Protocole de vérification en ligne du statut des certificats
2. **Vérification en temps réel** : Consultation immédiate de l'état de révocation
3. **Signature des réponses** : Les réponses OCSP sont signées pour garantir leur authenticité
4. **Optimisation des performances** : Cache et distribution des informations de révocation

> [!info] OCSP vs CRL Contrairement aux CRL (Certificate Revocation Lists) qui peuvent être volumineuses et mises à jour périodiquement, OCSP (Online Certificate Status Protocol) permet une vérification légère et en temps réel d'un certificat spécifique.

### Fonctionnement d'OCSP

Le protocole OCSP fonctionne selon ce flux :

```
Client (navigateur, application)
    │
    │ 1. Requête OCSP pour certificat X
    ▼
Autorité de Validation (VA)
    │
    │ 2. Consultation de la base de révocation
    │ 3. Génération de la réponse signée
    │
    ▼
Client
    │
    │ 4. Vérification de la signature de la réponse
    │ 5. Décision : accepter ou rejeter le certificat
```

### Types de réponses OCSP

La VA peut renvoyer trois types de réponses :

1. **Good** : Le certificat est valide et n'a pas été révoqué
2. **Revoked** : Le certificat a été révoqué (avec date et raison)
3. **Unknown** : La VA ne connaît pas ce certificat

> [!tip] OCSP Stapling Pour améliorer les performances et la confidentialité, le serveur peut "agrafer" (staple) une réponse OCSP signée à son certificat lors de la connexion TLS. Cela évite au client de contacter directement la VA et améliore la vitesse de connexion.

### Architecture de déploiement

#### VA intégrée

- Hébergée avec la CA
- Simplifie l'architecture
- Peut créer un point de charge unique

#### VA dédiée

- Serveurs séparés pour la validation
- Meilleure scalabilité
- Distribution géographique possible
- Résilience accrue

#### Réseau de VA

- Multiples VA réparties géographiquement
- Load balancing
- Haute disponibilité
- Utilisé par les grandes PKI publiques

> [!warning] Disponibilité critique Si la VA est indisponible et qu'un client ne peut pas vérifier le statut d'un certificat, il doit décider entre :
> 
> - **Fail-open** : Accepter le certificat (risque de sécurité)
> - **Fail-closed** : Rejeter le certificat (risque de disponibilité)
> 
> Cette décision doit être définie dans la politique de sécurité.

### Performance et mise en cache

Pour gérer une charge importante, les VA utilisent :

- **Caching des réponses** : Les réponses OCSP ont une durée de validité et peuvent être mises en cache
- **Pre-computation** : Pré-calcul des réponses pour les certificats actifs
- **CDN (Content Delivery Network)** : Distribution des réponses OCSP via un réseau global
- **Compression** : Optimisation de la taille des réponses

---

## 📚 Repository de certificats

Le **Repository de certificats** (ou annuaire de certificats) est le système de stockage et de distribution des certificats et des informations liées à la PKI.

### Rôle et responsabilités

Le repository centralise l'accès aux éléments de la PKI :

1. **Stockage des certificats** : Tous les certificats émis sont publiés
2. **Publication des CRL** : Listes de révocation accessibles publiquement
3. **Stockage des politiques** : Certificate Policy (CP) et Certification Practice Statement (CPS)
4. **Distribution** : Mise à disposition via protocoles standardisés
5. **Recherche** : Permettre la découverte de certificats par différents critères

### Technologies d'implémentation

#### Annuaires LDAP

Le protocole LDAP (Lightweight Directory Access Protocol) est traditionnellement utilisé pour les repositories :

```bash
# Structure typique d'un annuaire LDAP pour PKI
dc=example,dc=com
    │
    ├─── ou=People (certificats utilisateurs)
    │       ├─── cn=Alice Smith
    │       └─── cn=Bob Jones
    │
    ├─── ou=Devices (certificats machines/serveurs)
    │       ├─── cn=webserver.example.com
    │       └─── cn=mailserver.example.com
    │
    └─── ou=CRLs (listes de révocation)
            ├─── cn=RootCA CRL
            └─── cn=IntermediateCA CRL
```

> [!info] Attributs LDAP courants pour les certificats
> 
> - `userCertificate` : Le certificat X.509 encodé
> - `certificateRevocationList` : La CRL encodée
> - `authorityRevocationList` : CRL des CA
> - `cACertificate` : Certificat de la CA

#### Serveurs HTTP/HTTPS

Les PKI modernes utilisent souvent des serveurs web pour la distribution :

```
https://pki.example.com/
    │
    ├─── /certs/
    │       ├─── root-ca.crt
    │       ├─── intermediate-ca.crt
    │       └─── user-certificates/
    │
    ├─── /crl/
    │       ├─── root-ca.crl
    │       └─── intermediate-ca.crl
    │
    └─── /ocsp/
            └─── (point d'accès OCSP)
```

#### Bases de données spécialisées

Certaines PKI utilisent des bases de données optimisées :

- **Bases relationnelles** : PostgreSQL, MySQL pour la gestion
- **Bases NoSQL** : Pour la haute disponibilité et scalabilité
- **Systèmes distribués** : Pour les PKI globales

### Méthodes d'accès

Le repository doit être accessible via plusieurs mécanismes :

|Protocole|Usage|Caractéristiques|
|---|---|---|
|**LDAP**|Recherche et récupération de certificats|Standardisé, bien supporté, requêtes complexes|
|**HTTP/HTTPS**|Téléchargement de certificats et CRL|Simple, universel, compatible pare-feu|
|**OCSP**|Vérification de statut en temps réel|Léger, temps réel, bande passante réduite|
|**FTP**|Distribution de masse (rare)|Ancien, simple, unidirectionnel|

### Informations publiées dans le repository

#### Certificats

- **Certificats actifs** : Tous les certificats valides émis
- **Certificats expirés** : Peuvent être conservés pour archive/audit
- **Chaînes de certificats** : Certificats intermédiaires et racine

#### Listes de révocation (CRL)

Les CRL contiennent :

- Numéro de série des certificats révoqués
- Date de révocation
- Raison de la révocation
- Date de prochaine publication de CRL

> [!tip] Delta CRL Pour optimiser la taille, certaines PKI publient des "Delta CRL" qui ne contiennent que les changements depuis la dernière CRL complète. Les clients téléchargent la CRL de base plus les deltas pour avoir l'état actuel.

#### Documents de politique

- **Certificate Policy (CP)** : Règles générales de la PKI
- **Certification Practice Statement (CPS)** : Procédures détaillées d'implémentation
- **Contrats d'abonnement** : Termes et conditions pour les utilisateurs

### Architecture et disponibilité

Pour garantir la disponibilité du repository :

#### Réplication

- **Réplication maître-esclave** : Copie unidirectionnelle pour la lecture
- **Réplication multi-maître** : Synchronisation bidirectionnelle
- **Réplication géographique** : Serveurs dans différentes régions

#### Haute disponibilité

```
                   Load Balancer
                         │
          ┌──────────────┼──────────────┐
          │              │              │
     Repository 1   Repository 2   Repository 3
     (Paris)        (Londres)      (Francfort)
          │              │              │
          └──────────────┴──────────────┘
                    Base de données
                    (répliquée)
```

#### Performance

- **Mise en cache** : CDN pour distribuer les CRL et certificats
- **Compression** : Réduction de la taille des CRL
- **Indexation** : Bases de données indexées pour recherche rapide

> [!warning] Sécurité du repository Bien que le repository contienne des informations publiques, son intégrité est critique :
> 
> - Protection contre les modifications non autorisées
> - Surveillance des accès et tentatives de compromission
> - Sauvegarde régulière
> - HTTPS pour garantir l'authenticité lors du téléchargement

### Extensions dans les certificats pointant vers le repository

Les certificats contiennent des URLs vers le repository :

```
Certificate:
    ...
    X509v3 extensions:
        X509v3 CRL Distribution Points:
            Full Name:
              URI:http://pki.example.com/crl/intermediate-ca.crl
              
        Authority Information Access:
            OCSP - URI:http://ocsp.example.com
            CA Issuers - URI:http://pki.example.com/certs/intermediate-ca.crt
```

Ces extensions permettent aux applications de localiser automatiquement :

- Les CRL pour vérifier la révocation
- Les répondeurs OCSP
- Les certificats intermédiaires pour construire la chaîne de confiance

---

## 👥 Utilisateurs finaux

Les **utilisateurs finaux** (End Entities) sont toutes les entités qui utilisent les certificats émis par la PKI. Ils peuvent être des personnes, des serveurs, des applications ou des objets IoT.

### Types d'utilisateurs finaux

#### Utilisateurs humains

- **Employés** : Authentification réseau, signature d'emails, accès VPN
- **Clients externes** : Authentification sur portails clients, signature de documents
- **Administrateurs** : Accès privilégié aux systèmes critiques

#### Entités non-humaines

- **Serveurs web** : Certificats SSL/TLS pour HTTPS
- **Serveurs d'applications** : Authentification mutuelle entre services
- **Appareils IoT** : Authentification et chiffrement des communications
- **Applications logicielles** : Signature de code, mises à jour logicielles
- **Machines virtuelles et conteneurs** : Identité dans le cloud

### Responsabilités des utilisateurs finaux

Les utilisateurs finaux ont des obligations dans la PKI :

1. **Protection de la clé privée** : Sécuriser leur clé privée et ne jamais la divulguer
2. **Demande de certificat** : Générer une CSR avec des informations exactes
3. **Utilisation appropriée** : Utiliser le certificat uniquement pour les usages autorisés
4. **Notification de compromission** : Signaler immédiatement toute compromission suspectée
5. **Demande de révocation** : Demander la révocation lors du départ, perte de clé, etc.
6. **Conservation sécurisée** : Stocker le certificat et la clé de manière sécurisée
7. **Respect des politiques** : Suivre les procédures définies dans la CP/CPS

> [!warning] Compromission de clé privée Si un utilisateur suspecte que sa clé privée a été compromise (vol d'ordinateur, malware, divulgation accidentelle), il DOIT immédiatement :
> 
> 1. Notifier l'équipe PKI ou la RA
> 2. Demander la révocation du certificat
> 3. Demander un nouveau certificat avec une nouvelle paire de clés

### Cycle de vie du certificat pour l'utilisateur final

#### 1. Enrôlement initial

L'utilisateur doit s'enregistrer dans la PKI :

```bash
# Génération d'une paire de clés et d'une CSR
openssl req -new -newkey rsa:2048 -nodes \
    -keyout user-key.pem \
    -out user-csr.pem \
    -subj "/CN=Alice Smith/O=Example Corp/C=FR"
```

- Génération de la paire de clés (privée/publique)
- Création de la CSR avec les informations d'identité
- Soumission à la RA avec justificatifs
- Vérification d'identité par la RA
- Réception du certificat signé

#### 2. Utilisation quotidienne

Une fois le certificat obtenu :

- **Authentification** : Connexion aux ressources de l'entreprise
- **Signature numérique** : Signature d'emails, de documents
- **Chiffrement** : Protection des communications sensibles
- **Accès sécurisé** : VPN, Wi-Fi d'entreprise, applications

#### 3. Renouvellement

Avant expiration du certificat :

```bash
# Vérification de la date d'expiration
openssl x509 -in user-cert.pem -noout -enddate

# Génération d'une nouvelle CSR (peut réutiliser la même clé)
openssl req -new -key user-key.pem -out user-renewal-csr.pem
```

- Notification d'expiration imminente (généralement 30-60 jours avant)
- Génération d'une nouvelle CSR (avec nouvelle clé recommandée)
- Processus simplifié si l'identité n'a pas changé
- Obtention du nouveau certificat
- Transition progressive vers le nouveau certificat

#### 4. Révocation

Si nécessaire, demande de révocation :

- **Compromission** : Clé privée exposée ou volée
- **Fin d'emploi** : Départ de l'organisation
- **Changement d'identité** : Nom, rôle, organisation modifiés
- **Remplacement** : Mise à jour technique (algorithme obsolète)

> [!tip] Automatisation de la gestion Les grandes organisations utilisent des outils de gestion automatique des certificats pour :
> 
> - Envoyer des alertes d'expiration automatiques
> - Renouveler automatiquement les certificats
> - Déployer les certificats sur les postes
> - Révoquer automatiquement lors des départs

### Stockage des clés et certificats

Les utilisateurs finaux doivent protéger leurs matériaux cryptographiques :

#### Stockage logiciel

|Méthode|Sécurité|Usage|
|---|---|---|
|**Magasin système**|Moyenne|Windows Certificate Store, macOS Keychain|
|**Fichiers protégés**|Faible-Moyenne|Fichiers .pem/.pfx avec mot de passe|
|**Base de données chiffrée**|Moyenne|Applications d'entreprise|

#### Stockage matériel

|Dispositif|Sécurité|Usage|
|---|---|---|
|**Carte à puce**|Élevée|Authentification forte, signature|
|**Token USB**|Élevée|PKI mobile, accès multi-postes|
|**TPM (Trusted Platform Module)**|Élevée|Intégré au matériel, certificats machine|
|**HSM personnel**|Très élevée|Utilisateurs à hauts privilèges|

> [!info] Principe du stockage sécurisé La clé privée ne devrait JAMAIS quitter le dispositif de stockage sécurisé. Les opérations cryptographiques (signature, déchiffrement) sont effectuées à l'intérieur du dispositif, et seul le résultat en sort.

### Interfaces utilisateur

Les utilisateurs finaux interagissent avec la PKI via :

#### Portails web d'enrôlement

- Interface conviviale pour demander des certificats
- Workflow guidé : renseigner informations, joindre justificatifs
- Suivi de l'état de la demande
- Téléchargement du certificat émis

#### Applications de gestion

- Outils de gestion locale des certificats
- Visualisation des certificats installés
- Alertes d'expiration
- Fonctions de renouvellement

#### Intégrations natives

- Navigateurs web (gestion HTTPS, certificats clients)
- Clients email (S/MIME pour signature/chiffrement)
- Applications métier avec authentification par certificat
- Systèmes d'exploitation (stores de certificats)

### Formation et sensibilisation

Les utilisateurs finaux doivent être formés sur :

- **Importance de la sécurité** : Pourquoi protéger sa clé privée
- **Bonnes pratiques** : Mots de passe forts, pas de partage de clés
- **Procédures** : Comment demander, renouveler, révoquer un certificat
- **Détection d'incidents** : Reconnaître les signes de compromission
- **Support** : Qui contacter en cas de problème

> [!example] Scénarios de formation
> 
> - Que faire si votre ordinateur portable avec certificat est volé ?
> - Comment reconnaître un email de phishing se faisant passer pour la PKI ?
> - Pourquoi ne jamais envoyer sa clé privée par email ?
> - Comment vérifier qu'un site web utilise un certificat valide ?

---

## 🏗️ Architecture globale d'une PKI

Maintenant que nous avons détaillé chaque composant, voyons comment ils s'articulent dans une architecture complète.

### Vue d'ensemble des interactions

```
                    ┌─────────────────────┐
                    │    Root CA          │
                    │   (Hors ligne)      │
                    └──────────┬──────────┘
                               │ signe
                               ▼
                    ┌─────────────────────┐
                    │  Intermediate CA    │
                    │   (En ligne)        │
                    └──────────┬──────────┘
                               │
                ┌──────────────┼──────────────┐
                │              │              │
                ▼              ▼              ▼
    ┌───────────────┐  ┌──────────────┐  ┌─────────────┐
    │   RA Locale   │  │  Repository  │  │     VA      │
    │  (bureaux)    │  │    LDAP/     │  │   (OCSP)    │
    │               │  │     HTTP     │  │             │
    └───────┬───────┘  └──────┬───────┘  └──────┬──────┘
            │                 │                  │
            │  demande        │  publie          │  vérifie
            │  validation     │  consulte        │  statut
            │                 │                  │
            └─────────────────┴──────────────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │ Utilisateurs Finaux │
                    │  (personnes, apps,  │
                    │     serveurs)       │
                    └─────────────────────┘
```

### Flux de travail typiques

#### Flux 1 : Émission d'un certificat utilisateur

```
1. Utilisateur final
      │ Génère paire de clés + CSR
      ▼
2. RA locale
      │ Vérification identité (carte d'identité)
      │ Validation des informations
      │ Approbation de la demande
      ▼
3. CA intermédiaire
      │ Reçoit la demande approuvée
      │ Génère le certificat
      │ Signe avec sa clé privée
      ▼
4. Repository
      │ Publication du certificat
      │ Ajout à l'annuaire LDAP
      ▼
5. Utilisateur final
      │ Téléchargement du certificat
      │ Installation et utilisation
```

#### Flux 2 : Validation d'un certificat par un tiers

```
1. Application cliente (navigateur, email)
      │ Reçoit un certificat
      │ Vérifie signature et chaîne de confiance
      ▼
2. Repository
      │ Téléchargement certificats intermédiaires
      │ Construction de la chaîne complète
      ▼
3. VA (OCSP)
      │ Requête : ce certificat est-il révoqué ?
      │ Réponse signée : Good/Revoked/Unknown
      ▼
4. Application cliente
      │ Décision finale : accepter ou rejeter
```

#### Flux 3 : Révocation d'un certificat

```
1. Utilisateur final
      │ Demande de révocation (compromission)
      ▼
2. RA
      │ Vérification de l'identité du demandeur
      │ Validation de la raison de révocation
      │ Approbation
      ▼
3. CA
      │ Révocation du certificat
      │ Ajout à la CRL
      │ Mise à jour base OCSP
      ▼
4. Repository
      │ Publication de la nouvelle CRL
      │ Mise à disposition immédiate
      ▼
5. VA
      │ Mise à jour des réponses OCSP
      │ Certificat marqué "Revoked"
```

### Modèles d'architecture PKI

#### Architecture centralisée

```
                    Root CA
                       │
                Intermediate CA
                       │
        ┌──────────────┼──────────────┐
        │              │              │
       RA          Repository        VA
        │              │              │
        └──────────────┴──────────────┘
                       │
              Utilisateurs finaux
```

**Avantages** :

- Gestion simplifiée
- Coûts réduits
- Configuration uniforme
- Audit centralisé

**Inconvénients** :

- Point de défaillance unique
- Pas de redondance géographique
- Latence pour utilisateurs distants
- Scalabilité limitée

#### Architecture distribuée

```
            Root CA (hors ligne)
                   │
        ┌──────────┴──────────┐
        │                     │
  Intermediate CA 1     Intermediate CA 2
    (Europe)              (Amérique)
        │                     │
  ┌─────┼─────┐         ┌─────┼─────┐
  │     │     │         │     │     │
 RA  Repo   VA        RA   Repo   VA
  │     │     │         │     │     │
Utilisateurs         Utilisateurs
(Europe)             (Amérique)
```

**Avantages** :

- Haute disponibilité
- Résilience géographique
- Performance optimisée localement
- Scalabilité élevée

**Inconvénients** :

- Complexité de gestion
- Coûts plus élevés
- Synchronisation nécessaire
- Compétences distribuées requises

#### Architecture hiérarchique profonde

```
                Root CA
                   │
            ┌──────┴──────┐
            │             │
    Intermediate CA   Intermediate CA
       (Entreprise)      (Partenaires)
            │                 │
    ┌───────┴────────┐       │
    │                │       │
Sub-CA 1        Sub-CA 2    Sub-CA 3
(Département A) (Département B) (Partenaires)
    │                │          │
Certificats     Certificats  Certificats
utilisateurs    serveurs     externes
```

**Avantages** :

- Délégation de l'autorité
- Isolation des domaines
- Granularité des politiques
- Flexibilité organisationnelle

**Inconvénients** :

- Chaînes de confiance longues
- Complexité accrue
- Performance de validation
- Gestion multi-niveaux

### Considérations de sécurité globales

#### Défense en profondeur

La sécurité d'une PKI repose sur plusieurs couches :

|Couche|Mesures de sécurité|
|---|---|
|**Physique**|Salles sécurisées, contrôle d'accès biométrique, vidéosurveillance|
|**Réseau**|Segmentation, firewall, IDS/IPS, VPN pour accès distant|
|**Système**|Durcissement OS, patches à jour, antimalware, EDR|
|**Application**|Authentification forte, audit logging, principe du moindre privilège|
|**Cryptographique**|HSM, algorithmes robustes, gestion sécurisée des clés|
|**Procédurale**|Séparation des tâches, double contrôle, audits réguliers|
|**Humaine**|Formation, sensibilisation, vérification des antécédents|

#### Principe de moindre privilège

Chaque composant et utilisateur doit avoir uniquement les droits nécessaires :

- **Administrateurs CA** : Peuvent émettre et révoquer des certificats
- **Opérateurs RA** : Peuvent approuver des demandes mais pas émettre
- **Auditeurs** : Accès lecture seule aux journaux
- **Utilisateurs finaux** : Peuvent seulement demander/utiliser leurs certificats

> [!warning] Séparation des rôles Une personne ne devrait jamais cumuler les rôles d'administrateur CA et d'auditeur. Cette séparation est essentielle pour prévenir les abus et garantir l'intégrité de la PKI.

#### Audit et traçabilité

Tous les événements critiques doivent être journalisés :

- **Émission de certificats** : Qui, quand, pour qui, avec quels attributs
- **Révocation** : Qui a demandé, qui a approuvé, raison
- **Accès aux clés privées** : Toute utilisation de la clé de la CA
- **Modifications de configuration** : Changements de politiques ou paramètres
- **Tentatives d'accès** : Authentifications réussies et échouées
- **Opérations administratives** : Toute action privilégiée

> [!tip] Logs immuables Les journaux d'audit doivent être stockés de manière immuable (WORM - Write Once Read Many) et signés cryptographiquement pour prouver leur intégrité. Ils doivent être conservés pour la durée de vie des certificats plus une période d'archive.

### Politiques et conformité

#### Documents de politique essentiels

Une PKI bien gérée doit avoir :

**Certificate Policy (CP)** :

- Objectifs de la PKI
- Rôles et responsabilités
- Niveaux d'assurance proposés
- Durée de vie des certificats
- Usages autorisés
- Limitations de responsabilité

**Certification Practice Statement (CPS)** :

- Procédures techniques détaillées
- Mesures de sécurité physiques et logiques
- Processus d'émission et de révocation
- Gestion des clés privées
- Procédures d'audit
- Gestion des incidents

**Contrat d'abonnement** :

- Droits et obligations des utilisateurs
- Conditions d'utilisation
- Procédures de réclamation
- Clauses de confidentialité

> [!info] Hiérarchie des documents CP (stratégique) → CPS (tactique) → Procédures opérationnelles (opérationnel)
> 
> La CP définit "ce qui doit être fait", la CPS explique "comment c'est fait", et les procédures détaillent "les étapes précises".

#### Conformité réglementaire

Selon le secteur et la géographie, différentes normes peuvent s'appliquer :

|Standard/Réglementation|Domaine|Exigences clés|
|---|---|---|
|**WebTrust for CAs**|CAs publiques SSL/TLS|Audit annuel, contrôles stricts, transparence|
|**eIDAS**|UE - Signatures électroniques|Certification QSCD, services de confiance qualifiés|
|**NIST SP 800-57**|USA - Gestion des clés|Longueurs de clés, algorithmes approuvés|
|**ISO/IEC 27001**|Sécurité de l'information|SMSI, gestion des risques, amélioration continue|
|**Common Criteria (CC)**|Certification sécurité|Évaluation formelle des HSM, logiciels PKI|
|**PCI DSS**|Paiement par carte|Protection des clés de chiffrement, audits|

### Dimensionnement et performance

#### Facteurs de dimensionnement

Pour dimensionner une PKI, considérer :

**Nombre d'utilisateurs** :

- Utilisateurs actuels et croissance prévue
- Taux de renouvellement des certificats
- Pics de demandes (nouveaux employés, renouvellements de masse)

**Volumétrie** :

- Nombre de certificats émis par jour/mois/an
- Taille des CRL (impacte le repository et les clients)
- Requêtes OCSP par seconde (impacte la VA)

**Exigences de disponibilité** :

- SLA requis (99.9%, 99.99%, 99.999%)
- Temps de récupération acceptable (RTO)
- Perte de données acceptable (RPO)

> [!example] Exemple de dimensionnement Organisation de 50 000 employés :
> 
> - Certificats utilisateurs : 50 000 (durée 2 ans) → ~70 émissions/jour
> - Certificats serveurs : 500 (durée 1 an) → ~2 émissions/jour
> - Certificats IoT : 100 000 (durée 5 ans) → ~55 émissions/jour
> - **Total** : ~130 émissions/jour en moyenne, pics à ~500/jour
> - Requêtes OCSP : ~10 000/seconde aux heures de pointe

#### Optimisations de performance

**Pour la CA** :

- HSM performants pour les opérations de signature
- Pré-génération de certificats pour demandes standard
- Traitement par lots pour émissions massives
- Clustering pour haute disponibilité

**Pour le Repository** :

- CDN pour distribution des CRL et certificats
- Compression des CRL (peut réduire de 70-90%)
- Delta CRL pour limiter la taille
- Mise en cache agressive
- Indexation optimisée pour recherches LDAP

**Pour la VA** :

- Réponses OCSP pré-calculées et signées
- Distribution géographique des répondeurs
- OCSP Stapling pour réduire la charge
- Mise en cache avec TTL approprié

### Haute disponibilité et reprise d'activité

#### Architecture de haute disponibilité

```
          Load Balancer (actif/actif)
                    │
        ┌───────────┼───────────┐
        │           │           │
    CA Node 1   CA Node 2   CA Node 3
        │           │           │
        └───────────┴───────────┘
                    │
            HSM Cluster (clés partagées)
                    │
            Base de données
            (réplication master-master)
```

**Composants critiques** :

- **HSM en cluster** : Réplication des clés entre plusieurs HSM
- **Base de données** : Réplication synchrone ou asynchrone
- **Serveurs CA** : Load balancing, basculement automatique
- **Alimentation** : UPS, génératrices de secours
- **Réseau** : Liens redondants, multiples ISP

#### Plan de reprise d'activité (DRP)

Un DRP pour PKI doit couvrir :

1. **Sauvegarde des clés privées** :
    
    - Copies chiffrées des clés dans coffres-forts sécurisés
    - Split key (clé divisée entre plusieurs personnes)
    - Procédure de restauration documentée et testée
2. **Sauvegarde des données** :
    
    - Base de données des certificats émis
    - Journaux d'audit
    - Configuration système
    - Fréquence : quotidienne ou continue
3. **Site de secours** :
    
    - Site de reprise distant (DR site)
    - Infrastructure préconfigurée
    - Données répliquées en temps réel ou quasi-réel
4. **Procédures de basculement** :
    
    - Étapes détaillées de bascule vers le site de secours
    - Rôles et responsabilités définis
    - Communication vers les utilisateurs
    - Tests réguliers (au moins annuels)

> [!warning] Scénario catastrophe : Compromission de la Root CA Si la clé privée de la Root CA est compromise :
> 
> 1. **Révocation immédiate** de tous les certificats intermédiaires
> 2. **Communication** urgente à tous les utilisateurs
> 3. **Création** d'une nouvelle Root CA
> 4. **Migration** progressive vers la nouvelle PKI
> 5. **Investigation** forensique pour comprendre la compromission
> 
> C'est le pire scénario possible et peut nécessiter des mois de récupération. D'où l'importance critique de protéger la Root CA.

### Évolution et migration

#### Mise à jour des algorithmes cryptographiques

Les algorithmes vieillissent et doivent être renouvelés :

|Algorithme|Statut|Action|
|---|---|---|
|**SHA-1**|Déprécié|Migrer vers SHA-256 minimum|
|**RSA 1024**|Obsolète|Migrer vers RSA 2048+ ou ECC|
|**3DES**|En fin de vie|Migrer vers AES|
|**MD5**|Cassé|Ne plus utiliser|

**Stratégie de migration** :

1. Nouvelle CA avec algorithme moderne
2. Période de transition (dual-operation)
3. Renouvellement progressif des certificats
4. Révocation de l'ancienne CA après migration complète

#### Transition vers une nouvelle PKI

Raisons de migration :

- Changement de fournisseur
- Mise à niveau technologique
- Fusion d'organisations
- Compromission de l'ancienne PKI

**Approches** :

**Bridge CA** :

```
    Ancienne Root CA          Nouvelle Root CA
            │                        │
            └────── Bridge CA ────────┘
                        │
              Certificats de transition
```

**Cross-certification** :

- Les deux CA se certifient mutuellement
- Permet l'interopérabilité pendant la transition
- Les anciennes et nouvelles applications fonctionnent

**Migration complète** :

- Arrêt progressif de l'ancienne PKI
- Émission de tous nouveaux certificats
- Période de chevauchement nécessaire

> [!tip] Planification de migration Une migration PKI peut prendre 12-24 mois pour une grande organisation. Il faut :
> 
> - Inventorier tous les certificats et usages
> - Identifier les dépendances techniques
> - Former les équipes
> - Communiquer largement
> - Prévoir des rollback en cas de problème

### Surveillance et maintenance

#### Monitoring continu

Éléments à surveiller :

**Santé des composants** :

- Disponibilité CA, RA, VA, Repository
- Charge CPU/mémoire/disque
- Espace HSM disponible
- Connectivité réseau

**Métriques opérationnelles** :

- Nombre de certificats émis par jour
- Temps moyen d'émission
- Taux de rejet des demandes
- Nombre de révocations
- Requêtes OCSP/seconde
- Taille des CRL

**Alertes de sécurité** :

- Tentatives d'authentification échouées
- Accès non autorisés
- Modifications de configuration
- Certificats approchant de l'expiration
- Anomalies dans les logs d'audit

> [!example] Seuils d'alerte typiques
> 
> - **Critique** : CA inaccessible, HSM en erreur, base de données down
> - **Majeur** : Taux d'erreur OCSP >1%, temps de réponse >5s
> - **Mineur** : Certificats expirant dans 30 jours, utilisation disque >80%

#### Maintenance préventive

Tâches régulières :

**Quotidiennement** :

- Vérification des sauvegardes
- Revue des logs d'erreur
- Test des services critiques

**Hebdomadairement** :

- Revue des certificats expirés/révoqués
- Analyse des métriques de performance
- Vérification des alertes

**Mensuellement** :

- Mise à jour de sécurité (patches)
- Revue des accès et privilèges
- Test de restauration des sauvegardes
- Purge des anciennes CRL

**Trimestriellement** :

- Audit de sécurité interne
- Revue des politiques et procédures
- Formation de rappel pour les équipes

**Annuellement** :

- Audit externe (si requis)
- Test complet du plan de reprise d'activité
- Revue et mise à jour de la documentation
- Renouvellement des certificats de la CA intermédiaire

### Coûts et considérations budgétaires

#### Coûts initiaux (CAPEX)

- **Matériel** : Serveurs, HSM (50k-500k€), infrastructure réseau
- **Logiciels** : Licences PKI, bases de données, outils de gestion
- **Consulting** : Conception, implémentation (souvent 20-40% du projet)
- **Formation** : Personnel technique et utilisateurs finaux
- **Infrastructure** : Salles sécurisées, contrôles d'accès

#### Coûts récurrents (OPEX)

- **Maintenance logicielle** : Mises à jour, support (15-25% du coût logiciel annuellement)
- **Personnel** : Administrateurs PKI, opérateurs, auditeurs
- **Support** : Helpdesk pour utilisateurs finaux
- **Audits** : Audits externes réguliers si PKI publique
- **Hébergement** : Datacenter, énergie, refroidissement
- **Renouvellement matériel** : HSM, serveurs (cycle 3-5 ans)

> [!info] PKI as a Service De plus en plus d'organisations optent pour des PKI managées (cloud) pour :
> 
> - Réduire les coûts initiaux
> - Bénéficier d'expertise externe
> - Faciliter la scalabilité
> - Simplifier la conformité
> 
> Mais cela implique de confier des éléments critiques à un tiers.

---

## 🎯 Synthèse : Interactions entre composants

Pour conclure, voici comment tous les composants travaillent ensemble dans un scénario réel complet :

### Scénario : Un employé rejoint l'entreprise

```
1. RH enregistre le nouvel employé
      │
      ▼
2. RA locale notifiée (workflow automatisé)
      │ Vérifie documents RH
      │ Valide identité (carte d'identité + badge)
      ▼
3. RA crée demande pré-approuvée
      │ Génère CSR avec attributs employé
      ▼
4. CA intermédiaire
      │ Reçoit demande de la RA
      │ Génère certificat (CN=Jean Dupont, O=Example)
      │ Signe avec sa clé privée (stockée dans HSM)
      ▼
5. Repository LDAP
      │ Publication du certificat
      │ Ajout dans l'annuaire
      │ Mise à jour de la VA pour OCSP
      ▼
6. Système de gestion des certificats
      │ Déploiement automatique sur le poste de l'employé
      │ Installation dans le store Windows
      │ Configuration des applications (email, VPN, etc.)
      ▼
7. Employé utilise son certificat
      │ Authentification sur le réseau WiFi d'entreprise
      │ Connexion VPN depuis la maison
      │ Signature d'emails importants
      │ Accès aux applications métier
      ▼
8. Application vérifie le certificat
      │ Construction de la chaîne de confiance
      │ Vérification signature (Root CA → Intermediate CA → Certificat)
      │ Requête OCSP à la VA : certificat valide ?
      │ VA répond : "Good" (certificat valide)
      │ Accès accordé
```

### Points clés à retenir

> [!tip] Les 7 piliers d'une PKI robuste
> 
> 1. **Root CA hors ligne** : La base de la confiance, protégée au maximum
> 2. **CA intermédiaires opérationnelles** : Compartimentent les risques
> 3. **RA distribuées** : Valident l'identité près des utilisateurs
> 4. **VA hautement disponibles** : Réponses OCSP rapides et fiables
> 5. **Repository redondant** : Accès permanent aux certificats et CRL
> 6. **Utilisateurs formés** : Comprennent leurs responsabilités
> 7. **Audit continu** : Surveillance et traçabilité complète

Une PKI est un écosystème complexe où chaque composant a un rôle spécifique mais où tous doivent fonctionner harmonieusement. La sécurité globale dépend du maillon le plus faible, d'où l'importance d'une approche holistique de la conception, du déploiement et de l'exploitation.

---

**📌 Note finale** : Ce cours couvre les aspects fondamentaux de l'infrastructure PKI. Pour aller plus loin, chaque composant peut être étudié en profondeur avec ses protocoles (X.509, PKCS, OCSP, SCEP), ses implémentations (OpenSSL, Microsoft AD CS, EJBCA) et ses cas d'usage spécifiques (IoT, cloud, blockchain).