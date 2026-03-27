

📘 PARTIE 1 : Fondamentaux du routage IP Fichier Obsidian suggéré : `01-fondamentaux-routage.md`

**Sujets à couvrir :**

1. Concepts de base
    
    - Définition et rôle du routage
    - Différence entre routage et commutation
    - Routeur vs commutateur de niveau 3
    - Plan de données vs plan de contrôle
2. Adressage IP et sous-réseaux
    
    - Classes d'adresses IPv4
    - Masques de sous-réseau (CIDR)
    - Calcul de réseau, broadcast, plage d'hôtes
    - Supernetting et agrégation
3. Table de routage
    
    - Structure d'une table de routage
    - Types d'entrées (connecté, statique, dynamique)
    - Préfixe le plus long (Longest Prefix Match)
    - Route par défaut (gateway of last resort)
4. Processus de routage
    
    - Décision de routage paquet par paquet
    - Recherche dans la table de routage
    - Décrémentation du TTL
    - Fragmentation IP

---

📘 PARTIE 2 : Routage statique Fichier Obsidian suggéré : `02-routage-statique.md`

**Sujets à couvrir :**

1. Principes du routage statique
    
    - Définition et fonctionnement
    - Avantages et inconvénients
    - Cas d'usage appropriés
    - Charge administrative
2. Configuration des routes statiques
    
    - Syntaxe de base
    - Route vers un réseau distant
    - Route par défaut statique
    - Route avec next-hop vs interface de sortie
    - Routes statiques flottantes
3. Routes spéciales
    
    - Route nulle (null route)
    - Route récapitulative
    - Routes d'hôte (/32)

---

📘 PARTIE 3 : Protocoles de routage dynamique - Concepts généraux Fichier Obsidian suggéré : `03-protocoles-dynamiques-concepts.md`

**Sujets à couvrir :**

1. Introduction aux protocoles dynamiques
    
    - Nécessité du routage dynamique
    - Avantages et inconvénients
    - Convergence du réseau
    - Scalabilité
2. Classification des protocoles
    
    - IGP vs EGP
    - Distance Vector vs Link State vs Path Vector
    - Classful vs Classless
    - Protocoles à plat vs hiérarchiques
3. Métriques de routage
    
    - Hop count
    - Bande passante
    - Délai
    - Fiabilité
    - Charge
    - Coût composite
4. Distance administrative
    
    - Définition et rôle
    - Valeurs par défaut des protocoles
    - Modification de la distance administrative
    - Ordre de préférence

---

📘 PARTIE 4 : RIP (Routing Information Protocol) Fichier Obsidian suggéré : `04-protocole-rip.md`

**Sujets à couvrir :**

1. Présentation de RIP
    
    - Historique (RIPv1, RIPv2)
    - Caractéristiques principales
    - Limitations (15 hops maximum)
    - Temporisateurs RIP
2. Fonctionnement de RIP
    
    - Algorithme Bellman-Ford
    - Échange de tables de routage complètes
    - Mises à jour périodiques (30 secondes)
    - Mécanismes anti-boucles (split horizon, route poisoning, hold-down)
3. Configuration RIPv2
    
    - Activation du protocole
    - Annonce des réseaux
    - Configuration des interfaces passives
    - Résumé automatique et manuel
    - Authentication
4. Différences RIPv1 vs RIPv2
    
    - Support du VLSM
    - Multicasting vs Broadcasting
    - Authentication

---

📘 PARTIE 5 : OSPF (Open Shortest Path First) Fichier Obsidian suggéré : `05-protocole-ospf.md`

**Sujets à couvrir :**

1. Présentation d'OSPF
    
    - Protocole à état de liens
    - Standards (RFC 2328 pour OSPFv2)
    - Avantages par rapport à RIP
    - Convergence rapide
2. Architecture hiérarchique OSPF
    
    - Concept de zones (Areas)
    - Zone backbone (Area 0)
    - Types de zones (standard, stub, totally stub, NSSA)
    - Types de routeurs (IR, ABR, ASBR, BR)
3. Fonctionnement d'OSPF
    
    - Algorithme de Dijkstra (SPF)
    - Base de données d'état de liens (LSDB)
    - Types de paquets OSPF (Hello, DBD, LSR, LSU, LSAck)
    - Types de LSA (1 à 7)
    - Processus d'adjacence
