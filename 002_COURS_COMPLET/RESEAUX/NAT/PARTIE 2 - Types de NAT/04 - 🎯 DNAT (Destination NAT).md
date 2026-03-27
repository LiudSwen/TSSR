
---

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

## 🔄 Principe de fonctionnement

Le **DNAT (Destination Network Address Translation)** est une technique de translation qui modifie l'**adresse IP de destination** et/ou le **port de destination** d'un paquet réseau.

> [!info] Définition Contrairement au SNAT qui modifie la source, le DNAT transforme la destination d'un paquet pour le rediriger vers une autre machine ou un autre service.

### Fonctionnement en détail

1. **Paquet entrant** : Un paquet arrive sur le routeur/firewall avec une destination publique
2. **Table de NAT** : Le système consulte sa table de règles DNAT
3. **Translation** : L'adresse et/ou le port de destination sont modifiés
4. **Routage** : Le paquet est redirigé vers la nouvelle destination (généralement interne)
5. **Retour** : Les réponses suivent le chemin inverse avec translation automatique

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│   Internet  │ ──────> │   Firewall   │ ──────> │   Serveur   │
│             │         │   (DNAT)     │         │   Interne   │
│ Vers:       │         │              │         │             │
│ 203.0.113.5 │         │ Traduit vers │         │ 192.168.1.10│
│ Port: 80    │         │ 192.168.1.10 │         │ Port: 8080  │
└─────────────┘         └──────────────┘         └─────────────┘
```

> [!warning] Point d'attention Le DNAT s'applique dans la chaîne **PREROUTING** d'iptables, car la translation doit se faire **avant** la décision de routage.

---

## 📍 Translation de l'adresse de destination

### Principe de base

La translation d'adresse de destination consiste à remplacer l'IP de destination d'un paquet par une autre IP, permettant ainsi de rediriger le trafic vers un serveur spécifique du réseau interne.

### Syntaxe iptables

```bash
# Syntaxe générale
iptables -t nat -A PREROUTING -d <IP_PUBLIQUE> -j DNAT --to-destination <IP_PRIVÉE>

# Exemple concret
iptables -t nat -A PREROUTING -d 203.0.113.5 -j DNAT --to-destination 192.168.1.10
```

> [!example] Exemple pratique
> 
> ```bash
> # Rediriger tout le trafic vers 203.0.113.5 vers le serveur web interne
> iptables -t nat -A PREROUTING -i eth0 -d 203.0.113.5 -j DNAT --to-destination 192.168.1.10
> 
> # Avec interface spécifique
> iptables -t nat -A PREROUTING -i eth0 -p tcp -d 203.0.113.5 -j DNAT --to-destination 192.168.1.10
> ```

### Paramètres détaillés

|Paramètre|Description|Obligatoire|
|---|---|---|
|`-t nat`|Spécifie la table NAT|✅ Oui|
|`-A PREROUTING`|Ajoute la règle dans PREROUTING|✅ Oui|
|`-d <IP>`|Adresse de destination à matcher|⚠️ Recommandé|
|`-i <interface>`|Interface d'entrée|⚠️ Recommandé|
|`-p <protocole>`|Protocole (tcp, udp, icmp...)|❌ Optionnel|
|`--to-destination`|Nouvelle destination|✅ Oui|

### Translation vers une plage d'IP

```bash
# Répartition sur plusieurs serveurs (load balancing basique)
iptables -t nat -A PREROUTING -d 203.0.113.5 -j DNAT --to-destination 192.168.1.10-192.168.1.15

# Avec algorithme de répartition
iptables -t nat -A PREROUTING -d 203.0.113.5 -m statistic --mode random --probability 0.5 \
    -j DNAT --to-destination 192.168.1.10
iptables -t nat -A PREROUTING -d 203.0.113.5 \
    -j DNAT --to-destination 192.168.1.11
```

---

## 🔀 Redirection de ports (Port Forwarding)

### Concept fondamental

Le **Port Forwarding** est une forme spécifique de DNAT qui modifie à la fois l'adresse IP de destination **et** le port de destination. C'est la technique la plus utilisée pour exposer des services internes.

> [!info] Pourquoi c'est important Le Port Forwarding permet d'héberger plusieurs services sur une seule IP publique en utilisant différents ports, et d'améliorer la sécurité en masquant les ports réels des services.

### Syntaxe complète

```bash
# Syntaxe générale
iptables -t nat -A PREROUTING -p <protocole> -d <IP_PUBLIQUE> --dport <PORT_PUBLIC> \
    -j DNAT --to-destination <IP_PRIVÉE>:<PORT_PRIVÉ>

