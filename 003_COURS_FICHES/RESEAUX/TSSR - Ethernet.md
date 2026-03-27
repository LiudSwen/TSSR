# ⚡ L'essentiel en 5 minutes - ETHERNET

## 📌 C'est quoi en 2 lignes ?
Ethernet (IEEE 802.3) est **le protocole standard pour les réseaux locaux filaires (LAN)**. Il définit comment les données sont transmises via câbles (cuivre/fibre), identifiées par **adresses MAC**, et organisées en **trames** de 64 à 1518 octets.

---

## 💡 Concepts clés à retenir :

* **Ethernet** : Protocole de couche 2 (liaison) pour réseaux locaux, débits de 10 Mbps à 400 Gbps
* **Adresse MAC** : Identifiant physique unique de 48 bits (6 octets hexa) gravé sur chaque carte réseau
* **Trame Ethernet** : Unité de transmission contenant préambule, en-têtes (MAC src/dest, EtherType), payload (46-1500 octets), et CRC
* **MTU (Maximum Transmission Unit)** : Taille max du payload = 1500 octets (standard)
* **Switch (commutateur)** : Équipement de couche 2 qui transmet les trames uniquement au destinataire (vs hub qui diffuse partout)
* **VLAN (802.1Q)** : Segmentation logique d'un réseau physique en réseaux isolés sans câblage séparé

---

## 💻 Commandes essentielles :

```bash
# 🐧 Linux
ip link show                    # Afficher les interfaces et leurs MAC
ip l                            # Version abrégée (même résultat)
```

```powershell
# 🪟 Windows  
Get-NetAdapter                  # Lister les cartes réseau avec MAC, débit, statut
ipconfig /all                   # Voir config complète (IP + MAC)
```

```
# 🌐 Notation Ethernet
100BASE-T                       # 100 = Débit (Mbps), BASE = Bande de base, T = Twisted pairs
1000BASE-F                      # 1 Gbps sur fibre optique
08:00:27:BF:01:6F              # Format adresse MAC (6 paires hexa séparées par :)
```

---

## 📐 Calculs / Formules :

* **Conversion débit** : 8 bits = 1 octet → 100 Mb/s = 12,5 Mo/s
* **Taille trame** : Min 64 octets (avec en-têtes) / Max 1518 octets (MTU standard)
* **Bits adresse MAC** : 
  - Bit 7 (U/L) : 0=Universelle (constructeur), 1=Locale (admin)
  - Bit 8 (I/G) : 0=Individuelle (unicast), 1=Groupe (multicast/broadcast)

**Exemple concret :**
```
Débit : 1 Gbps = 1 000 000 000 bits/s
Conversion : 1 000 000 000 ÷ 8 = 125 000 000 octets/s = 125 Mo/s
Fichier 1 Go : 1024 Mo ÷ 125 Mo/s = ~8,2 secondes (théorique)
```

---

## ⚠️ Pièges à éviter :

* ❌ **Confondre 1 Gbps (débit) avec 1 Go (volume)** : 1 Gbps = 125 Mo/s de transfert réel
* ❌ **Faire confiance aux adresses MAC pour la sécurité** : Elles sont facilement modifiables (MAC spoofing)
* ❌ **Oublier le CRC** : Ethernet est "best effort", pas de retransmission si erreur (contrairement à TCP)
* ❌ **Mélanger câble droit/croisé** : Historiquement nécessaire, mais Auto MDI/MDIX corrige automatiquement sur équipements récents
* ❌ **Ignorer le MTU** : Jumbo frames (MTU > 1500) doivent être supportées sur TOUT le chemin réseau

---

## ✅ Bonnes pratiques :

