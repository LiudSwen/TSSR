

## 📑 Table des matières

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

## 🎯 Introduction aux logs pfSense

Les journaux (logs) de pfSense sont essentiels pour la surveillance, le dépannage et la sécurité de votre infrastructure réseau. Ils enregistrent tous les événements système, les connexions réseau, les actions du pare-feu et bien plus encore.

> [!info] Pourquoi les logs sont importants
> 
> - **Sécurité** : Détection des tentatives d'intrusion et des comportements anormaux
> - **Dépannage** : Identification rapide des problèmes de connectivité
> - **Conformité** : Preuve d'activité pour les audits
> - **Optimisation** : Analyse des performances et de l'utilisation du réseau

### Emplacement des logs

Les logs pfSense sont stockés en mémoire par défaut (volatile) pour préserver la durée de vie du stockage. Ils sont accessibles via :

- **Interface web** : Status → System Logs
- **Ligne de commande** : `/var/log/`
- **Syslog distant** : Configuration possible pour archivage permanent

> [!warning] Logs en mémoire volatile Par défaut, les logs sont perdus au redémarrage. Pour une conservation permanente, configurez un serveur Syslog distant ou activez le logging sur disque (déconseillé sur SSD).

---

## 📋 Types de journaux

### Logs système

**Accès** : Status → System Logs → System

Les logs système enregistrent tous les événements liés au fonctionnement de pfSense lui-même.

#### Contenu typique

|Type d'événement|Description|Exemple d'utilisation|
|---|---|---|
|Démarrage/arrêt|Boot, shutdown, reboot|Vérifier les redémarrages inattendus|
|Services|Démarrage/arrêt des services|Diagnostiquer un service qui ne démarre pas|
|Mises à jour|Installation de packages|Tracer les modifications système|
|Authentification|Connexions GUI/SSH|Détecter les accès non autorisés|
|Erreurs système|Problèmes matériels/logiciels|Identifier les dysfonctionnements|

#### Exemple de log système

```
Jan 10 14:32:15 php-fpm[12345]: /status_logs.php: Login successful for user 'admin' from 192.168.1.100
Jan 10 14:33:02 kernel: em0: link state changed to DOWN
Jan 10 14:33:05 kernel: em0: link state changed to UP
Jan 10 14:35:12 syslogd: kernel boot file is /boot/kernel/kernel
```

> [!tip] Analyse des logs système
> 
> - Surveillez les messages de type "error" ou "critical"
> - Les messages kernel peuvent indiquer des problèmes matériels
> - Les échecs d'authentification répétés signalent une possible attaque

### Logs pare-feu

**Accès** : Status → System Logs → Firewall

Les logs du pare-feu enregistrent toutes les connexions bloquées et autorisées (si configuré).

#### Structure d'une entrée de log pare-feu

Chaque ligne contient :

- **Date/Heure** : Timestamp de l'événement
- **Action** : block ou pass
- **Interface** : Interface réseau concernée (WAN, LAN, etc.)
- **Protocol** : TCP, UDP, ICMP, etc.
- **Source** : IP:port source
- **Destination** : IP:port destination
- **Flags** : Drapeaux TCP
- **Règle** : Numéro et description de la règle appliquée

#### Exemple de log pare-feu

```
Jan 10 15:22:45 WAN block 142.250.185.46:443 → 192.168.1.50:54321 TCP:S
Jan 10 15:23:10 LAN pass 192.168.1.100:52341 → 8.8.8.8:53 UDP
Jan 10 15:24:05 WAN block 185.220.101.5:12345 → 203.0.113.10:22 TCP:S [Port Scan]
```

> [!info] Configuration du logging Par défaut, seules les connexions **bloquées** sont loguées. Pour loguer les connexions autorisées :
> 
> - Éditez une règle de pare-feu
> - Cochez "Log packets that are handled by this rule"
> - Attention à la volumétrie générée !

#### Filtres visuels disponibles

L'interface web propose plusieurs filtres utiles :