# Exemple : Redirection HTTP standard
iptables -t nat -A PREROUTING -p tcp -d 203.0.113.5 --dport 80 \
    -j DNAT --to-destination 192.168.1.10:8080
```

### Exemples pratiques courants

```bash
# 1. Serveur Web (HTTP) - Port standard vers port personnalisé
iptables -t nat -A PREROUTING -i eth0 -p tcp -d 203.0.113.5 --dport 80 \
    -j DNAT --to-destination 192.168.1.10:8080

# 2. Serveur Web sécurisé (HTTPS)
iptables -t nat -A PREROUTING -i eth0 -p tcp -d 203.0.113.5 --dport 443 \
    -j DNAT --to-destination 192.168.1.10:443

# 3. Serveur SSH - Port non standard vers port standard
iptables -t nat -A PREROUTING -i eth0 -p tcp -d 203.0.113.5 --dport 2222 \
    -j DNAT --to-destination 192.168.1.20:22

# 4. Serveur FTP
iptables -t nat -A PREROUTING -i eth0 -p tcp -d 203.0.113.5 --dport 21 \
    -j DNAT --to-destination 192.168.1.30:21

# 5. Serveur de jeu (exemple : Minecraft)
iptables -t nat -A PREROUTING -i eth0 -p tcp -d 203.0.113.5 --dport 25565 \
    -j DNAT --to-destination 192.168.1.40:25565

# 6. Serveur RDP (Remote Desktop)
iptables -t nat -A PREROUTING -i eth0 -p tcp -d 203.0.113.5 --dport 3389 \
    -j DNAT --to-destination 192.168.1.50:3389

# 7. Redirection UDP (exemple : DNS)
iptables -t nat -A PREROUTING -i eth0 -p udp -d 203.0.113.5 --dport 53 \
    -j DNAT --to-destination 192.168.1.60:53
```

### Redirection de plages de ports

```bash
# Plage de ports consécutifs (exemple : FTP passif)
iptables -t nat -A PREROUTING -i eth0 -p tcp -d 203.0.113.5 \
    --dport 50000:50100 -j DNAT --to-destination 192.168.1.30

# Plusieurs ports spécifiques (multiport)
iptables -t nat -A PREROUTING -i eth0 -p tcp -d 203.0.113.5 \
    -m multiport --dports 80,443,8080,8443 \
    -j DNAT --to-destination 192.168.1.10
```

> [!tip] Astuce professionnelle Utilisez des ports non standards côté public pour réduire les scans automatiques et les attaques opportunistes. Par exemple, exposez SSH sur le port 2222 au lieu de 22.

### Schéma de redirection multi-services

```
Internet (203.0.113.5)
         │
         ├─ Port 80    ──> 192.168.1.10:8080  (Serveur Web)
         ├─ Port 443   ──> 192.168.1.10:443   (HTTPS)
         ├─ Port 2222  ──> 192.168.1.20:22    (SSH Admin)
         ├─ Port 3306  ──> 192.168.1.30:3306  (MySQL)
         └─ Port 25565 ──> 192.168.1.40:25565 (Minecraft)
```

---

## 🌐 Cas d'usage : exposition de services internes

### Scénarios d'utilisation typiques

#### 1. Hébergement de serveur web

```bash
# Configuration complète pour un serveur web interne
# HTTP
iptables -t nat -A PREROUTING -i eth0 -p tcp -d 203.0.113.5 --dport 80 \
    -j DNAT --to-destination 192.168.1.10:80

# HTTPS
iptables -t nat -A PREROUTING -i eth0 -p tcp -d 203.0.113.5 --dport 443 \
    -j DNAT --to-destination 192.168.1.10:443

