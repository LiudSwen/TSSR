

📘 PARTIE 1 : Introduction et concepts fondamentaux d'Active Directory Fichier Obsidian suggéré : `01-adds-introduction-concepts.md`

**Sujets à couvrir :**

1. Qu'est-ce qu'Active Directory Domain Services (ADDS)
    
    - Définition et rôle
    - Historique et versions
    - Cas d'usage en entreprise
2. Architecture logique d'Active Directory
    
    - Domaine
    - Arborescence (Tree)
    - Forêt (Forest)
    - Unités d'organisation (OU)
3. Architecture physique d'Active Directory
    
    - Contrôleurs de domaine (Domain Controller)
    - Sites Active Directory
    - Catalogue global (Global Catalog)
4. Les protocoles et services utilisés
    
    - LDAP
    - Kerberos
    - DNS (rôle critique)
    - SYSVOL et NETLOGON

---

📘 PARTIE 2 : Installation et configuration initiale d'ADDS Fichier Obsidian suggéré : `02-adds-installation-configuration.md`

**Sujets à couvrir :**

1. Prérequis techniques
    
    - Configuration serveur Windows Server
    - Configuration réseau et DNS
    - Nom de domaine et planification
2. Installation du rôle ADDS
    
    - Ajout du rôle via Server Manager
    - Installation via PowerShell
    - Fichiers et composants installés
3. Promotion d'un serveur en contrôleur de domaine
    
    - Création d'une nouvelle forêt
    - Ajout d'un contrôleur de domaine à un domaine existant
    - Configuration du mot de passe DSRM
    - Vérification post-installation
4. Configuration DNS intégrée à Active Directory
    
    - Zones DNS intégrées à AD
    - Enregistrements SRV
    - Résolution de noms dans le domaine

---

📘 PARTIE 3 : Gestion des objets Active Directory Fichier Obsidian suggéré : `03-adds-gestion-objets.md`

**Sujets à couvrir :**

1. Les utilisateurs (Users)
    
    - Création de comptes utilisateurs
    - Propriétés et attributs
    - Comptes de service et comptes système
    - Activation/désactivation de comptes
    - Réinitialisation de mots de passe
2. Les groupes (Groups)
    
    - Types de groupes (sécurité, distribution)
    - Étendues de groupes (local, global, universel)
    - Gestion des appartenances
    - Stratégie AGDLP
3. Les ordinateurs (Computers)
    
    - Comptes ordinateurs dans AD
    - Jonction d'un poste au domaine
    - Gestion et déplacement des comptes ordinateurs
4. Les unités d'organisation (OU)
    
    - Création et structure des OU
    - Délégation de contrôle
    - Stratégie de conception
5. Outils d'administration
    
    - Centre d'administration Active Directory
    - Utilisateurs et ordinateurs Active Directory
    - PowerShell pour la gestion AD (cmdlets de base)

---

📘 PARTIE 4 : Les stratégies de groupe (GPO) Fichier Obsidian suggéré : `04-adds-strategies-groupe-gpo.md`

**Sujets à couvrir :**

1. Introduction aux GPO
    
    - Définition et objectifs
    - Architecture des GPO
    - Stockage (SYSVOL)
2. Création et configuration de GPO
    
    - Console de gestion des stratégies de groupe (GPMC)
    - Configuration ordinateur vs Configuration utilisateur
    - Paramètres de stratégie disponibles
3. Application et liaison des GPO
    
    - Liaison aux domaines, sites et OU
    - Ordre d'application et héritage
    - Filtrage de sécurité
    - Filtres WMI
4. Priorité et résolution des GPO
    
    - Ordre de traitement (Local, Site, Domain, OU)
    - Blocage de l'héritage
    - Application forcée (Enforced)
    - Résolution de conflits
5. Déploiement de configurations courantes
    
    - Mappage de lecteurs réseau
    - Configuration du bureau et de l'environnement
    - Restrictions et sécurité
    - Installation de logiciels
    - Scripts de démarrage/arrêt et ouverture/fermeture de session
6. Dépannage des GPO
    
    - Résultats de stratégie de groupe (gpresult)
    - Modélisation de stratégie de groupe
    - Journaux d'événements

---

📘 PARTIE 5 : Gestion des droits et des permissions Fichier Obsidian suggéré : `05-adds-droits-permissions.md`

**Sujets à couvrir :**

1. Les permissions NTFS et leur lien avec AD
    
    - Rappel des permissions NTFS
    - Utilisation des groupes AD pour les permissions
2. Partage de fichiers et dossiers
    
    - Création de partages réseau
    - Permissions de partage vs permissions NTFS
    - Bonnes pratiques
