# ⚡ L'essentiel en 5 minutes - NAT (Network Address Translation)

## 📌 C'est quoi en 2 lignes ?

Le NAT traduit les adresses IP privées d'un réseau interne en adresses IP publiques pour permettre l'accès à Internet. C'est une solution transitoire à la pénurie d'adresses IPv4, massivement utilisée sur les box Internet et routeurs d'entreprise.

---

## 💡 Concepts clés à retenir

- **NAT (Network Address Translation)** : Mécanisme de traduction d'adresses IP entre réseaux privé (LAN) et public (WAN)
- **Adresses privées RFC 1918** : 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 - non routables sur Internet
- **PAT/NAPT** : Traduction d'adresse IP **+ port source** - permet à plusieurs machines de partager une seule IP publique
- **DNAT** : Traduction d'adresse IP **de destination** - permet de publier des services internes vers Internet
- **NAT 1:1** : Association statique fixe entre une IP privée et une IP publique dédiée (DMZ)

---

## 💻 Syntaxes essentielles

```bash
# 📊 Plages d'adresses privées (RFC 1918)
10.0.0.0/8          # 10.0.0.0 → 10.255.255.255
172.16.0.0/12       # 172.16.0.0 → 172.31.255.255
192.168.0.0/16      # 192.168.0.0 → 192.168.255.255
```

```bash
# 🔄 Exemple de traduction PAT/NAPT
IP Interne:Port → IP Publique:Port
10.1.1.11:52369 ⇔ 203.1.113.123:52369
```

```bash
# 🌐 Exemple de traduction DNAT (port forwarding)
IP Publique:Port Externe → IP Privée:Port Interne
203.1.113.123:80 → 172.16.1.15:80
```

```bash
# 🔗 Exemple de NAT 1:1
IP Privée ⇔ IP Publique dédiée
172.16.1.20 ⇔ 203.1.113.50
```

---

## 📐 Types de NAT (3 critères combinables)

|**Critère**|**Options**|
|---|---|
|**Sens de traduction**|Source (sortie Internet) / Destination (entrée)|
|**Mode d'association**|Statique (fixe) / Dynamique (temporaire)|
|**Niveau de traduction**|@IP seule / @IP + port|

---

## ⚠️ Pièges à éviter

