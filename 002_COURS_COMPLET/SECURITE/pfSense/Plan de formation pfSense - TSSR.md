

## 📘 PARTIE 1 : Introduction et installation

**Dossier Obsidian suggéré :** `01-introduction-installation/`

**Sujets à couvrir :**

1. Présentation de pfSense → `01-presentation-pfsense.md`
    
    - Qu'est-ce que pfSense
    - Fonctionnalités principales
    - Cas d'usage en entreprise
    - Différences avec d'autres solutions (OPNsense, routeurs commerciaux)
2. Prérequis et préparation → `02-prerequis-preparation.md`
    
    - Configuration matérielle minimale et recommandée
    - Architectures réseau supportées
    - Téléchargement de l'ISO
    - Création du support d'installation
3. Installation de pfSense → `03-installation.md`
    
    - Démarrage sur le support d'installation
    - Assistant d'installation
    - Configuration du partitionnement
    - Première configuration console (interfaces WAN/LAN)
4. Premier accès à l'interface web → `04-premier-acces-web.md`
    
    - Connexion à l'interface WebGUI
    - Assistant de configuration initial
    - Modification du mot de passe admin
    - Configuration du fuseau horaire et nom d'hôte

---

## 📘 PARTIE 2 : Configuration réseau de base

**Dossier Obsidian suggéré :** `02-configuration-reseau/`

**Sujets à couvrir :**

1. Configuration des interfaces → `01-configuration-interfaces.md`
    
    - Types d'interfaces (WAN, LAN, OPT)
    - Attribution des interfaces réseau
    - Configuration IP statique vs DHCP
    - VLANs sur les interfaces
2. Configuration du service DHCP → `02-service-dhcp.md`
    
    - Activation du serveur DHCP
    - Plages d'adresses IP
    - Baux statiques (DHCP static mappings)
    - Options DHCP avancées
3. Gestion DNS → `03-gestion-dns.md`
    
    - DNS Resolver vs DNS Forwarder
    - Configuration du DNS Resolver (Unbound)
    - Serveurs DNS externes
    - Surcharges d'hôtes (host overrides)
4. Passerelle et routage → `04-passerelle-routage.md`
    
    - Configuration des passerelles
    - Routes statiques
    - Groupes de passerelles
    - Monitoring des passerelles

---

## 📘 PARTIE 3 : Pare-feu et règles de filtrage

**Dossier Obsidian suggéré :** `03-pare-feu-filtrage/`

**Sujets à couvrir :**

1. Principes du pare-feu pfSense → `01-principes-pare-feu.md`
    
    - Fonctionnement du pare-feu stateful
    - Ordre d'évaluation des règles
    - Actions (Pass, Block, Reject)
    - États des connexions
2. Création de règles de pare-feu → `02-creation-regles.md`
    
    - Interface de création de règles
    - Source et destination
    - Protocoles et ports
    - Options avancées (logging, scheduling)
3. Alias et objets réseau → `03-alias-objets.md`
    
    - Types d'alias (IP, ports, URLs)
    - Création et gestion des alias
    - Utilisation dans les règles
    - Importation de listes
4. NAT (Network Address Translation) → `04-nat.md`
    
    - NAT sortant (Outbound NAT)
    - Redirection de ports (Port Forward)
    - NAT 1:1
    - NPt (IPv6)

---

## 📘 PARTIE 4 : Services réseau essentiels

**Dossier Obsidian suggéré :** `04-services-reseau/`

**Sujets à couvrir :**

1. Proxy web et filtrage de contenu → `01-proxy-filtrage.md`
    
    - Squid Proxy
    - Configuration du proxy transparent
    - Squidguard pour le filtrage
    - Listes noires et catégories
2. Service VPN - OpenVPN → `02-openvpn.md`
    
    - Présentation d'OpenVPN
    - Configuration du serveur OpenVPN
    - Création des certificats clients
    - Export de la configuration client
3. Service VPN - IPsec → `03-ipsec.md`
    
    - Présentation d'IPsec
    - Tunnel site-to-site
    - Configuration Phase 1 et Phase 2
    - Dépannage des tunnels IPsec