|Filtre|Utilité|
|---|---|
|**Action**|block / pass / reject|
|**Interface**|WAN, LAN, DMZ, etc.|
|**Protocol**|TCP, UDP, ICMP, etc.|
|**Source/Destination**|Recherche par IP ou réseau|

> [!warning] Volume des logs pare-feu Sur un réseau actif, les logs pare-feu peuvent croître très rapidement. Filtrez intelligemment et utilisez un serveur Syslog distant pour l'archivage.

### Logs DHCP

**Accès** : Status → System Logs → DHCP

Les logs DHCP tracent toutes les attributions et renouvellements d'adresses IP.

#### Informations enregistrées

- **DHCPDISCOVER** : Client recherche un serveur DHCP
- **DHCPOFFER** : Serveur propose une adresse
- **DHCPREQUEST** : Client demande l'adresse proposée
- **DHCPACK** : Serveur confirme l'attribution
- **DHCPRELEASE** : Client libère son adresse
- **DHCPNACK** : Serveur refuse la demande

#### Exemple de log DHCP

```
Jan 10 16:10:23 dhcpd: DHCPDISCOVER from aa:bb:cc:dd:ee:ff via em1
Jan 10 16:10:24 dhcpd: DHCPOFFER on 192.168.1.150 to aa:bb:cc:dd:ee:ff via em1
Jan 10 16:10:25 dhcpd: DHCPREQUEST for 192.168.1.150 from aa:bb:cc:dd:ee:ff via em1
Jan 10 16:10:25 dhcpd: DHCPACK on 192.168.1.150 to aa:bb:cc:dd:ee:ff via em1
```

> [!example] Cas d'utilisation
> 
> - **Dépannage connectivité** : Vérifier qu'un client obtient bien une IP
> - **Détection de conflits** : Identifier les DHCPNACK répétés
> - **Audit réseau** : Tracer les appareils qui se connectent
> - **Troubleshooting MAC** : Retrouver quelle IP a été attribuée à quel appareil

### Autres logs importants

#### OpenVPN Logs

**Accès** : Status → System Logs → OpenVPN

Enregistre les connexions VPN, authentifications, déconnexions et erreurs de tunnel.

```
Jan 10 17:05:42 openvpn[23456]: user@192.168.1.100:52341 VERIFY OK
Jan 10 17:05:43 openvpn[23456]: user/192.168.1.100:52341 PUSH: Received control message
```

#### IPsec Logs

**Accès** : Status → System Logs → IPsec

Trace les négociations de tunnel IPsec, établissement des SA (Security Associations), et erreurs de connexion.

#### Package Logs

Certains packages (Squid, Snort, pfBlockerNG) génèrent leurs propres logs accessibles depuis leurs interfaces respectives.

---

## 🔍 Filtrage et recherche dans les logs

### Filtres de l'interface web

L'interface web de pfSense offre des outils de filtrage puissants pour chaque type de log.

#### Filtres disponibles

```
┌─────────────────────────────────────┐
│ Nombre de lignes : [50] [100] [500]│
│ Inverser l'ordre : ☐                │
│ Auto-refresh : ☐ 10s                │
│                                     │
│ Filtres spécifiques au type de log │
│ - Interface                         │
│ - Action (block/pass)               │
│ - Protocol                          │
│ - IP Source/Destination             │
└─────────────────────────────────────┘
```

#### Recherche par texte

Utilisez le champ de recherche en haut des logs pour filtrer par :

- Adresse IP (`192.168.1.100`)
- Port (`:443` ou `:80`)
- Protocole (`TCP`, `UDP`)
- Mot-clé (`error`, `denied`, `accepted`)

> [!tip] Recherche avancée
> 
> - Utilisez des expressions régulières pour des recherches complexes
> - Combinez plusieurs filtres pour affiner les résultats
> - Export des logs filtrés possible via "Download current log"

### Ligne de commande

Pour des recherches plus avancées, connectez-vous en SSH et utilisez les outils Unix.

#### Commandes essentielles

