## 1. Le Routage

### Principe

- IP permet l'interconnexion de réseaux distincts grâce à des **routeurs** (passerelles).
- Si la destination est sur le **même réseau** → envoi direct via la couche liaison (Ethernet).
- Si la destination est sur un **réseau différent** → on consulte la **table de routage**.

### Table de routage

Chaque nœud (hôte ou routeur) possède une table de routage. Chaque entrée contient :

|Champ|Description|
|---|---|
|Destination|Adresse réseau + masque|
|Next hop|Adresse de la passerelle pour y accéder|
|Interface|Interface locale vers la passerelle|
|Métrique|Qualité de la route (moins = mieux)|

> 💡 En **IPv6**, on utilise les adresses **lien local** (fe80::…) des routeurs comme next hop.

### Passerelle par défaut (default gateway)

Route de dernier recours : `0.0.0.0/0` (IPv4) ou `::/0` (IPv6).  
Utilisée quand aucune route plus précise ne correspond.

### Agrégation de routes (supernetting)

Pour réduire la taille des tables, on regroupe plusieurs réseaux en un seul préfixe plus grand.  
Ex : `192.168.0.0/24` + `192.168.5.0/24` + `192.168.12.0/24` → `192.168.0.0/17`

### Commandes utiles

|OS|Commande|Action|
|---|---|---|
|Linux|`ip route`|Afficher la table IPv4|
|Linux|`ip -6 route`|Afficher la table IPv6|
|Linux|`ip route add 10.0.0.0/8 via 192.168.1.1`|Ajouter une route|
|Linux|`ip route add default via 192.168.1.254`|Définir la passerelle par défaut|
|Windows|`route print`|Afficher les tables IPv4 et IPv6|
|Windows|`route add 10.0.0.0/8 192.168.1.1`|Ajouter une route|

### Activer le routage sur Linux (transformer un Linux en routeur)

```bash
sysctl -w net.ipv4.ip_forward=1          # Activer le routage IPv4
sysctl -w net.ipv6.conf.all.forwarding=1 # Activer le routage IPv6
# Persistant : éditer /etc/sysctl.conf puis recharger avec :
sysctl -p /etc/sysctl.conf
```

---

## 2. Routage dynamique

> Indispensable pour les réseaux avec **plus de 5 routeurs** ou fréquemment modifiés.  
> Les routeurs échangent automatiquement leurs tables de routage.

|Protocole|Usage|Port|Particularités|
|---|---|---|---|
|**RIP**|Petits réseaux|UDP 520|Max 15 sauts, simple|
|**EIGRP**|Grands réseaux|IP 88|Propriétaire Cisco, convergence rapide|
|**OSPF**|Réseaux moyens/grands|IP 89|Ouvert, supporte VLSM, plus rapide que RIP|
|**BGP**|Internet (entre ISP)|TCP 179|Routage inter-systèmes autonomes|

---

## 3. Protocoles de transport (couche 4)

### UDP — User Datagram Protocol

- **Protocole** : minimal, sans connexion, sans fiabilité
- **N° de protocole IP** : 17
- **En-tête** : 4 champs (src port, dst port, length, checksum) — **8 octets**
- Datagramme jeté silencieusement si checksum ou taille invalide
- **Cas d'usage** : DNS, streaming, jeux en ligne, diffusion

### TCP — Transmission Control Protocol

- **Protocole** : fiable, orienté connexion, bidirectionnel (full duplex)
- **N° de protocole IP** : 6
- **En-tête** : 15 champs dont numéros de séquence/acquittement, flags, fenêtre — **20 octets minimum**
- **Cas d'usage** : HTTP/S, SSH, FTP, email

#### Flags TCP

|Flag|Rôle|
|---|---|
|SYN|Synchronisation (ouverture connexion)|
|ACK|Acquittement d'un segment reçu|
|FIN|Fin d'envoi (fermeture connexion)|
|RST|Réinitialisation forcée|
|PSH|Vider le tampon immédiatement|
|URG|Données urgentes|

#### Three-way handshake (ouverture)

```
Client          Serveur
  |--- SYN (seq=x) ---------->|
  |<-- SYN+ACK (seq=y,ack=x+1)|
  |--- ACK (ack=y+1) -------->|
       [connexion établie]
```

#### Fermeture de connexion (4 échanges)

```
Client          Serveur
  |--- FIN (seq=x) ---------->|
  |<-- ACK (ack=x+1) ---------|
  |<-- FIN (seq=y) -----------|
  |--- ACK (ack=y+1) -------->|
```

### Ports

|Plage|Type|Usage|
|---|---|---|
|0 – 1023|Well Known Ports|Serveurs standards (géré IANA)|
|1024 – 49151|Registered Ports|Serveurs applicatifs|
|49152 – 65535|Ephemeral Ports|Clients (port source temporaire)|

**Ports connus à retenir :**

|Port|Protocole|Transport|
|---|---|---|
|22|SSH|TCP|
|53|DNS|TCP/UDP|
|80|HTTP|TCP|
|443|HTTPS|TCP|
|520|RIP|UDP|
|179|BGP|TCP|

---

## 4. Exemples concrets

### Exemple 1 — Ping sur le même réseau

Machine `192.168.0.11/24` → `192.168.0.42/24`  
→ Même réseau `/24` ✅ : envoi **direct via ARP + Ethernet**, pas de routeur.

### Exemple 2 — Ping vers un autre réseau

Machine `192.168.0.11/24` → `192.168.1.42/24`  
→ Réseaux différents : consultation de la table de routage.  
→ Table contient : `192.168.1.0/24 via 192.168.0.1`  
→ ARP pour obtenir le MAC de `192.168.0.1`, paquet IP envoyé au **routeur**.  
→ Le routeur relaie vers `192.168.1.42`.

### Exemple 3 — Table de routage Linux

```
default via 10.0.0.254 dev enp0s3
10.0.0.0/24 dev enp0s3 proto kernel
192.168.128.0/17 via 10.0.0.2 dev enp0s3
192.168.0.0/17 via 10.0.0.1 dev enp0s3
```

→ Tout ce qui ne matche rien → passerelle `10.0.0.254`  
→ `192.168.200.x` → routeur `10.0.0.2` (car dans `192.168.128.0/17`)  
→ `192.168.5.x` → routeur `10.0.0.1` (car dans `192.168.0.0/17`)

### Exemple 4 — Connexion HTTP (TCP)

```
Client :52341  →  Serveur :80
  SYN  →
  ← SYN+ACK
  ACK  →
  [Requête HTTP]  →
  ← [Réponse HTTP]
  FIN / FIN+ACK
```

Port **source éphémère** (52341), port **destination standard** (80).