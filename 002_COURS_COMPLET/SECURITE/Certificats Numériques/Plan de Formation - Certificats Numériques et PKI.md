

📘 PARTIE 1 : Introduction à la cryptographie et aux certificats numériques Fichier Obsidian suggéré : `01-intro-cryptographie-certificats.md`

**Sujets à couvrir :**

1. Bases de la cryptographie
    
    - Cryptographie symétrique vs asymétrique
    - Concept de clé publique et clé privée
    - Fonction de hachage
    - Signature numérique
2. Les certificats numériques
    
    - Définition et rôle d'un certificat numérique
    - Structure d'un certificat X.509
    - Champs principaux (Subject, Issuer, Validity, Public Key)
    - Format des certificats (PEM, DER, PFX/P12)
3. Cas d'usage des certificats
    
    - Authentification de serveurs web (HTTPS)
    - Signature de documents
    - Chiffrement d'emails
    - Authentification utilisateur

---

📘 PARTIE 2 : Infrastructure à clés publiques (PKI) Fichier Obsidian suggéré : `02-infrastructure-pki.md`

**Sujets à couvrir :**

1. Composants d'une PKI
    
    - Autorité de certification (CA)
    - Autorité d'enregistrement (RA)
    - Autorité de validation (VA)
    - Repository de certificats
    - Utilisateurs finaux
2. Hiérarchie de certification
    
    - CA racine (Root CA)
    - CA intermédiaire (Subordinate CA)
    - Chaîne de confiance
    - CA publiques vs CA privées
3. Cycle de vie d'un certificat
    
    - Demande de certificat (CSR)
    - Validation de l'identité
    - Émission du certificat
    - Publication et distribution
    - Renouvellement
    - Révocation

---

📘 PARTIE 3 : Gestion de la révocation des certificats Fichier Obsidian suggéré : `03-revocation-certificats.md`

**Sujets à couvrir :**

1. Raisons de révocation
    
    - Compromission de clé privée
    - Changement d'affiliation
    - Cessation d'activité
    - Suspension temporaire
2. Mécanismes de révocation
    
    - Liste de révocation de certificats (CRL)
    - Structure d'une CRL
    - Online Certificate Status Protocol (OCSP)
    - OCSP Stapling
3. Validation de certificats
    
    - Vérification de la chaîne de confiance
    - Vérification du statut de révocation
    - Vérification de la période de validité
    - Vérification de l'usage

---

📘 PARTIE 4 : Implémentation pratique sous Windows Server Fichier Obsidian suggéré : `04-implementation-windows-server.md`

**Sujets à couvrir :**

1. Installation d'Active Directory Certificate Services (AD CS)
    
    - Prérequis
    - Rôles et services
    - Types d'installation (Enterprise vs Standalone)
    - Configuration initiale
2. Configuration d'une CA d'entreprise
    
    - Paramètres de la CA
    - Modèles de certificats
    - Stratégies d'émission
    - Configuration des points de distribution CRL et AIA
3. Gestion des certificats
    
    - Demande et émission de certificats
    - Approbation manuelle vs automatique
    - Renouvellement de certificats
    - Révocation de certificats
    - Sauvegarde et restauration de la CA

---

📘 PARTIE 5 : Déploiement et utilisation des certificats Fichier Obsidian suggéré : `05-deploiement-utilisation.md`

**Sujets à couvrir :**

1. Déploiement automatique via GPO
    
    - Auto-enrollment
    - Distribution des certificats racine
    - Configuration des clients
    - Paramètres de renouvellement automatique
2. Utilisation des certificats dans l'infrastructure
    
    - Sécurisation IIS avec certificats SSL/TLS
    - Authentification par carte à puce
    - Signature de code
    - Chiffrement EFS
    - Sécurisation du trafic RDP
    - Authentification 802.1X
3. Gestion des certificats utilisateurs
    
    - Certificat dans le magasin personnel
    - Export/Import de certificats
    - Protection de la clé privée
    - Certificats sur supports externes

---

📘 PARTIE 6 : Sécurité et bonnes pratiques Fichier Obsidian suggéré : `06-securite-bonnes-pratiques.md`

**Sujets à couvrir :**

1. Sécurisation de la PKI
    
    - Isolation de la CA racine (offline root CA)
    - Sécurité physique et logique
    - Contrôle d'accès à la CA
    - Audit et journalisation
    - Protection des clés privées (HSM)
2. Bonnes pratiques opérationnelles
    
    - Durée de validité des certificats
    - Taille des clés cryptographiques
    - Algorithmes recommandés
    - Politique de certificat (CP)
    - Déclaration des pratiques de certification (CPS)
3. Maintenance et supervision
    
    - Surveillance de la CA
    - Gestion des modèles de certificats
    - Planification du renouvellement de la CA
    - Archivage et récupération de clés
    - Plan de reprise après sinistre

---

📘 PARTIE 7 : Dépannage et résolution de problèmes Fichier Obsidian suggéré : `07-depannage-troubleshooting.md`

**Sujets à couvrir :**

1. Problèmes courants
    
    - Erreurs de chaîne de confiance
    - Certificats expirés
    - Problèmes de révocation (CRL inaccessible)
    - Erreurs d'auto-enrollment
    - Incompatibilités de certificats
2. Outils de diagnostic
    
    - Certutil
    - MMC Certificats
    - Observateur d'événements
    - Analyseur de certificats en ligne
    - Wireshark pour analyse SSL/TLS
3. Procédures de dépannage
    
    - Vérification de la connectivité aux points de distribution
    - Reconstruction de la chaîne de certificats
    - Nettoyage du cache de certificats
    - Renouvellement forcé
    - Résolution des problèmes de permission