```bash
# Afficher les dernières lignes du log système
tail -f /var/log/system.log

# Rechercher une IP spécifique dans les logs pare-feu
grep "192.168.1.100" /var/log/filter.log

# Compter les occurrences d'un événement
grep -c "block" /var/log/filter.log

# Rechercher avec contexte (5 lignes avant/après)
grep -C 5 "error" /var/log/system.log

# Filtrer par période (avec awk)
awk '/Jan 10 14:/{print}' /var/log/system.log

# Logs DHCP seulement pour une MAC
grep "aa:bb:cc:dd:ee:ff" /var/log/dhcpd.log
```

> [!info] Logs principaux
> 
> - `/var/log/system.log` : Logs système
> - `/var/log/filter.log` : Logs pare-feu
> - `/var/log/dhcpd.log` : Logs DHCP
> - `/var/log/vpn.log` : Logs OpenVPN
> - `/var/log/ipsec.log` : Logs IPsec

### Configuration Syslog distant

Pour archiver les logs de manière permanente et centralisée :

**Status → System Logs → Settings**

#### Configuration

```
☑ Enable Remote Logging
Remote log servers : 192.168.1.200:514
Remote Syslog Contents : Everything
```

|Option|Description|
|---|---|
|**Enable Remote Logging**|Active l'envoi vers serveur externe|
|**Remote log servers**|IP:port du serveur Syslog|
|**Remote Syslog Contents**|Sélection des logs à envoyer|

> [!warning] Sécurité Syslog
> 
> - Utilisez un réseau sécurisé pour le Syslog (VLAN dédié)
> - Envisagez TLS pour chiffrer les logs en transit
> - Protégez votre serveur Syslog contre les accès non autorisés

#### Formats supportés

- **BSD Syslog** : RFC 3164 (port UDP 514)
- **Syslog-ng** : Compatible
- **Rsyslog** : Compatible
- **Graylog / ELK** : Intégration possible

---

## 🛠️ Outils de diagnostic réseau

pfSense intègre de nombreux outils pour diagnostiquer les problèmes réseau sans passer par la ligne de commande.

**Accès** : Diagnostics → (divers sous-menus)

### Ping

**Diagnostics → Ping**

Teste la connectivité réseau basique vers une destination.

#### Paramètres

|Paramètre|Description|Valeur typique|
|---|---|---|
|**Hostname**|IP ou nom de domaine|`8.8.8.8` ou `google.com`|
|**IP Protocol**|IPv4 ou IPv6|IPv4|
|**Source Address**|Interface source|Auto ou interface spécifique|
|**Maximum number of pings**|Nombre de paquets|3-10|

```bash
# Équivalent ligne de commande
ping -c 4 8.8.8.8
```

> [!example] Cas d'utilisation
> 
> - Vérifier la connectivité Internet (ping 8.8.8.8)
> - Tester la résolution DNS (ping google.com)
> - Diagnostiquer une latence élevée
> - Vérifier la connectivité entre VLANs

### Traceroute

**Diagnostics → Traceroute**

Affiche le chemin réseau complet vers une destination, hop par hop.

#### Paramètres

|Paramètre|Description|
|---|---|
|**Hostname**|Destination à tracer|
|**Maximum number of hops**|Limite de sauts (défaut 30)|
|**Protocol**|ICMP, UDP ou TCP|
|**Source Address**|Interface source|

```bash
# Équivalent ligne de commande
traceroute 8.8.8.8
```

#### Interprétation des résultats

```
 1  192.168.1.1 (192.168.1.1)  0.5 ms
 2  10.0.0.1 (10.0.0.1)  2.3 ms
 3  * * *  (timeout)
 4  142.250.185.46 (142.250.185.46)  15.2 ms
```

- **Chaque ligne** = un routeur (hop)
- **Temps** = latence du hop
- **`* * *`** = hop qui ne répond pas (normal pour certains routeurs)
- **Latence croissante** = normale sur Internet

> [!tip] Diagnostic de routage
> 
> - Utilisez traceroute pour identifier où un paquet est perdu
> - Un hop qui ne répond pas n'est pas forcément problématique
> - Comparez avec un traceroute réussi vers une autre destination

### DNS Lookup

