# Plan de cours SSH pour formation TSSR

📘 PARTIE 1 : Introduction et concepts fondamentaux du SSH Fichier Obsidian suggéré : `01-ssh-introduction-concepts.md`

**Sujets à couvrir :**

1. Qu'est-ce que SSH
    
    - Définition et historique
    - Différences avec Telnet et rlogin
    - Versions du protocole (SSH-1 vs SSH-2)
    - Port par défaut et protocole TCP
2. Architecture et composants
    
    - Client SSH
    - Serveur SSH (sshd)
    - Modèle client-serveur
    - Agents SSH
3. Cas d'usage et applications
    
    - Connexion à distance sécurisée
    - Transfert de fichiers
    - Tunneling et redirection de ports
    - Exécution de commandes à distance

---

📘 PARTIE 2 : Cryptographie et sécurité SSH Fichier Obsidian suggéré : `02-ssh-cryptographie-securite.md`

**Sujets à couvrir :**

1. Principes cryptographiques
    
    - Chiffrement symétrique
    - Chiffrement asymétrique
    - Fonctions de hachage
    - Échange de clés Diffie-Hellman
2. Mécanismes de sécurité SSH
    
    - Authentification du serveur
    - Authentification du client
    - Intégrité des données
    - Confidentialité de la communication
3. Types de clés SSH
    
    - Clés RSA
    - Clés DSA
    - Clés ECDSA
    - Clés Ed25519
    - Empreintes de clés (fingerprints)

---

📘 PARTIE 3 : Installation et configuration SSH sur Linux Fichier Obsidian suggéré : `03-ssh-linux-installation-config.md`

**Sujets à couvrir :**

1. Installation du serveur OpenSSH
    
    - Installation sur Debian/Ubuntu
    - Vérification de l'installation    
    - Démarrage et arrêt du service
    - Activation au démarrage (systemctl)
    - Vérification du statut
    - Redémarrage et rechargement de configuration
2. Configuration du serveur SSH (sshd_config)
    
    - Localisation du fichier de configuration
    - Paramètres de base (Port, ListenAddress)
    - Options d'authentification
    - Options de sécurité
    - Validation de la configuration
3. Configuration du client SSH (ssh_config)
    
    - Fichier global vs fichier utilisateur
    - Configuration par hôte
    - Paramètres de connexion
    - Options de sécurité client

---

📘 PARTIE 4 : Utilisation du client SSH sur Linux Fichier Obsidian suggéré : `04-ssh-linux-client-utilisation.md`

**Sujets à couvrir :**

1. Connexion SSH de base
    
    - Syntaxe de la commande ssh
    - Connexion avec utilisateur et hôte
    - Spécification du port
    - Première connexion et vérification de l'hôte
2. Authentification par mot de passe
    
    - Connexion interactive
    - Problèmes courants
    - Désactivation (sécurité)
3. Authentification par clés publiques
    
    - Génération de paires de clés (ssh-keygen)
    - Copie de la clé publique (ssh-copy-id)
    - Configuration manuelle du fichier authorized_keys
    - Permissions correctes des fichiers
4. Options avancées de connexion
    
    - Exécution de commandes à distance
    - Mode verbeux (-v, -vv, -vvv)
    - Compression des données
    - Keepalive et timeouts

---

📘 PARTIE 5 : Transfert de fichiers avec SSH sur Linux Fichier Obsidian suggéré : `05-ssh-linux-transfert-fichiers.md`

**Sujets à couvrir :**

1. SCP (Secure Copy)
    
    - Syntaxe de base
    - Copie de fichier local vers distant
    - Copie de fichier distant vers local
    - Copie récursive de répertoires
    - Options courantes (-P, -r, -p, -v)
2. SFTP (SSH File Transfer Protocol)
    
    - Connexion SFTP interactive
    - Commandes SFTP (get, put, ls, cd, etc.)
    - Mode batch et automatisation
    - Clients SFTP graphiques
3. Rsync over SSH
    
    - Avantages de rsync
    - Syntaxe avec SSH
    - Synchronisation de répertoires
    - Options de sauvegarde

---

📘 PARTIE 6 : Fonctionnalités avancées SSH sur Linux Fichier Obsidian suggéré : `06-ssh-linux-fonctions-avancees.md`

