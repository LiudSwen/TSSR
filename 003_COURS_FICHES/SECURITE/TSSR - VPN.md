## ⚡ L'essentiel en 5 minutes - VPN (Réseaux Privés Virtuels)

### 📌 C'est quoi en 2 lignes ?

Un VPN simule un réseau privé sécurisé en passant par des réseaux publics (Internet) via un tunnel chiffré. Il permet de connecter des sites distants, des utilisateurs nomades ou des machines spécifiques comme s'ils étaient sur le même réseau local.

---

### 💡 Concepts clés à retenir :

- **Tunnel** : Passage sécurisé à travers un réseau, basé sur l'encapsulation de protocoles (PDU traité comme donnée)
- **VPN niveau 2** : Transporte des **trames Ethernet** (mode pont/bridge) - exemple : tap dans OpenVPN
- **VPN niveau 3** : Transporte des **paquets IP** (mode routeur) - exemple : tun dans OpenVPN, IPsec
- **Types de VPN** : Site-à-site (gateway↔gateway), Accès distant (client↔gateway), Point-à-point (host↔host)
- **Transparent** : L'utilisateur travaille comme s'il était physiquement sur le réseau local (pas d'action manuelle)

---

### 🌐 Protocoles VPN essentiels :

#### **IPsec (niveau 3 - dans IP)** :

```bash
# 🔐 Composants IPsec
IKEv2               # Négociation tunnel (UDP 500, ou 4500 si NAT)
AH                  # Authentification + intégrité (protocole IP 51)
ESP                 # Confidentialité + auth + intégrité (protocole IP 50)

# Modes IPsec
Mode Transport      # Protège couche 4 (TCP/UDP) - hôte à hôte
Mode Tunnel         # Protège paquet IP entier - gateway à gateway
```

#### **TLS (niveau 5-6 - au-dessus de TCP/UDP)** :

```bash
# 🔒 Versions TLS
SSL 1.0/2.0/3.0     # ❌ DEPRECATED
TLS 1.0/1.1         # ❌ DEPRECATED
TLS 1.2             # ✅ Acceptable (compatibilité)
TLS 1.3             # ✅ RECOMMANDÉ
DTLS 1.3            # TLS sur UDP

# Utilisations courantes
HTTPS (TCP 443)     # HTTP over TLS
FTPS (TCP 989/990)  # FTP over TLS
SMTPS (TCP 465/587) # SMTP over TLS
DoT (TCP/UDP 853)   # DNS over TLS
```

#### **OpenVPN (basé sur TLS)** :

```bash
# 🔧 Configuration OpenVPN
Port standard       # UDP/TCP 1194
Mode tun            # VPN niveau 3 (routeur, paquets IP)
Mode tap            # VPN niveau 2 (pont, trames Ethernet)

# Authentification
Certificats X.509   # Configuration standard (PKI interne)
PSK                 # Pre-Shared Key (simple, moins sécurisé)
Login/password      # Possible mais déconseillé

# Outils PKI
easy-rsa            # Simplifier création CA + certificats
openssl             # Gestion certificats manuelle
```

---

### 📐 Protocoles et ports :

|Protocole|Port/Protocole IP|Usage|
|---|---|---|
|**IKEv2**|UDP 500 (ou 4500 NAT)|Négociation IPsec|
|**AH**|IP protocole 51|Auth + intégrité IPsec|
|**ESP**|IP protocole 50|Confidentialité IPsec|
|**OpenVPN**|UDP/TCP 1194|Tunnel TLS|
|**HTTPS**|TCP 443|HTTP sécurisé|

---

### ⚠️ Pièges à éviter :

- ❌ **Tunnel ≠ VPN sécurisé** : GRE, L2TP, SSH tunnels ne sont PAS des VPN chiffrés par défaut
- ❌ **Utiliser SSL/TLS 1.0/1.1** : Dépréciés pour failles de sécurité (RFC 8996)
- ❌ **AH seul sans ESP** : Pas de confidentialité, données en clair (juste authentifiées)
- ❌ **Mode transport IPsec pour VPN** : Ne protège pas l'entête IP, préférer mode tunnel
- ❌ **NAT sans traversal** : IKE échoue, nécessite port UDP 4500 pour NAT-T
- ❌ **Clé privée CA en ligne** : Compromission = tout le VPN est foutu, stocker hors ligne
- ❌ **Pas de révocation** : Certificat volé = accès permanent, prévoir CRL ou OCSP

---

### ✅ Bonnes pratiques :

- ✅ **TLS 1.3 minimum** : Sécurité maximale, PFS (Perfect Forward Secrecy) par défaut
- ✅ **PKI interne pour VPN entreprise** : Éviter CA publiques (coût, contrôle), créer sa propre CA
- ✅ **Mode tunnel IPsec** : Protège entièrement le paquet IP original (adresses sources/dest)
- ✅ **ESP plutôt que AH** : Fournit confidentialité + authentification + intégrité
- ✅ **Authentification mutuelle** : Client authentifie serveur ET serveur authentifie client
- ✅ **Bastion/Jump server** : Point d'accès unique pour administration, réduit surface d'attaque
- ✅ **Révocation prévue** : Déployer CRL (manuel) ou OCSP (automatique) dès la PKI
- ✅ **Surveillance accrue** : VPN = brèche entre réseaux, logs et monitoring essentiels

---

### 📚 Vocabulaire technique :

|Terme|Définition courte|
|---|---|
|**PDU**|Protocol Data Unit - donnée d'un protocole (trame/paquet/segment)|
|**Encapsulation**|Traiter un PDU comme donnée dans un autre PDU (ex: IP dans ESP dans IP)|
|**SA (Security Association)**|Ensemble des paramètres crypto négociés pour une connexion IPsec|
|**SPI**|Security Parameter Index - identifiant de la SA (dans entêtes AH/ESP)|
|**ICV**|Integrity Check Value - hash d'authentification (type HMAC)|
|**PSK**|Pre-Shared Key - clé secrète partagée manuellement|
|**PKI**|Public Key Infrastructure - système de gestion des certificats (CA, CRL)|
|**CSR**|Certificate Signing Request - demande de signature de certificat|
|**CRL**|Certificate Revocation List - liste des certificats révoqués (manuel)|
|**OCSP**|Online Certificate Status Protocol - vérification validité certif (auto)|
|**PFS**|Perfect Forward Secrecy - compromission clé ≠ déchiffrement passé|
|**Handshake**|Poignée de main - phase de négociation/authentification TLS|
|**Bastion**|Serveur point d'accès unique et sécurisé pour administration|
|**Jump server**|Serveur intermédiaire pour rebondir vers ressources internes|

---

### 🎯 À retenir ABSOLUMENT :

1. 💡 **Théorique** : VPN niveau 3 (IP) = IPsec ou OpenVPN/tun, niveau 2 (Ethernet) = OpenVPN/tap ou L2TP
2. 💻 **Pratique** : IPsec = IKEv2 (négo UDP 500) + ESP (IP proto 50) en mode tunnel / OpenVPN = TLS 1.3 + certificats X.509
3. ⚠️ **Piège** : VPN ouvre une brèche réseau → authentification robuste obligatoire + surveillance + éventuellement segmentation réseau

---

### 🔧 Processus de mise en place (OpenVPN) :

```bash
# 1️⃣ Créer PKI (sur machine hors ligne de préférence)
easy-rsa init-pki
easy-rsa build-ca              # Certificat + clé privée CA

# 2️⃣ Pour chaque serveur/client
easy-rsa gen-req server1       # Génère CSR
easy-rsa sign-req server server1  # Signe CSR → certificat

# 3️⃣ Déployer
# Serveur : certificat serveur + clé privée serveur + certificat CA
# Client  : certificat client + clé privée client + certificat CA

# 4️⃣ Révocation si compromission
easy-rsa revoke client1        # Révoquer certificat
easy-rsa gen-crl               # Générer CRL
# → Déployer CRL sur serveur OpenVPN
```

---

### 📊 Schéma décisionnel :

```
Besoin d'interconnecter réseaux ?
│
├─ OUI, en permanence (filiales) 
│  → VPN site-à-site (mode tunnel IPsec ou OpenVPN)
│
├─ OUI, utilisateurs nomades
│  → VPN accès distant (OpenVPN client, IKEv2)
│
└─ OUI, administration sécurisée
   → Bastion (Guacamole, Azure Bastion) ou Jump server (SSH/RDP)

Quel protocole ?
│
├─ Matériel propriétaire (routeur Cisco/Fortinet) → IPsec
├─ Multiplateforme, contrôle total → OpenVPN
└─ Performance maximale, moderne → WireGuard (non traité ici)
```