# Autoriser le forwarding (nécessaire!)
iptables -A FORWARD -p tcp -d 192.168.1.10 --dport 80 -j ACCEPT
iptables -A FORWARD -p tcp -d 192.168.1.10 --dport 443 -j ACCEPT
```

> [!warning] N'oubliez pas le FORWARD Le DNAT seul ne suffit pas ! Vous devez également autoriser le trafic dans la chaîne FORWARD pour que les paquets soient réellement acheminés vers le serveur interne.

#### 2. Accès distant sécurisé (SSH)

```bash
# SSH sur port non standard pour la sécurité
iptables -t nat -A PREROUTING -i eth0 -p tcp -d 203.0.113.5 --dport 2222 \
    -j DNAT --to-destination 192.168.1.20:22

# Avec limitation de source (whitelist IP)
iptables -t nat -A PREROUTING -i eth0 -p tcp -s 198.51.100.0/24 \
    -d 203.0.113.5 --dport 2222 -j DNAT --to-destination 192.168.1.20:22

# Règle FORWARD correspondante
iptables -A FORWARD -p tcp -d 192.168.1.20 --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
```

#### 3. Serveur de base de données (accès restreint)

```bash
# MySQL accessible uniquement depuis certaines IP
iptables -t nat -A PREROUTING -i eth0 -p tcp -s 198.51.100.0/24 \
    -d 203.0.113.5 --dport 3306 -j DNAT --to-destination 192.168.1.30:3306

# PostgreSQL
iptables -t nat -A PREROUTING -i eth0 -p tcp -s 198.51.100.0/24 \
    -d 203.0.113.5 --dport 5432 -j DNAT --to-destination 192.168.1.31:5432
```

> [!warning] Sécurité des bases de données N'exposez JAMAIS directement une base de données sur Internet sans restrictions d'IP source. Utilisez toujours un VPN ou une whitelist stricte.

#### 4. Services de messagerie

```bash
# Serveur SMTP
iptables -t nat -A PREROUTING -i eth0 -p tcp -d 203.0.113.5 --dport 25 \
    -j DNAT --to-destination 192.168.1.40:25

# IMAP
iptables -t nat -A PREROUTING -i eth0 -p tcp -d 203.0.113.5 --dport 993 \
    -j DNAT --to-destination 192.168.1.40:993

# Submission (SMTP sécurisé)
iptables -t nat -A PREROUTING -i eth0 -p tcp -d 203.0.113.5 --dport 587 \
    -j DNAT --to-destination 192.168.1.40:587
```

#### 5. Configuration multi-environnement

```bash
# Production (port 80)
iptables -t nat -A PREROUTING -i eth0 -p tcp -d 203.0.113.5 --dport 80 \
    -j DNAT --to-destination 192.168.1.10:80

# Staging (port 8080)
iptables -t nat -A PREROUTING -i eth0 -p tcp -d 203.0.113.5 --dport 8080 \
    -j DNAT --to-destination 192.168.1.11:80

# Development (port 8081)
iptables -t nat -A PREROUTING -i eth0 -p tcp -d 203.0.113.5 --dport 8081 \
    -j DNAT --to-destination 192.168.1.12:80
```

#### 6. Load Balancing simple

```bash
# Répartition aléatoire entre deux serveurs web
iptables -t nat -A PREROUTING -i eth0 -p tcp -d 203.0.113.5 --dport 80 \
    -m statistic --mode random --probability 0.5 \
    -j DNAT --to-destination 192.168.1.10:80

iptables -t nat -A PREROUTING -i eth0 -p tcp -d 203.0.113.5 --dport 80 \
    -j DNAT --to-destination 192.168.1.11:80
```

### Architecture typique avec DNAT

```
                          ┌─────────────────────┐
                          │     Internet        │
                          └──────────┬──────────┘
                                     │
                                     │ 203.0.113.5
                          ┌──────────▼──────────┐
                          │   Firewall/Router   │
                          │    (DNAT Rules)     │
                          └──────────┬──────────┘
                                     │ 192.168.1.1
                    ┌────────────────┼────────────────┐
                    │                │                │
          ┌─────────▼────────┐  ┌───▼─────────┐  ┌──▼──────────┐
          │  Web Server      │  │  SSH Server │  │  DB Server  │
          │  192.168.1.10:80 │  │ 192.168.1.20│  │192.168.1.30 │
          │  (Port 80, 443)  │  │  (Port 22)  │  │ (Port 3306) │
          └──────────────────┘  └─────────────┘  └─────────────┘
