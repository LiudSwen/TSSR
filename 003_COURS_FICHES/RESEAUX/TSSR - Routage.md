# ⚡ L'essentiel en 5 minutes - Le routage IP, protocoles dynamiques & transport

## 📌 C'est quoi en 2 lignes ?

Le routage IP permet de faire communiquer des machines sur des réseaux différents via des routeurs et des tables de routage. Les protocoles de transport (TCP/UDP) gèrent la communication entre processus applicatifs via des ports.

---

## 💡 Concepts clés à retenir :

- **Routage** : Mécanisme permettant de transmettre des paquets IP entre réseaux différents via des routeurs
- **Table de routage** : Liste des destinations (réseaux) et passerelles (next hop) pour acheminer les paquets
- **Port** : Identifiant de processus (0-65535) permettant de distinguer les applications sur une même adresse IP
- **UDP** : Protocole léger non fiable sans connexion (pas de garantie de livraison)
- **TCP** : Protocole fiable avec connexion, garantissant l'ordre et la livraison des segments

---

## 💻 Commandes essentielles :

```bash
# 🐧 Linux - Routage
ip route                                    # Afficher table routage IPv4
ip -6 route                                 # Afficher table routage IPv6
ip route add 192.168.1.0/24 via 10.0.0.1   # Ajouter route statique
ip route add default via 10.0.0.254        # Ajouter passerelle par défaut

# 🐧 Linux - Activer le routage
sysctl net.ipv4.ip_forward                 # Consulter état routage IPv4
sysctl -w net.ipv4.ip_forward=1           # Activer routage IPv4 (temporaire)
sysctl -w net.ipv6.conf.all.forwarding=1  # Activer routage IPv6 (temporaire)
sysctl -p /etc/sysctl.conf                # Recharger config persistante
```

```powershell
# 🪟 Windows - Routage
route print                                # Afficher tables routage
route add 192.168.1.0/24 10.0.0.1         # Ajouter route
route delete 192.168.1.0/24               # Supprimer route
Get-NetRoute                              # Afficher table (PowerShell)
```

```bash
# 🌐 Protocoles de routage dynamique
RIP     : Port UDP 520, max 15 sauts (petits réseaux)
EIGRP   : Port 88, Cisco uniquement (réseaux complexes)
OSPF    : Port 89, standard ouvert (réseaux moyens/grands)
BGP     : Port TCP 179, routage Internet entre AS
```

---

## 📐 Concepts réseau :

- **Next hop** : Adresse du routeur suivant pour atteindre une destination
- **Métrique** : Mesure de qualité d'une route (plus bas = meilleur)
- **Passerelle par défaut** : Routeur utilisé quand aucune route spécifique n'existe
- **Préfixe de routage** : Agrégation de plusieurs réseaux en un seul pour réduire la taille des tables

**Exemple de décision de routage :**

```
Machine 192.168.0.11 veut joindre 192.168.1.42
1. Calcul : 192.168.1.42 n'est pas sur mon réseau (192.168.0.0/24)
2. Consultation table : route vers 192.168.1.0/24 via 192.168.0.1
3. Envoi : Paquet IP pour .1.42 dans trame Ethernet vers MAC du routeur .0.1
```

---

## 📊 Ports et plages :

|Plage|Type|Usage|
|---|---|---|
|**0-1023**|Well Known Ports|Ports système serveurs (DNS=53, HTTP=80, HTTPS=443)|
|**1024-49151**|Registered Ports|Ports utilisateurs serveurs|
|**49152-65535**|Ephemeral Ports|Ports dynamiques clients|

---

## 🔄 TCP vs UDP :

|Caractéristique|**TCP**|**UDP**|
|---|---|---|
|**Protocole IP**|6|17|
|**Connexion**|Oui (3-way handshake)|Non|
|**Fiabilité**|Acquittements + retransmissions|Aucune garantie|
|**Ordre**|Garanti (numéros de séquence)|Non garanti|
|**Entête**|20 octets minimum|8 octets|
|**Usage**|HTTP, SSH, FTP, Email|DNS, Streaming, VoIP|

---

## 🤝 Three-Way Handshake TCP :