**Diagnostics → DNS Lookup**

Teste la résolution DNS et affiche les enregistrements DNS.

#### Paramètres

|Paramètre|Description|Exemple|
|---|---|---|
|**Hostname**|Domaine à résoudre|`google.com`|
|**Record Type**|Type d'enregistrement|A, AAAA, MX, TXT, etc.|
|**DNS Server**|Serveur DNS à interroger|8.8.8.8 ou auto|

```bash
# Équivalent ligne de commande
nslookup google.com
dig google.com A
```

#### Types d'enregistrements utiles

- **A** : IPv4 address
- **AAAA** : IPv6 address
- **MX** : Mail exchange (serveurs mail)
- **TXT** : Texte (SPF, DKIM, etc.)
- **CNAME** : Alias canonical
- **NS** : Name servers
- **SOA** : Start of authority

> [!example] Cas d'utilisation
> 
> - Vérifier que le DNS fonctionne
> - Diagnostiquer des problèmes de résolution
> - Valider une configuration DNS interne
> - Vérifier des enregistrements MX pour le mail

### ARP Table

**Diagnostics → ARP Table**

Affiche la table ARP (Address Resolution Protocol) qui associe les adresses IP aux adresses MAC.

```
IP Address         MAC Address        Interface  Expires
192.168.1.100      aa:bb:cc:dd:ee:ff  em1        1200s
192.168.1.101      11:22:33:44:55:66  em1        800s
```

> [!info] Utilité de la table ARP
> 
> - Identifier quel appareil utilise une IP
> - Détecter les conflits d'adresses IP
> - Diagnostiquer les problèmes de communication locale
> - Vérifier la présence d'un appareil sur le réseau

### States Table

**Diagnostics → States**

Affiche toutes les connexions actives gérées par le pare-feu (state table).

#### Informations affichées

```
Protocol  Source IP:Port     Destination IP:Port  State     Age
TCP       192.168.1.100:52341 → 142.250.185.46:443  ESTABLISHED 45s
UDP       192.168.1.101:53421 → 8.8.8.8:53         SINGLE     2s
```

|Colonne|Description|
|---|---|
|**Protocol**|TCP, UDP, ICMP|
|**Source**|IP:port origine|
|**Destination**|IP:port destination|
|**State**|État de la connexion|
|**Age**|Durée de vie de l'état|

#### États TCP courants

- **SYN_SENT** : Connexion en cours d'établissement
- **ESTABLISHED** : Connexion active
- **FIN_WAIT** : Fermeture en cours
- **CLOSED** : Connexion fermée

> [!warning] Saturation de la table d'états Si la table d'états est pleine, de nouvelles connexions seront refusées. Surveillez le nombre d'états sous **Status → Monitoring**.

### Halt/Reboot System

**Diagnostics → Halt/Reboot**

Permet de redémarrer ou arrêter proprement pfSense.

> [!warning] Arrêt du système Un arrêt brutal (coupure électrique) peut corrompre la configuration. Utilisez toujours cette fonction pour un arrêt propre.

### Command Prompt

**Diagnostics → Command Prompt**

Interface web pour exécuter des commandes shell directement.

```bash
# Exemples de commandes utiles
ifconfig                    # Afficher les interfaces
netstat -rn                 # Table de routage
top                         # Processus actifs
pfctl -s rules             # Règles pare-feu actives
pfctl -s states | wc -l    # Nombre d'états actifs
```

> [!tip] Précautions
> 
> - N'exécutez que des commandes que vous comprenez
> - Certaines commandes peuvent affecter le système
> - Préférez SSH pour les tâches administratives complexes

---

## 📦 Captures de paquets

La capture de paquets (packet capture) est l'outil le plus puissant pour diagnostiquer les problèmes réseau complexes.

**Accès** : Diagnostics → Packet Capture

### Configuration d'une capture

#### Paramètres essentiels

