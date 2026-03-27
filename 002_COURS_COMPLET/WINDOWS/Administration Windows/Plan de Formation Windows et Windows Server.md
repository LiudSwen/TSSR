

📘 PARTIE 1 : Fondamentaux de Windows Client Fichier Obsidian suggéré : `01-fondamentaux-windows-client.md`

**Sujets à couvrir :**

1. **Présentation de Windows**
    
    - Historique et versions (7, 8, 10, 11)
    - Éditions (Home, Pro, Enterprise)
    - Architecture système (32 bits vs 64 bits)
2. **Interface et navigation**
    
    - Bureau et barre des tâches
    - Menu Démarrer
    - Explorateur de fichiers
    - Panneau de configuration vs Paramètres
3. **Système de fichiers**
    
    - NTFS vs FAT32
    - Arborescence Windows (C:\Windows, Program Files, Users)
    - Autorisations de base (lecture, écriture, exécution)
    - Attributs de fichiers

---

📘 PARTIE 2 : Administration Windows Client Fichier Obsidian suggéré : `02-administration-windows-client.md`

**Sujets à couvrir :**

1. **Outils d'administration**
    
    - Gestionnaire des tâches
    - Observateur d'événements
    - Gestion de l'ordinateur
    - Services Windows
    - Planificateur de tâches
2. **Gestion des utilisateurs et groupes locaux**
    
    - Comptes locaux
    - Comptes Microsoft
    - Types de comptes (Administrateur, Standard)
    - Contrôle de compte d'utilisateur (UAC)
    - Console Utilisateurs et groupes locaux
    - Création et gestion de groupes locaux
    - Groupes locaux prédéfinis
    - Commandes net user et net localgroup
3. **Gestion des logiciels**
    
    - Installation et désinstallation
    - Programmes et fonctionnalités
    - Applications de démarrage
    - Mises à jour Windows Update
4. **Gestion du matériel**
    
    - Gestionnaire de périphériques
    - Pilotes (installation, mise à jour)
    - Plug and Play
    - Résolution des conflits matériels
5. **Performance et maintenance**
    
    - Défragmentation
    - Nettoyage de disque
    - Analyse des performances
    - Gestionnaire de disques

---

📘 PARTIE 3 : Réseau et Connectivité Fichier Obsidian suggéré : `03-reseau-connectivite.md`

**Sujets à couvrir :**

1. **Configuration réseau de base**
    
    - Adressage IP (statique vs DHCP)
    - Masque de sous-réseau et passerelle
    - DNS
    - Test de connectivité (ping, ipconfig, nslookup)
2. **Partage de ressources**
    
    - Partages de fichiers et dossiers
    - Permissions de partage vs permissions NTFS
    - Lecteurs réseau mappés
    - Imprimantes partagées
3. **Groupe de travail**
    
    - Concept de workgroup
    - Découverte réseau
    - Accès aux ressources partagées
    - Limitations du groupe de travail

---

📘 PARTIE 4 : Introduction à Windows Server Fichier Obsidian suggéré : `04-introduction-windows-server.md`

**Sujets à couvrir :**

1. **Présentation de Windows Server**
    
    - Versions (2012, 2016, 2019, 2022)
    - Éditions (Standard, Datacenter)
    - Différences avec Windows Client
    - Modes d'installation (GUI, Server Core)
2. **Installation et configuration initiale**
    
    - Prérequis matériels
    - Processus d'installation
    - Configuration post-installation (sconfig)
    - Nom de l'ordinateur et groupe de travail
3. **Gestionnaire de serveur**
    
    - Interface et navigation
    - Tableau de bord
    - Ajout de rôles et fonctionnalités
    - Gestion à distance
4. **Rôles et fonctionnalités**
    
    - Concept de rôle vs fonctionnalité
    - Rôles principaux (aperçu)
    - Bonnes pratiques d'installation

---