```

---

## ⚖️ Différence avec SNAT (Source NAT)

### Comparaison fondamentale

|Critère|DNAT|SNAT|
|---|---|---|
|**Champ modifié**|Adresse/Port de **destination**|Adresse/Port de **source**|
|**Chaîne iptables**|`PREROUTING`|`POSTROUTING`|
|**Direction**|Trafic **entrant**|Trafic **sortant**|
|**Objectif**|Exposer des services internes|Masquer le réseau interne|
|**Usage typique**|Port forwarding, reverse proxy|NAT sortant, partage connexion|

### Visualisation comparative

#### DNAT (trafic entrant)

```
AVANT DNAT:
┌──────────┐         ┌──────────┐         ┌──────────┐
│ Internet │ ──────> │ Firewall │    ?    │  Serveur │
│          │         │          │         │  Interne │
│ SRC: X   │         │          │         │          │
│ DST: PUB │         │          │         │          │
└──────────┘         └──────────┘         └──────────┘

APRÈS DNAT:
┌──────────┐         ┌──────────┐         ┌──────────┐
│ Internet │         │ Firewall │ ──────> │  Serveur │
│          │         │  (DNAT)  │         │  Interne │
│ SRC: X   │         │          │         │          │
│ DST: PUB │         │ DST: PRIV│         │          │
└──────────┘         └──────────┘         └──────────┘
```

#### SNAT (trafic sortant)

```
AVANT SNAT:
┌──────────┐         ┌──────────┐         ┌──────────┐
│  Serveur │ ──────> │ Firewall │    ?    │ Internet │
│  Interne │         │          │         │          │
│          │         │          │         │          │
│ SRC: PRIV│         │          │         │ DST: X   │
└──────────┘         └──────────┘         └──────────┘

APRÈS SNAT:
┌──────────┐         ┌──────────┐         ┌──────────┐
│  Serveur │         │ Firewall │ ──────> │ Internet │
│  Interne │         │  (SNAT)  │         │          │
│          │         │          │         │          │
│ SRC: PRIV│         │ SRC: PUB │         │ DST: X   │
└──────────┘         └──────────┘         └──────────┘
```

### Utilisation conjointe

> [!info] Complémentarité DNAT et SNAT sont souvent utilisés ensemble dans une configuration réseau complète :
> 
> - **DNAT** pour permettre l'accès aux services internes depuis l'extérieur
> - **SNAT** pour permettre aux machines internes d'accéder à Internet

```bash
# Configuration complète avec DNAT + SNAT

# DNAT : Redirection du port 80 vers le serveur web interne
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 \
    -j DNAT --to-destination 192.168.1.10:80

# SNAT : Masquerade pour la sortie Internet des machines internes
iptables -t nat -A POSTROUTING -o eth0 -s 192.168.1.0/24 -j MASQUERADE

# FORWARD : Autoriser le trafic
iptables -A FORWARD -i eth0 -o eth1 -p tcp --dport 80 -d 192.168.1.10 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
```

### Points de translation dans le flux

```
Paquet entrant (DNAT) :
   [Internet] ──> PREROUTING (DNAT) ──> ROUTING ──> FORWARD ──> [Serveur interne]
                       │
                       └─> Modification de la DESTINATION

Paquet sortant (SNAT) :
   [Machine interne] ──> ROUTING ──> FORWARD ──> POSTROUTING (SNAT) ──> [Internet]
                                                        │
                                                        └─> Modification de la SOURCE
```

---

## ⚠️ Pièges courants et bonnes pratiques

### Pièges à éviter

#### 1. Oublier les règles FORWARD

```bash
# ❌ ERREUR : Seulement le DNAT
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.1.10:80

# ✅ CORRECT : DNAT + FORWARD
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.1.10:80
iptables -A FORWARD -p tcp -d 192.168.1.10 --dport 80 -j ACCEPT
iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
```

> [!warning] Règle d'or Tout DNAT doit être accompagné d'une règle FORWARD correspondante, sinon les paquets seront bloqués après la translation.

#### 2. Ne pas activer l'IP forwarding

```bash
# Vérifier l'état
cat /proc/sys/net/ipv4/ip_forward
# Si = 0, l'activer

