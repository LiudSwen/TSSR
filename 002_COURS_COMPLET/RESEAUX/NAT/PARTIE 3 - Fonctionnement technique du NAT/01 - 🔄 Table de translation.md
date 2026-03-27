

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

## 🗂️ Structure de la table NAT

### Qu'est-ce que la table NAT ?

La table NAT est le **cœur du mécanisme de translation d'adresses**. C'est une structure de données dynamique maintenue par le routeur NAT qui enregistre toutes les correspondances entre adresses/ports privés et publics.

> [!info] Analogie
> Pensez à la table NAT comme un **registre de correspondance postal** : chaque colis (paquet) qui entre ou sort doit être enregistré avec son adresse d'origine et sa nouvelle adresse de destination.

### Architecture de la table

La table NAT contient généralement les champs suivants :

| Champ | Description | Exemple |
|-------|-------------|---------|
| **IP Source Interne** | Adresse privée de l'hôte | `192.168.1.10` |
| **Port Source Interne** | Port utilisé par l'hôte | `54321` |
| **IP Source Externe** | Adresse publique traduite | `203.0.113.5` |
| **Port Source Externe** | Port public assigné | `12000` |
| **IP Destination** | Adresse du serveur distant | `93.184.216.34` |
| **Port Destination** | Port du service distant | `443` (HTTPS) |
| **Protocole** | Type de transport | `TCP` / `UDP` |
| **Timestamp** | Moment de création | `2025-12-17 14:30:00` |
| **TTL/Timeout** | Temps restant avant expiration | `300 secondes` |

> [!example] Exemple d'entrée complète
> ```
> Inside Local:   192.168.1.10:54321
> Inside Global:  203.0.113.5:12000
> Outside Global: 93.184.216.34:443
> Protocol:       TCP
> Created:        14:30:00
> Expires:        14:35:00
> State:          ESTABLISHED
> ```

### Types de tables selon le type de NAT

La structure de la table varie selon le type de NAT utilisé :

#### NAT Statique
```
IP Privée         ↔  IP Publique
192.168.1.50      ↔  203.0.113.10
```
- Mappings **permanents**
- Configuration **manuelle**
- Pas de notion de ports (mapping 1:1)

#### NAT Dynamique
```
IP Privée         →  IP Publique (pool)
192.168.1.10      →  203.0.113.5
192.168.1.11      →  203.0.113.6
```
- Assignation **temporaire** depuis un pool
- Pas de translation de ports
- Une IP publique = un hôte privé à la fois

#### PAT/NAT Overload
```
IP:Port Privé           ↔  IP:Port Public
192.168.1.10:54321     ↔  203.0.113.5:12000
192.168.1.11:54322     ↔  203.0.113.5:12001
192.168.1.12:54323     ↔  203.0.113.5:12002
```
- Mappings **IP + Port**
- Une seule IP publique pour plusieurs hôtes
- Le plus utilisé en pratique

---

## 🔗 Entrées et mappings

### Création d'une entrée

Une entrée dans la table NAT est créée lors de l'**envoi du premier paquet** d'une connexion sortante.

#### Processus de création (flux sortant)

1. **Paquet arrive du réseau interne**
   ```
   Source: 192.168.1.10:54321
   Dest:   93.184.216.34:443
   ```

2. **Le routeur consulte la table NAT** → Aucune entrée existante

3. **Création d'un nouveau mapping**
   - Sélection d'un port public disponible (ex: `12000`)
   - Enregistrement de la correspondance
   - Translation du paquet

4. **Paquet modifié envoyé sur Internet**
   ```
   Source: 203.0.113.5:12000
   Dest:   93.184.216.34:443
   ```

> [!tip] Attribution des ports
> Les routeurs NAT utilisent généralement une **plage de ports élevés** (1024-65535) pour éviter les conflits avec les services bien connus (0-1023).

### Utilisation d'une entrée existante

Pour les **paquets suivants** de la même connexion :

1. **Paquet sortant** : Le routeur trouve l'entrée existante et applique la même translation
2. **Paquet entrant** : Le routeur utilise la table inversée pour router vers le bon hôte interne

#### Flux bidirectionnel

```
ALLER (Inside → Outside)
Client interne          NAT Router              Serveur externe
192.168.1.10:54321  →  203.0.113.5:12000  →   93.184.216.34:443
     [SYN]               [Translation]             [SYN]

RETOUR (Outside → Inside)
93.184.216.34:443   →  203.0.113.5:12000  →   192.168.1.10:54321
   [SYN-ACK]            [Lookup + Reverse]       [SYN-ACK]
```

