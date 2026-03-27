# ⚡ L'essentiel en 5 minutes - Internet Protocol version 4 (IPv4)

## 📌 C'est quoi en 2 lignes ?

IPv4 est le protocole de couche 3 (réseau) qui permet l'interconnexion de réseaux physiques hétérogènes via des adresses logiques sur 32 bits. Il gère le routage, la fragmentation et l'acheminement non fiable de paquets indépendants entre interfaces réseau.

---

## 💡 Concepts clés à retenir :

* **Adresse IPv4** : Identifiant 32 bits (4 octets) d'une interface réseau, noté en décimal pointé (ex: 192.168.1.10)
* **CIDR** : Notation d'adresse avec taille de préfixe réseau (ex: 192.168.1.0/24 = masque 255.255.255.0)
* **Masque de réseau** : Séquence de 32 bits (1 suivis de 0) définissant la partie réseau vs hôte d'une adresse
* **Fragmentation** : Découpage d'un paquet IP trop grand pour le MTU du lien, réassemblé uniquement par le destinataire final
* **TTL (Time To Live)** : Durée de vie du paquet en nombre de sauts, décrémenté à chaque routeur, paquet jeté si = 0

---

## 💻 Commandes essentielles :

```bash
# 🐧 Linux
ip address show                    # Affiche toutes les configs IP
ip -4 address show dev enp0s3      # Config IPv4 d'une interface
ip address add 192.168.0.24/24 dev enp0s3  # Ajoute une adresse IP
ip address del 192.168.0.24/24 dev enp0s3  # Supprime une adresse IP
ip neighbour show                  # Affiche le cache ARP
ip a                               # Raccourci pour "ip address show"
```

```powershell
# 🪟 Windows  
Get-NetIPConfiguration             # Affiche la config réseau
Get-NetAdapter                     # Liste les interfaces réseau
New-NetIPAddress -InterfaceIndex 2 -IPAddress 192.168.0.24 -PrefixLength 24 -DefaultGateway 192.168.0.1  # Configure IP statique
```

```bash
# 🌐 Configuration permanente Linux
# /etc/network/interfaces (Debian/Ubuntu)
auto enp0s3
iface enp0s3 inet static
    address 192.168.0.10/24
    gateway 192.168.0.1
```

---

## 📐 Calculs / Formules :

* **Adresse réseau** : Adresse IP AND Masque (bit à bit)
* **Adresse broadcast** : Adresse réseau OR NOT Masque (dernière adresse de la plage)
* **Nombre d'hôtes** : 2^(32-CIDR) - 2 (enlever adresse réseau et broadcast)
* **Masque depuis CIDR** : n bits à 1, puis (32-n) bits à 0

**Exemple concret :**
```
Adresse : 172.16.10.35/21
Masque /21 = 255.255.248.0 (21 bits à 1)

Calcul adresse réseau :
  172.16.10.35  = 10101100.00010000.00001010.00100011
  255.255.248.0 = 11111111.11111111.11111000.00000000
  AND           = 10101100.00010000.00001000.00000000
Résultat : 172.16.8.0

Nombre d'hôtes : 2^(32-21) - 2 = 2^11 - 2 = 2046 hôtes

Broadcast : 172.16.15.255 (dernier octet + bits hôte à 1)
```

---

## ⚠️ Pièges à éviter :

* ❌ **Oublier les adresses réservées** : Première adresse = réseau, dernière = broadcast (non assignables aux hôtes)
* ❌ **Confondre masque et CIDR** : /24 ≠ 24.0.0.0 mais = 255.255.255.0 (notation différente, même concept)
* ❌ **Fragmenter avec Don't Fragment = 1** : Le paquet sera jeté et ICMP enverra une erreur au lieu de fragmenter
* ❌ **Utiliser classes A/B/C aujourd'hui** : Obsolète depuis CIDR (1993), on découpe librement avec /n
* ❌ **Négliger le cache ARP** : Les entrées expirées causent des requêtes broadcast inutiles, vérifier avec `ip neighbour`

---

## ✅ Bonnes pratiques :

* ✅ **Vérifier la compatibilité des masques** : Toutes les interfaces d'un même réseau physique doivent avoir le même préfixe réseau
* ✅ **Planifier l'adressage** : Prévoir la croissance, éviter de gaspiller les adresses publiques (utiliser plages privées RFC 1918)
* ✅ **Documenter les plages** : Maintenir un plan d'adressage clair (qui utilise quoi, VLAN associé, usage)
* ✅ **Utiliser CIDR** : Plus flexible que les classes, permet de sous-découper et d'agréger les routes efficacement
* ✅ **Lire les RFC** : RFC 791 (IP), RFC 826 (ARP), RFC 792 (ICMP) = sources officielles pour comprendre les détails

---

## 📚 Vocabulaire technique :