# ✅ Activation temporaire
echo 1 > /proc/sys/net/ipv4/ip_forward

# ✅ Activation permanente
# Éditer /etc/sysctl.conf
net.ipv4.ip_forward = 1

# Appliquer
sysctl -p
```

#### 3. Ordre des règles incorrect

```bash
# ❌ ERREUR : Règle générique avant règle spécifique
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.1.10
iptables -t nat -A PREROUTING -s 198.51.100.5 -p tcp --dport 80 -j DNAT --to-destination 192.168.1.11

# ✅ CORRECT : Règle spécifique en premier
iptables -t nat -A PREROUTING -s 198.51.100.5 -p tcp --dport 80 -j DNAT --to-destination 192.168.1.11
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.1.10
```

#### 4. Problème avec hairpin NAT (loopback)

> [!warning] Hairpin NAT Si des machines du réseau interne essaient d'accéder au service via l'IP publique, elles seront bloquées sans configuration spéciale.

```bash
# Solution : Ajouter une règle SNAT pour le trafic interne
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -d 192.168.1.10 \
    -p tcp --dport 80 -j MASQUERADE
```

### Bonnes pratiques

#### 1. Documentation des règles

```bash
# Ajoutez des commentaires explicites
iptables -t nat -A PREROUTING -p tcp --dport 80 \
    -j DNAT --to-destination 192.168.1.10:80 \
    -m comment --comment "Web-Server-Production"

# Listez les règles avec commentaires
iptables -t nat -L PREROUTING -n -v --line-numbers
```

#### 2. Limitation par interface

```bash
# ✅ Toujours spécifier l'interface source
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 \
    -j DNAT --to-destination 192.168.1.10:80

# Évite les redirections non désirées depuis d'autres interfaces
```

#### 3. Utilisation de stateful rules

```bash
# Autoriser les connexions établies et liées
iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT

# Puis seulement les nouvelles connexions DNAT
iptables -A FORWARD -p tcp -d 192.168.1.10 --dport 80 -m state --state NEW -j ACCEPT
```

#### 4. Logging pour le debug

```bash
# Log des paquets DNAT avant la règle finale
iptables -t nat -A PREROUTING -p tcp --dport 80 \
    -j LOG --log-prefix "DNAT-HTTP: " --log-level 4

iptables -t nat -A PREROUTING -p tcp --dport 80 \
    -j DNAT --to-destination 192.168.1.10:80

# Visualiser les logs
tail -f /var/log/kern.log | grep DNAT
```

#### 5. Sauvegarde et restauration

```bash
# ✅ Sauvegarder les règles
iptables-save > /etc/iptables/rules.v4

# ✅ Restaurer les règles
iptables-restore < /etc/iptables/rules.v4

# Pour Debian/Ubuntu : installer iptables-persistent
apt-get install iptables-persistent
```

#### 6. Tests de configuration

```bash
# Tester depuis l'extérieur
curl http://203.0.113.5

# Vérifier les connexions actives
conntrack -L | grep 192.168.1.10

# Tracer le chemin du paquet
iptables -t raw -A PREROUTING -p tcp --dport 80 -j TRACE
iptables -t raw -A OUTPUT -p tcp --dport 80 -j TRACE
# Voir les logs avec: tail -f /var/log/kern.log
```

> [!tip] Astuce de production Créez un script de test automatique qui vérifie la disponibilité de tous vos services DNAT après chaque modification de règles.

### Checklist de vérification

- [ ] IP forwarding activé (`ip_forward = 1`)
- [ ] Règle DNAT dans PREROUTING
- [ ] Règle FORWARD correspondante
- [ ] Interface source spécifiée (`-i`)
- [ ] Commentaires ajoutés pour la documentation
- [ ] Règles sauvegardées
- [ ] Tests effectués depuis l'extérieur
- [ ] Logs vérifiés
- [ ] Hairpin NAT configuré si nécessaire
- [ ] Politiques de sécurité appliquées (whitelist IP si nécessaire)

---

> [!tip] Astuce finale Utilisez `nft` (nftables) pour les nouvelles installations, car il remplace progressivement iptables et offre une syntaxe plus claire. Les concepts DNAT restent identiques !

```bash
# Exemple avec nftables
nft add rule nat prerouting tcp dport 80 dnat to 192.168.1.10:8080
```