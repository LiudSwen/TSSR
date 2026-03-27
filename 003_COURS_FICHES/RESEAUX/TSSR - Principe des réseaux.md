## ⚡ L'essentiel en 5 minutes - Principes des réseaux

### 📌 C'est quoi en 2 lignes ?
Les réseaux découpent l'information en **datagrammes** acheminés via des **protocoles en couches** (OSI/TCP-IP). Chaque équipement (switch, routeur, firewall) opère sur une couche spécifique pour acheminer les données de bout en bout.

---

### 💡 Concepts clés à retenir :

* **Datagramme** : Morceau d'information acheminé séparément pour optimiser le réseau
* **Protocole** : Norme définissant format des messages, langage et scénario de communication
* **Encapsulation** : PDU couche N+1 devient payload couche N (en-tête + données)
* **PDU (Protocol Data Unit)** : En-tête protocolaire + charge utile (payload/SDU)
* **Modèle en couches** : Découpage du problème réseau en sous-problèmes indépendants
* **OSI** : Modèle théorique 7 couches servant de grille d'analyse (norme ISO 7498)
* **TCP/IP** : Modèle pratique 4 couches utilisé sur Internet (adoption 1983)
* **Port** : Numéro identifiant une application/service (porte d'entrée du service)
* **Topologie** : Architecture physique/logique définissant liaisons entre équipements

---

### 💻 Commandes essentielles :

```bash
# 🌐 Ports standards à connaître
HTTP    → TCP 80        # Web (Hypertext Transfer Protocol)
HTTPS   → TCP 443       # Web sécurisé
FTP     → TCP 21        # Transfert de fichiers
DNS     → UDP 53        # Résolution de noms
SSH     → TCP 22        # Administration distante sécurisée
SMTP    → TCP 25        # Envoi email
```

---

### 📐 Modèle OSI (7 couches) vs TCP/IP (4 couches) :

**OSI (Open Systems Interconnection)**
```
7. Application    → PDU: Données        | HTTP, FTP, DNS
6. Présentation   → PDU: Données        | Syntaxe/format (ex: chiffrement)
5. Session        → PDU: Données        | Ouverture/fermeture dialogue
4. Transport      → PDU: Segment/Dgram  | TCP (fiable), UDP (rapide)
3. Réseau         → PDU: Paquet         | IP, routage
2. Liaison        → PDU: Trame          | Ethernet, WiFi, adresse MAC
1. Physique       → PDU: Bit            | Câbles, signaux électriques
```

**↓ ÉMISSION (du haut vers le bas) :**

1. **Couche 7 (Application)** : Crée les données (email)
2. **Couche 6 (Présentation)** : Encode/chiffre les données
3. **Couche 5 (Session)** : Ouvre une session de communication
4. **Couche 4 (Transport)** : Découpe en segments + ajoute port TCP/UDP
5. **Couche 3 (Réseau)** : Ajoute adresses IP source/destination → **Paquet**
6. **Couche 2 (Liaison)** : Ajoute adresses MAC + contrôle erreurs → **Trame**
7. **Couche 1 (Physique)** : Convertit en signaux électriques → **Bits**

**↑ RÉCEPTION (du bas vers le haut) :**

- Le destinataire **désencapsule** : chaque couche retire son entête et passe à la couche supérieure jusqu'à récupérer les données originales
  
  
**TCP/IP (modèle pratique)**
```
4. Application    → Équivalent OSI 5-6-7
3. Transport      → TCP/UDP
2. Internet       → IP (routage)
1. Accès réseau   → Équivalent OSI 1-2
```

**Exemple d'encapsulation :**
```
Données App → [TCP Header | Données] = Segment
            → [IP Header | Segment] = Paquet
            → [Eth Header | Paquet | Eth Trailer] = Trame
            → Bits sur le câble
```

---

### ⚠️ Pièges à éviter :

* ❌ **Confondre port et protocole** : Le port est le numéro (ex: 80), le protocole est la méthode de communication (ex: HTTP)
* ❌ **Oublier l'encapsulation** : Chaque couche ajoute son en-tête, le PDU grossit en descendant les couches
* ❌ **Croire que OSI = TCP/IP** : OSI est théorique (7 couches), TCP/IP est pratique (4 couches, utilisé sur Internet)
* ❌ **Confondre topologie physique et logique** : Physique = câblage réel, Logique = flux de données
* ❌ **Mélanger les équipements et leurs couches** : Un hub (L1) diffuse tout, un switch (L2) filtre par MAC, un routeur (L3) route par IP

---

### ✅ Bonnes pratiques :

* ✅ **Toujours penser en couches** : Identifier à quelle couche OSI/TCP-IP appartient un problème pour mieux le résoudre
* ✅ **Connaître les organismes de standardisation** : IETF (RFC pour TCP/IP), IEEE (802.x pour Ethernet/WiFi), ITU
* ✅ **Mémoriser les équipements par couche** : Facilite le diagnostic réseau (ex: problème MAC → switch L2, problème IP → routeur L3)
* ✅ **Distinguer commutation de circuit vs routage** : Circuit = canal dédié (qualité garantie), Routage = chemins multiples (résilience)

---

### 📚 Vocabulaire technique :

| Terme | Définition courte |
|-------|------------------|
| **SDU (Service Data Unit)** | Charge utile / payload transmis entre couches |
| **Hub** | Équipement passif L1 qui recopie tout sur tous les ports |
| **Switch** | Équipement actif L2 qui filtre par adresse MAC (full/half duplex) |
| **Routeur** | Équipement actif L3 qui route les paquets entre réseaux via table de routage |
| **Switch L2/L3** | Switch avec fonction de routage inter-VLAN |
| **Firewall** | Équipement L3-7 filtrant communications selon règles de sécurité |
| **VLAN** | Réseau logique séparant le trafic sur un switch L2 |
| **MAC (Media Access Control)** | Adresse physique unique couche 2 (ex: 00:1A:2B:3C:4D:5E) |
| **LAN/MAN/WAN** | Local/Metropolitan/Wide Area Network (échelle réseau) |
| **RFC (Request For Comments)** | Documents de standardisation IETF (ex: RFC 791 pour IP) |
| **Pont (Bridge)** | Équipement L2 reliant réseaux physiques différents |
| **Passerelle (Gateway)** | Point d'entrée vers un autre réseau (L3-7) |
| **Backbone (Core)** | Cœur de réseau très haut débit |
| **Edge** | Périphérie du réseau (frontière interne/externe) |
| **Half/Full Duplex** | Communication unidirectionnelle/bidirectionnelle simultanée |

---

### 🎯 À retenir ABSOLUMENT (3 points max) :

1. 💡 **Théorique** : Encapsulation = chaque couche ajoute son en-tête au PDU de la couche supérieure (Données → Segment → Paquet → Trame → Bits)

2. 💻 **Pratique** : Switch L2 filtre par MAC, Routeur L3 route par IP, Firewall L3-7 filtre selon règles de sécurité

3. ⚠️ **Piège** : Ne JAMAIS confondre modèle OSI (7 couches théoriques) et TCP/IP (4 couches pratiques utilisées sur Internet depuis 1983)