### Types de mappings

#### Endpoint-Independent Mapping (Full Cone)

Un seul mapping pour toutes les destinations :

```
Inside: 192.168.1.10:54321
Outside: 203.0.113.5:12000

Valide pour TOUTES les destinations :
→ 93.184.216.34:443
→ 8.8.8.8:53
→ 1.1.1.1:80
```

> [!info] Caractéristiques
> - **Avantage** : Simplifie les connexions P2P
> - **Inconvénient** : Moins sécurisé (n'importe qui peut envoyer des paquets sur ce port)

#### Address-Dependent Mapping (Restricted Cone)

Un mapping par adresse de destination :

```
Inside: 192.168.1.10:54321
Outside: 203.0.113.5:12000 → UNIQUEMENT vers 93.184.216.34
Outside: 203.0.113.5:12001 → UNIQUEMENT vers 8.8.8.8
```

> [!info] Caractéristiques
> - Plus sécurisé que Full Cone
> - Permet toujours les connexions entrantes de l'hôte distant

#### Address and Port-Dependent Mapping (Symmetric NAT)

Un mapping unique par couple IP:Port de destination :

```
Inside: 192.168.1.10:54321
Outside: 203.0.113.5:12000 → 93.184.216.34:443
Outside: 203.0.113.5:12001 → 93.184.216.34:80
Outside: 203.0.113.5:12002 → 8.8.8.8:53
```

> [!warning] Attention
> Le **Symmetric NAT** est le plus sécurisé mais pose des problèmes pour :
> - Les applications P2P (VoIP, visioconférence)
> - Les jeux en ligne
> - Certains VPN
> 
> Il nécessite souvent des techniques de traversée de NAT (STUN, TURN, ICE).

### Consultation de la table NAT

Sur un routeur Cisco, vous pouvez visualiser la table avec :

```bash
# Afficher toutes les translations actives
Router# show ip nat translations

# Afficher les translations pour une IP spécifique
Router# show ip nat translations inside 192.168.1.10

# Afficher les statistiques NAT
Router# show ip nat statistics

# Effacer les translations dynamiques
Router# clear ip nat translation *
```

> [!example] Exemple de sortie
> ```
> Pro Inside global      Inside local       Outside local      Outside global
> tcp 203.0.113.5:12000  192.168.1.10:54321 93.184.216.34:443  93.184.216.34:443
> tcp 203.0.113.5:12001  192.168.1.11:54322 8.8.8.8:53         8.8.8.8:53
> udp 203.0.113.5:12002  192.168.1.12:54323 1.1.1.1:53         1.1.1.1:53
> ```

---

## ⏱️ Durée de vie des sessions

### Concept de timeout

Les entrées NAT ne restent pas **indéfiniment** dans la table. Elles ont une **durée de vie limitée** pour :

- **Libérer les ports** publics pour d'autres connexions
- **Économiser la mémoire** du routeur
- **Améliorer la sécurité** (fermer les connexions inactives)

> [!info] Pourquoi un timeout ?
> Sans timeout, un routeur NAT pourrait rapidement **épuiser ses 65535 ports** disponibles, même si la plupart des connexions sont inactives depuis longtemps.

### Durées par défaut selon le protocole

| Protocole | État | Timeout par défaut | Justification |
|-----------|------|-------------------|---------------|
| **TCP** | SYN envoyé | 60 secondes | Attente du SYN-ACK |
| **TCP** | ESTABLISHED | 24 heures (86400 sec) | Connexion active |
| **TCP** | FIN envoyé | 60 secondes | Fermeture en cours |
| **UDP** | N/A | 5 minutes (300 sec) | Sans état, délai court |
| **ICMP** | Echo Request | 60 secondes | Ping rapide |

> [!warning] Variations importantes
> Ces valeurs sont des **recommandations RFC**. Dans la pratique :
> - Les box Internet : souvent **2-5 minutes pour UDP**
> - Les firewalls d'entreprise : peuvent aller jusqu'à **1 heure pour TCP établi**
> - Les routeurs NAT stricts : **30 secondes pour UDP**

### Mécanisme de rafraîchissement

#### Pour TCP (avec état)

Le timeout se **réinitialise** à chaque paquet échangé :

```
T=0     Client envoie SYN          → Timer = 24h
T=1s    Serveur répond SYN-ACK     → Timer = 24h (reset)
T=10s   Client envoie données      → Timer = 24h (reset)
T=20s   Serveur répond             → Timer = 24h (reset)
...
T=24h   Aucun paquet depuis 24h    → Entrée supprimée
```

> [!tip] TCP Keepalive
> Pour maintenir une connexion TCP ouverte à travers le NAT, les applications peuvent envoyer des **TCP Keepalive** :
> ```bash
> # Exemple Linux : keepalive toutes les 60 secondes
> setsockopt(sock, SOL_SOCKET, SO_KEEPALIVE, 1)
> setsockopt(sock, IPPROTO_TCP, TCP_KEEPIDLE, 60)
> ```

#### Pour UDP (sans état)

UDP n'ayant **pas de notion de connexion**, le timer démarre dès le premier paquet et **n'est pas réinitialisé automatiquement** :

```
T=0     Client envoie paquet UDP   → Timer = 5 min
T=30s   Serveur répond             → Timer = 5 min (reset)
T=4min  Silence total              → Timer décrémente
T=5min  Timeout atteint            → Entrée supprimée
```

> [!warning] Problème typique : VoIP et jeux en ligne
> Beaucoup d'applications temps réel utilisent UDP. Si elles n'envoient rien pendant 5 minutes (ex: mise en pause d'un jeu), le mapping NAT **disparaît** et la connexion est **perdue**.
> 
> **Solution** : Envoyer des paquets **keepalive** toutes les 30-60 secondes.

### Configuration des timeouts

#### Sur routeur Cisco

```bash
# Configuration des timeouts NAT
Router(config)# ip nat translation timeout 300
Router(config)# ip nat translation tcp-timeout 3600
Router(config)# ip nat translation udp-timeout 120
Router(config)# ip nat translation finrst-timeout 30
Router(config)# ip nat translation icmp-timeout 60

# Vérifier les timeouts configurés
Router# show ip nat statistics
```

#### Sur Linux (iptables/netfilter)

```bash
# Afficher les timeouts actuels
cat /proc/sys/net/netfilter/nf_conntrack_tcp_timeout_established
cat /proc/sys/net/netfilter/nf_conntrack_udp_timeout

# Modifier les timeouts (en secondes)
echo 3600 > /proc/sys/net/netfilter/nf_conntrack_tcp_timeout_established
echo 120 > /proc/sys/net/netfilter/nf_conntrack_udp_timeout

# Rendre permanent (dans /etc/sysctl.conf)
net.netfilter.nf_conntrack_tcp_timeout_established = 3600
net.netfilter.nf_conntrack_udp_timeout = 120
```

### Saturation de la table NAT

#### Signes de saturation

Quand la table NAT est **pleine**, les symptômes incluent :

- ❌ **Impossibilité d'ouvrir de nouvelles connexions**
- ❌ **Erreurs "Connection refused" aléatoires**
- ❌ **Lenteur généralisée du réseau**
- ❌ **Messages logs "NAT table full"**

#### Limites typiques

| Type d'équipement | Limite approximative |
|-------------------|---------------------|
| Box Internet domestique | 4 000 - 10 000 sessions |
| Routeur SMB (PME) | 50 000 - 100 000 sessions |
| Firewall entreprise | 1 000 000+ sessions |

> [!example] Calcul rapide
> Une famille de 4 personnes avec :
> - 10 onglets web ouverts par personne = 40 connexions HTTP(S)
> - 2 smartphones en streaming = 4 connexions
> - 1 console de jeu = 20-50 connexions
> - Services en arrière-plan (mises à jour, sync) = 50+ connexions
> 
> **Total** : ~150 sessions actives (bien en dessous des limites)

#### Solutions en cas de saturation

1. **Réduire les timeouts** (surtout UDP)
   ```bash
   ip nat translation udp-timeout 60
   ```

2. **Augmenter la mémoire dédiée au NAT**
   ```bash
   Router(config)# ip nat translation max-entries 100000
   ```

3. **Identifier les clients gourmands**
   ```bash
   # Afficher le nombre de sessions par IP interne
   show ip nat translations | include 192.168.1
   ```

4. **Passer à un équipement plus performant**

> [!tip] Astuce de diagnostic
> Sur Linux, surveillez la table de connexions :
> ```bash
> # Nombre total de connexions trackées
> cat /proc/sys/net/netfilter/nf_conntrack_count
> 
> # Limite maximale
> cat /proc/sys/net/netfilter/nf_conntrack_max
> 
> # Afficher les connexions par IP
> conntrack -L | awk '{print $5}' | sort | uniq -c | sort -rn | head
> ```

### Pièges courants liés aux timeouts

#### 1. Sessions TCP "zombies"

```
Problème : Connexion TCP établie mais le client crash sans envoyer FIN
Résultat : L'entrée NAT reste active pendant 24h
Impact   : Gaspillage de ports publics
```

**Solution** : Activer TCP keepalive côté application

#### 2. UDP et applications temps réel

```
Problème : Application VoIP/Gaming en pause > 5 minutes
Résultat : Le mapping NAT expire
Impact   : Perte de connexion au retour
```

**Solution** : Envoyer des keepalive UDP toutes les 30-60 secondes

#### 3. FTP et timeouts courts

```
Problème : FTP établit une connexion de contrôle, puis des connexions de données
Résultat : Si timeout trop court, les connexions de données échouent
Impact   : Transferts FTP interrompus
```

**Solution** : Utiliser FTP passif ou augmenter les timeouts

#### 4. Sessions HTTP/2 et HTTP/3

```
Problème : Ces protocoles maintiennent UNE connexion longue durée
Résultat : Si la connexion est idle > timeout, elle est coupée
Impact   : L'application doit se reconnecter
```

**Solution** : Configurer des timeouts longs (1h+) pour TCP établi

---

## 🎯 Bonnes pratiques

### Pour les administrateurs réseau

✅ **Adapter les timeouts à l'usage**
```bash
# Réseau bureautique standard
tcp-timeout 3600      # 1 heure
udp-timeout 300       # 5 minutes

# Réseau avec VoIP/Gaming
udp-timeout 600       # 10 minutes

# Datacentre/serveurs
tcp-timeout 86400     # 24 heures
```

✅ **Monitorer la table NAT**
```bash
# Script de surveillance (à mettre dans cron)
#!/bin/bash
CURRENT=$(cat /proc/sys/net/netfilter/nf_conntrack_count)
MAX=$(cat /proc/sys/net/netfilter/nf_conntrack_max)
PERCENT=$((CURRENT * 100 / MAX))

if [ $PERCENT -gt 80 ]; then
    echo "ALERT: NAT table at ${PERCENT}% capacity"
fi
```

✅ **Logger les événements NAT**
```bash
Router(config)# ip nat log translations syslog
```

### Pour les développeurs d'applications

✅ **Implémenter des keepalives**
```python
# Exemple Python : keepalive UDP toutes les 30s
import socket
import time

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
while True:
    sock.sendto(b"keepalive", (server_ip, server_port))
    time.sleep(30)
```

✅ **Gérer les déconnexions NAT**
```javascript
// Exemple JavaScript : reconnexion automatique
websocket.onclose = function() {
    console.log("Connection lost, reconnecting...");
    setTimeout(connect, 1000); // Reconnexion après 1s
};
```

✅ **Utiliser des timeouts applicatifs plus courts que les timeouts NAT**
```
Timeout NAT = 300s (5 min)
→ Votre application : timeout = 240s (4 min)
→ Permet de détecter et fermer proprement avant expiration NAT
```

---

## 📊 Astuces de troubleshooting

### Vérifier l'état d'une connexion

```bash
# Cisco
show ip nat translations verbose

# Linux
conntrack -L | grep 192.168.1.10

# Afficher avec les timeouts restants
conntrack -L -o extended | grep 192.168.1.10
```

### Débugger le NAT en temps réel

```bash
# Cisco
debug ip nat detailed
debug ip nat translation

# Linux (netfilter)
echo 1 > /proc/sys/net/netfilter/nf_log_all_netns
dmesg -w | grep NAT
```

### Forcer la suppression d'une entrée

```bash
# Cisco - supprimer toutes les translations
clear ip nat translation *

# Cisco - supprimer une translation spécifique
clear ip nat translation tcp inside 192.168.1.10 54321

# Linux - supprimer une connexion spécifique
conntrack -D -s 192.168.1.10 -p tcp --dport 443
```

> [!warning] Attention
> Supprimer une entrée NAT **coupe immédiatement** la connexion correspondante. À utiliser uniquement pour du troubleshooting ou pour libérer des ressources en urgence.