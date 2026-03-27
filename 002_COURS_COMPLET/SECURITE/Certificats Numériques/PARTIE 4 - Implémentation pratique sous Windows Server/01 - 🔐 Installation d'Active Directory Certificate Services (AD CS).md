

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

## 🎯 Prérequis

Avant d'installer Active Directory Certificate Services, plusieurs éléments doivent être en place pour garantir une installation réussie et fonctionnelle.

### Prérequis système

> [!info] Configuration matérielle minimale
> 
> - **Processeur** : 1.4 GHz 64 bits ou supérieur
> - **RAM** : 2 GB minimum (4 GB recommandé)
> - **Espace disque** : 32 GB minimum
> - **Système d'exploitation** : Windows Server 2016/2019/2022

### Prérequis réseau et Active Directory

> [!warning] Domaine Active Directory obligatoire pour Enterprise CA Pour installer une **AC d'entreprise**, le serveur DOIT être membre d'un domaine Active Directory. Une AC autonome peut être installée sur un serveur autonome ou membre d'un groupe de travail.

**Configuration réseau requise :**

- Adresse IP statique configurée
- Résolution DNS fonctionnelle
- Connectivité au contrôleur de domaine (pour Enterprise CA)
- Ports réseau nécessaires ouverts :
    - TCP 135 (RPC)
    - TCP 445 (SMB)
    - Port personnalisé pour l'autorité d'enregistrement web (optionnel)

### Prérequis Active Directory

Pour une installation Enterprise CA, les éléments suivants doivent être en place :

|Élément|Détail|
|---|---|
|**Schéma AD**|Étendu pour supporter les certificats (automatique depuis Windows Server 2008)|
|**Permissions administratives**|Membre du groupe **Enterprise Admins** ou **Domain Admins**|
|**Services AD**|Active Directory Domain Services (AD DS) fonctionnel|
|**DNS**|Zones de recherche directe et inversée configurées|

### Prérequis de sécurité

> [!tip] Isolation du serveur d'autorité de certification Pour une AC racine, il est fortement recommandé d'installer le serveur sur une machine dédiée, isolée du réseau après configuration. Cette AC sera hors ligne pour maximiser la sécurité.

**Bonnes pratiques de sécurité :**

- Utiliser un serveur dédié pour l'AC (ne pas installer d'autres rôles critiques)
- Prévoir une solution de sauvegarde robuste
- Mettre en place un système HSM (Hardware Security Module) pour les environnements critiques
- Documenter toutes les procédures d'installation et de configuration
- Planifier la hiérarchie PKI avant l'installation

### Prérequis de nommage

> [!warning] Le nom du serveur ne peut pas être modifié après installation Une fois AD CS installé, le nom du serveur est gravé dans les certificats émis. Toute modification nécessiterait une réinstallation complète.

**Conventions de nommage recommandées :**

- AC racine : `CA-ROOT-01`, `ROOTCA01`
- AC subordonnée : `CA-SUB-01`, `ISSUINGCA01`
- Éviter les noms génériques comme `SERVER01`

---

## 🧩 Rôles et services

Active Directory Certificate Services est composé de plusieurs services de rôle qui peuvent être installés selon les besoins de votre infrastructure PKI.

### Vue d'ensemble des services de rôle

AD CS n'est pas un service monolithique mais un ensemble de composants modulaires. Vous pouvez installer uniquement les services nécessaires à votre cas d'usage.

### Service de rôle : Autorité de certification (CA)

> [!info] Composant central obligatoire L'**Autorité de certification** est le seul service de rôle obligatoire. C'est le cœur du système PKI qui émet et gère les certificats numériques.

**Fonctions principales :**

- Émission de certificats numériques
- Révocation de certificats compromis ou obsolètes
- Publication des listes de révocation (CRL)
- Validation des demandes de certificats
- Archivage des certificats émis

**Deux types d'autorités de certification :**

|Type|Usage|Caractéristiques|
|---|---|---|
|**AC racine**|Sommet de la hiérarchie PKI|Hors ligne, certificat auto-signé, durée de vie longue (10-20 ans)|
|**AC subordonnée**|Émission quotidienne de certificats|En ligne, certificat signé par l'AC racine, durée de vie moyenne (5-10 ans)|

### Service de rôle : Inscription web de l'autorité de certification

**Objectif :** Permettre aux utilisateurs de demander et récupérer des certificats via une interface web (HTTPS).

> [!example] Cas d'usage typique Un utilisateur distant ou sur un poste non-membre du domaine peut accéder à `https://ca-server/certsrv` pour demander un certificat utilisateur ou récupérer la chaîne de certificats.

**Fonctionnalités :**

- Demande de certificats via navigateur web
- Récupération de certificats en attente
- Téléchargement du certificat de l'AC et de la CRL
- Support des smart cards (avec middleware approprié)

**Prérequis pour ce service :**

- IIS (Internet Information Services) installé
- ASP.NET activé
- Certificat SSL pour le site web (peut être auto-signé initialement)

### Service de rôle : Service d'inscription de périphériques réseau

**Objectif :** Permettre aux routeurs, commutateurs et autres équipements réseau d'obtenir des certificats pour IPsec, 802.1X, etc.

> [!info] Protocole SCEP Ce service implémente le protocole **SCEP** (Simple Certificate Enrollment Protocol) qui est le standard pour l'inscription automatique des équipements réseau.

**Équipements supportés :**

- Routeurs Cisco, Juniper, etc.
- Points d'accès WiFi
- Commutateurs de niveau 3
- Pare-feu matériels
- Tout équipement supportant SCEP

**Prérequis :**

- IIS installé
- Autorité de certification déjà configurée
- Comptes de service dédiés pour SCEP

### Service de rôle : Service Web d'inscription de certificats

**Objectif :** Fournir une interface web moderne (basée sur WCF) pour l'inscription de certificats par les applications et services.

**Différence avec l'inscription web classique :**