|Paramètre|Description|Recommandation|
|---|---|---|
|**Interface**|Interface à écouter|Choisir l'interface concernée|
|**Host Address**|Filtrer par IP|Optionnel, réduit le volume|
|**Port**|Filtrer par port|Ex: 80, 443, 22|
|**Packet Length**|Taille max par paquet|0 = complet, 96 = headers seulement|
|**Count**|Nombre de paquets|100-1000 selon le besoin|
|**Detail Level**|Verbosité|Normal ou Full|

#### Exemple de configuration

```
Interface : WAN
Host Address : 192.168.1.100
Port : 443
Protocol : TCP
Packet Length : 0 (full packet)
Count : 500
```

> [!info] Filtres BPF pfSense utilise la syntaxe BPF (Berkeley Packet Filter) pour les captures avancées :
> 
> - `host 192.168.1.100` : Trafic depuis/vers cette IP
> - `port 80` : Trafic HTTP
> - `tcp and port 443` : Trafic HTTPS seulement
> - `not port 22` : Tout sauf SSH

### Lancement et analyse

1. **Démarrez la capture** : Cliquez sur "Start"
2. **Reproduisez le problème** : Effectuez l'action qui pose problème
3. **Arrêtez la capture** : Cliquez sur "Stop"
4. **Téléchargez le fichier** : Format `.pcap`
5. **Analysez avec Wireshark** : Outil d'analyse professionnel

#### Analyse avec Wireshark

Wireshark est l'outil de référence pour analyser les fichiers `.pcap`.

**Installation** : Téléchargez depuis [wireshark.org](https://www.wireshark.org/)

**Filtres Wireshark courants** :

```
ip.addr == 192.168.1.100        # Tout trafic d'une IP
tcp.port == 443                  # Trafic HTTPS
http.request.method == "GET"     # Requêtes HTTP GET
tcp.flags.syn == 1               # Paquets SYN (début connexion)
tcp.analysis.retransmission      # Retransmissions (problème réseau)
dns                              # Requêtes DNS
icmp                             # Paquets ICMP (ping)
```

> [!example] Cas d'utilisation des captures
> 
> - **Connectivité bloquée** : Vérifier si les paquets arrivent
> - **Lenteur réseau** : Identifier les retransmissions
> - **Problème SSL/TLS** : Analyser le handshake
> - **DNS qui ne fonctionne pas** : Voir les requêtes/réponses
> - **Ports bloqués** : Confirmer que les SYN arrivent

### Captures ciblées

#### Capturer uniquement le handshake TCP

```
Protocol : TCP
Port : 443
Count : 50
Packet Length : 96
```

Capture légère pour diagnostiquer les problèmes de connexion sans capturer les données.

#### Capturer le trafic DNS

```
Protocol : UDP
Port : 53
Count : 100
```

Utile pour diagnostiquer les problèmes de résolution DNS.

#### Capturer depuis une IP spécifique

```
Host Address : 192.168.1.100
Direction : Both
```

Capture tout le trafic entrant et sortant d'un hôte particulier.

> [!warning] Confidentialité et sécurité
> 
> - Les captures contiennent des données en clair (mots de passe, cookies)
> - Ne partagez jamais un fichier `.pcap` sans le nettoyer
> - Stockez les captures en lieu sûr
> - Supprimez les captures après analyse

### Outils complémentaires

#### tcpdump (ligne de commande)

Si vous êtes connecté en SSH :

```bash
# Capture basique sur WAN
tcpdump -i em0 -n

# Capture vers un fichier
tcpdump -i em0 -w /tmp/capture.pcap

# Capture avec filtre
tcpdump -i em0 'host 192.168.1.100 and port 443'

# Afficher uniquement les headers
tcpdump -i em0 -nn -vv

# Limiter le nombre de paquets
tcpdump -i em0 -c 100
```

#### tshark (Wireshark CLI)

Wireshark en ligne de commande, disponible via package manager.

```bash
# Capture avec filtres Wireshark
tshark -i em0 -f 'port 443' -Y 'ssl.handshake.type == 1'
```

---

## ✅ Bonnes pratiques

### Surveillance régulière

> [!tip] Routine de surveillance
> 
> - Consultez les logs système quotidiennement
> - Vérifiez les tentatives de connexion bloquées
> - Surveillez les alertes DHCP (NACK, conflits)
> - Examinez les logs d'authentification (GUI, SSH, VPN)

### Gestion de la rétention

```
Status → System Logs → Settings

┌────────────────────────────────────┐
│ Log Message Count : 500000         │
│ Log Retention : 7 days             │
│ Reset Logs on Clear : ☐            │
└────────────────────────────────────┘
```

|Paramètre|Recommandation|
|---|---|
|**Petit réseau**|100000 messages, 7 jours|
|**Réseau moyen**|500000 messages, 14 jours|
|**Grand réseau**|Syslog distant obligatoire|

### Sécurité des logs

> [!warning] Protection des logs
> 
> - Restreignez l'accès SSH aux administrateurs seulement
> - Activez l'audit des connexions (logs d'authentification)
> - Utilisez un serveur Syslog sur un réseau isolé
> - Chiffrez les logs sensibles
> - Sauvegardez régulièrement les logs critiques