4. Métrique OSPF
    
    - Calcul du coût (référence / bande passante)
    - Modification du coût
    - Référence de bande passante
5. Configuration OSPF
    
    - Activation du processus OSPF
    - Annonce des réseaux avec wildcards
    - Router ID
    - Interfaces passives
    - Priorité et élection DR/BDR
    - Types de réseaux (broadcast, point-to-point, NBMA)
    - Résumé inter-zones
    - Route par défaut dans OSPF
    - Authentication

---

📘 PARTIE 6 : EIGRP (Enhanced Interior Gateway Routing Protocol) Fichier Obsidian suggéré : `06-protocole-eigrp.md`

**Sujets à couvrir :**

1. Présentation d'EIGRP
    
    - Protocole hybride Cisco
    - Caractéristiques avancées
    - DUAL (Diffusing Update Algorithm)
    - Convergence rapide
2. Fonctionnement d'EIGRP
    
    - Tables EIGRP (voisins, topologie, routage)
    - Successor et Feasible Successor
    - Condition de faisabilité (Feasibility Condition)
    - Requêtes et réponses
3. Métrique composite EIGRP
    
    - Calcul de la métrique (K-values)
    - Bande passante et délai
    - Fiabilité et charge (optionnel)
    - Métrique classique vs wide metrics
4. Configuration EIGRP
    
    - Activation du processus EIGRP
    - Numéro de système autonome (AS)
    - Annonce des réseaux
    - Interfaces passives
    - Router ID
    - Résumé manuel
    - Load balancing (equal-cost et unequal-cost)
    - Authentication

---

📘 PARTIE 7 : BGP (Border Gateway Protocol) Fichier Obsidian suggéré : `07-protocole-bgp.md`

**Sujets à couvrir :**

1. Présentation de BGP
    
    - Protocole de routage externe (EGP)
    - Path Vector Protocol
    - Routage sur Internet
    - BGP-4 (RFC 4271)
2. Concepts BGP
    
    - Système autonome (AS)
    - Numéros AS publics et privés
    - eBGP vs iBGP
    - Sessions BGP (peering)
3. Fonctionnement de BGP
    
    - Établissement de session TCP (port 179)
    - Types de messages BGP (Open, Update, Keepalive, Notification)
    - Attributs de chemins (AS_PATH, NEXT_HOP, LOCAL_PREF, MED, etc.)
    - Processus de sélection du meilleur chemin
4. Configuration de base BGP
    
    - Activation du processus BGP
    - Configuration des voisins (neighbors)
    - Annonce des réseaux
    - Next-hop-self pour iBGP
    - Agrégation de routes

---

📘 PARTIE 8 : Redistribution de routes Fichier Obsidian suggéré : `08-redistribution-routes.md`

**Sujets à couvrir :**

1. Concepts de redistribution
    
    - Définition et nécessité
    - Points de redistribution
    - Risques (boucles de routage, sous-optimalité)
2. Mécanismes de redistribution
    
    - Redistribution unidirectionnelle vs bidirectionnelle
    - Seed metric
    - Adaptation des métriques entre protocoles
    - Filtrage lors de la redistribution
3. Configuration de la redistribution
    
    - Redistribution entre protocoles dynamiques
    - Redistribution de routes statiques
    - Redistribution de routes connectées
    - Route maps pour contrôler la redistribution
    - Modification de la distance administrative
4. Bonnes pratiques
    
    - Éviter les boucles de routage
    - Utilisation de route tags
    - Filtrage avec ACL et prefix-lists
    - Points uniques de redistribution

---

📘 PARTIE 9 : Filtrage et contrôle du routage Fichier Obsidian suggéré : `09-filtrage-controle.md`

**Sujets à couvrir :**

1. Listes de distribution (Distribute lists)
    
    - Filtrage des mises à jour de routage
    - Application en entrée et sortie
    - Utilisation d'ACL standard et étendue
2. Prefix lists
    
    - Syntaxe et fonctionnement
    - Correspondance de préfixes avec longueur
    - Opérateurs ge et le
    - Avantages sur les ACL
3. Route maps
    
    - Structure (sequence, permit/deny)
    - Clauses match et set
    - Applications multiples
    - Policy-based routing (PBR)
