

## 📘 PARTIE 1 - Fondamentaux de Windows Server

**Dossier Obsidian suggéré :** `01-fondamentaux-windows-server/`

**Sujets à couvrir :**

1. Introduction à Windows Server → `01-introduction-windows-server.md`
    
    - Historique et évolutions des versions Windows Server
    - Différences entre Windows Client et Windows Server
    - Éditions de Windows Server (Standard, Datacenter, Essentials)
    - Cas d'usage et positionnement en entreprise
2. Installation et configuration initiale → `02-installation-configuration.md`
    
    - Prérequis matériels et logiciels
    - Modes d'installation (Desktop Experience vs Server Core)
    - Processus d'installation pas à pas
    - Configuration post-installation (nom, IP, fuseau horaire)
    - Windows Admin Center
3. Interface et outils d'administration → `03-interface-outils-admin.md`
    
    - Server Manager
    - Panneau de configuration vs Paramètres
    - Outils d'administration Windows (MMC)
    - PowerShell : introduction et utilisation de base
    - Gestionnaire des tâches et moniteur de ressources

---

## 📘 PARTIE 2 - Gestion des utilisateurs et des groupes

**Dossier Obsidian suggéré :** `02-utilisateurs-groupes/`

**Sujets à couvrir :**

1. Comptes utilisateurs locaux → `01-comptes-utilisateurs-locaux.md`
    
    - Création et gestion des comptes utilisateurs
    - Propriétés des comptes utilisateurs
    - Comptes intégrés (Administrateur, Invité)
    - Gestion des mots de passe et stratégies
2. Groupes locaux → `02-groupes-locaux.md`
    
    - Concept et utilité des groupes
    - Groupes intégrés (Administrateurs, Utilisateurs, etc.)
    - Création et gestion des groupes
    - Appartenance et imbrication
3. Profils utilisateurs → `03-profils-utilisateurs.md`
    
    - Types de profils (local, itinérant, obligatoire)
    - Structure d'un profil utilisateur
    - Gestion et dépannage des profils

---

## 📘 PARTIE 3 - Système de fichiers et stockage

**Dossier Obsidian suggéré :** `03-fichiers-stockage/`

**Sujets à couvrir :**

1. NTFS et systèmes de fichiers → `01-ntfs-systemes-fichiers.md`
    
    - Comparaison FAT32, NTFS, ReFS
    - Caractéristiques et avantages de NTFS
    - Formatage et conversion de partitions
2. Gestion des disques → `02-gestion-disques.md`
    
    - Disques de base vs disques dynamiques
    - Partitions et volumes
    - Gestionnaire de disques
    - Montage de volumes
    - Commandes diskpart
3. Permissions NTFS → `03-permissions-ntfs.md`
    
    - Types de permissions (lecture, écriture, modification, etc.)
    - Permissions de base et permissions avancées
    - Héritage des permissions
    - Propriétaire et prise de contrôle
    - Permissions effectives
4. Partages réseau → `04-partages-reseau.md`
    
    - Création et configuration de partages
    - Permissions de partage vs permissions NTFS
    - Partages administratifs
    - Accès aux partages (UNC)
    - Gestion des sessions et fichiers ouverts
5. Quotas de disque → `05-quotas-disque.md`
    
    - Concept et utilité des quotas
    - Configuration des quotas NTFS
    - Suivi et gestion des quotas

---

## 📘 PARTIE 4 - Active Directory Domain Services

**Dossier Obsidian suggéré :** `04-active-directory/`

**Sujets à couvrir :**

1. Concepts d'Active Directory → `01-concepts-active-directory.md`
    
    - Qu'est-ce qu'Active Directory
    - Domaines, arborescences et forêts
    - Contrôleurs de domaine
    - Sites et réplication
    - Catalogue global
2. Installation et configuration d'AD DS → `02-installation-adds.md`
    
    - Prérequis pour AD DS
    - Promotion d'un serveur en contrôleur de domaine
    - Création d'une nouvelle forêt/domaine
    - Ajout d'un contrôleur de domaine supplémentaire
    - Vérification du bon fonctionnement
3. Unités d'organisation (OU) → `03-unites-organisation.md`
    
    - Concept et utilité des OU
    - Création et gestion des OU
    - Délégation de contrôle
    - Stratégie de conception des OU
4. Gestion des utilisateurs et groupes AD → `04-utilisateurs-groupes-ad.md`
    
    - Création d'utilisateurs dans AD
    - Propriétés et attributs des comptes
    - Groupes de domaine (types et étendues)
    - Stratégie AGDLP/AGUDLP
    - Désactivation et suppression de comptes
5. Objets ordinateurs → `05-objets-ordinateurs.md`
    
    - Jonction d'un poste au domaine
    - Gestion des comptes ordinateurs
    - Redémarrage et réinitialisation de comptes
    - Déplacement d'ordinateurs entre OU