### Analyse proactive

#### Indicateurs à surveiller

**Signes d'attaque** :

- Multiples tentatives de connexion échouées
- Scans de ports (nombreux SYN vers différents ports)
- Trafic inhabituel depuis/vers des pays inattendus
- Pics de trafic ICMP (DDoS potentiel)

**Signes de problème réseau** :

- Retransmissions TCP fréquentes
- Timeouts DHCP répétés
- Erreurs DNS récurrentes
- Interfaces qui flappent (UP/DOWN)

**Signes de problème performance** :

- État de table saturée
- CPU/RAM élevée dans les logs système
- Délais de réponse croissants

### Automatisation

#### Notifications par email

Configurez des alertes email pour les événements critiques :

**System → Advanced → Notifications**

```
SMTP Server : smtp.gmail.com:587
From Address : pfsense@domain.com
Notification E-Mail : admin@domain.com
☑ Enable SMTP Authentication
```

#### Scripts personnalisés

Créez des scripts pour automatiser l'analyse :

```bash
#!/bin/sh
# Exemple : Alerter si plus de 100 connexions bloquées en 1 minute

COUNT=$(grep -c "block" /var/log/filter.log | tail -60)
if [ $COUNT -gt 100 ]; then
    echo "Alerte : $COUNT connexions bloquées" | mail -s "pfSense Alert" admin@domain.com
fi
```

### Documentation

> [!tip] Tenez un journal des incidents
> 
> - Notez chaque problème diagnostiqué
> - Documentez la solution appliquée
> - Conservez les captures de paquets importantes
> - Créez une base de connaissance interne

---

## 🎯 Récapitulatif

|Outil|Usage principal|Quand l'utiliser|
|---|---|---|
|**Logs Système**|Événements pfSense|Problèmes de services, authentification|
|**Logs Pare-feu**|Connexions bloquées/autorisées|Règles inefficaces, attaques|
|**Logs DHCP**|Attribution d'IP|Client sans connectivité|
|**Ping**|Test connectivité basique|Premier diagnostic|
|**Traceroute**|Chemin réseau|Problème de routage|
|**DNS Lookup**|Résolution DNS|Sites inaccessibles|
|**ARP Table**|Correspondance IP/MAC|Conflits d'adresses|
|**States Table**|Connexions actives|Saturation, connexions fantômes|
|**Packet Capture**|Analyse approfondie|Tous les problèmes complexes|

> [!info] Méthodologie de diagnostic
> 
> 1. **Identifier** : Quel est le symptôme exact ?
> 2. **Consulter** : Vérifier les logs appropriés
> 3. **Tester** : Utiliser ping/traceroute/DNS lookup
> 4. **Capturer** : Si besoin, faire une capture de paquets
> 5. **Analyser** : Wireshark pour approfondir
> 6. **Résoudre** : Appliquer le correctif
> 7. **Documenter** : Noter la solution

Les journaux et outils de diagnostic pfSense sont vos meilleurs alliés pour maintenir un réseau sain, sécurisé et performant. Maîtrisez-les pour devenir autonome dans la résolution de problèmes !