* ✅ **Toujours vérifier le lien physique d'abord** : Diode "link" allumée = câble OK, base du diagnostic réseau
* ✅ **Utiliser des câbles catégorie adaptée** : CAT5e minimum (1 Gbps), CAT6a pour 10 Gbps
* ✅ **Documenter les VLAN** : Noter ports/VLAN dans un tableau (évite les erreurs d'isolation)
* ✅ **Privilégier la fibre pour longue distance** : > 100m = fibre obligatoire (cuivre limité)
* ✅ **Configurer le VLAN natif** : Sur liens trunk 802.1Q, définir un VLAN par défaut pour trames non taggées

---

## 📚 Vocabulaire technique :

| Terme | Définition courte |
|-------|------------------|
| **EtherType** | Champ 2 octets indiquant le protocole encapsulé (0x0800=IPv4, 0x0806=ARP, 0x86DD=IPv6) |
| **Flooding** | Switch diffuse la trame sur tous les ports (destination MAC inconnue) |
| **Learning** | Switch apprend l'association MAC/port en analysant les trames sources |
| **Préambule** | 7 octets 0xAA + 1 octet 0xAB pour synchroniser émetteur/récepteur |
| **CRC/FCS** | 4 octets de contrôle d'erreur, trame jetée si incorrect |
| **Broadcast** | Adresse MAC FF:FF:FF:FF:FF:FF = envoi à tous les hôtes du réseau |
| **Trunk (802.1Q)** | Lien inter-switch transportant plusieurs VLAN (trame taggée 4 octets) |
| **PoE** | Alimentation électrique via câble Ethernet (caméras IP, téléphones VoIP) |
| **Duplex** | Half = émission OU réception / Full = émission ET réception simultanées |

---

## 🎯 À retenir ABSOLUMENT :

1. 💡 **Théorique** : Adresse MAC = 6 octets hexa, unique par interface, bit 7/8 pour U/L et I/G
2. 💻 **Pratique** : `ip link show` (Linux) / `Get-NetAdapter` (Windows) pour voir les MAC
3. ⚠️ **Piège** : Ne JAMAIS se fier aux MAC pour la sécurité (facilement modifiables), MTU par défaut = 1500 octets

---

## 📊 Structure trame Ethernet II (à connaître par cœur) :

```
[Préambule 8 octets][MAC Dest 6][MAC Src 6][EtherType 2][Payload 46-1500][CRC 4]
│                  │            │          │            │                │
│                  └─ Début trame validé   │            └─ Données IP    └─ Contrôle erreur
└─ Synchronisation (10101010...10101011)   └─ 0x0800 (IPv4) ou 0x86DD (IPv6)
```

**Taille totale** : 64 à 1518 octets (hors préambule)  
**Gap inter-trame** : 96 bits de silence entre chaque trame

---

## 🔧 Tableau des catégories câbles RJ45 :

| Catégorie | Débit max | Distance max | Usage typique |
|-----------|-----------|--------------|---------------|
| **CAT 5** | 100 Mb/s | 100 m | Obsolète |
| **CAT 5e** | 1 Gb/s | 100 m | Standard actuel |
| **CAT 6** | 1/10 Gb/s | 100/50 m | Recommandé |
| **CAT 6a** | 10 Gb/s | 100 m | Haute performance |
| **CAT 7** | 10 Gb/s | 100 m | Blindage renforcé |
| **CAT 8** | 25-40 Gb/s | 30 m | Datacenters |

---

## 🔀 Fonctionnement du Switch (5 opérations) :

1. **Learning** : Apprend MAC source → enregistre dans table MAC avec port d'arrivée
2. **Flooding** : MAC destination inconnue → diffuse sur TOUS les ports (sauf source)
3. **Forwarding** : MAC destination connue → envoie UNIQUEMENT sur port destinataire
4. **Filtering** : Source et destination sur même port → ne transmet PAS
5. **Aging** : Efface les entrées MAC inactives après timeout (libère mémoire)

---

## 📡 VLAN - Points clés :

* **Objectif** : Séparer les domaines de broadcast sans infrastructure physique séparée
* **802.1Q** : Tag 4 octets ajouté entre MAC source et EtherType (12 bits pour VLAN ID = 4094 VLAN max)
* **Port Access** : Accepte trafic non-taggé d'un seul VLAN
* **Port Trunk** : Transporte plusieurs VLAN entre switches (trames taggées)
* **Isolation** : Hôtes de VLAN différents ne peuvent PAS communiquer directement (besoin routeur)

```
Trame normale :  [MAC Dest][MAC Src][EtherType][Payload]
Trame 802.1Q  :  [MAC Dest][MAC Src][0x8100][VLAN Tag][EtherType][Payload]
                                     └─ 4 octets (3 bits priorité + 12 bits VLAN ID)
```
