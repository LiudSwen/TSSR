# ⚡ L'essentiel en 5 minutes - IPv6

## 📌 C'est quoi en 2 lignes ?

IPv6 est le protocole IP sur 128 bits qui remplace IPv4 (32 bits) pour résoudre la pénurie d'adresses. Il apporte l'autoconfiguration (SLAAC), supprime le broadcast/NAT, simplifie l'en-tête et intègre IPsec.

---

## 💡 Concepts clés à retenir

- **Adresse IPv6** : 128 bits en hexa, 8 groupes de 16 bits séparés par `:` (ex: `2001:db8::1/64`)
- **SLAAC** : Autoconfiguration sans serveur DHCP via annonces routeur (RA)
- **NDP** : Remplace ARP, utilise ICMPv6 pour découverte voisins/routeurs
- **Multicast** : Remplace le broadcast, préfixe `ff00::/8`
- **Préfixe /64** : Standard pour tous les sous-réseaux IPv6

---

## 💻 Commandes essentielles


```bash
# 🌐 Notation IPv6
2001:0db8:0000:85a3::ac1f:8001    # Forme complète
2001:db8:0:85a3::ac1f:8001        # Forme courte (:: = une seule fois)
fe80::1%eth0                      # Link-Local avec interface
```


```bash
# 🐧 Linux
ip -6 addr show                   # Afficher adresses IPv6
ip -6 route show                  # Table de routage IPv6
ping6 2001:db8::1                 # Ping IPv6
ping6 fe80::1%eth0                # Ping Link-Local (% + interface obligatoire)
```


```powershell
# 🪟 Windows
ipconfig                          # Afficher config réseau
ping 2001:db8::1                  # Ping IPv6
netsh interface ipv6 show address # Détails IPv6
```

---

## 📐 Adresses essentielles

**Préfixes à connaître :**
- `::1/128` → Loopback (127.0.0.1)
- `fe80::/10` → Link-Local (non routable, autoconfigurée)
- `fd00::/8` → Unique Local (privé routable, ex: 10.0.0.0/8)
- `2000::/3` → Global Unicast (publique Internet)
- `ff02::1` → All-nodes multicast
- `ff02::2` → All-routers multicast

**Structure d'une adresse :**
```
┌──────────────────┬──────────────────┐
│  Préfixe réseau  │  ID Interface    │
│     64 bits      │     64 bits      │
└──────────────────┴──────────────────┘
Exemple: 2001:db8:1234:5678::1/64
         └─────┬──────┘ └───┬────┘
           Réseau      Hôte
```

---

## 📐 Simplification d'adresses

**Règles :**
1. Supprimer les `0` devant : `0db8` → `db8`
2. Remplacer UNE suite de `:0:0:` par `::` (une seule fois max)

**Exemple :**
```
Donnée : 2001:0db8:0000:0000:0000:0000:0000:0001

Calcul : 
Étape 1 → 2001:db8:0:0:0:0:0:1
Étape 2 → 2001:db8::1

Résultat : 2001:db8::1/128
```

---

## ⚠️ Pièges à éviter

- **❌ Utiliser `::` deux fois** : `fe80::1::2` est INVALIDE (un seul `::` autorisé)
- **❌ Bloquer ICMPv6** : Casse NDP, SLAAC, PMTUD → réseau inutilisable
- **❌ Ping Link-Local sans interface** : `ping6 fe80::1` échoue, utiliser `ping6 fe80::1%eth0`
- **❌ Confondre portées** : Link-Local (fe80::/10) n'est PAS routable entre VLANs
- **❌ Oublier le préfixe /64** : Toujours spécifier `/64` pour les sous-réseaux

---

## ✅ Bonnes pratiques