📘 PARTIE 5 : Active Directory Domain Services (AD DS) Fichier Obsidian suggéré : `05-active-directory.md`

**Sujets à couvrir :**

1. **Concepts Active Directory**
    
    - Domaine, arbre, forêt
    - Contrôleur de domaine
    - Avantages du domaine vs workgroup
    - Schema, catalogue global
2. **Installation d'AD DS**
    
    - Prérequis (DNS, IP fixe)
    - Promotion d'un serveur en contrôleur de domaine
    - Configuration du domaine
    - Niveaux fonctionnels
3. **Structure organisationnelle**
    
    - Unités d'organisation (OU)
    - Objets AD (utilisateurs, ordinateurs, groupes)
    - Arborescence logique
    - Délégation de contrôle
4. **Gestion des utilisateurs et groupes**
    
    - Création d'utilisateurs
    - Propriétés des comptes
    - Jointure de postes au domaine
    - Types de groupes (sécurité, distribution)
    - Étendues de groupes (local, global, universel)
    - Groupes prédéfinis

---

📘 PARTIE 6 : Stratégies de Groupe (GPO) Fichier Obsidian suggéré : `06-strategies-groupe.md`

**Sujets à couvrir :**

1. **Concepts des GPO**
    
    - Définition et utilité
    - GPO locales vs GPO de domaine
    - Héritage et priorité
    - Ordre d'application (LSDOU)
2. **Création et gestion des GPO**
    
    - Console de gestion (GPMC)
    - Création d'une GPO
    - Liaison aux conteneurs (site, domaine, OU)
    - Éditeur de stratégies de groupe
3. **Paramètres courants**
    
    - Configuration ordinateur vs utilisateur
    - Stratégies de sécurité
    - Scripts de démarrage/arrêt/ouverture/fermeture de session
    - Redirection de dossiers
    - Installation de logiciels
4. **Dépannage des GPO**
    
    - gpupdate et gpresult
    - Mode de traitement (loopback)
    - Résolution des conflits
    - Rapports de stratégie de groupe

---

📘 PARTIE 7 : Services Réseau Essentiels Fichier Obsidian suggéré : `07-services-reseau.md`

**Sujets à couvrir :**

1. **DNS (Domain Name System)**
    
    - Rôle du DNS
    - Zones DNS (directe, inverse)
    - Enregistrements (A, AAAA, CNAME, MX, PTR)
    - Configuration du serveur DNS
    - Résolution de noms
2. **DHCP (Dynamic Host Configuration Protocol)**
    
    - Fonctionnement du DHCP
    - Étendues et plages d'adresses
    - Réservations
    - Options DHCP
    - Bail d'adresse
3. **Intégration DNS et DHCP**
    
    - Mise à jour dynamique DNS
    - DHCP et Active Directory
    - Configuration conjointe

---

📘 PARTIE 8 : Gestion des Disques et Stockage Fichier Obsidian suggéré : `08-disques-stockage.md`

**Sujets à couvrir :**

1. **Types de disques**
    
    - Disques de base vs dynamiques
    - MBR vs GPT
    - Partitions et volumes
    - Lettres de lecteur
2. **Gestion des volumes**
    
    - Création et formatage
    - Extension et réduction de volumes
    - Volumes simples
    - Points de montage
3. **RAID logiciel**
    
    - RAID 0 (agrégation)
    - RAID 1 (miroir)
    - RAID 5 (parité)
    - Gestion de la défaillance
4. **Espaces de stockage**
    
    - Concept et avantages
    - Pools de stockage
    - Résilience (simple, miroir, parité)
    - Provisionnement fin

---

📘 PARTIE 9 : Partage de Fichiers et Serveur d'Impression Fichier Obsidian suggéré : `09-partage-impression.md`

**Sujets à couvrir :**

1. **Serveur de fichiers**
    
    - Installation du rôle
    - Création de partages
    - Permissions de partage SMB
    - Partages cachés
    - Partages administratifs