| Terme | Définition courte |
|-------|------------------|
| **MTU** | Maximum Transmission Unit : taille max d'un paquet sur un lien (ex: Ethernet = 1500 octets) |
| **IETF** | Internet Engineering Task Force : organisme qui standardise les protocoles via les RFC |
| **RFC** | Request For Comments : documents numérotés décrivant les standards Internet |
| **Routeur** | Nœud IP transmettant des paquets entre réseaux différents (passerelle de couche 3) |
| **Hôte** | Nœud IP qui n'est pas un routeur (machine finale) |
| **Préfixe réseau** | Partie commune de l'adresse IP identifiant un réseau logique (ex: 192.168.1 dans 192.168.1.0/24) |
| **ARP** | Address Resolution Protocol : résout adresse IP → adresse MAC sur un lien local |
| **ICMP** | Internet Control Message Protocol : messages de contrôle/erreur IP (ping, traceroute) |
| **CIDR** | Classless Inter-Domain Routing : notation adresse/longueur_préfixe sans classes A/B/C |
| **Lien** | Réseau physique (couche 1-2) : Ethernet, WiFi, etc. |
| **Voisins** | Nœuds directement connectés sur le même lien physique |
| **Checksum** | Somme de contrôle pour détecter les erreurs dans l'entête IP (recalculée à chaque saut) |

---

## 🎯 À retenir ABSOLUMENT :

1. 💡 **Théorique** : Adresse IP = préfixe réseau (n bits) + identifiant hôte (32-n bits). Masque permet de séparer les deux via AND logique.

2. 💻 **Pratique** : `ip address add <IP>/<CIDR> dev <interface>` (Linux) configure une adresse temporaire. Permanent = `/etc/network/interfaces`.

3. ⚠️ **Piège** : Les plages privées (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) ne sont PAS routables sur Internet → nécessitent NAT pour l'accès externe.

---

## 📦 Entête IPv4 (structure simplifiée) :

```
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|Version|  IHL  |Type of Service|          Total Length         |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|         Identification        |Flags|      Fragment Offset    |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|  Time to Live |    Protocol   |         Header Checksum       |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                       Source Address                          |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Destination Address                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Options (variable)            |  Padding   |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

**Champs vitaux :**
- **Version** : 4 (toujours pour IPv4)
- **IHL** : Taille entête en mots de 32 bits (min 5 = 20 octets)
- **Total Length** : Taille paquet entier (entête + données, max 65535)
- **TTL** : Décrémenté à chaque saut, paquet jeté si 0
- **Protocol** : Protocole encapsulé (1=ICMP, 6=TCP, 17=UDP)
- **Source/Destination Address** : Adresses IP 32 bits

---

## 🔧 Protocoles associés :

**ICMP (Protocol 1) - Contrôle et diagnostic :**
- Type 0/8 : Echo Reply/Request (ping)
- Type 3 : Destination Unreachable
- Type 11 : Time Exceeded (traceroute)

**ARP (EtherType 0x806) - Résolution IP → MAC :**
- Requête broadcast : "Qui a l'IP X.X.X.X ?"
- Réponse unicast : "C'est moi, voici ma MAC"
- Cache consulté avant chaque envoi (évite broadcast répété)

---

## 📊 Plages d'adresses réservées (RFC 1918) :

| Plage CIDR         | Plage décimale                | Nombre d'adresses | Usage                         |
| ------------------ | ----------------------------- | ----------------- | ----------------------------- |
| **10.0.0.0/8**     | 10.0.0.0 - 10.255.255.255     | ~16 millions      | Grands réseaux privés         |
| **172.16.0.0/12**  | 172.16.0.0 - 172.31.255.255   | ~1 million        | Réseaux moyens                |
| **192.168.0.0/16** | 192.168.0.0 - 192.168.255.255 | ~65000            | Petits réseaux (box Internet) |
| **127.0.0.0/8**    | 127.0.0.0 - 127.255.255.255   | Loopback          | Interface locale (localhost)  |

---

## 📖 Références essentielles :

- **RFC 791** : Internet Protocol (IPv4) - Standard fondamental
- **RFC 826** : Address Resolution Protocol (ARP)
- **RFC 792** : Internet Control Message Protocol (ICMP)
- **RFC 1918** : Address Allocation for Private Internets (plages privées)
- **RFC 2632** : Classless Inter-Domain Routing (CIDR)

---

## 💾 Astuce de révision :

**Testez dans une VM Linux :**
```bash
# Scénario pratique complet
sudo ip addr add 192.168.100.50/24 dev eth0    # Configurer IP
ip addr show eth0                               # Vérifier
ping 192.168.100.1                              # Tester connectivité
ip neighbour                                    # Voir cache ARP
sudo ip addr del 192.168.100.50/24 dev eth0    # Nettoyer
```

**Calculez mentalement :**
- /24 = 254 hôtes
- /25 = 126 hôtes  
- /26 = 62 hôtes
- /27 = 30 hôtes
- /28 = 14 hôtes
- /29 = 6 hôtes
- /30 = 2 hôtes (point-à-point)

---

**📌 La pratique bat la théorie ! Testez chaque commande dans une VM pour ancrer les concepts. 🚀**
