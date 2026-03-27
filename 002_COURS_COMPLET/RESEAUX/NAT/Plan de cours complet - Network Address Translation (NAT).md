# 

📘 **PARTIE 1 : Fondamentaux du NAT**  
Fichier Obsidian suggéré : `01-fondamentaux-nat.md`

**Sujets à couvrir :**

1. **Contexte et problématique**
    
    - Épuisement des adresses IPv4
    - Limitations de l'adressage public
    - Besoin de sécurité et d'isolation
2. **Définition et principe de base**
    
    - Qu'est-ce que le NAT
    - Rôle dans l'architecture réseau
    - Position dans le modèle OSI
3. **Adressage IP : public vs privé**
    
    - Plages d'adresses privées RFC 1918
    - Adresses publiques routables
    - Notion d'espace d'adressage

---

📘 **PARTIE 2 : Types de NAT**  
Fichier Obsidian suggéré : `02-types-nat.md`

**Sujets à couvrir :**

1. **NAT statique (Static NAT)**
    
    - Principe de fonctionnement
    - Mapping 1:1
    - Cas d'usage
2. **NAT dynamique (Dynamic NAT)**
    
    - Principe de fonctionnement
    - Pool d'adresses publiques
    - Limites et contraintes
3. **PAT/NAT overload (Port Address Translation)**
    
    - Principe de fonctionnement
    - Multiplexage par ports
    - Cas d'usage le plus courant
4. **DNAT (Destination NAT)**
    
    - Principe de fonctionnement
    - Translation de l'adresse de destination
    - Redirection de ports (Port Forwarding)
    - Cas d'usage : exposition de services internes
    - Différence avec SNAT (Source NAT)
5. **Comparaison des types**
    
    - Avantages et inconvénients
    - Choix selon le contexte
    - Tableau comparatif des différents types

---

📘 **PARTIE 3 : Fonctionnement technique du NAT**  
Fichier Obsidian suggéré : `03-fonctionnement-technique.md`

**Sujets à couvrir :**

1. **Table de translation**
    
    - Structure de la table NAT
    - Entrées et mappings
    - Durée de vie des sessions
2. **Traitement des paquets**
    
    - Flux sortant (inside to outside)
    - Flux entrant (outside to inside)
    - Modification des en-têtes IP
3. **Translation des ports**
    
    - Ports sources dynamiques
    - Ports de destination
    - Gestion des conflits
4. **États et suivi de connexion**
    
    - Connexions TCP
    - Sessions UDP
    - Protocoles ICMP

---

📘 **PARTIE 4 : Terminologie et concepts NAT**  
Fichier Obsidian suggéré : `04-terminologie-nat.md`

**Sujets à couvrir :**

1. **Interfaces NAT**
    
    - Inside local
    - Inside global
    - Outside local
    - Outside global
2. **Concepts avancés**
    
    - NAT Hairpinning
    - NAT Loopback
    - Double NAT

---

📘 **PARTIE 5 : Configuration NAT sur équipements Cisco**  
Fichier Obsidian suggéré : `05-configuration-cisco.md`

**Sujets à couvrir :**

1. **Configuration NAT statique**
    
    - Commandes de configuration
    - Définition des interfaces inside/outside
    - Vérification et dépannage
2. **Configuration NAT dynamique**
    
    - Création du pool d'adresses
    - ACL pour sélection du trafic
    - Association pool et ACL
3. **Configuration PAT**
    
    - PAT avec interface
    - PAT avec pool d'adresses
    - Overload configuration
4. **Port Forwarding (redirection de ports)**
    
    - Configuration de redirections statiques
    - Cas d'usage typiques
    - Commandes de configuration

---

📘 **PARTIE 6 : NAT et protocoles spécifiques**  
Fichier Obsidian suggéré : `06-nat-protocoles.md`

**Sujets à couvrir :**

1. **Protocoles problématiques avec NAT**
    
    - FTP et modes actif/passif
    - SIP et VoIP
    - IPsec et VPN
    - Protocoles avec IP embarquée
2. **Solutions et contournements**
    
    - ALG (Application Layer Gateway)
    - NAT Traversal
    - STUN/TURN/ICE

---

📘 **PARTIE 7 : Sécurité et NAT**  
Fichier Obsidian suggéré : `07-securite-nat.md`

**Sujets à couvrir :**

1. **Avantages sécuritaires**
    
    - Masquage de la topologie interne
    - Protection par obscurité
    - Filtrage implicite
2. **Limitations sécuritaires**
    
    - NAT n'est pas un firewall
    - Vulnérabilités potentielles
    - Nécessité de mesures complémentaires
3. **NAT et traçabilité**
    
    - Journalisation des connexions
    - Problématiques légales
    - Identification des utilisateurs

---

📘 **PARTIE 8 : Dépannage et monitoring NAT**  
Fichier Obsidian suggéré : `08-depannage-nat.md`

**Sujets à couvrir :**

1. **Commandes de vérification**
    
    - Show ip nat translations
    - Show ip nat statistics
    - Debug ip nat
2. **Problèmes courants**
    
    - Épuisement du pool d'adresses
    - Conflits de ports
    - Configuration incorrecte des ACL
    - Interfaces mal définies
3. **Méthodologie de dépannage**
    
    - Vérification de la configuration
    - Analyse du flux de paquets
    - Vérification de la table de translation
4. **Optimisation**
    
    - Timeouts et tuning
    - Gestion des ressources
    - Logs et monitoring

---

📘 **PARTIE 9 : NAT dans différents contextes**  
Fichier Obsidian suggéré : `09-nat-contextes.md`

**Sujets à couvrir :**

1. **NAT sur routeurs d'entreprise**
    
    - Architecture typique
    - Bonnes pratiques
    - Dimensionnement
2. **NAT sur pare-feu**
    
    - Intégration avec les règles de filtrage
    - NAT et zones de sécurité
3. **NAT chez les opérateurs**
    
    - CGN (Carrier-Grade NAT)
    - NAT444
    - Problématiques spécifiques
4. **NAT sur équipements Linux**
    
    - iptables/netfilter
    - nftables
    - Concepts SNAT/DNAT/MASQUERADE

---

📘 **PARTIE 10 : Alternatives et évolutions**  
Fichier Obsidian suggéré : `10-alternatives-evolutions.md`

**Sujets à couvrir :**

1. **Limitations du NAT**
    
    - Complexité des applications peer-to-peer
    - Problèmes de bout-en-bout
    - Impact sur les performances
2. **IPv6 comme solution**
    
    - Espace d'adressage suffisant
    - Fin du besoin de NAT
    - Période de transition
3. **NAT64/DNS64**
    
    - Interconnexion IPv4/IPv6
    - Principe de fonctionnement
    - Cas d'usage
4. **NPTv6 (NAT66)**
    
    - NAT en IPv6
    - Cas d'usage spécifiques
    - Controverses