- **❌ Port forwarding oublié** : Impossible d'héberger un serveur sans DNAT/port forwarding configuré
- **❌ Collision de ports** : Si le port source est déjà utilisé, le routeur doit modifier le port (d'où le terme PAT)
- **❌ Protocoles incompatibles** : FTP actif, certains protocoles VoIP, protocoles sans notion de port (ICMP, ESP)
- **❌ Blocage d'IP groupé** : Une seule IP publique est vue de l'extérieur - un utilisateur malveillant peut faire blacklister toute l'entreprise
- **❌ Rupture du principe de bout en bout** : Les paquets sont modifiés en transit → checksums recalculées, incompatibilité avec IPsec en mode transport

---

## ✅ Bonnes pratiques

- **✅ PAT/NAPT pour les clients** : Utiliser PAT/NAPT (traduction source dynamique) pour donner accès Internet aux postes clients
- **✅ DNAT pour les serveurs** : Utiliser DNAT/port forwarding pour publier des services internes (HTTP, HTTPS, RDP...)
- **✅ NAT 1:1 pour les DMZ** : Attribuer une IP publique dédiée aux serveurs critiques exposés (tous les ports accessibles)
- **✅ Règles de pare-feu strictes** : Le NAT n'est PAS un pare-feu - toujours coupler avec des règles de filtrage
- **✅ Documenter les mappings** : Tenir à jour une table des correspondances statiques (DNAT/NAT 1:1)

---

## 📚 Vocabulaire technique

|**Terme**|**Définition courte**|
|---|---|
|**Masquerade**|Autre nom du NAT (masquage d'adresse interne)|
|**Port forwarding**|Redirection de port - DNAT avec changement de port (ex: 8080 externe → 80 interne)|
|**Table de traduction**|Table maintenue par le routeur pour associer flux internes ⇔ flux externes|
|**SNAT**|Source NAT - traduction de l'adresse source (équivalent PAT/NAPT)|
|**Static NAT**|NAT 1:1 - association fixe entre une IP privée et une IP publique|
|**NAT overload**|Autre nom du PAT/NAPT - plusieurs machines partagent une IP publique|
|**Carrier-grade NAT**|NAT déployé directement sur le réseau de l'opérateur (NAT en cascade)|
|**NPTv6**|Network Prefix Translation pour IPv6 (rarement utilisé)|

---

## 🎯 À retenir ABSOLUMENT

1. **💡 Théorique** : NAT traduit des IPs privées en IPs publiques - 3 critères : sens (source/destination), mode (statique/dynamique), niveau (IP/IP+port)
2. **💻 Pratique** : PAT/NAPT pour les clients (dynamique), DNAT/port forwarding pour les serveurs (statique), NAT 1:1 pour les DMZ (IP dédiée)
3. **⚠️ Piège** : NAT modifie les paquets (checksums) → incompatible avec certains protocoles (FTP actif, IPsec transport, protocoles sans ports)

---

## 📊 Tableau récapitulatif des 3 types principaux

|**Type**|**Sens**|**Mode**|**Niveau**|**Usage**|**Exemple**|
|---|---|---|---|---|---|
|**PAT/NAPT**|Source|Dynamique|IP + port|Accès Internet clients|10.1.1.11:52369 ⇔ 203.1.113.123:52369|
|**DNAT**|Destination|Statique|IP (+ port)|Publication de services|203.1.113.123:80 → 172.16.1.15:80|
|**NAT 1:1**|Source + Destination|Statique|IP seule|Serveur en DMZ (IP publique dédiée)|172.16.1.20 ⇔ 203.1.113.50|

---

## 🔧 Exemple concret de flux PAT/NAPT

```
Requête sortante :
  Client interne : 10.1.1.11:52369 → Google : 216.58.214.83:443
  Routeur traduit : 203.1.113.123:52369 → 216.58.214.83:443
  
Réponse entrante :
  Google répond : 216.58.214.83:443 → 203.1.113.123:52369
  Routeur traduit : 216.58.214.83:443 → 10.1.1.11:52369
```

**Table de traduction du routeur** :

|**Interne**|**Externe**|
|---|---|
|10.1.1.11:52369|203.1.113.123:52369|

---

## 🔧 Exemple concret de flux DNAT

```
Requête entrante :
  Client Internet : 204.1.97.10:57221 → Serveur public : 203.1.113.123:80
  Routeur traduit : 204.1.97.10:57221 → Serveur interne : 172.16.1.15:80
  
Réponse sortante :
  Serveur répond : 172.16.1.15:80 → 204.1.97.10:57221
  Routeur traduit : 203.1.113.123:80 → 204.1.97.10:57221
```

**Table de traduction du routeur** :

|**Interne**|**Externe**|
|---|---|
|172.16.1.15:80|203.1.113.123:80|

---

## 🚨 Limites du NAT

- **Consommation d'adresses publiques** : NAT 1:1 consomme une IP publique par serveur
- **Complexité de publication** : Plusieurs serveurs HTTP nécessitent des ports non standard (8080, 8443...) ou plusieurs IPs publiques
- **Traçabilité impossible** : Depuis l'extérieur, impossible de distinguer les machines internes (même IP publique)
- **Lourdeur de traitement** : Recalcul des checksums IP/TCP/UDP à chaque paquet

---

## 🌐 NAT et IPv6

- **IPv6 rend NAT obsolète** : Adresses publiques en quantité quasi-illimitée (2^128 adresses)
- **NPTv6 existe mais rare** : Traduction de préfixe réseau (pour compatibilité/sécurité)
- **Déploiement lent** : NAT reste massivement utilisé en IPv4 - une raison d'accélérer le passage à IPv6