```
Client              Serveur
  |                    |
  |----SYN (seq=x)--->|  1. Demande connexion
  |                    |
  |<--SYN-ACK---------|  2. Acceptation (seq=y, ack=x+1)
  |    (seq=y,ack=x+1) |
  |                    |
  |----ACK (ack=y+1)-->|  3. Confirmation
  |                    |
 [CONNECTÉ]        [CONNECTÉ]
```

---

## ⚠️ Pièges à éviter :

- ❌ **Table de routage vide** : Sans route par défaut, impossible de joindre des réseaux inconnus
- ❌ **Oublier d'activer le forwarding** : Un Linux ne route pas par défaut (ip_forward=0)
- ❌ **Confondre adresse destination IP et MAC** : Le paquet IP garde l'IP finale, mais la trame Ethernet vise le routeur
- ❌ **Next hop en IPv6** : Toujours utiliser l'adresse **link-local** (fe80::) du routeur, pas la globale
- ❌ **Ports identiques** : Impossible d'avoir 2 processus sur le même port/IP (sauf socket réutilisation)

---

## ✅ Bonnes pratiques :

- ✅ **Agréger les routes** : Utiliser des sur-réseaux pour réduire la taille des tables de routage
- ✅ **Routes statiques pour petits réseaux** : Simple et suffisant pour <5 routeurs
- ✅ **Routage dynamique pour grands réseaux** : OSPF/BGP pour adaptation automatique aux pannes
- ✅ **TCP pour fiabilité** : Toujours choisir TCP quand l'intégrité des données est critique
- ✅ **Vérifier le routage avec `ping`/`traceroute`** : Tester la connectivité après config

---

## 📚 Vocabulaire technique :

|Terme|Définition courte|
|---|---|
|**MTU**|Maximum Transmission Unit (taille max paquet, souvent 1500 octets)|
|**MSS**|Maximum Segment Size (taille max données TCP, négocié lors handshake)|
|**TTL**|Time To Live (compteur limitant la durée de vie d'un paquet, décrémenté à chaque routeur)|
|**Fenêtre TCP**|Nombre d'octets que le récepteur peut recevoir sans acquittement|
|**Checksum**|Somme de contrôle pour détecter erreurs de transmission|
|**Système Autonome (AS)**|Ensemble de réseaux sous une même administration (utilisé par BGP)|

---

## 🎯 À retenir ABSOLUMENT :

1. 💡 **Théorique** : Le routage utilise l'adresse **réseau** de destination, pas l'adresse hôte complète → agrégation = tables plus petites
2. 💻 **Pratique** : `sysctl -w net.ipv4.ip_forward=1` pour transformer un Linux en routeur (+ config persistante dans /etc/sysctl.conf)
3. ⚠️ **Piège** : En IPv6, le next hop doit TOUJOURS être une adresse **link-local fe80::** du routeur

---

## 🔧 Configuration rapide routeur Linux :

```bash
# 1. Activer le routage
echo 1 > /proc/sys/net/ipv4/ip_forward
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

# 2. Ajouter routes statiques
ip route add 192.168.1.0/24 via 10.0.0.1 dev enp0s3
ip route add default via 10.0.0.254

# 3. Vérifier
ip route
ping -c 3 192.168.1.42
```

---

## 📦 Structure segments TCP/UDP :

```
UDP (8 octets entête) :
┌─────────────┬─────────────┐
│  Port src   │  Port dst   │ 16 bits chacun
├─────────────┼─────────────┤
│   Length    │  Checksum   │
└─────────────┴─────────────┘
       │
       └──> PDU (données)

TCP (20+ octets entête) :
┌─────────────┬─────────────┐
│  Port src   │  Port dst   │
├─────────────────────────────┤
│    Sequence number (32b)    │ N° segment
├─────────────────────────────┤
│ Acknowledgment number (32b) │ Prochain N° attendu
├────┬────┬──────┬────────────┤
│Offs│Rsvd│Flags │  Window    │ URG|ACK|PSH|RST|SYN|FIN
├─────────────┬───────────────┤
│  Checksum   │ Urgent ptr    │
└─────────────┴───────────────┘
       │
       └──> PDU (données)
```