4. Résumé et agrégation
    
    - Résumé automatique vs manuel
    - Suppression de routes spécifiques
    - Résumé inter-zones (OSPF)
    - Super-routes

---

📘 PARTIE 10 : Routage IPv6 Fichier Obsidian suggéré : `10-routage-ipv6.md`

**Sujets à couvrir :**

1. Fondamentaux IPv6
    
    - Format d'adresse IPv6
    - Types d'adresses (unicast, multicast, anycast)
    - Adresses link-local, global unicast, unique local
    - SLAAC et DHCPv6
2. Routage statique IPv6
    
    - Configuration de routes statiques IPv6
    - Route par défaut IPv6 (::/0)
    - Next-hop link-local
3. Protocoles de routage IPv6
    
    - RIPng (RIP next generation)
    - OSPFv3
    - EIGRP pour IPv6
    - MP-BGP (Multiprotocol BGP)
4. Configuration des protocoles IPv6
    
    - Activation du routage IPv6
    - Configuration RIPng
    - Configuration OSPFv3 (sur les interfaces)
    - Configuration EIGRP IPv6

---

📘 PARTIE 11 : Optimisation et dépannage du routage Fichier Obsidian suggéré : `11-optimisation-depannage.md`

**Sujets à couvrir :**

1. Optimisation des performances
    
    - Tuning des temporisateurs
    - Summarization stratégique
    - Filtrage des mises à jour inutiles
    - Load balancing (ECMP)
    - Unequal-cost load balancing (EIGRP)
2. Haute disponibilité
    
    - Protocoles de redondance (HSRP, VRRP, GLBP)
    - Fast convergence
    - BFD (Bidirectional Forwarding Detection)
    - Route tracking
3. Méthodologie de dépannage
    
    - Approche structurée (layered approach)
    - Vérification de la connectivité (ping, traceroute)
    - Analyse de la table de routage
    - Vérification des adjacences
4. Commandes de diagnostic
    
    - show ip route
    - show ip protocols
    - show ip ospf neighbor / database
    - show ip eigrp neighbors / topology
    - show ip bgp summary
    - debug (avec précautions)
    - Logs et messages d'erreur
5. Problèmes courants
    
    - Routes manquantes
    - Boucles de routage
    - Black holes
    - Flapping d'adjacence
    - Problèmes de métrique
    - Asymétrie de routage

---

📘 PARTIE 12 : Sécurité du routage Fichier Obsidian suggéré : `12-securite-routage.md`

**Sujets à couvrir :**

1. Menaces sur le routage
    
    - Injection de routes malveillantes
    - Déni de service sur les protocoles de routage
    - Usurpation d'identité de routeur
    - Man-in-the-middle
2. Mécanismes d'authentification
    
    - Authentication MD5 (RIP, OSPF, EIGRP)
    - Authentication BGP (TCP MD5)
    - Clés et key chains
    - Rotation des clés
3. Bonnes pratiques de sécurisation
    
    - Filtrage des mises à jour de routage
    - Limitation des voisinages (passive interfaces)
    - TTL Security (GTSM)
    - Prefix filtering strict
    - Isolation du plan de contrôle (CoPP)
4. Sécurité BGP
    
    - Filtrage des préfixes privés
    - Bogon filtering
    - AS path filtering
    - Limitation du nombre de préfixes (maximum-prefix)
    - RPKI (Resource Public Key Infrastructure) - concepts

---

📘 PARTIE 13 : VRF et routage avancé Fichier Obsidian suggéré : `13-vrf-routage-avance.md`

**Sujets à couvrir :**

1. VRF (Virtual Routing and Forwarding)
    
    - Concept de virtualisation du routage
    - Tables de routage multiples
    - Isolation du trafic
    - VRF-Lite vs MPLS VPN
2. Configuration VRF
    
    - Création de VRF
    - Association d'interfaces à une VRF
    - Configuration de protocoles de routage par VRF
    - Route leaking entre VRF
3. Policy-Based Routing (PBR)
    
    - Routage basé sur des politiques
    - Route maps pour PBR
    - Cas d'usage (QoS, load balancing, traffic engineering)
4. Concepts avancés
    
    - MPLS (Multiprotocol Label Switching) - introduction
    - Traffic engineering
    - Routage multicast - concepts de base