- **✅ Toujours utiliser /64** : Standard SLAAC, ne jamais utiliser /127 ou /128 sauf loopback
- **✅ Autoriser ICMPv6** : Vital pour NDP, diagnostics (ping6), Path MTU Discovery
- **✅ Dual-stack** : Activer IPv4 et IPv6 simultanément pendant la transition
- **✅ Notation courte** : Utiliser `2001:db8::1` au lieu de `2001:0db8:0000:...:0001`
- **✅ Sécuriser NDP** : Activer RA Guard sur les switchs pour éviter rogue RA

---

## 📚 Vocabulaire technique

| Terme | Définition courte |
|-------|-------------------|
| **SLAAC** | Autoconfiguration sans serveur DHCP via Router Advertisement |
| **NDP** | Neighbor Discovery Protocol - remplace ARP (via ICMPv6 type 135/136) |
| **DAD** | Duplicate Address Detection - vérifie unicité adresse avant utilisation |
| **RA** | Router Advertisement - annonce périodique des routeurs (ICMPv6 type 134) |
| **RS** | Router Solicitation - demande d'annonce routeur (ICMPv6 type 133) |
| **EUI-64** | Méthode génération ID interface depuis MAC (obsolète, privacy issues) |
| **Anycast** | Adresse partagée, routée vers l'hôte le plus proche |
| **PMTUD** | Path MTU Discovery - détecte MTU max du chemin (min 1280 octets) |

---

## 🎯 À retenir ABSOLUMENT

1. **💡 Théorique** : IPv6 = 128 bits, notation hexa avec `:`, un seul `::`, préfixe `/64` obligatoire
2. **💻 Pratique** : Link-Local `fe80::/64` (auto), Global `2000::/3` (Internet), ping6 avec `%interface`
3. **⚠️ Piège** : **JAMAIS bloquer ICMPv6** = destruction complète du réseau IPv6

---

## 📋 Processus SLAAC (autoconfiguration)
```
1. Interface UP
   └─> Génère Link-Local fe80::/64 + ID interface

2. DAD (Neighbor Solicitation)
   └─> Vérifie unicité adresse

3. Router Solicitation (RS) → ff02::2
   └─> Demande préfixe réseau

4. Router Advertisement (RA) reçu
   ├─> Préfixe /64
   ├─> Durée de vie
   └─> Routeur par défaut

5. Construction adresse globale
   └─> Préfixe + ID interface

6. DAD sur adresse globale

7. ✅ Configuration terminée
```

---

## 🌐 En-tête IPv6 (40 octets fixes)
```
┌─────────┬──────────────┬─────────────────┐
│ Version │Traffic Class │   Flow Label    │
│  4b     │     8b       │      20b        │
├─────────┴──────────────┴─────────────────┤
│      Payload Length (16b)                │
├────────────────────┬─────────────────────┤
│  Next Header (8b)  │  Hop Limit (8b)     │
├────────────────────┴─────────────────────┤
│      Source Address (128b)               │
├──────────────────────────────────────────┤
│      Destination Address (128b)          │
└──────────────────────────────────────────┘

Next Header = 58 → ICMPv6
Next Header = 6  → TCP
Next Header = 17 → UDP
```

---

## 🔧 ICMPv6 - Messages essentiels
```
Type 1   : Destination Unreachable
Type 2   : Packet Too Big (PMTUD)
Type 128 : Echo Request (ping6)
Type 129 : Echo Reply
Type 133 : Router Solicitation (RS)
Type 134 : Router Advertisement (RA)
Type 135 : Neighbor Solicitation (remplace ARP Request)
Type 136 : Neighbor Advertisement (remplace ARP Reply)
```
---

## 📊 IPv4 vs IPv6

|IPv4|IPv6|
|---|---|---|
|**Taille**|32 bits|128 bits|
|**Notation**|Décimal (192.168.1.1)|Hexa (2001:db8::1)|
|**Config**|DHCP/Statique|SLAAC/DHCPv6/Statique|
|**Broadcast**|Oui|Non (multicast)|
|**NAT**|Omniprésent|Inutile|
|**Fragmentation**|Routeurs fragmentent|Seule source fragmente|