**Sujets à couvrir :**

1. SSH Agent et gestion des clés
    
    - Lancement de ssh-agent
    - Ajout de clés (ssh-add)
    - Forwarding de l'agent
    - Sécurité de l'agent
2. Tunneling SSH (Port Forwarding)
    
    - Tunneling local (Local Port Forwarding)
    - Tunneling distant (Remote Port Forwarding)
    - Tunneling dynamique (SOCKS proxy)
    - Use cases pratiques
3. Configuration SSH avancée
    
    - Fichier ~/.ssh/config
    - Alias d'hôtes
    - ProxyJump et ProxyCommand
    - Multiplexing de connexions (ControlMaster)
4. X11 Forwarding
    
    - Configuration du forwarding X11
    - Options -X et -Y
    - Applications graphiques distantes
    - Sécurité du X11 forwarding

---

📘 PARTIE 7 : Sécurisation avancée SSH sur Linux Fichier Obsidian suggéré : `07-ssh-linux-securisation.md`

**Sujets à couvrir :**

1. Durcissement de la configuration serveur
    
    - Désactivation de l'authentification par mot de passe
    - Désactivation de l'authentification root
    - Restriction des utilisateurs autorisés (AllowUsers, DenyUsers)
    - Limitation des groupes (AllowGroups, DenyGroups)
    - Changement du port SSH
2. Protection contre les attaques
    
    - Configuration de fail2ban
    - Limitation des tentatives de connexion
    - Timeouts de connexion
    - Restriction par IP (iptables/firewalld)
3. Authentification multifacteur (2FA)
    
    - Installation de Google Authenticator PAM
    - Configuration PAM pour SSH
    - Configuration sshd pour 2FA
    - Utilisation combinée clé + 2FA
4. Audit et logs SSH
    
    - Localisation des logs SSH
    - Analyse des logs de connexion
    - Monitoring des accès
    - Outils d'audit (lastlog, last, who)

---

📘 PARTIE 8 : SSH sur Windows - Installation et configuration Fichier Obsidian suggéré : `08-ssh-windows-installation-config.md`

**Sujets à couvrir :**

1. OpenSSH natif sur Windows 10/11 et Server
    
    - Activation d'OpenSSH Client
    - Activation d'OpenSSH Server
    - Vérification de l'installation
    - Différences avec Linux
2. Gestion du service OpenSSH sous Windows
    
    - Services Windows (services.msc)
    - Gestion via PowerShell
    - Configuration du démarrage automatique
    - Vérification du statut
3. Configuration du serveur OpenSSH Windows
    
    - Localisation des fichiers de configuration
    - Fichier sshd_config sous Windows
    - Paramètres spécifiques Windows
    - Shell par défaut (PowerShell vs cmd)
4. Pare-feu Windows et SSH
    
    - Règles de pare-feu pour SSH
    - Configuration via GUI
    - Configuration via PowerShell
    - Vérification des règles

---

📘 PARTIE 9 : Utilisation SSH sur Windows Fichier Obsidian suggéré : `09-ssh-windows-utilisation.md`

**Sujets à couvrir :**

1. Client SSH natif Windows
    
    - Utilisation depuis PowerShell
    - Utilisation depuis CMD
    - Syntaxe et options
    - Windows Terminal
2. Authentification sous Windows
    
    - Authentification par mot de passe Windows
    - Génération de clés SSH sous Windows
    - Emplacement des clés (~/.ssh sous Windows)
    - Configuration du fichier authorized_keys
3. Clients SSH tiers pour Windows
    
    - PuTTY
    - MobaXterm
    - WinSCP pour SFTP
    - Comparaison et cas d'usage
4. Connexion depuis Windows vers Linux
    
    - Configuration client
    - Gestion des clés
    - Transfert de fichiers
    - Bonnes pratiques

---

📘 PARTIE 10 : Fonctionnalités avancées SSH sur Windows Fichier Obsidian suggéré : `10-ssh-windows-avances.md`

**Sujets à couvrir :**

1. SSH Agent sous Windows
    
    - Service ssh-agent Windows
    - Gestion des clés via ssh-add
    - Persistance des clés
    - Intégration avec Git