4. Service VPN - WireGuard → `04-wireguard.md`
    
    - Présentation de WireGuard
    - Configuration du tunnel
    - Gestion des peers
    - Avantages vs OpenVPN/IPsec

---

## 📘 PARTIE 5 : Haute disponibilité et redondance

**Dossier Obsidian suggéré :** `05-haute-disponibilite/`

**Sujets à couvrir :**

1. CARP (Common Address Redundancy Protocol) → `01-carp.md`
    
    - Principe de la haute disponibilité
    - Configuration du CARP
    - IP virtuelles
    - Basculement automatique
2. Configuration du cluster HA → `02-cluster-ha.md`
    
    - Préparation des deux nœuds
    - Synchronisation de configuration (xmlrpc)
    - Interface de synchronisation
    - Tests de basculement
3. Multi-WAN et équilibrage de charge → `03-multi-wan.md`
    
    - Configuration de plusieurs WAN
    - Groupes de passerelles (failover, load balancing)
    - Règles de routage par politique
    - Monitoring et bascule

---

## 📘 PARTIE 6 : Sécurité avancée

**Dossier Obsidian suggéré :** `06-securite-avancee/`

**Sujets à couvrir :**

1. IDS/IPS avec Snort ou Suricata → `01-ids-ips.md`
    
    - Différences Snort vs Suricata
    - Installation et activation
    - Règles et signatures
    - Gestion des alertes
2. Filtrage de paquets avancé → `02-filtrage-avance.md`
    
    - Traffic Shaper (limitation de bande passante)
    - Limiteur de trafic
    - Priorisation QoS
    - Politiques par utilisateur/application
3. Pfblocker-NG → `03-pfblocker.md`
    
    - Installation du package
    - Blocage géographique (GeoIP)
    - Listes DNSBL
    - Listes IP malveillantes
4. Certificats et authentification → `04-certificats-auth.md`
    
    - Autorité de certification interne
    - Gestion des certificats
    - Authentification RADIUS
    - Portail captif

---

## 📘 PARTIE 7 : Monitoring et maintenance

**Dossier Obsidian suggéré :** `07-monitoring-maintenance/`

**Sujets à couvrir :**

1. Tableau de bord et monitoring → `01-dashboard-monitoring.md`
    
    - Widgets du tableau de bord
    - Surveillance de l'état système
    - Graphiques de trafic
    - États des services
2. Journaux et diagnostics → `02-logs-diagnostics.md`
    
    - Types de logs (système, pare-feu, DHCP)
    - Filtrage et recherche dans les logs
    - Outils de diagnostic réseau
    - Captures de paquets
3. Sauvegardes et restauration → `03-sauvegardes.md`
    
    - Sauvegarde de la configuration XML
    - Sauvegarde automatique
    - Restauration de configuration
    - Réinitialisation d'usine
4. Mises à jour et gestion des packages → `04-mises-a-jour.md`
    
    - Vérification des mises à jour
    - Installation des mises à jour système
    - Gestion des packages additionnels
    - Retour arrière et snapshots

---

## 📘 PARTIE 8 : Cas pratiques et scénarios

**Dossier Obsidian suggéré :** `08-cas-pratiques/`

**Sujets à couvrir :**

1. Scénario PME simple → `01-scenario-pme.md`
    
    - Architecture réseau typique
    - Configuration WAN/LAN
    - Règles de pare-feu de base
    - Services essentiels (DHCP, DNS)
2. Scénario avec segmentation réseau → `02-scenario-segmentation.md`
    
    - Séparation des réseaux (VLAN)
    - Règles inter-VLAN
    - Réseau invité isolé
    - DMZ pour serveurs
3. Scénario télétravail → `03-scenario-teletravail.md`
    
    - Mise en place VPN distant
    - Accès sécurisé aux ressources
    - Authentification des utilisateurs
    - Split tunneling
4. Dépannage courant → `04-depannage.md`
    
    - Problèmes de connectivité WAN
    - Règles de pare-feu inefficaces
    - Problèmes de performance
    - Méthodologie de diagnostic