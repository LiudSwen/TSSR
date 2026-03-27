

## 📘 PARTIE 1 : Introduction et concepts fondamentaux

**Dossier Obsidian suggéré :** `01-introduction-concepts/`

**Sujets à couvrir :**

1. Présentation de nftables → `01-presentation-nftables.md`
    
    - Historique et évolution depuis iptables
    - Avantages par rapport à iptables
    - Architecture générale de nftables
    - Cas d'usage et contexte d'utilisation
2. Concepts de base du filtrage réseau → `02-concepts-filtrage.md`
    
    - Principes du pare-feu
    - Notion de paquets réseau
    - Différents types de filtrage (stateful/stateless)
    - Politiques par défaut (accept/drop)
3. Terminologie nftables → `03-terminologie.md`
    
    - Tables
    - Chaînes (chains)
    - Règles (rules)
    - Familles d'adresses (ip, ip6, inet, arp, bridge)
    - Hooks et priorités

---

## 📘 PARTIE 2 : Installation et configuration de base

**Dossier Obsidian suggéré :** `02-installation-configuration/`

**Sujets à couvrir :**

1. Installation de nftables → `01-installation.md`
    
    - Vérification de la disponibilité
    - Installation sur Debian/Ubuntu
    - Installation sur RedHat/CentOS
    - Vérification du service systemd
2. Commandes de base → `02-commandes-base.md`
    
    - Structure de la commande nft
    - Lister les règles (list)
    - Vider les règles (flush)
    - Sauvegarder et restaurer la configuration
3. Première configuration → `03-premiere-configuration.md`
    
    - Création d'une table
    - Création d'une chaîne
    - Ajout de règles simples
    - Activation au démarrage

---

## 📘 PARTIE 3 : Structure et organisation

**Dossier Obsidian suggéré :** `03-structure-organisation/`

**Sujets à couvrir :**

1. Les tables → `01-tables.md`
    
    - Concept et rôle des tables
    - Familles d'adresses (inet, ip, ip6)
    - Création et suppression de tables
    - Conventions de nommage
2. Les chaînes → `02-chaines.md`
    
    - Chaînes de base (base chains)
    - Chaînes utilisateur (regular chains)
    - Types de chaînes (filter, nat, route)
    - Hooks disponibles (prerouting, input, forward, output, postrouting)
    - Priorités des chaînes
3. Les règles → `03-regles.md`
    
    - Structure d'une règle
    - Position des règles (add, insert)
    - Gestion des handles
    - Modification et suppression de règles

---

## 📘 PARTIE 4 : Critères de filtrage

**Dossier Obsidian suggéré :** `04-criteres-filtrage/`

**Sujets à couvrir :**

1. Filtrage par adresses → `01-filtrage-adresses.md`
    
    - Adresses IP source et destination
    - Plages d'adresses (CIDR)
    - Ensembles d'adresses (sets)
2. Filtrage par ports et protocoles → `02-filtrage-ports-protocoles.md`
    
    - Protocoles (tcp, udp, icmp)
    - Ports source et destination
    - Plages de ports
    - Services communs
3. Filtrage par interfaces → `03-filtrage-interfaces.md`
    
    - Interface d'entrée (iifname)
    - Interface de sortie (oifname)
    - Cas d'usage multiples interfaces
4. Autres critères → `04-autres-criteres.md`
    
    - États de connexion (ct state)
    - Marquage de paquets (mark)
    - Limites de taux (limit)
    - Compteurs (counter)

---

## 📘 PARTIE 5 : Actions et verdicts

**Dossier Obsidian suggéré :** `05-actions-verdicts/`

**Sujets à couvrir :**

1. Verdicts de base → `01-verdicts-base.md`
    
    - accept
    - drop
    - reject (et différences avec drop)
    - Types de messages reject
2. Verdicts avancés → `02-verdicts-avances.md`
    
    - jump (saut vers chaîne utilisateur)
    - goto
    - return
    - queue
3. Actions sans verdict → `03-actions.md`
    
    - log (journalisation)
    - counter (compteur)
    - limit (limitation de débit)
    - Combinaison d'actions

---

## 📘 PARTIE 6 : Filtrage stateful et suivi de connexion

**Dossier Obsidian suggéré :** `06-filtrage-stateful/`

**Sujets à couvrir :**

1. Le suivi de connexion → `01-suivi-connexion.md`
    
    - Concept de conntrack
    - États de connexion (new, established, related, invalid)
    - Activation du suivi de connexion
2. Règles stateful → `02-regles-stateful.md`
    
    - Autoriser les connexions établies
    - Bloquer les nouvelles connexions
    - Gérer les connexions liées (FTP, etc.)

---

## 📘 PARTIE 7 : NAT (Network Address Translation)

**Dossier Obsidian suggéré :** `07-nat/`

**Sujets à couvrir :**

1. Concepts du NAT → `01-concepts-nat.md`
    
    - Principe du NAT
    - SNAT (Source NAT / Masquerading)
    - DNAT (Destination NAT / Port forwarding)
    - Cas d'usage courants
2. Configuration SNAT → `02-configuration-snat.md`
    
    - Masquerading pour partage de connexion
    - SNAT avec IP fixe
    - Chaîne postrouting
3. Configuration DNAT → `03-configuration-dnat.md`
    
    - Redirection de ports
    - Chaîne prerouting
    - Combinaison DNAT et filtrage

---

## 📘 PARTIE 8 : Sets et maps

**Dossier Obsidian suggéré :** `08-sets-maps/`

**Sujets à couvrir :**

1. Les sets (ensembles) → `01-sets.md`
    
    - Concept et utilité des sets
    - Création de sets anonymes
    - Création de sets nommés
    - Types de données dans les sets
2. Les maps (dictionnaires) → `02-maps.md`
    
    - Concept des maps
    - Maps pour le NAT dynamique
    - Maps pour le routage
    - Verdicts maps

---

## 📘 PARTIE 9 : Cas pratiques courants

**Dossier Obsidian suggéré :** `09-cas-pratiques/`

**Sujets à couvrir :**

1. Pare-feu serveur web → `01-parefeu-serveur-web.md`
    
    - Politique par défaut restrictive
    - Autorisation SSH, HTTP, HTTPS
    - Protection contre les scans
    - Journalisation des tentatives
2. Pare-feu routeur/passerelle → `02-parefeu-routeur.md`
    
    - Activation du forwarding
    - NAT sortant (masquerading)
    - Filtrage du trafic transféré
    - Redirections de ports
3. Protection contre les attaques → `03-protection-attaques.md`
    
    - Limitation de taux (rate limiting)
    - Protection contre le scan de ports
    - Protection SYN flood
    - Blacklisting d'adresses

---

## 📘 PARTIE 10 : Gestion et maintenance

**Dossier Obsidian suggéré :** `10-gestion-maintenance/`

**Sujets à couvrir :**

1. Sauvegarde et restauration → `01-sauvegarde-restauration.md`
    
    - Export de la configuration
    - Import de configuration
    - Fichiers de configuration
    - Gestion des versions
2. Débogage et journalisation → `02-debogage-journalisation.md`
    
    - Activation du log
    - Lecture des logs
    - Analyse du trafic bloqué
    - Outils de diagnostic
3. Bonnes pratiques → `03-bonnes-pratiques.md`
    
    - Organisation des règles
    - Commentaires et documentation
    - Tests avant mise en production
    - Règles de sécurité à respecter
    - Politique de moindre privilège