2. **Gestion avancée des permissions**
    
    - Permissions NTFS détaillées
    - Héritage des permissions
    - Propriété des fichiers
    - Permissions effectives
    - Audit d'accès aux fichiers
3. **DFS (Distributed File System)**
    
    - Espaces de noms DFS
    - Réplication DFS
    - Avantages et cas d'usage
4. **Serveur d'impression**
    
    - Installation du rôle
    - Ajout d'imprimantes
    - Partage d'imprimantes
    - Pilotes d'impression
    - Gestion des files d'attente
    - Déploiement par GPO

---

📘 PARTIE 10 : Sécurité Windows Server Fichier Obsidian suggéré : `10-securite-server.md`

**Sujets à couvrir :**

1. **Pare-feu Windows**
    
    - Profils (domaine, privé, public)
    - Règles entrantes et sortantes
    - Configuration avancée
    - Pare-feu et Active Directory
2. **Stratégies de sécurité**
    
    - Stratégies de mot de passe
    - Stratégies de verrouillage de compte
    - Stratégies d'audit
    - Droits des utilisateurs
    - Options de sécurité
3. **Windows Defender**
    
    - Antivirus intégré
    - Analyses et mises à jour
    - Exclusions
    - Gestion centralisée
4. **Mises à jour et correctifs**
    
    - Windows Update sur serveur
    - Stratégie de patching
    - Redémarrage et maintenance

---

📘 PARTIE 11 : Sauvegarde et Restauration Fichier Obsidian suggéré : `11-sauvegarde-restauration.md`

**Sujets à couvrir :**

1. **Sauvegarde Windows Server**
    
    - Windows Server Backup
    - Types de sauvegarde (complète, incrémentielle)
    - Planification des sauvegardes
    - Destinations de sauvegarde
2. **Restauration de données**
    
    - Restauration de fichiers
    - Restauration de volumes
    - Restauration complète du système
    - Récupération bare metal
3. **Clichés instantanés (Shadow Copies)**
    
    - Configuration des clichés
    - Restauration de versions précédentes
    - Planification et stockage
4. **Plan de reprise d'activité**
    
    - Stratégie de sauvegarde 3-2-1
    - Documentation
    - Tests de restauration
    - Sauvegarde d'Active Directory

---

📘 PARTIE 12 : Accès à Distance Fichier Obsidian suggéré : `12-acces-distance.md`

**Sujets à couvrir :**

1. **Bureau à distance (RDP)**
    
    - Activation du Bureau à distance
    - Connexion Bureau à distance
    - Options de connexion
    - Gestion des sessions
2. **Accès SSH à Windows**
    
    - Installation d'OpenSSH Server
    - Configuration et démarrage du service
    - Connexion SSH à Windows
    - Gestion des clés SSH (optionnel)
3. **Gestion à distance**
    
    - Outils d'administration de serveur distant (RSAT)
    - Gestion de l'ordinateur à distance
    - Gestionnaire de serveur distant
    - MMC distante

---

📘 PARTIE 13 : Surveillance et Dépannage Fichier Obsidian suggéré : `13-surveillance-depannage.md`

**Sujets à couvrir :**

1. **Journaux d'événements**
    
    - Types de journaux (Application, Système, Sécurité)
    - Filtrage et recherche
    - Lecture et interprétation
    - Journaux des rôles serveur
2. **Analyse des performances**
    
    - Moniteur de ressources
    - Moniteur de performances (Perfmon)
    - Compteurs de performance courants
    - Identification des goulots d'étranglement
3. **Outils de diagnostic**
    
    - Best Practices Analyzer
    - Diagnostics réseau (tracert, pathping)
    - Centre de maintenance
4. **Méthodologie de dépannage**
    
    - Identification du problème
    - Collecte d'informations
    - Analyse et diagnostic
    - Mise en œuvre de la solution
    - Documentation