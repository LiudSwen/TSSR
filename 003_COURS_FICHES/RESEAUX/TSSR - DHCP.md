# ⚡ L'essentiel en 5 minutes - DHCP (Dynamic Host Configuration Protocol)

## 📌 C'est quoi en 2 lignes ?

Protocole permettant l'attribution **automatique** des paramètres réseau IP (adresse, masque, passerelle, DNS) aux machines d'un réseau. Évite la configuration manuelle et centralise la gestion pour éviter erreurs humaines et conflits d'IP.

---

## 💡 Concepts clés à retenir :

- **DHCP** : Protocole client/serveur (RFC 2131/2132) pour automatiser la configuration IP
- **Bail (lease)** : Durée pendant laquelle une adresse IP est réservée à un client
- **Étendue (scope)** : Plage d'adresses IP gérée par le serveur DHCP
- **Réservation** : Attribution d'une IP fixe à une adresse MAC spécifique
- **DORA** : Séquence standard d'échange DHCP (Discover, Offer, Request, Acknowledge)

---

## 💻 Syntaxe et ports essentiels :


```bash
# 🌐 Ports UDP
Port 67 : Serveur DHCP (écoute)
Port 68 : Client DHCP (réception)

# 📡 Adresses spéciales
0.0.0.0          # IP source du client sans config
255.255.255.255  # Broadcast pour DHCPDISCOVER
```


```bash
# 🔄 Séquence DORA complète
1. DHCPDISCOVER  # Client → Broadcast : "Cherche serveur DHCP"
2. DHCPOFFER     # Serveur → Client : "Voici une IP disponible"
3. DHCPREQUEST   # Client → Serveur : "J'accepte cette IP"
4. DHCPACK       # Serveur → Client : "IP réservée, paramètres envoyés"
```

---

## 📋 Messages DHCP supplémentaires :

| Message | Direction | Rôle |
|---------|-----------|------|
| **DHCPNACK** | Serveur → Client | Refus de réservation (IP invalide) |
| **DHCPDECLINE** | Client → Serveur | IP déjà utilisée (détecté par ARP) |
| **DHCPRELEASE** | Client → Serveur | Résiliation du bail (libère l'IP) |
| **DHCPINFORM** | Client → Serveur | Demande paramètres sans IP (déjà configuré) |

---

## ⚙️ Paramètres distribués par DHCP :

**Obligatoires :**
* Adresse IP
* Masque de sous-réseau (CIDR)
* Durée du bail

**Optionnels (Options DHCP) :**
* Passerelle par défaut (Option 3)
* Serveurs DNS (Option 6)
* Nom de domaine (Option 15)
* Serveur TFTP/PXE (Options 66/67)
* Serveurs NTP (Option 42)

---

## 🔄 Cas d'utilisation pratiques :

### Cas 1 : Première connexion
```
DHCPDISCOVER → DHCPOFFER → DHCPREQUEST → DHCPACK
```

### Cas 2 : Redémarrage (IP toujours valide)
```
DHCPREQUEST direct → DHCPACK (si OK) ou DHCPNACK (si expirée)
```

### Cas 3 : Expiration du bail
```
DHCPNACK → DHCPDISCOVER (nouvelle séquence DORA)
```

### Cas 4 : Changement de réseau
```
DHCPNACK (IP hors sous-réseau) → DHCPDISCOVER
```

---

## ⚠️ Pièges à éviter :

- ❌ **Identification par MAC seule** : Les adresses MAC ne sont PAS fiables (spoofing, VMs) → Utiliser **Option 61 Client Identifier** (IPv4) ou **DUID** (IPv6)
- ❌ **Pas de relais DHCP** : Les broadcasts ne traversent pas les routeurs → Configurer **ip-helper** sur routeurs pour joindre serveur DHCP distant
- ❌ **Doublons d'IP** : Sans DHCP, risque de conflits → Le client doit vérifier via ARP après DHCPACK (envoi DHCPDECLINE si occupée)

---

## ✅ Bonnes pratiques :

- ✅ **Bail adapté** : Court pour appareils nomades (smartphones), long pour postes fixes
- ✅ **Réservations** : Pour serveurs, imprimantes, équipements critiques (IP fixe via MAC/Client ID)
- ✅ **Documentation** : Maintenir plan d'adressage avec étendues et réservations à jour
- ✅ **Redondance** : Déployer plusieurs serveurs DHCP coordonnés (tolérance de pannes)
- ✅ **Surveillance** : Monitorer les logs pour détecter comportements anormaux (attaques)

---

## 📚 Vocabulaire technique :

|Terme|Définition courte|
|---|---|
|**Bail (lease)**|Durée de réservation d'une IP à un client|
|**Étendue (scope)**|Plage d'adresses IP gérée par le serveur|
|**Domaine de collision**|Zone réseau où les broadcasts DHCP sont propagés (limité par routeurs)|
|**BOOTP**|Ancêtre de DHCP pour démarrage réseau (diskless)|
|**PXE**|Démarrage réseau via TFTP (utilise options DHCP 66/67)|
|**RARP**|Protocole obsolète résolvant MAC → IP (remplacé par BOOTP puis DHCP)|

---

## 🎯 À retenir ABSOLUMENT :

1. 💡 **Théorique** : Séquence **DORA** = Discover, Offer, Request, Acknowledge (échange minimal fonctionnel)
2. 💻 **Pratique** : Ports **UDP 67 (serveur) / 68 (client)** + Broadcast **255.255.255.255** pour DISCOVER
3. ⚠️ **Piège** : Identification MAC seule **NON fiable** → Activer Option 61 ou DUID pour tracking client sécurisé