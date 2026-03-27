

## 📋 Table des matières

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

## Qu'est-ce que pfSense

### 🎯 Définition

pfSense est une **distribution firewall/routeur open source** basée sur FreeBSD. Il s'agit d'une solution de sécurité réseau complète qui transforme un ordinateur standard en un pare-feu et routeur professionnel.

> [!info] Origine du nom Le nom "pfSense" provient de **pf** (Packet Filter), le système de filtrage de paquets de FreeBSD, et **sense**, évoquant la détection et le contrôle intelligent du trafic réseau.

### 🏢 Qui développe pfSense ?

- **Éditeur** : Netgate (anciennement Electric Sheep Fencing)
- **Première version** : 2004 (fork de m0n0wall)
- **Type de licence** : Apache License 2.0
- **Modèle économique** : Open source avec support commercial optionnel

### 🔧 Architecture technique

pfSense repose sur plusieurs composants clés :

|Composant|Fonction|Technologie|
|---|---|---|
|**Système d'exploitation**|Base du système|FreeBSD (actuellement 15.x)|
|**Filtrage de paquets**|Firewall stateful|pf (Packet Filter)|
|**Interface web**|Administration|PHP/Bootstrap|
|**Gestion des paquets**|Extensions|pkg (FreeBSD package manager)|

> [!tip] Pourquoi FreeBSD ? FreeBSD est reconnu pour sa stabilité exceptionnelle, sa performance réseau supérieure et son système pf considéré comme l'un des meilleurs firewalls au monde.

---

## Fonctionnalités principales

### 🔥 Firewall avancé

**Filtrage stateful (avec état)**

- Inspection des connexions établies
- Suivi des états de connexion TCP/UDP/ICMP
- Protection contre les attaques de type spoofing

**Règles de filtrage granulaires**

- Filtrage par IP source/destination
- Filtrage par ports et protocoles
- Filtrage par plages horaires
- Filtrage géographique (GeoIP)
- Alias pour simplifier la gestion

> [!example] Exemple de cas d'usage Bloquer tout le trafic provenant de Chine et Russie sauf pour des serveurs spécifiques autorisés via des alias.

### 🌐 Routage et NAT

**Capacités de routage**

- Routage statique et dynamique (BGP, OSPF via packages)
- Multi-WAN (équilibrage de charge et basculement)
- Policy-Based Routing
- VLAN (802.1Q) natif

**NAT (Network Address Translation)**

- NAT sortant (Outbound NAT)
- Redirection de ports (Port Forwarding)
- NAT 1:1 (mappage IP statique)
- NAT réflexion pour accès interne

### 🔐 VPN (Virtual Private Network)

pfSense intègre plusieurs technologies VPN :

|Type VPN|Usage typique|Avantages|
|---|---|---|
|**IPsec**|Site-to-Site (interconnexion bureaux)|Standard industriel, haute sécurité|
|**OpenVPN**|Accès distant (Road Warriors)|Flexible, traverse les NAT facilement|
|**WireGuard**|Performance maximale|Très rapide, code simple et audité|
|**L2TP/IPsec**|Clients mobiles natifs|Compatible iOS/Android sans app|

> [!warning] Chiffrement pfSense supporte des algorithmes de chiffrement modernes (AES-256, ChaCha20) et permet de désactiver les protocoles obsolètes (DES, MD5).

### 📊 Services réseau intégrés

**DHCP Server & Relay**

- Serveur DHCP IPv4 et IPv6
- Réservations statiques
- Options personnalisées
- Mode relay pour serveurs DHCP externes

**DNS**

- DNS Resolver (Unbound) - recommandé
- DNS Forwarder (dnsmasq) - legacy
- DNS sur TLS (DoT) et DNS sur HTTPS (DoH)
- Filtrage DNS (blocage de domaines)

**Proxy et filtrage de contenu**