---

## 📘 PARTIE 5 - Stratégies de groupe (GPO)

**Dossier Obsidian suggéré :** `05-strategies-groupe/`

**Sujets à couvrir :**

1. Introduction aux GPO → `01-introduction-gpo.md`
    
    - Concept et fonctionnement des GPO
    - Stratégies locales vs stratégies de domaine
    - Ordre de traitement des GPO (LSDOU)
    - Éditeur de gestion des stratégies de groupe
2. Création et liaison de GPO → `02-creation-liaison-gpo.md`
    
    - Création d'une GPO
    - Liaison aux sites, domaines et OU
    - Filtrage de sécurité
    - Filtres WMI
3. Configuration des stratégies → `03-configuration-strategies.md`
    
    - Configuration ordinateur vs utilisateur
    - Stratégies vs préférences
    - Principales stratégies utiles
    - Modèles d'administration (ADMX)
4. Gestion et dépannage des GPO → `04-gestion-depannage-gpo.md`
    
    - Actualisation des stratégies (gpupdate)
    - Jeu de stratégie résultant (RSoP)
    - GPResult
    - Sauvegarde et restauration de GPO
    - Résolution de problèmes courants

---

## 📘 PARTIE 6 - Services réseau essentiels

**Dossier Obsidian suggéré :** `06-services-reseau/`

**Sujets à couvrir :**

1. Service DNS → `01-service-dns.md`
    
    - Rôle et fonctionnement du DNS
    - Installation du rôle DNS
    - Zones DNS (primaire, secondaire, intégrée AD)
    - Enregistrements DNS (A, AAAA, CNAME, MX, PTR, SRV)
    - Redirecteurs et résolution de noms
    - Maintenance et dépannage DNS
2. Service DHCP → `02-service-dhcp.md`
    
    - Rôle et fonctionnement du DHCP
    - Installation du rôle DHCP
    - Création et configuration d'étendues
    - Réservations et exclusions
    - Options DHCP
    - Autorisation du serveur DHCP dans AD
    - Surveillance et dépannage DHCP

---

## 📘 PARTIE 7 - Services de fichiers et d'impression

**Dossier Obsidian suggéré :** `07-fichiers-impression/`

**Sujets à couvrir :**

1. Services de fichiers avancés → `01-services-fichiers-avances.md`
    
    - Rôle Services de fichiers et de stockage
    - Gestionnaire de ressources du serveur de fichiers (FSRM)
    - Quotas et filtrage de fichiers
    - Rapports de stockage
    - Tâches de gestion de fichiers
2. Système de fichiers DFS → `02-dfs.md`
    
    - DFS Namespace (espace de noms)
    - DFS Replication
    - Installation et configuration
    - Cibles de dossiers
    - Réplication de contenu
3. Cliché instantané (VSS) → `03-cliche-instantane.md`
    
    - Concept de Volume Shadow Copy
    - Configuration des clichés instantanés
    - Restauration de fichiers via clichés
    - Planification et gestion
4. Services d'impression → `04-services-impression.md`
    
    - Installation du rôle Serveur d'impression
    - Ajout et partage d'imprimantes
    - Gestion des pilotes d'imprimante
    - Déploiement d'imprimantes par GPO
    - Surveillance des files d'impression

---

## 📘 PARTIE 8 - Sécurité de base

**Dossier Obsidian suggéré :** `08-securite-base/`

**Sujets à couvrir :**

1. Pare-feu Windows → `01-pare-feu-windows.md`
    
    - Principe et profils de pare-feu
    - Configuration via interface graphique
    - Règles entrantes et sortantes
    - Configuration via PowerShell
    - Dépannage du pare-feu
2. Windows Defender → `02-windows-defender.md`
    
    - Antivirus et protection en temps réel
    - Analyses et mise à jour des définitions
    - Exclusions et paramètres
    - Gestion centralisée
3. Stratégies de sécurité locales → `03-strategies-securite-locales.md`
    
    - Stratégies de mot de passe
    - Stratégies de verrouillage de compte
    - Stratégies d'audit
    - Attribution des droits utilisateur
    - Options de sécurité
4. Chiffrement avec BitLocker → `04-bitlocker.md`
    
    - Principe du chiffrement BitLocker
    - Prérequis (TPM)
    - Activation de BitLocker
    - Gestion des clés de récupération
    - BitLocker sur lecteurs amovibles
5. Mises à jour Windows → `05-mises-a-jour.md`
    
    - Windows Update
    - Types de mises à jour
    - Configuration de Windows Update
    - WSUS : principe et installation
    - Gestion des mises à jour via GPO

---

## 📘 PARTIE 9 - Surveillance et maintenance

**Dossier Obsidian suggéré :** `09-surveillance-maintenance/`

**Sujets à couvrir :**