2. Transfert de fichiers sous Windows
    
    - SCP avec OpenSSH Windows
    - SFTP natif Windows
    - Clients graphiques (WinSCP, FileZilla)
    - Automatisation avec PowerShell
3. Tunneling SSH sous Windows
    
    - Port Forwarding depuis Windows
    - Configuration des tunnels
    - Applications pratiques
    - Outils GUI pour tunneling
4. PowerShell Remoting via SSH
    
    - Configuration de PowerShell SSH Remoting
    - Connexion à des serveurs Windows distants
    - Connexion à des serveurs Linux
    - Cmdlets PowerShell pour SSH

---

📘 PARTIE 11 : Interopérabilité Linux-Windows Fichier Obsidian suggéré : `11-ssh-interoperabilite.md`

**Sujets à couvrir :**

1. Connexion Windows vers Linux
    
    - Configuration des clés croisées
    - Gestion des permissions
    - Problèmes courants de compatibilité
    - Encodage et line endings
2. Connexion Linux vers Windows
    
    - Configuration du serveur OpenSSH Windows
    - Authentification depuis Linux
    - Exécution de commandes PowerShell
    - Transfert de fichiers bidirectionnel
3. Gestion des clés multi-plateformes
    
    - Conversion de formats de clés (PuTTY/OpenSSH)
    - Utilisation des mêmes clés sur Linux et Windows
    - Outils de conversion (puttygen)
    - Bonnes pratiques
4. Scripts d'automatisation cross-platform
    
    - Automatisation des connexions SSH
    - Scripts Bash vs PowerShell
    - Transferts automatisés de fichiers
    - Monitoring et logs

---

📘 PARTIE 12 : Troubleshooting et résolution de problèmes Fichier Obsidian suggéré : `12-ssh-troubleshooting.md`

**Sujets à couvrir :**

1. Problèmes de connexion courants
    
    - Connection refused
    - Connection timeout
    - Permission denied
    - Host key verification failed
    - Too many authentication failures
2. Diagnostic et outils
    
    - Mode verbose SSH (-v, -vv, -vvv)
    - Analyse des logs serveur
    - Test de connectivité réseau (ping, telnet, nc)
    - Vérification des services et ports
3. Problèmes de permissions
    
    - Permissions des fichiers .ssh
    - Permissions de authorized_keys
    - Propriétaire des fichiers
    - SELinux et AppArmor
4. Problèmes spécifiques Windows
    
    - Problèmes de pare-feu
    - Permissions NTFS
    - Problèmes de service
    - Incompatibilités de configuration

---

📘 PARTIE 13 : Administration et bonnes pratiques Fichier Obsidian suggéré : `13-ssh-administration-bonnes-pratiques.md`

**Sujets à couvrir :**

1. Gestion des utilisateurs et accès
    
    - Création de comptes pour SSH
    - Restriction d'accès par utilisateur
    - Groupes et politiques d'accès
    - Révocation d'accès
2. Sauvegarde et restauration
    
    - Sauvegarde des clés SSH
    - Sauvegarde des configurations
    - Procédures de restauration
    - Documentation des configurations
3. Bonnes pratiques de sécurité
    
    - Politique de gestion des clés
    - Rotation des clés
    - Audit régulier des accès
    - Principe du moindre privilège
    - Séparation des environnements
4. Standards et conformité
    
    - Standards de sécurité SSH
    - Exigences de conformité (ANSSI, NIST)
    - Documentation et traçabilité
    - Revues de sécurité

---

📘 PARTIE 14 : Cas d'usage professionnels et architecture Fichier Obsidian suggéré : `14-ssh-cas-usage-architecture.md`

**Sujets à couvrir :**

1. Bastion SSH (Jump Host)
    
    - Concept et architecture
    - Configuration d'un bastion
    - ProxyJump et ProxyCommand
    - Sécurisation du bastion
2. Gestion centralisée des clés
    
    - Problématiques à grande échelle
    - Solutions de gestion de clés
    - Rotation automatisée
    - Compliance et audit
3. SSH dans les environnements DevOps
    
    - Ansible et SSH
    - Déploiement automatisé
    - CI/CD et SSH
    - Container et SSH
4. Haute disponibilité et performance
    
    - Load balancing SSH
    - Optimisation des performances
    - Multiplexing de connexions
    - Compression et bande passante