|Inscription web classique|Service Web d'inscription|
|---|---|
|Interface HTML pour humains|API SOAP pour applications|
|Navigation par navigateur|Appels programmatiques|
|Certificats utilisateur/ordinateur|Tous types de certificats|

**Cas d'usage :**

- Applications d'entreprise automatisant l'obtention de certificats
- Scripts PowerShell pour le provisionnement massif
- Outils de gestion tiers

### Service de rôle : Service Web de stratégie d'inscription de certificats

**Objectif :** Centraliser et publier les stratégies d'inscription de certificats pour les clients.

> [!tip] Nécessaire pour l'inscription automatique avancée Ce service est requis si vous souhaitez que les clients non-membres du domaine puissent bénéficier de l'inscription automatique ou si vous avez des stratégies d'inscription complexes.

**Fonctions :**

- Distribution des modèles de certificats disponibles
- Application des règles d'autorisation d'inscription
- Support de l'inscription multiforest

### Service de rôle : Répondeur en ligne (OCSP)

**Objectif :** Fournir des réponses en temps réel sur l'état de révocation des certificats.

> [!info] Alternative moderne aux CRL **OCSP** (Online Certificate Status Protocol) est plus efficace que le téléchargement de listes CRL complètes, surtout pour les grands déploiements.

**Avantages d'OCSP :**

- Réponses en temps réel (pas de cache obsolète)
- Bande passante réduite (requête par certificat)
- Meilleure expérience utilisateur (validation plus rapide)
- Support natif dans tous les navigateurs modernes

**Architecture typique :**

```
Client → Répondeur OCSP → Base de données CA → Réponse (Good/Revoked/Unknown)
```

### Service de rôle : Service d'inscription de l'autorité de certification

**Objectif :** Gérer l'inscription des AC subordonnées auprès des AC parentes dans une hiérarchie PKI multi-niveaux.

**Quand l'utiliser :**

- Hiérarchie PKI à trois niveaux ou plus
- AC racine hors ligne avec multiples AC intermédiaires
- Renouvellement automatisé des certificats d'AC subordonnée

### Tableau récapitulatif des services de rôle

|Service|Obligatoire|Nécessite IIS|Cas d'usage principal|
|---|---|---|---|
|**Autorité de certification**|✅ Oui|❌ Non|Émission et gestion de certificats|
|**Inscription web**|❌ Non|✅ Oui|Demandes manuelles via navigateur|
|**Service périphériques réseau**|❌ Non|✅ Oui|Certificats pour équipements (SCEP)|
|**Service Web d'inscription**|❌ Non|✅ Oui|API pour applications|
|**Service Web de stratégie**|❌ Non|✅ Oui|Stratégies centralisées|
|**Répondeur OCSP**|❌ Non|✅ Oui|Validation de révocation en temps réel|
|**Service d'inscription CA**|❌ Non|❌ Non|Hiérarchies PKI complexes|

> [!warning] Attention aux dépendances Si vous installez des services web (inscription web, SCEP, etc.), vous devez d'abord installer et configurer IIS. L'installation d'AD CS peut le faire automatiquement, mais il est préférable de le faire manuellement pour mieux contrôler la configuration.

---

## 🏗️ Types d'installation

AD CS peut être installé selon deux architectures principales : **Enterprise CA** ou **Standalone CA**. Le choix dépend de votre infrastructure et de vos besoins.

### Enterprise CA (Autorité de certification d'entreprise)

> [!info] Intégration Active Directory Une **Enterprise CA** est étroitement intégrée à Active Directory et exploite ses fonctionnalités pour simplifier la gestion des certificats dans un environnement d'entreprise.

#### Caractéristiques principales

**Intégration AD :**

- Stocke les modèles de certificats dans Active Directory
- Publie automatiquement les certificats dans l'annuaire AD
- Utilise les groupes de sécurité AD pour contrôler l'accès
- Supporte l'inscription automatique basée sur les GPO

**Gestion des demandes :**

- Approbation automatique possible (selon les modèles)
- Validation de l'identité via les comptes AD
- Pas besoin d'approbation manuelle pour les certificats courants
- Support natif de l'auto-inscription

**Modèles de certificats :**

- Bibliothèque de modèles prédéfinis (utilisateur, ordinateur, serveur web, etc.)
- Possibilité de créer des modèles personnalisés
- Modèles duplicables et modifiables
- Contrôle d'accès granulaire par modèle

#### Prérequis spécifiques

|Prérequis|Détail|
|---|---|
|**Domaine AD**|Le serveur DOIT être membre d'un domaine|
|**Permissions**|Compte Enterprise Admins ou Domain Admins|
|**DNS**|Résolution DNS fonctionnelle|
|**Connectivité**|Accès permanent aux contrôleurs de domaine|

#### Quand utiliser une Enterprise CA

> [!example] Scénarios d'usage
> 
> - Environnement d'entreprise avec Active Directory existant
> - Besoin d'inscription automatique de certificats
> - Gestion centralisée via GPO
> - Émission de certificats utilisateur pour authentification (VPN, WiFi, etc.)
> - Certificats pour l'authentification des ordinateurs (IPsec, 802.1X)

#### Avantages et inconvénients

**✅ Avantages :**

- Gestion simplifiée grâce à l'intégration AD
- Inscription automatique et renouvellement automatique
- Contrôle d'accès basé sur les groupes AD
- Déploiement facile via GPO
- Audit et traçabilité intégrés

**❌ Inconvénients :**

- Nécessite obligatoirement Active Directory
- Dépendance à la disponibilité d'AD
- Complexité accrue pour la reprise après sinistre
- Moins adapté pour les environnements non-Windows

### Standalone CA (Autorité de certification autonome)

> [!info] Indépendance d'Active Directory Une **Standalone CA** fonctionne de manière indépendante sans nécessiter Active Directory. Elle offre plus de flexibilité au prix d'une gestion plus manuelle.

#### Caractéristiques principales

**Indépendance :**

- Aucune dépendance à Active Directory
- Peut être installée sur un serveur workgroup
- Fonctionne sur des systèmes non-Windows (via outils tiers)
- Configuration entièrement locale