1. Journaux d'événements → `01-journaux-evenements.md`
    
    - Observateur d'événements
    - Types de journaux (Application, Sécurité, Système)
    - Niveaux d'événements
    - Filtrage et recherche
    - Création de vues personnalisées
    - Abonnements aux événements
2. Surveillance des ressources système → `02-surveillance-ressources.md`
    
    - Gestionnaire des tâches (onglets Performances, Processus)
    - Moniteur de ressources (CPU, Mémoire, Disque, Réseau)
    - Surveillance en temps réel
    - Identification des processus gourmands
    - Surveillance de l'utilisation disque
3. Gestion des processus → `03-gestion-processus.md`
    
    - Visualisation des processus (Gestionnaire des tâches, tasklist)
    - Arrêt de processus (taskkill, Stop-Process)
    - Filtrage et recherche de processus
    - Gestion des services vs processus
    - Priorités des processus
4. Analyseur de performances → `04-analyseur-performances.md`
    
    - Moniteur de performances
    - Compteurs de performance essentiels
    - Ensembles de collecteurs de données
    - Rapports de performances
    - Identification des goulots d'étranglement
5. Sauvegarde et restauration → `05-sauvegarde-restauration.md`
    
    - Windows Server Backup
    - Types de sauvegardes (complète, incrémentielle)
    - Configuration de sauvegardes planifiées
    - Restauration de fichiers et volumes
    - Récupération de l'état du système
    - Sauvegarde d'Active Directory
6. Copie et synchronisation avec Robocopy → `06-robocopy.md`
    
    - Syntaxe et options principales de Robocopy
    - Copie miroir et synchronisation
    - Options de retry et logging
    - Exclusions de fichiers et dossiers
    - Automatisation avec scripts et tâches planifiées
7. Tâches planifiées → `07-taches-planifiees.md`
    
    - Planificateur de tâches
    - Création de tâches
    - Déclencheurs et actions
    - Conditions et paramètres
    - Surveillance de l'exécution

---

## 📘 PARTIE 10 - PowerShell pour l'administration

**Dossier Obsidian suggéré :** `10-powershell-administration/`

**Sujets à couvrir :**

1. Fondamentaux PowerShell → `01-fondamentaux-powershell.md`
    
    - Console vs ISE vs VS Code
    - Cmdlets et syntaxe
    - Get-Help et Get-Command
    - Alias et pipeline
    - Variables et types de données
2. Gestion des objets → `02-gestion-objets.md`
    
    - Concept d'objets et propriétés
    - Select-Object, Where-Object, Sort-Object
    - ForEach-Object
    - Mesure et groupement
    - Export et import de données (CSV, JSON, XML)
3. Scripts PowerShell → `03-scripts-powershell.md`
    
    - Création de scripts (.ps1)
    - Stratégie d'exécution
    - Paramètres et fonctions
    - Structures de contrôle (if, switch, boucles)
    - Gestion des erreurs (try/catch)
4. Administration courante avec PowerShell → `04-administration-powershell.md`
    
    - Gestion des utilisateurs et groupes AD
    - Gestion des OU et GPO
    - Gestion des services
    - Gestion des processus
    - Requêtes WMI/CIM
    - Administration à distance (PSRemoting)

---

## 📘 PARTIE 11 - Services d'accès distant

**Dossier Obsidian suggéré :** `11-acces-distant/`

**Sujets à couvrir :**

1. Bureau à distance (RDP) → `01-bureau-a-distance.md`
    
    - Activation du Bureau à distance
    - Connexion Bureau à distance (mstsc)
    - Configuration et paramètres
    - Gestion des licences RDS (notions de base)
    - Sécurisation de RDP
2. Windows Admin Center → `02-windows-admin-center.md`
    
    - Installation et configuration
    - Gestion de serveurs via navigateur
    - Fonctionnalités principales
    - Gestion à distance simplifiée

---

## 📘 PARTIE 12 - Dépannage système

**Dossier Obsidian suggéré :** `12-depannage-systeme/`

**Sujets à couvrir :**

1. Outils de dépannage → `01-outils-depannage.md`
    
    - Gestionnaire de périphériques
    - Informations système (msinfo32)
    - Moniteur de fiabilité
    - Outils de diagnostic réseau (ping, ipconfig, nslookup, tracert)
    - Analyseur de réseau (Wireshark - notions)
2. Modes de démarrage et récupération → `02-demarrage-recuperation.md`
    
    - Options de démarrage avancées
    - Mode sans échec
    - Environnement de récupération Windows (WinRE)
    - Restauration du système
    - Réparation du démarrage
3. Résolution de problèmes courants → `03-problemes-courants.md`
    
    - Problèmes de démarrage
    - Problèmes de performances
    - Problèmes réseau
    - Problèmes d'authentification
    - Problèmes de GPO
    - Méthodologie de dépannage