3. Délégation de contrôle dans Active Directory
    
    - Assistant de délégation de contrôle
    - Permissions sur les objets AD
    - Cas d'usage courants
4. Groupes privilégiés et administratifs
    
    - Administrateurs du domaine
    - Administrateurs de l'entreprise
    - Administrateurs de schéma
    - Autres groupes intégrés

---

📘 PARTIE 6 : Services d'authentification et d'autorisation Fichier Obsidian suggéré : `06-adds-authentification-autorisation.md`

**Sujets à couvrir :**

1. Processus d'authentification Kerberos
    
    - Principe de fonctionnement
    - Tickets TGT et TGS
    - KDC (Key Distribution Center)
2. Authentification NTLM
    
    - Principe de fonctionnement
    - Différences avec Kerberos
    - Cas d'usage et limitations
3. Ouverture de session sur le domaine
    
    - Processus d'ouverture de session interactive
    - Profils utilisateurs (local, itinérant, obligatoire)
    - Scripts de connexion
4. Stratégies de mots de passe et de compte
    
    - Stratégie de mot de passe de domaine
    - Stratégie de verrouillage de compte
    - PSO (Password Settings Objects) pour stratégies affinées

---

📘 PARTIE 7 : Haute disponibilité et maintenance d'ADDS Fichier Obsidian suggéré : `07-adds-haute-disponibilite-maintenance.md`

**Sujets à couvrir :**

1. Contrôleurs de domaine multiples
    
    - Réplication entre contrôleurs de domaine
    - Topologie de réplication
    - Sites et liens de sites
    - RODC (Read-Only Domain Controller)
2. Rôles FSMO (Flexible Single Master Operations)
    
    - Les 5 rôles FSMO
    - Localisation des rôles
    - Transfert et saisie des rôles
3. Sauvegarde et restauration d'Active Directory
    
    - Sauvegarde de l'état du système
    - Restauration faisant autorité
    - Restauration ne faisant pas autorité
    - Mode de restauration des services d'annuaire (DSRM)
4. Maintenance courante
    
    - Défragmentation de la base AD
    - Gestion de la corbeille Active Directory
    - Surveillance de la santé d'AD (dcdiag, repadmin)
    - Nettoyage des métadonnées

---

📘 PARTIE 8 : Intégration et interopérabilité Fichier Obsidian suggéré : `08-adds-integration-interoperabilite.md`

**Sujets à couvrir :**

1. Intégration des postes clients Windows
    
    - Jonction au domaine
    - Configuration des paramètres réseau
    - Application des GPO sur les clients
2. Services complémentaires d'Active Directory
    
    - Services de certificats Active Directory (AD CS) - introduction
    - Services de fédération Active Directory (AD FS) - introduction
    - Azure Active Directory et synchronisation - introduction
3. Gestion à distance et outils d'administration
    
    - RSAT (Remote Server Administration Tools)
    - Administration depuis un poste client
    - PowerShell à distance

---

📘 PARTIE 9 : Sécurité d'Active Directory Fichier Obsidian suggéré : `09-adds-securite.md`

**Sujets à couvrir :**

1. Bonnes pratiques de sécurité
    
    - Principe du moindre privilège
    - Comptes administratifs séparés
    - Protection des comptes privilégiés
2. Sécurisation des contrôleurs de domaine
    
    - Durcissement des serveurs
    - Mise à jour et correctifs
    - Restriction d'accès physique et logique
3. Audit et journalisation
    
    - Configuration de l'audit dans les GPO
    - Surveillance des événements de sécurité
    - Journaux d'événements importants
4. Protection contre les attaques courantes
    
    - Pass-the-Hash
    - Golden Ticket
    - Énumération AD
    - Mesures de prévention de base

---

📘 PARTIE 10 : Dépannage et résolution de problèmes courants Fichier Obsidian suggéré : `10-adds-depannage.md`

**Sujets à couvrir :**

1. Méthodologie de dépannage
    
    - Identification du problème
    - Collecte d'informations
    - Tests et validation
2. Problèmes d'authentification
    
    - Impossible d'ouvrir une session
    - Erreurs de relation d'approbation
    - Problèmes de mot de passe
3. Problèmes de réplication
    
    - Détection des erreurs de réplication
    - Résolution des conflits
    - Utilisation de repadmin
4. Problèmes DNS liés à AD
    
    - Enregistrements SRV manquants
    - Problèmes de résolution de noms
    - Configuration DNS incorrecte
5. Outils de diagnostic
    
    - dcdiag
    - repadmin
    - nltest
    - Observateur d'événements
    - PowerShell pour le diagnostic