**Gestion des demandes :**

- Toutes les demandes nécessitent une approbation manuelle par défaut
- Pas d'inscription automatique native
- Validation manuelle de l'identité du demandeur
- Processus de demande/approbation explicite

**Modèles de certificats :**

- Pas d'accès aux modèles de certificats AD
- Utilisation de types de certificats basiques prédéfinis
- Personnalisation via fichiers INF ou scripts
- Moins de flexibilité dans la conception de certificats

#### Prérequis spécifiques

|Prérequis|Détail|
|---|---|
|**Domaine AD**|❌ Non requis (mais compatible)|
|**Permissions**|Administrateur local suffisant|
|**DNS**|Recommandé mais pas obligatoire|
|**Connectivité**|Peut fonctionner isolée du réseau|

#### Quand utiliser une Standalone CA

> [!example] Scénarios d'usage
> 
> - **AC racine hors ligne** (cas d'usage principal)
> - Environnement sans Active Directory
> - Émission de certificats pour des entités externes (partenaires, clients)
> - AC de test ou de développement
> - Certificats pour des équipements non-Windows
> - Besoin de contrôle strict sur chaque émission

#### Avantages et inconvénients

**✅ Avantages :**

- Indépendance totale d'Active Directory
- Peut être complètement isolée (AC racine hors ligne)
- Contrôle total et manuel sur chaque émission
- Simplicité de conception (pas de dépendances complexes)
- Adapté aux environnements hétérogènes

**❌ Inconvénients :**

- Pas d'inscription automatique
- Gestion manuelle chronophage
- Pas de modèles personnalisables
- Pas d'intégration GPO
- Audit plus complexe

### Tableau comparatif complet

|Critère|Enterprise CA|Standalone CA|
|---|---|---|
|**Domaine AD requis**|✅ Oui, obligatoire|❌ Non|
|**Inscription automatique**|✅ Oui|❌ Non|
|**Approbation automatique**|✅ Possible|❌ Non (manuel)|
|**Modèles de certificats**|✅ Nombreux, personnalisables|⚠️ Basiques uniquement|
|**Déploiement GPO**|✅ Oui|❌ Non|
|**AC racine hors ligne**|⚠️ Possible mais complexe|✅ Usage recommandé|
|**Environnements non-Windows**|⚠️ Limité|✅ Adapté|
|**Complexité de gestion**|⚠️ Moyenne à élevée|🟢 Simple|
|**Évolutivité**|✅ Excellente|⚠️ Moyenne|

### Architecture de hiérarchie PKI typique

> [!tip] Meilleure pratique : Hiérarchie à deux niveaux L'architecture la plus courante combine les deux types :
> 
> - **AC racine** : Standalone CA, hors ligne
> - **AC subordonnée(s)** : Enterprise CA, en ligne

**Avantages de cette approche :**

1. **Sécurité maximale** : L'AC racine est hors ligne et protégée
2. **Flexibilité opérationnelle** : Les AC subordonnées sont intégrées à AD
3. **Inscription automatique** : Les utilisateurs bénéficient de l'auto-inscription
4. **Révocation facilitée** : En cas de compromission d'une AC subordonnée, seule celle-ci doit être révoquée

**Schéma d'architecture :**

```
┌─────────────────────────────────────┐
│   AC Racine (Standalone CA)         │
│   Hors ligne, sécurisée             │
│   Certificat auto-signé             │
│   Durée : 20 ans                    │
└──────────────┬──────────────────────┘
               │
               │ Signe
               ▼
┌─────────────────────────────────────┐
│   AC Subordonnée (Enterprise CA)    │
│   En ligne, intégrée AD             │
│   Certificat signé par AC racine    │
│   Durée : 10 ans                    │
└──────────────┬──────────────────────┘
               │
               │ Émet
               ▼
         ┌─────────┬─────────┬─────────┐
         ▼         ▼         ▼         ▼
     Utilisateurs Ordinateurs Serveurs Équipements
```

### Cas d'usage particuliers

**AC racine Enterprise dans un très petit environnement :**

> [!warning] Non recommandé en production Bien que techniquement possible, installer une AC racine comme Enterprise CA expose la clé privée racine sur un serveur en ligne, ce qui est un risque de sécurité majeur.

**Usage acceptable :** Environnements de test, laboratoires, très petites structures (< 50 postes) avec contraintes budgétaires.

**AC Standalone pour certificats externes :**

Utiliser une AC Standalone dédiée pour émettre des certificats à des partenaires ou clients externes, indépendamment de votre PKI interne. Cela isole les risques et simplifie la gestion.

---

## ⚙️ Configuration initiale

Après l'installation du rôle AD CS, la configuration initiale est cruciale. Elle définit des paramètres qui ne pourront plus être modifiés sans réinstallation complète.

### Workflow de configuration

> [!info] Processus en deux étapes L'installation d'AD CS se fait en deux phases distinctes :
> 
> 1. **Installation du rôle** : Ajout des binaires et services
> 2. **Configuration de l'AC** : Paramétrage des options de l'autorité de certification

### Installation du rôle AD CS

**Via Server Manager (interface graphique) :**

1. Ouvrir **Server Manager**
2. Cliquer sur **Manage** → **Add Roles and Features**
3. Sélectionner **Role-based or feature-based installation**
4. Choisir le serveur cible
5. Sélectionner **Active Directory Certificate Services**
6. Choisir les services de rôle nécessaires :
    - ✅ **Certification Authority** (obligatoire)
    - ⬜ Certification Authority Web Enrollment (optionnel)
    - ⬜ Certificate Enrollment Policy Web Service (optionnel)
    - ⬜ Certificate Enrollment Web Service (optionnel)
    - ⬜ Online Responder (optionnel)
7. Installer les fonctionnalités requises (IIS si services web sélectionnés)
8. Confirmer et lancer l'installation

**Via PowerShell :**

```powershell
# Installation du rôle de base (AC uniquement)
Install-WindowsFeature -Name ADCS-Cert-Authority -IncludeManagementTools

# Installation avec les services web
Install-WindowsFeature -Name ADCS-Cert-Authority, ADCS-Web-Enrollment -IncludeManagementTools

# Vérification de l'installation
Get-WindowsFeature -Name ADCS-*
```

> [!warning] L'installation seule ne configure pas l'AC Après l'installation du rôle, un bandeau jaune apparaît dans Server Manager indiquant "Configuration Required". Vous devez impérativement lancer la configuration pour rendre l'AC opérationnelle.

### Configuration de l'autorité de certification

#### Lancement de l'assistant de configuration

**Via Server Manager :**

1. Cliquer sur le **drapeau de notification** (triangle jaune)
2. Cliquer sur **Configure Active Directory Certificate Services**

**Via PowerShell :**

```powershell
# Lancement de l'assistant
Install-AdcsCertificationAuthority
```

#### Paramètres de configuration - Enterprise CA

**Écran 1 : Credentials**

Spécifier un compte avec les permissions **Enterprise Admins** ou **Domain Admins**.

> [!tip] Compte dédié recommandé Utilisez un compte de service dédié plutôt que votre compte administrateur personnel pour améliorer la traçabilité.

**Écran 2 : Role Services**

Cocher **Certification Authority** (déjà sélectionné si installé précédemment). Cocher d'autres services si nécessaire.

**Écran 3 : Setup Type**

Choisir entre :

- **Enterprise CA** (nécessite AD)
- **Standalone CA** (indépendant)

**Écran 4 : CA Type**

|Type|Usage|Certificat|
|---|---|---|
|**Root CA**|Sommet de la hiérarchie|Auto-signé|
|**Subordinate CA**|Niveau intermédiaire ou d'émission|Signé par AC parente|

> [!info] Choix architectural
> 
> - Pour une nouvelle PKI : choisir **Root CA**
> - Pour une AC sous une racine existante : choisir **Subordinate CA**

**Écran 5 : Private Key**

- **Create a new private key** : Création d'une nouvelle AC
- **Use existing private key** : Restauration ou renouvellement d'une AC existante

**Paramètres de la clé privée :**

|Paramètre|Valeur recommandée|Explication|
|---|---|---|
|**Cryptographic provider**|RSA#Microsoft Software Key Storage Provider|Standard, compatible avec tous les clients|
|**Key length**|4096 bits (AC racine), 2048 bits (AC subordonnée)|Compromis sécurité/performance|
|**Hash algorithm**|SHA256|SHA1 est obsolète, SHA256 est le standard actuel|

> [!warning] Ces paramètres sont définitifs La longueur de clé et l'algorithme de hachage ne peuvent pas être modifiés après configuration. Le renouvellement du certificat d'AC conservera ces paramètres sauf reconfiguration complète.

**Écran 6 : CA Name**

Définir le nom distinctif (DN) de l'autorité de certification.

**Structure du DN :**

```
CN=Nom de l'AC
```

**Exemples de noms :**

|Type d'AC|Exemple de nom|Explication|
|---|---|---|
|AC racine|`ContosoCorp-Root-CA`|Identifie clairement la fonction|
|AC subordonnée émettrice|`ContosoCorp-Issuing-CA-01`|Indique le rôle et permet la numérotation|
|AC subordonnée intermédiaire|`ContosoCorp-Intermediate-CA`|Distingue du niveau d'émission|

> [!tip] Conventions de nommage
> 
> - Inclure le nom de l'organisation
> - Indiquer le type d'AC (Root, Intermediate, Issuing)
> - Numéroter si plusieurs AC du même type
> - Éviter les caractères spéciaux
> - Rester concis (< 64 caractères)

**Distinguished Name Suffix :**

Par défaut, AD ajoute automatiquement les suffixes DC (Domain Component) basés sur votre domaine AD :

```
CN=ContosoCorp-Root-CA, DC=contoso, DC=com
```

**Écran 7 : Validity Period**

Définir la durée de validité du certificat de l'AC.

|Type d'AC|Durée recommandée|Justification|
|---|---|---|
|**AC racine**|20-25 ans|Rarement renouvelée, hors ligne|
|**AC subordonnée intermédiaire**|10-15 ans|Renouvellement occasionnel|
|**AC subordonnée émettrice**|5-10 ans|Renouvellement régulier, en ligne|

> [!warning] Règle importante Un certificat émis par une AC ne peut JAMAIS avoir une durée de validité supérieure à celle du certificat de l'AC émettrice. Exemple : si votre AC subordonnée a une validité de 5 ans, vous ne pourrez émettre de certificats de plus de 5 ans.

**Écran 8 : Certificate Database**

Définir l'emplacement de stockage de la base de données de certificats et des logs.

**Emplacements par défaut :**

```
Database : C:\Windows\System32\CertLog\<CA-Name>.edb
Database log : C:\Windows\System32\CertLog\
```

> [!tip] Bonnes pratiques de stockage
> 
> - **Volume dédié** : Placer la base sur un volume séparé (ex: `D:\CertDB\`)
> - **Performance** : Utiliser un disque SSD pour de meilleures performances
> - **Sauvegarde** : S'assurer que ce volume est inclus dans les sauvegardes
> - **Taille** : Prévoir 2-10 GB selon le volume d'émission

**Écran 9 : Confirmation**

Vérifier tous les paramètres avant de confirmer. Une fois l'installation lancée, la plupart des paramètres ne pourront pas être modifiés.

#### Configuration post-installation immédiate

Une fois l'assistant de configuration terminé, plusieurs tâches doivent être effectuées immédiatement.

**1. Vérifier le statut du service :**

```powershell
# Vérifier que le service est démarré
Get-Service -Name CertSvc

# Démarrer manuellement si nécessaire
Start-Service -Name CertSvc
```

**2. Ouvrir la console de gestion :**

```
Démarrer → Outils d'administration → Certification Authority
```

Ou via PowerShell :

```powershell
certsrv.msc
```

**3. Vérifier les emplacements de publication (CDP et AIA) :**

> [!info] CDP et AIA
> 
> - **CDP** (CRL Distribution Point) : Emplacement où les clients téléchargent les listes de révocation
> - **AIA** (Authority Information Access) : Emplacement où les clients récupèrent le certificat de l'AC émettrice

**Accéder aux paramètres :**

1. Dans la console Certification Authority, clic droit sur le nom de l'AC
2. Sélectionner **Properties**
3. Onglet **Extensions**

**Vérifier les URLs par défaut :**

Par défaut, AD CS configure automatiquement les URLs pour un environnement Active Directory :

```
CDP (CRL) :
- ldap:///CN=<CRLName>,CN=<CAName>,CN=CDP,CN=Public Key Services,CN=Services,<ConfigurationContainer>
- http://<ServerDNSName>/CertEnroll/<CAName><CRLNameSuffix>.crl

AIA (Certificate) :
- ldap:///CN=<CACertificateName>,CN=AIA,CN=Public Key Services,CN=Services,<ConfigurationContainer>
- http://<ServerDNSName>/CertEnroll/<ServerDNSName>_<CAName><CertificateName>.crt
```

> [!warning] URLs HTTP pour les clients non-domaine Les URLs LDAP ne fonctionnent que pour les clients membres du domaine. Pour les clients externes ou non-domaine, les URLs HTTP sont essentielles. Assurez-vous qu'elles sont accessibles.

**4. Configurer la publication web des CRL :**

Le répertoire virtuel CertEnroll dans IIS doit pointer vers le dossier de stockage des CRL :

```
C:\Windows\System32\CertSrv\CertEnroll\
```

**Vérification :**

```powershell
# Vérifier le répertoire virtuel IIS
Get-WebVirtualDirectory -Site "Default Web Site" -Name "CertEnroll"
```

**5. Publier la première CRL :**

```powershell
# Publier une nouvelle CRL
certutil -CRL
```

Vérifier la publication :

```powershell
# Lister les CRL publiées
certutil -store CA
```

**6. Configurer les intervalles de publication CRL :**

Par défaut :

- **Base CRL** : Publiée toutes les semaines (7 jours)
- **Delta CRL** : Publiée toutes les 24 heures

> [!tip] Ajuster selon votre environnement
> 
> - **Environnement à faible activité** : Base CRL hebdomadaire suffit
> - **Environnement critique** : Réduire à 1-2 jours pour la base CRL
> - **Delta CRL** : Conserver 24h ou réduire à 12h pour les environnements critiques

**Modification des intervalles :**

1. Console Certification Authority → Clic droit sur **Revoked Certificates**
2. Sélectionner **Properties**
3. Onglet **CRL Publishing Parameters**

```powershell
# Via PowerShell (exemple : Base CRL tous les 3 jours)
certutil -setreg CA\CRLPeriod "Days"
certutil -setreg CA\CRLPeriodUnits 3

# Delta CRL toutes les 12 heures
certutil -setreg CA\CRLDeltaPeriod "Hours"
certutil -setreg CA\CRLDeltaPeriodUnits 12

# Redémarrer le service pour appliquer
Restart-Service -Name CertSvc

# Republier immédiatement
certutil -CRL
```

**7. Configurer l'audit :**

> [!info] Traçabilité obligatoire L'audit des événements PKI est crucial pour la sécurité et la conformité. Il permet de tracer toutes les opérations sensibles (émission, révocation, modifications).

**Activer l'audit de l'AC :**

1. Console Certification Authority → Clic droit sur le nom de l'AC
2. **Properties** → Onglet **Auditing**
3. Cocher les événements à auditer :
    - ✅ **Back up and restore the CA database**
    - ✅ **Change CA configuration**
    - ✅ **Change CA security settings**
    - ✅ **Issue and manage certificate requests**
    - ✅ **Revoke certificates and publish CRLs**
    - ✅ **Store and retrieve archived keys**
    - ✅ **Start and stop Certificate Services**

**Configurer la stratégie d'audit Windows :**

```powershell
# Activer l'audit des accès aux objets
auditpol /set /subcategory:"Certification Services" /success:enable /failure:enable
```

**Vérifier les logs :**

Les événements sont enregistrés dans :

```
Event Viewer → Applications and Services Logs → Microsoft → Windows → CertificationAuthority → Operational
```

**8. Sauvegarder la configuration et les clés :**

> [!warning] CRITIQUE : Sauvegarde immédiate obligatoire Avant toute mise en production, vous DEVEZ effectuer une sauvegarde complète de l'AC. La perte de la clé privée de l'AC rendrait tous les certificats émis inutilisables.

**Éléments à sauvegarder :**

|Élément|Emplacement|Méthode|
|---|---|---|
|**Clé privée et certificat**|Certificat → Export|Fichier PFX protégé par mot de passe|
|**Base de données**|`C:\Windows\System32\CertLog\`|Windows Server Backup ou certutil|
|**Configuration**|Registre CA|Export via certutil|

**Sauvegarde de la clé privée (PFX) :**

1. Console Certification Authority → Clic droit sur le nom de l'AC
2. **All Tasks** → **Back up CA...**
3. Sélectionner **Private key and CA certificate**
4. Choisir un emplacement sécurisé (de préférence hors ligne)
5. Définir un **mot de passe très robuste**
6. Stocker le fichier PFX et le mot de passe dans des emplacements séparés et sécurisés

```powershell
# Sauvegarde via PowerShell
Backup-CARoleService -Path "D:\Backup\CA" -Password (Read-Host -AsSecureString) -KeyOnly
```

> [!danger] Sécurité du fichier PFX
> 
> - **Ne JAMAIS** stocker le PFX sur le serveur de production
> - Utiliser un coffre-fort physique ou HSM
> - Séparer le fichier et le mot de passe
> - Documenter la procédure de récupération
> - Tester régulièrement la restauration

**Sauvegarde de la base de données :**

```powershell
# Arrêter le service
Stop-Service -Name CertSvc

# Sauvegarde complète
Backup-CARoleService -Path "D:\Backup\CA" -DatabaseOnly

# Redémarrer le service
Start-Service -Name CertSvc
```

**Export de la configuration :**

```powershell
# Exporter la configuration complète
certutil -backup "D:\Backup\CA\Config"

# Exporter les clés de registre
reg export "HKLM\SYSTEM\CurrentControlSet\Services\CertSvc\Configuration" "D:\Backup\CA\Registry_CA.reg"
```

#### Configuration post-installation - AC subordonnée

Si vous configurez une **AC subordonnée**, des étapes supplémentaires sont nécessaires pour obtenir le certificat signé par l'AC parente.

**Processus de demande de certificat pour AC subordonnée :**

**1. Générer la demande de certificat :**

Lors de la configuration initiale, si vous sélectionnez **Subordinate CA**, l'assistant vous demande comment obtenir le certificat :

Options disponibles :

- **Send a certificate request to a parent CA**
- **Save a certificate request to file on the target machine**
- **Use a certificate request sent manually to a parent CA**

> [!tip] Méthode recommandée Pour une AC racine **hors ligne**, choisir **Save to file**. Pour une AC racine en ligne, **Send automatically** est plus simple.

**2. Soumettre la demande à l'AC parente (si hors ligne) :**

```powershell
# Sur le serveur AC subordonnée, générer le fichier de demande
# (déjà fait par l'assistant, généralement dans C:\)
# Fichier : <CAName>.req

# Transférer le fichier .req sur l'AC racine (clé USB, réseau sécurisé)

# Sur l'AC racine (hors ligne), démarrer le service
Start-Service -Name CertSvc

# Soumettre et approuver la demande
certreq -submit -config "RootCA-Server\RootCA-Name" "C:\SubCA.req" "C:\SubCA.cer"

# Alternative via l'interface graphique
# Ouvrir Certification Authority → Clic droit sur CA → All Tasks → Submit new request
```

**3. Installer le certificat signé sur l'AC subordonnée :**

```powershell
# Transférer le fichier .cer de l'AC racine vers l'AC subordonnée

# Installer le certificat
certutil -installcert "C:\SubCA.cer"

# Vérifier l'installation
certutil -store My

# Démarrer le service
Start-Service -Name CertSvc
```

**4. Publier le certificat de l'AC racine :**

> [!info] Chaîne de confiance Les clients doivent avoir accès au certificat de l'AC racine pour valider les certificats émis par l'AC subordonnée.

**Distribution via GPO (pour clients domaine) :**

Le certificat de l'AC racine doit être ajouté au magasin **Trusted Root Certification Authorities** de tous les clients.

```powershell
# Via GPO
# Computer Configuration → Policies → Windows Settings → Security Settings → Public Key Policies → Trusted Root Certification Authorities
# Importer le certificat .cer de l'AC racine
```

**Publication dans AD (automatique pour Enterprise CA) :**

```powershell
# Publier dans Active Directory
certutil -dspublish -f "C:\RootCA.cer" RootCA

# Publier dans NTAuthCertificates (si nécessaire pour authentification domaine)
certutil -dspublish -f "C:\RootCA.cer" NTAuthCA
```

#### Configuration des modèles de certificats (Enterprise CA uniquement)

> [!info] Modèles disponibles uniquement pour Enterprise CA Les modèles de certificats sont une fonctionnalité exclusive aux Enterprise CA. Les Standalone CA utilisent des types de certificats basiques.

**Accéder aux modèles de certificats :**

1. Console Certification Authority → Développer le nom de l'AC
2. Clic droit sur **Certificate Templates** → **Manage**

Cela ouvre la console **Certificate Templates**.

**Publier des modèles sur l'AC :**

Par défaut, seuls quelques modèles sont activés. Pour en activer d'autres :

1. Console Certification Authority → Clic droit sur **Certificate Templates**
2. **New** → **Certificate Template to Issue**
3. Sélectionner les modèles à publier (ex: Web Server, User, Computer)

**Modèles par défaut couramment utilisés :**

|Modèle|Usage|Configuration|
|---|---|---|
|**User**|Authentification utilisateur|Auto-inscription activable|
|**Computer**|Authentification ordinateur|Auto-inscription par défaut|
|**Web Server**|Certificats SSL/TLS pour serveurs web|Demande manuelle|
|**Domain Controller**|Authentification DC|Auto-inscription automatique|
|**Workstation Authentication**|802.1X, VPN|Auto-inscription activable|

**Dupliquer et personnaliser un modèle :**

1. Console Certificate Templates → Clic droit sur un modèle → **Duplicate Template**
2. Onglet **General** : Donner un nom et configurer la validité
3. Onglet **Request Handling** : Définir le comportement (auto-inscription, export de clé privée)
4. Onglet **Security** : Définir qui peut demander le certificat (Read + Enroll)
5. Onglet **Subject Name** : Configurer comment le sujet est construit
6. **OK** pour créer le nouveau modèle
7. Publier le modèle sur l'AC

```powershell
# Lister les modèles publiés sur l'AC
certutil -CATemplates

# Ajouter un modèle
certutil -SetCATemplates +MyCustomTemplate
```

#### Configuration de l'inscription automatique (Enterprise CA)

> [!tip] Fonctionnalité clé pour les environnements entreprise L'inscription automatique permet aux utilisateurs et ordinateurs d'obtenir automatiquement les certificats dont ils ont besoin sans intervention manuelle.

**Prérequis :**

- Enterprise CA configurée
- Modèles de certificats avec permissions appropriées
- Clients membres du domaine

**Étapes de configuration :**

**1. Configurer les permissions sur le modèle :**

Dans la console Certificate Templates :

1. Clic droit sur le modèle → **Properties**
2. Onglet **Security**
3. Ajouter le groupe cible (ex: **Domain Users**, **Domain Computers**)
4. Accorder les permissions :
    - ✅ **Read**
    - ✅ **Enroll**
    - ✅ **Autoenroll**

**2. Créer une GPO pour activer l'inscription automatique :**

**Pour les ordinateurs :**

```
GPO → Computer Configuration → Policies → Windows Settings → Security Settings → Public Key Policies → Certificate Services Client - Auto-Enrollment

Configuration :
- Configuration Model : Enabled
- ✅ Renew expired certificates, update pending certificates, and remove revoked certificates
- ✅ Update certificates that use certificate templates
```

**Pour les utilisateurs :**

```
GPO → User Configuration → Policies → Windows Settings → Security Settings → Public Key Policies → Certificate Services Client - Auto-Enrollment

(Mêmes options que pour les ordinateurs)
```

**3. Forcer l'application de la GPO sur un client test :**

```powershell
# Sur le client
gpupdate /force

# Déclencher manuellement l'inscription automatique
certutil -pulse
```

**4. Vérifier l'émission des certificats :**

```powershell
# Sur le client, ouvrir le magasin de certificats
certmgr.msc

# Vérifier dans Personal → Certificates
```

Sur le serveur AC :

```powershell
# Lister les certificats émis récemment
certutil -view -restrict "NotAfter>=now-1" -out "CommonName,RequesterName"
```

#### Vérification finale de la configuration

**Liste de contrôle post-installation :**

> [!example] Checklist de validation Avant de mettre l'AC en production, vérifier tous ces points :

- [ ] Service CertSvc démarré et configuré en démarrage automatique
- [ ] Certificat de l'AC valide et installé
- [ ] CRL publiée et accessible via HTTP
- [ ] Points de distribution CDP et AIA correctement configurés
- [ ] Audit activé sur l'AC et dans Windows
- [ ] Sauvegarde de la clé privée effectuée et testée
- [ ] Sauvegarde de la base de données planifiée
- [ ] Modèles de certificats publiés (Enterprise CA)
- [ ] Inscription automatique configurée (Enterprise CA)
- [ ] Certificat de l'AC racine distribué aux clients
- [ ] Test d'émission de certificat réussi
- [ ] Test de révocation et publication CRL réussi
- [ ] Documentation complète de la configuration

**Tests de validation :**

**1. Tester l'émission d'un certificat :**

```powershell
# Demander un certificat simple via certreq
# Créer un fichier de demande (test.inf)
```

Contenu de `test.inf` :

```ini
[NewRequest]
Subject = "CN=Test Certificate,OU=IT,O=Contoso,L=Paris,S=IDF,C=FR"
KeyLength = 2048
Exportable = TRUE
MachineKeySet = FALSE
RequestType = Cert

[EnhancedKeyUsageExtension]
OID=1.3.6.1.5.5.7.3.2 ; Client Authentication
```

```powershell
# Soumettre la demande
certreq -new test.inf test.req
certreq -submit -config "CA-Server\CA-Name" test.req test.cer

# Installer le certificat
certreq -accept test.cer

# Vérifier
certutil -store My "Test Certificate"
```

**2. Tester la révocation :**

```powershell
# Révoquer le certificat de test
certutil -revoke <SerialNumber> 0

# Republier la CRL
certutil -CRL

# Vérifier que le certificat apparaît dans la CRL
certutil -store CA | findstr <SerialNumber>
```

**3. Vérifier l'accessibilité des URLs CDP/AIA :**

```powershell
# Tester l'accès HTTP à la CRL
Invoke-WebRequest -Uri "http://ca-server/CertEnroll/<CAName>.crl"

# Tester l'accès au certificat de l'AC
Invoke-WebRequest -Uri "http://ca-server/CertEnroll/<CAName>.crt"
```

Depuis un navigateur web, accéder à :

```
http://<ca-server>/CertEnroll/
```

Vous devriez voir la liste des fichiers CRL et CRT.

**4. Vérifier la chaîne de certificats :**

```powershell
# Vérifier la chaîne complète
certutil -verify -urlfetch test.cer
```

Cette commande valide :

- La signature du certificat
- La chaîne jusqu'à la racine de confiance
- L'accès aux CDP (CRL)
- L'accès aux AIA (certificat émetteur)
- Le statut de révocation

> [!info] Résultat attendu La commande doit retourner **"Certificate is valid"** sans erreur de révocation ou de chaîne de confiance.

#### Cas particulier : AC racine hors ligne

> [!warning] Procédure spécifique pour AC racine hors ligne Une AC racine hors ligne nécessite une gestion particulière car elle ne sera pas accessible en permanence sur le réseau.

**Étapes supplémentaires pour AC racine hors ligne :**

**1. Configuration initiale :**

- Installer et configurer l'AC (Standalone CA, Root CA)
- Définir une longue période de validité (20-25 ans)
- Configurer une longue période de publication CRL (6-12 mois)

**2. Publication de la CRL avant mise hors ligne :**

```powershell
# Configurer une période CRL longue (6 mois)
certutil -setreg CA\CRLPeriod "Months"
certutil -setreg CA\CRLPeriodUnits 6

# Désactiver Delta CRL (inutile pour une AC hors ligne)
certutil -setreg CA\CRLDeltaPeriod "Days"
certutil -setreg CA\CRLDeltaPeriodUnits 0

# Redémarrer et publier
Restart-Service -Name CertSvc
certutil -CRL
```

**3. Exporter les éléments nécessaires :**

```powershell
# Exporter le certificat de l'AC racine
certutil -ca.cert "C:\Export\RootCA.cer"

# Exporter la CRL
Copy-Item "C:\Windows\System32\CertSrv\CertEnroll\*.crl" -Destination "C:\Export\"

# Sauvegarde complète
Backup-CARoleService -Path "C:\Backup\RootCA" -Password (Read-Host -AsSecureString)
```

**4. Transférer vers les serveurs en ligne :**

Copier les fichiers suivants vers le serveur web qui hébergera les CDP/AIA :

- `RootCA.cer` (certificat de l'AC racine)
- `RootCA.crl` (CRL de l'AC racine)

Placer ces fichiers dans le répertoire `C:\inetpub\wwwroot\CertEnroll\` du serveur web (ou équivalent).

**5. Mettre l'AC hors ligne :**

```powershell
# Arrêter le service
Stop-Service -Name CertSvc
Set-Service -Name CertSvc -StartupType Disabled

# Éteindre le serveur
Stop-Computer
```

> [!tip] Stockage physique sécurisé Le serveur AC racine doit être :
> 
> - Débranché du réseau
> - Stocké dans un coffre-fort ou salle sécurisée
> - Accessible uniquement aux administrateurs PKI autorisés
> - Démarré uniquement pour les opérations suivantes :
>     - Émission de certificats pour AC subordonnées
>     - Renouvellement du certificat de l'AC racine
>     - Révocation d'une AC subordonnée
>     - Publication d'une nouvelle CRL (tous les 6 mois)

**6. Calendrier d'opérations récurrentes :**

|Opération|Fréquence|Procédure|
|---|---|---|
|**Publication CRL**|Tous les 6 mois|Démarrer AC → Publier CRL → Copier sur serveur web → Arrêter AC|
|**Sauvegarde**|Après chaque démarrage|Backup complet de la base et des clés|
|**Émission certificat AC sub**|À la demande (rare)|Démarrer AC → Signer demande → Arrêter AC|
|**Test de restauration**|Annuel|Restaurer sur environnement test isolé|

### Dépannage des problèmes courants

> [!warning] Problèmes fréquents et solutions Voici les problèmes les plus courants rencontrés lors de l'installation et de la configuration initiale d'AD CS.

#### Le service CertSvc ne démarre pas

**Symptômes :**

- Erreur au démarrage du service
- Event ID 100 dans le journal d'événements

**Causes possibles et solutions :**

|Cause|Solution|
|---|---|
|Base de données corrompue|Restaurer depuis sauvegarde ou recréer|
|Permissions insuffisantes|Vérifier les permissions sur `C:\Windows\System32\CertLog\`|
|Certificat d'AC manquant ou invalide|Réinstaller le certificat|
|Port déjà utilisé|Vérifier les conflits avec d'autres services|

```powershell
# Vérifier les logs détaillés
Get-EventLog -LogName Application -Source "CertificationAuthority" -Newest 50

# Réparer les permissions
icacls "C:\Windows\System32\CertLog" /grant "NT AUTHORITY\SYSTEM:(OI)(CI)F"
```

#### Les clients ne peuvent pas accéder aux CRL

**Symptômes :**

- Erreur de validation de certificat sur les clients
- "The revocation function was unable to check revocation for the certificate"

**Solutions :**

```powershell
# Vérifier l'accessibilité HTTP des CRL
Test-NetConnection -ComputerName ca-server -Port 80

# Vérifier les URLs configurées
certutil -getreg CA\CRLPublicationURLs

# Tester manuellement le téléchargement
Invoke-WebRequest -Uri "http://ca-server/CertEnroll/<CAName>.crl"

# Vérifier les permissions IIS
icacls "C:\Windows\System32\CertSrv\CertEnroll" /grant "IIS_IUSRS:(R)"
```

#### L'inscription automatique ne fonctionne pas

**Symptômes :**

- Les certificats ne sont pas émis automatiquement
- Aucune erreur visible

**Checklist de dépannage :**

```powershell
# Sur le client, vérifier la GPO appliquée
gpresult /h gpresult.html
# Ouvrir gpresult.html et chercher "Certificate Services Client"

# Vérifier les permissions sur le modèle
# Console Certificate Templates → Clic droit sur modèle → Properties → Security
# Vérifier Read + Enroll + Autoenroll

# Forcer la mise à jour GPO
gpupdate /force

# Déclencher manuellement l'inscription
certutil -pulse

# Consulter les logs d'inscription
Get-EventLog -LogName Application -Source "Microsoft-Windows-CertificateServicesClient-AutoEnrollment"
```

#### Erreur "Cannot find object or property"

**Symptômes :**

- Erreur lors de la publication de modèles
- Impossible d'accéder à Certificate Templates

**Solution :**

```powershell
# Vérifier l'extension du schéma AD
Get-ADObject -Identity "CN=Schema,CN=Configuration,DC=contoso,DC=com" -Properties objectVersion

# Forcer la réplication AD
repadmin /syncall /AdeP

# Réenregistrer les DLL Certificate Services
regsvr32 certcli.dll
regsvr32 certadm.dll
```

---

## 🎓 Récapitulatif

### Points clés à retenir

> [!tip] L'essentiel de l'installation AD CS
> 
> **Prérequis :**
> 
> - Serveur membre d'un domaine AD (pour Enterprise CA)
> - Permissions Enterprise Admins ou Domain Admins
> - Planification de la hiérarchie PKI avant installation
> 
> **Configuration :**
> 
> - Choix entre Enterprise CA (intégré AD) et Standalone CA (autonome)
> - Choix entre Root CA (racine) et Subordinate CA (subordonnée)
> - Paramètres de clé privée : 4096 bits pour racine, 2048 bits pour subordonnée
> - Algorithme de hachage : SHA256 minimum
> 
> **Post-installation obligatoire :**
> 
> - Configuration des URLs CDP et AIA
> - Publication de la première CRL
> - Sauvegarde de la clé privée et de la base de données
> - Activation de l'audit
> - Tests de validation

### Architecture recommandée

Pour un déploiement d'entreprise standard :

```
AC Racine (Standalone, hors ligne)
    └── AC Subordonnée 1 (Enterprise, en ligne) → Certificats utilisateurs/ordinateurs
    └── AC Subordonnée 2 (Enterprise, en ligne) → Certificats serveurs web
```

### Prochaines étapes

Maintenant que l'installation et la configuration initiale sont terminées, les étapes suivantes incluront :

- Configuration avancée des modèles de certificats
- Mise en place de l'autorité d'enregistrement web
- Configuration d'OCSP pour la validation en temps réel
- Gestion des révocations et renouvellements
- Haute disponibilité et reprise après sinistre

---

_📚 Cours rédigé pour Obsidian - Certificats Numériques et PKI_