- Squid (proxy cache HTTP/HTTPS)
- SquidGuard (filtrage d'URL)
- Snort/Suricata (IDS/IPS via packages)

### 📈 Monitoring et diagnostics

**Tableaux de bord**

- Widgets personnalisables
- Graphiques en temps réel
- Vue d'ensemble du système

**Outils de diagnostic**

- Captures de paquets (tcpdump intégré)
- Ping, traceroute, DNS lookup
- ARP table, états de connexion
- Logs centralisés et exportables

**Notifications**

- Email, Slack, Telegram
- Alertes sur événements système
- Rapports programmés

> [!tip] Package RRD Graphs Le package RRDtool permet de créer des graphiques détaillés sur l'utilisation de la bande passante, CPU, mémoire sur plusieurs semaines/mois.

### 🔄 Haute disponibilité

**CARP (Common Address Redundancy Protocol)**

- Failover automatique entre firewalls
- Synchronisation des états de connexion
- Synchronisation de la configuration

**pfsync**

- Réplication des tables d'état en temps réel
- Continuité des connexions lors du basculement

---

## Cas d'usage en entreprise

### 🏪 PME (10-50 utilisateurs)

**Besoins couverts**

- Protection périmétrique (firewall Internet)
- VPN pour télétravail (OpenVPN)
- Filtrage web basique
- Gestion des accès invités (portail captif)

**Configuration typique**

- 1 interface WAN (Internet)
- 1 interface LAN (réseau interne)
- 1 interface DMZ optionnelle (serveurs publics)
- CPU 2-4 cœurs, 4-8 Go RAM

> [!example] Exemple concret Une entreprise de 30 personnes avec 10 employés en télétravail utilise pfSense pour fournir un accès VPN sécurisé, bloquer les sites malveillants et segmenter le réseau invités du réseau interne.

### 🏢 Moyennes entreprises (50-500 utilisateurs)

**Besoins couverts**

- Multi-WAN avec équilibrage de charge
- VLANs multiples (départements séparés)
- IDS/IPS (Suricata) pour détection d'intrusions
- QoS pour prioriser le trafic critique
- Redondance HA (2 pfSense en CARP)

**Configuration typique**

- 2 WAN (2 FAI différents)
- 5-10 VLANs (Comptabilité, RH, IT, Production, etc.)
- Cluster HA (2 appliances synchronisées)
- CPU 8+ cœurs, 16+ Go RAM

### 🏭 Sites distants et succursales

**Besoins couverts**

- Connexion site-to-site IPsec vers siège
- Routage automatique via VPN
- Configuration centralisée
- Faible coût par site

**Avantages**

- Déploiement sur matériel modeste
- Gestion à distance via VPN
- Standardisation de la sécurité

### 🏠 Fournisseurs de services (MSP/Hébergeurs)

**Besoins couverts**

- Isolation multi-tenant (plusieurs clients)
- Gestion centralisée de multiples instances
- Billing basé sur l'utilisation
- Automatisation via API

> [!info] Package pfSense-API Des packages comme Fauxapi permettent de gérer pfSense via REST API pour automatiser le déploiement et la configuration.

### 🎓 Institutions éducatives

**Besoins couverts**

- Filtrage de contenu strict
- Portail captif pour authentification
- Limitation de bande passante par utilisateur
- Logs détaillés pour conformité

**Configuration typique**

- FreeRADIUS pour authentification centralisée
- Squid + SquidGuard pour filtrage web
- Limiteurs de bande passante par profil

---

## Différences avec d'autres solutions

### 🆚 pfSense vs OPNsense

OPNsense est un fork de pfSense créé en 2015. Voici les différences principales :

|Critère|pfSense|OPNsense|
|---|---|---|
|**Interface**|PHP, évolution progressive|Interface moderne HardenedBSD|
|**Mises à jour**|Majeures moins fréquentes|Mises à jour plus régulières|
|**Entreprise**|Netgate (support officiel)|Deciso (support officiel)|
|**Plugins**|Packages via pkg|Plugins via interface|
|**API**|Packages tiers nécessaires|API intégrée nativement|
|**Communauté**|Plus large et ancienne|Communauté croissante|
|**Documentation**|Très complète (Netgate Docs)|Documentation correcte|

> [!tip] Quel choisir ?
> 
> - **pfSense** : Écosystème mature, communauté énorme, documentation exhaustive, support Netgate
> - **OPNsense** : Interface plus moderne, API native, mises à jour fréquentes, philosophie plus ouverte

**Points communs**

- Tous deux basés sur FreeBSD
- Fonctionnalités firewall quasi identiques
- Compatibles avec le matériel similaire
- Open source et gratuits

### 🆚 pfSense vs Routeurs commerciaux (Cisco, Fortinet, etc.)

|Critère|pfSense|Cisco ASA/Fortinet|
|---|---|---|
|**Coût**|Gratuit (ou appliance Netgate)|Très élevé (licence + support)|
|**Licence**|Open source|Propriétaire|
|**Matériel**|Tout PC x86 compatible|Appliances propriétaires|
|**Support**|Communauté + Netgate payant|Support 24/7 inclus|
|**Certifications**|Peu de formations officielles|Nombreuses certifications|
|**Enterprise features**|Via packages|Intégré et supporté|
|**Interface**|Web uniquement|Web + CLI + GUI|

**Avantages pfSense**

- ✅ Coût quasi nul pour petites structures
- ✅ Flexibilité matérielle totale
- ✅ Transparence du code
- ✅ Pas de vendor lock-in
- ✅ Communauté active et réactive

**Avantages solutions commerciales**

- ✅ Support 24/7 garanti
- ✅ Certifications reconnues
- ✅ Intégration écosystème (SD-WAN, SIEM)
- ✅ SLA contractuels
- ✅ Fonctionnalités avancées testées et validées

> [!warning] Considérations légales Certaines industries régulées (finance, santé) peuvent exiger des solutions avec support commercial et certifications spécifiques. pfSense peut être utilisé avec le support Netgate pour répondre à ces exigences.

### 🆚 pfSense vs Solutions Cloud (AWS Security Groups, Azure Firewall)

|Critère|pfSense|Firewalls Cloud natifs|
|---|---|---|
|**Localisation**|On-premise ou VM|Cloud uniquement|
|**Contrôle**|Total|Limité par le fournisseur|
|**Coût**|Fixe (matériel/VM)|À l'usage (variable)|
|**Intégration**|Configuration manuelle|Intégration native cloud|
|**Flexibilité**|Maximale|Dépend du provider|

**Quand utiliser pfSense**

- Infrastructure on-premise
- Contrôle total requis
- Multi-cloud ou hybride (interconnexion)
- Coûts prévisibles

**Quand utiliser solutions cloud**

- Infrastructure 100% cloud
- Évolutivité automatique nécessaire
- Intégration IaC (Terraform, etc.)

### 🆚 pfSense vs Solutions logicielles (iptables, nftables)

|Critère|pfSense|iptables/nftables Linux|
|---|---|---|
|**Facilité**|Interface graphique|Ligne de commande|
|**Courbe d'apprentissage**|Moyenne|Élevée|
|**Flexibilité**|Élevée via GUI|Maximale via scripting|
|**Maintenance**|Simplifiée|Expertise requise|
|**Visualisation**|Dashboards intégrés|Nécessite outils externes|

> [!tip] Complémentarité pfSense peut être utilisé en périphérie réseau tandis que iptables/nftables gèrent le filtrage au niveau des serveurs Linux individuels.

---

## 🎯 Récapitulatif

pfSense est une solution firewall/routeur professionnelle qui offre :

- **Gratuité** et transparence (open source)
- **Fonctionnalités complètes** (firewall, VPN, routage, services réseau)
- **Flexibilité matérielle** (tout PC compatible x86)
- **Interface graphique** intuitive et complète
- **Extensibilité** via packages
- **Communauté** large et active

Il convient particulièrement aux PME, sites distants, laboratoires et organisations cherchant une alternative économique et performante aux solutions commerciales tout en conservant un niveau professionnel.

> [!info] Prochaine étape L'installation et la configuration initiale de pfSense permettront de mettre en pratique ces concepts théoriques.