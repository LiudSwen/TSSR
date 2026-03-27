
## 📑 Table des matières

```table-of-contents
```toc
minLevel: 2
maxLevel: 2
```
---

## 1. Prérequis et préparation

### 1.1 Vérifications préalables

Avant de commencer, assurez-vous que votre serveur possède une **adresse IP statique** configurée. Un serveur DHCP ne peut pas avoir d'IP dynamique.

```bash
# Vérifier la configuration IP actuelle
ip addr show
```

```bash
# Vérifier la configuration réseau dans Debian
cat /etc/network/interfaces
```

> [!info] Pourquoi une IP statique ? Le serveur DHCP doit avoir une adresse IP fixe pour que les clients puissent toujours le contacter au même endroit sur le réseau.

> [!warning] Conflit avec NetworkManager Si NetworkManager est actif, il peut interférer avec la configuration réseau. Privilégiez `/etc/network/interfaces` pour un serveur.

### 1.2 Mise à jour du système

Mettons à jour la liste des paquets et le système pour garantir la dernière version du serveur DHCP.

```bash
# Mise à jour de la liste des paquets disponibles
sudo apt update

# Mise à niveau des paquets installés (optionnel mais recommandé)
sudo apt upgrade -y
```

> [!tip] Bonne pratique Effectuez toujours un `apt update` avant d'installer de nouveaux paquets pour obtenir les versions les plus récentes.

### ✅ Checkpoint 1

- [ ] Le serveur possède une IP statique
- [ ] La configuration réseau est correcte dans `/etc/network/interfaces`
- [ ] Le système est à jour

---

## 2. Installation du serveur DHCP

### 2.1 Installation du paquet isc-dhcp-server

Le paquet `isc-dhcp-server` est l'implémentation standard du protocole DHCP maintenue par l'Internet Systems Consortium.

```bash
# Installation du serveur DHCP
sudo apt install isc-dhcp-server -y
```

> [!info] ISC DHCP Server C'est le serveur DHCP le plus utilisé sous Linux. Il est robuste, éprouvé et largement documenté.

### 2.2 Vérification de l'installation

Vérifions que le service est bien installé (même s'il ne démarre pas encore, c'est normal).

```bash
# Vérifier le statut du service
sudo systemctl status isc-dhcp-server
```

Résultat attendu : Le service apparaît comme `loaded` mais probablement `failed` ou `inactive` car non configuré.

> [!warning] Service en échec normal À ce stade, il est **normal** que le service soit en échec. Il n'a pas encore été configuré avec une interface réseau ni de plage d'adresses.

### ✅ Checkpoint 2

- [ ] Le paquet isc-dhcp-server est installé
- [ ] Le service apparaît dans systemctl (même en échec)

---

## 3. Configuration de l'interface d'écoute

### 3.1 Identification de l'interface réseau

Identifions l'interface réseau sur laquelle le serveur DHCP doit écouter les requêtes.

```bash
# Lister toutes les interfaces réseau
ip link show
```

Notez le nom de votre interface (exemple : `eth0`, `ens33`, `enp0s3`).

### 3.2 Configuration du fichier isc-dhcp-server

Nous allons indiquer au serveur DHCP sur quelle(s) interface(s) il doit écouter.

```bash
# Éditer le fichier de configuration des interfaces
sudo nano /etc/default/isc-dhcp-server
```

Modifiez la ligne `INTERFACESv4` pour spécifier votre interface :

```bash
# Configuration pour IPv4
INTERFACESv4="eth0"

# Configuration pour IPv6 (laisser vide si non utilisé)
INTERFACESv6=""
```

> [!tip] Plusieurs interfaces Vous pouvez spécifier plusieurs interfaces séparées par des espaces : `INTERFACESv4="eth0 eth1"`

> [!warning] Nom exact de l'interface Utilisez le nom **exact** de votre interface tel que retourné par `ip link show`. Une erreur ici empêchera le démarrage du service.

### ✅ Checkpoint 3

- [ ] L'interface réseau est identifiée
- [ ] Le fichier `/etc/default/isc-dhcp-server` est configuré
- [ ] Le nom de l'interface correspond exactement

---

## 4. Configuration du serveur DHCP

### 4.1 Sauvegarde de la configuration par défaut

Créons une sauvegarde du fichier de configuration original avant toute modification.

```bash
# Sauvegarde du fichier de configuration original
sudo cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.backup
```

> [!tip] Toujours sauvegarder Prenez l'habitude de sauvegarder les fichiers de configuration avant modification. Cela permet un rollback rapide en cas d'erreur.

### 4.2 Configuration de base du DHCP

Éditons le fichier principal de configuration du serveur DHCP.

```bash
# Éditer le fichier de configuration DHCP
sudo nano /etc/dhcp/dhcpd.conf
```

### 4.3 Structure de configuration recommandée

Voici une configuration type pour un réseau d'entreprise :

```conf
# ============================================
# Configuration globale du serveur DHCP
# ============================================

# Nom de domaine distribué aux clients
option domain-name "entreprise.local";

# Serveurs DNS distribués aux clients (ex: DNS interne puis Google DNS)
option domain-name-servers 192.168.1.1, 8.8.8.8;

# Durée du bail par défaut (en secondes) - 24 heures
default-lease-time 86400;

# Durée maximale du bail - 7 jours
max-lease-time 604800;

# Le serveur DHCP est autoritaire sur ce réseau (répond avec autorité)
authoritative;

# Journalisation des événements DHCP
log-facility local7;

# ============================================
# Déclaration du sous-réseau
# ============================================

subnet 192.168.1.0 netmask 255.255.255.0 {
    # Plage d'adresses IP à distribuer
    range 192.168.1.100 192.168.1.200;
    
    # Passerelle par défaut (routeur)
    option routers 192.168.1.1;
    
    # Masque de sous-réseau
    option subnet-mask 255.255.255.0;
    
    # Adresse de broadcast
    option broadcast-address 192.168.1.255;
}

# ============================================
# Réservations DHCP (IP fixes par MAC)
# ============================================

# Exemple : Imprimante réseau
host imprimante-rh {
    hardware ethernet 00:11:22:33:44:55;
    fixed-address 192.168.1.50;
}

# Exemple : Serveur de fichiers
host serveur-fichiers {
    hardware ethernet AA:BB:CC:DD:EE:FF;
    fixed-address 192.168.1.10;
}
```

> [!info] Explication des paramètres clés
> 
> - **domain-name** : Le suffixe DNS ajouté aux noms d'hôtes
> - **domain-name-servers** : Serveurs DNS fournis aux clients
> - **default-lease-time** : Durée de validité d'une IP (24h = 86400 secondes)
> - **max-lease-time** : Durée maximale possible (7 jours = 604800 secondes)
> - **authoritative** : Le serveur est la référence pour ce réseau
> - **range** : Pool d'adresses IP distribuables dynamiquement

> [!warning] Adresse du serveur DHCP L'adresse IP du serveur DHCP doit être **en dehors** de la plage définie dans `range`. Par exemple, si le serveur est en 192.168.1.5, la plage doit commencer à .100 minimum.

> [!tip] Réservations DHCP Les réservations permettent d'attribuer toujours la même IP à un équipement spécifique (identifié par son adresse MAC). Idéal pour les imprimantes, serveurs, points d'accès WiFi, etc.

### 4.4 Adapter la configuration à votre réseau

Modifiez les paramètres suivants selon votre infrastructure :

|Paramètre|Exemple|À adapter selon|
|---|---|---|
|`subnet`|192.168.1.0|Votre réseau|
|`netmask`|255.255.255.0|Votre masque|
|`range`|192.168.1.100 - 200|Plage disponible|
|`option routers`|192.168.1.1|Votre passerelle|
|`option domain-name-servers`|192.168.1.1, 8.8.8.8|Vos DNS|
|`option domain-name`|"entreprise.local"|Votre domaine|

### ✅ Checkpoint 4

- [ ] Le fichier dhcpd.conf est sauvegardé
- [ ] La configuration est adaptée à votre réseau
- [ ] Les adresses IP correspondent à votre plan d'adressage
- [ ] La plage DHCP n'inclut pas l'IP du serveur

---

## 5. Vérification et validation de la configuration

### 5.1 Test de syntaxe

Avant de démarrer le service, vérifions que la configuration ne contient pas d'erreurs de syntaxe.

```bash
# Tester la configuration DHCP
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf
```

Résultat attendu : `Syntax: OK` ou aucun message d'erreur.

> [!warning] Erreurs courantes
> 
> - **Accolades mal fermées** : Vérifiez chaque `{` a son `}`
> - **Point-virgule manquant** : Chaque ligne de directive doit se terminer par `;`
> - **Adresses IP invalides** : Vérifiez la syntaxe des adresses
> - **Plage IP incohérente** : L'IP de fin doit être > IP de début

### 5.2 Vérification des permissions

Assurons-nous que le fichier de baux DHCP existe et a les bonnes permissions.

```bash
# Créer le fichier de baux s'il n'existe pas
sudo touch /var/lib/dhcp/dhcpd.leases

# Vérifier les permissions
ls -l /var/lib/dhcp/dhcpd.leases
```

> [!info] Fichier dhcpd.leases Ce fichier enregistre tous les baux DHCP actifs (quelle IP est attribuée à quel client). Il est automatiquement géré par le serveur.

### ✅ Checkpoint 5

- [ ] La syntaxe de la configuration est valide
- [ ] Le fichier dhcpd.leases existe
- [ ] Aucune erreur n'est remontée par le test

---

## 6. Démarrage et activation du service

### 6.1 Démarrage du service DHCP

Démarrons maintenant le service avec la configuration que nous venons de créer.

```bash
# Démarrer le service DHCP
sudo systemctl start isc-dhcp-server
```

### 6.2 Vérification du statut

Vérifions que le service a bien démarré sans erreur.

```bash
# Vérifier le statut détaillé du service
sudo systemctl status isc-dhcp-server
```

Résultat attendu : `Active: active (running)` en vert.

> [!warning] Service failed Si le service est en échec, consultez les logs avec `sudo journalctl -xeu isc-dhcp-server` pour identifier l'erreur.

### 6.3 Activation au démarrage

Configurons le service pour qu'il démarre automatiquement au boot du serveur.

```bash
# Activer le démarrage automatique
sudo systemctl enable isc-dhcp-server
```

> [!tip] Persistance du service `enable` garantit que le serveur DHCP redémarrera automatiquement après un reboot du serveur, essentiel en production.

### 6.4 Consultation des logs

Les logs du serveur DHCP sont essentiels pour le dépannage et le monitoring.

```bash
# Afficher les logs en temps réel
sudo tail -f /var/log/syslog | grep dhcpd

# Ou avec journalctl (méthode moderne)
sudo journalctl -u isc-dhcp-server -f
```

> [!info] Que voir dans les logs ?
> 
> - **DHCPDISCOVER** : Un client cherche un serveur DHCP
> - **DHCPOFFER** : Le serveur propose une IP
> - **DHCPREQUEST** : Le client accepte l'IP proposée
> - **DHCPACK** : Le serveur confirme l'attribution
> - **DHCPNAK** : Le serveur refuse la requête

### ✅ Checkpoint 6

- [ ] Le service est actif (running)
- [ ] Le service est activé au démarrage (enabled)
- [ ] Les logs sont accessibles et ne montrent pas d'erreur
- [ ] Le serveur écoute sur la bonne interface

---

## 7. Tests et validation du serveur DHCP

### 7.1 Vérification de l'écoute réseau

Vérifions que le serveur écoute bien sur le port DHCP (67/UDP).

```bash
# Vérifier les ports en écoute
sudo ss -ulnp | grep dhcpd
```

Résultat attendu : Ligne contenant `0.0.0.0:67` ou l'IP de votre interface.

> [!info] Port DHCP Le serveur DHCP écoute sur le port UDP 67, les clients envoient depuis le port UDP 68.

### 7.2 Consultation des baux actifs

Regardons si des clients ont déjà obtenu une adresse IP.

```bash
# Afficher les baux DHCP actifs
sudo cat /var/lib/dhcp/dhcpd.leases
```

Ce fichier liste tous les baux attribués avec :

- L'adresse IP
- L'adresse MAC du client
- Les dates de début et fin de bail
- Le hostname du client (si fourni)

### 7.3 Test depuis un client

**Sur un poste client Windows :**

```cmd
# Libérer l'adresse IP actuelle
ipconfig /release

# Renouveler et obtenir une nouvelle IP
ipconfig /renew

# Vérifier la configuration obtenue
ipconfig /all
```

**Sur un client Linux :**

```bash
# Libérer le bail DHCP
sudo dhclient -r

# Obtenir une nouvelle IP
sudo dhclient -v eth0

# Vérifier la configuration
ip addr show eth0
```

> [!tip] Vérifications côté client Confirmez que le client a bien reçu :
> 
> - Une IP dans la plage définie
> - La bonne passerelle
> - Les bons serveurs DNS
> - Le bon nom de domaine

### 7.4 Test de ping

Depuis le client ayant obtenu une IP, testez la connectivité :

```bash
# Ping vers le serveur DHCP
ping 192.168.1.5

# Ping vers la passerelle
ping 192.168.1.1

# Ping vers un serveur externe (test DNS + routage)
ping google.com
```

> [!warning] Firewall Si les pings échouent, vérifiez que le pare-feu du serveur autorise les requêtes DHCP (ports UDP 67-68) et ICMP (ping).

### ✅ Checkpoint 7

- [ ] Le serveur écoute sur le port 67/UDP
- [ ] Des baux apparaissent dans dhcpd.leases
- [ ] Un client test obtient une IP correcte
- [ ] La connectivité réseau fonctionne depuis le client
- [ ] Les paramètres réseau (DNS, passerelle) sont corrects

---

## 8. Configuration avancée (optionnel)

### 8.1 Configuration de plusieurs sous-réseaux

Si votre infrastructure comporte plusieurs VLANs ou sous-réseaux :

```conf
# Premier sous-réseau (bureaux)
subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.100 192.168.1.200;
    option routers 192.168.1.1;
    option domain-name-servers 192.168.1.1;
}

# Deuxième sous-réseau (production)
subnet 192.168.2.0 netmask 255.255.255.0 {
    range 192.168.2.50 192.168.2.150;
    option routers 192.168.2.1;
    option domain-name-servers 192.168.2.1;
}
```

### 8.2 Configuration d'options PXE (boot réseau)

Pour un environnement avec déploiement par PXE :

```conf
subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.100 192.168.1.200;
    option routers 192.168.1.1;
    
    # Serveur TFTP pour PXE
    next-server 192.168.1.10;
    filename "pxelinux.0";
}
```

### 8.3 Configuration de pools d'adresses avec options différentes

Différencier les options selon le type de client :

```conf
subnet 192.168.1.0 netmask 255.255.255.0 {
    option routers 192.168.1.1;
    option domain-name-servers 192.168.1.1;
    
    # Pool pour les postes utilisateurs
    pool {
        range 192.168.1.100 192.168.1.150;
        default-lease-time 28800;  # 8 heures
    }
    
    # Pool pour les équipements mobiles
    pool {
        range 192.168.1.151 192.168.1.200;
        default-lease-time 3600;  # 1 heure
    }
}
```

> [!tip] Cas d'usage des pools Utilisez les pools pour appliquer des durées de bail différentes selon les types d'équipements ou pour segmenter logiquement votre attribution d'IP.

### ✅ Checkpoint 8

- [ ] Les configurations avancées sont adaptées à vos besoins
- [ ] Chaque configuration a été testée
- [ ] La documentation est mise à jour

---

## 9. Sécurisation et maintenance

### 9.1 Configuration du pare-feu

Autorisons uniquement les flux DHCP nécessaires.

**Avec UFW (Uncomplicated Firewall) :**

```bash
# Autoriser DHCP entrant
sudo ufw allow 67/udp

# Vérifier les règles
sudo ufw status
```

**Avec iptables :**

```bash
# Autoriser les requêtes DHCP
sudo iptables -A INPUT -p udp --dport 67 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 68 -j ACCEPT

# Sauvegarder les règles
sudo iptables-save | sudo tee /etc/iptables/rules.v4
```

> [!warning] Tester avant de sauvegarder Testez toujours vos règles de pare-feu avant de les rendre permanentes pour éviter de vous bloquer l'accès au serveur.

### 9.2 Monitoring et alertes

Surveillons régulièrement l'utilisation du pool d'adresses.

```bash
# Compter les baux actifs
grep "^lease" /var/lib/dhcp/dhcpd.leases | wc -l

# Voir les baux expirés récemment
grep "ends" /var/lib/dhcp/dhcpd.leases | tail -20
```

> [!tip] Script de monitoring Créez un script de surveillance pour être alerté quand le pool d'adresses atteint 80% d'utilisation.

### 9.3 Sauvegarde de la configuration

```bash
# Script de sauvegarde régulière
sudo tar -czf /backup/dhcp-backup-$(date +%Y%m%d).tar.gz \
    /etc/dhcp/dhcpd.conf \
    /etc/default/isc-dhcp-server \
    /var/lib/dhcp/dhcpd.leases
```

> [!tip] Automatisation Planifiez cette sauvegarde avec une tâche cron hebdomadaire.

### 9.4 Rotation des logs

Les logs DHCP peuvent rapidement prendre de l'espace.

```bash
# Vérifier la configuration de rotation
cat /etc/logrotate.d/isc-dhcp-server
```

Configuration recommandée :

```conf
/var/log/dhcpd.log {
    weekly
    rotate 4
    compress
    missingok
    notifempty
}
```

### ✅ Checkpoint 9

- [ ] Le pare-feu autorise le trafic DHCP
- [ ] Un système de monitoring est en place
- [ ] Les sauvegardes sont configurées
- [ ] La rotation des logs est active

---

## 10. Dépannage courant

### 10.1 Le service ne démarre pas

**Symptôme :** `systemctl status isc-dhcp-server` montre `failed`

**Vérifications :**

```bash
# Consulter les logs d'erreur
sudo journalctl -xeu isc-dhcp-server

# Tester la configuration
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf

# Vérifier l'interface configurée
cat /etc/default/isc-dhcp-server
ip link show
```

**Causes fréquentes :**

- Erreur de syntaxe dans dhcpd.conf
- Interface réseau incorrecte ou inactive
- Port 67 déjà utilisé par un autre service
- Permissions incorrectes sur dhcpd.leases

### 10.2 Les clients n'obtiennent pas d'IP

**Symptôme :** Les clients restent en APIPA (169.254.x.x) ou sans IP

**Vérifications :**

```bash
# Vérifier que le service écoute
sudo ss -ulnp | grep 67

# Vérifier les logs en temps réel
sudo journalctl -u isc-dhcp-server -f

# Vérifier le pare-feu
sudo ufw status
sudo iptables -L -n -v | grep 67
```

**Causes fréquentes :**

- Pare-feu bloque les ports 67/68 UDP
- Serveur DHCP sur la mauvaise interface
- Pas de route entre le client et le serveur
- Autre serveur DHCP sur le réseau (conflit)
- Client sur un VLAN différent sans DHCP relay

### 10.3 Conflit d'adresses IP

**Symptôme :** Messages "DHCPDECLINE" dans les logs

**Solution :**

```bash
# Vérifier les doublons dans le réseau
sudo nmap -sn 192.168.1.0/24

# Nettoyer les anciens baux
sudo systemctl stop isc-dhcp-server
sudo mv /var/lib/dhcp/dhcpd.leases /var/lib/dhcp/dhcpd.leases.old
sudo touch /var/lib/dhcp/dhcpd.leases
sudo systemctl start isc-dhcp-server
```

> [!warning] Conflit d'IP Les conflits surviennent souvent quand des équipements ont des IP statiques dans la plage DHCP. Excluez ces adresses de la plage ou créez des réservations.

### 10.4 Réservations qui ne fonctionnent pas

**Vérifications :**

```bash
# Vérifier l'adresse MAC du client
ip link show  # Sur Linux
ipconfig /all  # Sur Windows

# Format correct dans dhcpd.conf
host nom-client {
    hardware ethernet aa:bb:cc:dd:ee:ff;  # Minuscules avec :
    fixed-address 192.168.1.50;
}
```

> [!tip] Format MAC Utilisez toujours des minuscules et des deux-points `:` pour les adresses MAC dans la configuration DHCP.

### ✅ Checkpoint 10

- [ ] Vous savez consulter les logs
- [ ] Vous connaissez les commandes de diagnostic
- [ ] Vous avez identifié les erreurs courantes

---

## 11. Configuration complète pas à pas

### 11.1 Script d'installation complet

Voici un script commenté regroupant **toutes les commandes** dans l'ordre d'exécution :

```bash
#!/bin/bash
# ============================================
# Script d'installation serveur DHCP - Debian
# ============================================

# VARIABLES À PERSONNALISER
INTERFACE="eth0"                    # Interface réseau du serveur
SUBNET="192.168.1.0"                # Réseau
NETMASK="255.255.255.0"             # Masque
RANGE_START="192.168.1.100"         # Début de plage
RANGE_END="192.168.1.200"           # Fin de plage
GATEWAY="192.168.1.1"               # Passerelle
DNS_PRIMARY="192.168.1.1"           # DNS primaire
DNS_SECONDARY="8.8.8.8"             # DNS secondaire
DOMAIN="entreprise.local"           # Nom de domaine

# Mise à jour du système
echo "Mise à jour du système..."
sudo apt update
sudo apt upgrade -y

# Installation du serveur DHCP
echo "Installation du serveur DHCP..."
sudo apt install isc-dhcp-server -y

# Configuration de l'interface d'écoute
echo "Configuration de l'interface d'écoute..."
sudo sed -i "s/INTERFACESv4=\"\"/INTERFACESv4=\"$INTERFACE\"/" /etc/default/isc-dhcp-server

# Sauvegarde de la configuration par défaut
echo "Sauvegarde de la configuration..."
sudo cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.backup

# Création de la nouvelle configuration
echo "Création de la configuration DHCP..."
sudo tee /etc/dhcp/dhcpd.conf > /dev/null <<EOF
# Configuration DHCP générée automatiquement
option domain-name "$DOMAIN";
option domain-name-servers $DNS_PRIMARY, $DNS_SECONDARY;
default-lease-time 86400;
max-lease-time 604800;
authoritative;
log-facility local7;

subnet $SUBNET netmask $NETMASK {
    range $RANGE_START $RANGE_END;
    option routers $GATEWAY;
    option subnet-mask $NETMASK;
    option broadcast-address ${SUBNET%.*}.255;
}
EOF

# Test de la configuration
echo "Test de la configuration..."
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf

if [ $? -eq 0 ]; then
    echo "✓ Configuration valide"
    
    # Création du fichier de baux
    sudo touch /var/lib/dhcp/dhcpd.leases
    
    # Démarrage du service
    echo "Démarrage du service..."
    sudo systemctl restart isc-dhcp-server
    sudo systemctl enable isc-dhcp-server
    
    # Vérification du statut
    echo "Statut du service:"
    sudo systemctl status isc-dhcp-server --no-pager
    
    echo ""
    echo "✓ Installation terminée avec succès!"
    echo "Consultez les logs avec: sudo journalctl -u isc-dhcp-server -f"
else
    echo "✗ Erreur dans la configuration, vérifiez la syntaxe"
    exit 1
fi
```

### 11.2 Template de configuration à personnaliser

Copiez ce template et remplacez les valeurs entre crochets :

```conf
# ============================================
# TEMPLATE CONFIGURATION DHCP
# À personnaliser selon votre environnement
# ============================================

# PARAMÈTRES GLOBAUX
option domain-name "[DOMAIN_NAME]";              # Ex: entreprise.local
option domain-name-servers [DNS1], [DNS2];       # Ex: 192.168.1.1, 8.8.8.8
default-lease-time [LEASE_TIME];                 # Ex: 86400 (24h)
max-lease-time [MAX_LEASE];                      # Ex: 604800 (7j)
authoritative;
log-facility local7;

# DÉCLARATION SOUS-RÉSEAU
subnet [NETWORK_ADDRESS] netmask [NETMASK] {    # Ex: 192.168.1.0 / 255.255.255.0
    range [IP_START] [IP_END];                   # Ex: 192.168.1.100 192.168.1.200
    option routers [GATEWAY];                    # Ex: 192.168.1.1
    option subnet-mask [NETMASK];                # Ex: 255.255.255.0
    option broadcast-address [BROADCAST];        # Ex: 192.168.1.255
}

# RÉSERVATIONS (optionnel)
host [HOSTNAME] {
    hardware ethernet [MAC_ADDRESS];             # Ex: aa:bb:cc:dd:ee:ff
    fixed-address [RESERVED_IP];                 # Ex: 192.168.1.50
}
```

**Variables à remplacer :**

|Variable|Exemple|Description|
|---|---|---|
|`[DOMAIN_NAME]`|entreprise.local|Nom de domaine interne|
|`[DNS1]`, `[DNS2]`|192.168.1.1, 8.8.8.8|Serveurs DNS|
|`[LEASE_TIME]`|86400|Durée bail défaut (secondes)|
|`[MAX_LEASE]`|604800|Durée bail maximale (secondes)|
|`[NETWORK_ADDRESS]`|192.168.1.0|Adresse du réseau|
|`[NETMASK]`|255.255.255.0|Masque de sous-réseau|
|`[IP_START]`|192.168.1.100|Début de la plage DHCP|
|`[IP_END]`|192.168.1.200|Fin de la plage DHCP|
|`[GATEWAY]`|192.168.1.1|Passerelle par défaut|
|`[BROADCAST]`|192.168.1.255|Adresse de broadcast|
|`[HOSTNAME]`|imprimante-rh|Nom de l'hôte réservé|
|`[MAC_ADDRESS]`|aa:bb:cc:dd:ee:ff|Adresse MAC (minuscules)|
|`[RESERVED_IP]`|192.168.1.50|IP réservée pour l'hôte|

### 11.3 Checklist de validation post-configuration

Utilisez cette checklist pour valider que votre serveur DHCP fonctionne correctement :

#### Phase 1 : Installation et configuration

- [ ] Le système Debian est à jour (`apt update && apt upgrade`)
- [ ] Le paquet `isc-dhcp-server` est installé
- [ ] Le fichier `/etc/default/isc-dhcp-server` contient la bonne interface
- [ ] Le fichier `/etc/dhcp/dhcpd.conf` est correctement configuré
- [ ] Une sauvegarde de la configuration originale existe
- [ ] La syntaxe est validée (`dhcpd -t -cf /etc/dhcp/dhcpd.conf`)
- [ ] Le fichier `/var/lib/dhcp/dhcpd.leases` existe

#### Phase 2 : Démarrage du service

- [ ] Le service démarre sans erreur (`systemctl start isc-dhcp-server`)
- [ ] Le statut est "active (running)" (`systemctl status isc-dhcp-server`)
- [ ] Le service est activé au démarrage (`systemctl is-enabled isc-dhcp-server`)
- [ ] Le serveur écoute sur le port 67/UDP (`ss -ulnp | grep dhcpd`)
- [ ] Aucune erreur dans les logs (`journalctl -u isc-dhcp-server`)

#### Phase 3 : Tests fonctionnels

- [ ] Un client Windows obtient une IP (`ipconfig /renew`)
- [ ] Un client Linux obtient une IP (`dhclient -v`)
- [ ] L'IP obtenue est dans la plage configurée
- [ ] La passerelle est correctement configurée
- [ ] Les serveurs DNS sont correctement configurés
- [ ] Le nom de domaine est correctement distribué
- [ ] Les réservations DHCP fonctionnent (si configurées)
- [ ] Le bail DHCP apparaît dans `/var/lib/dhcp/dhcpd.leases`

#### Phase 4 : Sécurité et monitoring

- [ ] Le pare-feu autorise les ports 67-68/UDP
- [ ] Les logs sont accessibles et lisibles
- [ ] Un système de sauvegarde est en place
- [ ] La rotation des logs est configurée
- [ ] Le monitoring de l'utilisation du pool est actif

### 11.4 Erreurs fréquentes lors du copier-coller

> [!warning] Attention au copier-coller ! Ces erreurs peuvent survenir lors de la copie de commandes depuis ce guide :

**1. Guillemets transformés**

```bash
# ✗ INCORRECT (guillemets typographiques)
option domain-name "entreprise.local";

# ✓ CORRECT (guillemets droits)
option domain-name "entreprise.local";
```

**2. Tirets transformés**

```bash
# ✗ INCORRECT (tiret cadratin)
systemctl status isc-dhcp-server

# ✓ CORRECT (tiret simple)
systemctl status isc-dhcp-server
```

**3. Espaces invisibles ou tabulations**

```conf
# Assurez-vous qu'il n'y a pas d'espaces avant les accolades
subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.100 192.168.1.200;
}
```

**4. Retours à la ligne manquants**

```conf
# ✗ INCORRECT (collé sur une ligne)
subnet 192.168.1.0 netmask 255.255.255.0 { range 192.168.1.100 192.168.1.200; }

# ✓ CORRECT (formaté correctement)
subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.100 192.168.1.200;
}
```

**5. Point-virgules oubliés**

```conf
# ✗ INCORRECT
option routers 192.168.1.1

# ✓ CORRECT
option routers 192.168.1.1;
```

> [!tip] Méthode recommandée
> 
> 1. Copiez le code dans un éditeur de texte brut (nano, vim, notepad++)
> 2. Vérifiez visuellement les guillemets et tirets
> 3. Testez la syntaxe avec `dhcpd -t` avant d'appliquer
> 4. Consultez les logs en cas d'erreur

---

## 12. Commandes de référence rapide

### 12.1 Gestion du service

```bash
# Démarrer le service
sudo systemctl start isc-dhcp-server

# Arrêter le service
sudo systemctl stop isc-dhcp-server

# Redémarrer le service
sudo systemctl restart isc-dhcp-server

# Recharger la configuration (sans couper les baux existants)
sudo systemctl reload isc-dhcp-server

# Voir le statut
sudo systemctl status isc-dhcp-server

# Activer au démarrage
sudo systemctl enable isc-dhcp-server

# Désactiver au démarrage
sudo systemctl disable isc-dhcp-server
```

### 12.2 Consultation et analyse

```bash
# Logs en temps réel
sudo journalctl -u isc-dhcp-server -f

# Logs depuis le dernier démarrage
sudo journalctl -u isc-dhcp-server -b

# 100 dernières lignes de logs
sudo journalctl -u isc-dhcp-server -n 100

# Voir les baux actifs
sudo cat /var/lib/dhcp/dhcpd.leases

# Compter les baux actifs
grep "^lease" /var/lib/dhcp/dhcpd.leases | wc -l

# Voir les ports en écoute
sudo ss -ulnp | grep dhcpd

# Tester la configuration
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf
```

### 12.3 Commandes clients

**Windows :**

```cmd
ipconfig /release          # Libérer l'IP
ipconfig /renew            # Renouveler l'IP
ipconfig /all              # Voir toute la config
ipconfig /displaydns       # Voir le cache DNS
```

**Linux :**

```bash
sudo dhclient -r eth0      # Libérer l'IP
sudo dhclient -v eth0      # Obtenir une IP (verbose)
ip addr show eth0          # Voir la config IP
nmcli device show eth0     # Avec NetworkManager
```

### 12.4 Diagnostic réseau

```bash
# Scanner le réseau
sudo nmap -sn 192.168.1.0/24

# Voir la table ARP
arp -a

# Capturer le trafic DHCP
sudo tcpdump -i eth0 port 67 or port 68

# Tester la connectivité
ping -c 4 192.168.1.1
```

---

## 13. Scénarios d'usage courants

### 13.1 Ajouter une réservation DHCP

**Objectif :** Attribuer toujours la même IP à un équipement spécifique (imprimante, serveur, etc.)

```bash
# 1. Identifier l'adresse MAC de l'équipement
# Sur Windows : ipconfig /all
# Sur Linux : ip link show

# 2. Éditer la configuration
sudo nano /etc/dhcp/dhcpd.conf

# 3. Ajouter la réservation
host imprimante-compta {
    hardware ethernet 00:11:22:33:44:55;
    fixed-address 192.168.1.45;
}

# 4. Tester la syntaxe
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf

# 5. Recharger la configuration
sudo systemctl reload isc-dhcp-server

# 6. Vérifier dans les logs
sudo journalctl -u isc-dhcp-server -f
```

### 13.2 Étendre la plage d'adresses

**Objectif :** Augmenter le nombre d'adresses disponibles

```bash
# 1. Éditer la configuration
sudo nano /etc/dhcp/dhcpd.conf

# 2. Modifier la plage
# Ancien : range 192.168.1.100 192.168.1.200;
# Nouveau : range 192.168.1.100 192.168.1.250;

# 3. Vérifier qu'aucune IP de la nouvelle plage n'est utilisée en statique
sudo nmap -sn 192.168.1.200-250

# 4. Recharger
sudo systemctl reload isc-dhcp-server
```

### 13.3 Modifier la durée des baux

**Objectif :** Adapter la durée de validité des IP selon vos besoins

```bash
sudo nano /etc/dhcp/dhcpd.conf

# Pour des postes fixes (moins de renouvellements)
default-lease-time 86400;      # 24 heures
max-lease-time 604800;         # 7 jours

# Pour des équipements mobiles (renouvellements fréquents)
default-lease-time 3600;       # 1 heure
max-lease-time 43200;          # 12 heures

sudo systemctl reload isc-dhcp-server
```

### 13.4 Exclure des adresses de la plage

**Objectif :** Réserver des adresses pour attribution manuelle

```conf
subnet 192.168.1.0 netmask 255.255.255.0 {
    # Première plage : .100 à .149
    range 192.168.1.100 192.168.1.149;
    
    # On saute .150 à .159 (réservé pour serveurs)
    
    # Deuxième plage : .160 à .200
    range 192.168.1.160 192.168.1.200;
    
    option routers 192.168.1.1;
}
```

> [!tip] Bonne pratique Documentez clairement dans votre plan d'adressage quelles plages sont DHCP et lesquelles sont statiques.

---

## 14. Intégration avec l'infrastructure

### 14.1 DHCP et DNS dynamique

Pour mettre à jour automatiquement le DNS lors des attributions DHCP :

```conf
# Dans dhcpd.conf
ddns-update-style interim;
ddns-updates on;
ddns-domainname "entreprise.local.";

# Clé partagée pour sécuriser les mises à jour DNS
include "/etc/dhcp/ddns-keys.conf";

zone entreprise.local. {
    primary 192.168.1.10;  # Serveur DNS
    key DHCP_UPDATER;
}
```

> [!info] DDNS Le DNS dynamique permet aux clients DHCP d'enregistrer automatiquement leur nom d'hôte dans le DNS. Nécessite une configuration coordonnée entre DHCP et BIND9.

### 14.2 DHCP Relay pour plusieurs VLANs

Si votre serveur DHCP doit servir plusieurs sous-réseaux via un routeur :

**Sur le routeur/switch L3 :**

```bash
# Configuration du DHCP relay (exemple Cisco)
interface Vlan10
 ip helper-address 192.168.1.5  # IP du serveur DHCP
```

**Sur le serveur DHCP :**

```conf
# Déclaration de chaque sous-réseau
subnet 192.168.10.0 netmask 255.255.255.0 {
    range 192.168.10.100 192.168.10.200;
    option routers 192.168.10.1;
}

subnet 192.168.20.0 netmask 255.255.255.0 {
    range 192.168.20.100 192.168.20.200;
    option routers 192.168.20.1;
}
```

### 14.3 Haute disponibilité (DHCP Failover)

Pour deux serveurs DHCP en redondance :

**Sur le serveur primaire :**

```conf
failover peer "dhcp-failover" {
    primary;
    address 192.168.1.5;
    port 647;
    peer address 192.168.1.6;
    peer port 647;
    max-response-delay 60;
    max-unacked-updates 10;
    mclt 3600;
    split 128;
    load balance max seconds 3;
}

subnet 192.168.1.0 netmask 255.255.255.0 {
    pool {
        failover peer "dhcp-failover";
        range 192.168.1.100 192.168.1.200;
    }
    option routers 192.168.1.1;
}
```

**Sur le serveur secondaire :**

```conf
failover peer "dhcp-failover" {
    secondary;
    address 192.168.1.6;
    port 647;
    peer address 192.168.1.5;
    peer port 647;
    max-response-delay 60;
    max-unacked-updates 10;
    load balance max seconds 3;
}

# Même configuration de subnet
```

> [!warning] Complexité du failover La configuration en haute disponibilité nécessite une synchronisation précise entre les deux serveurs. À réserver aux environnements critiques.

---

## 15. Documentation et bonnes pratiques professionnelles

### 15.1 Plan d'adressage IP

Documentez toujours votre plan d'adressage :

```markdown
## Plan d'adressage réseau 192.168.1.0/24

| Plage | Usage | Type | Notes |
|-------|-------|------|-------|
| .1 | Passerelle | Statique | Routeur principal |
| .2-.9 | Serveurs | Statique | DNS, AD, Web, etc. |
| .10-.49 | Équipements réseau | Statique | Switches, AP, etc. |
| .50-.99 | Réservations DHCP | Réservé | Imprimantes, etc. |
| .100-.200 | Pool DHCP | Dynamique | Postes utilisateurs |
| .201-.254 | Libre | - | Extension future |
```

### 15.2 Journal des modifications

Maintenez un journal des changements :

```bash
# Créer un fichier de changelog
sudo nano /etc/dhcp/CHANGELOG.md
```

```markdown
# Changelog serveur DHCP

## 2024-12-08 - Installation initiale
- Installation isc-dhcp-server
- Configuration plage 192.168.1.100-200
- Bail par défaut : 24h

## 2024-12-10 - Ajout réservations
- Imprimante RH : 192.168.1.50
- Imprimante Compta : 192.168.1.51

## 2024-12-15 - Extension plage
- Plage étendue jusqu'à .250
- Durée bail augmentée à 48h
```

### 15.3 Procédure d'intervention

Documentez les procédures pour vos collègues :

```markdown
## Procédure : Ajouter une réservation DHCP

1. Obtenir l'adresse MAC de l'équipement
2. Choisir une IP dans la plage réservée (.50-.99)
3. Éditer `/etc/dhcp/dhcpd.conf`
4. Ajouter le bloc host
5. Tester la syntaxe : `dhcpd -t`
6. Recharger : `systemctl reload isc-dhcp-server`
7. Mettre à jour le plan d'adressage
8. Mettre à jour le changelog
```

### 15.4 Contacts et escalade

```markdown
## Contacts - Serveur DHCP

**Administrateur principal :** Jean Dupont (j.dupont@entreprise.local)
**Backup :** Marie Martin (m.martin@entreprise.local)

**En cas de problème :**
1. Vérifier les logs : `journalctl -u isc-dhcp-server`
2. Vérifier le service : `systemctl status isc-dhcp-server`
3. Si indisponibilité : Contacter l'administrateur
4. Si critique : Contacter l'astreinte au 06.XX.XX.XX.XX

**Documentation :** \\serveur\docs\reseau\dhcp\
**Sauvegardes :** \\serveur\backup\dhcp\
```

---

## 16. Ressources complémentaires

### 16.1 Documentation officielle

- **ISC DHCP Server** : https://www.isc.org/dhcp/
- **Man pages** :
    
    ```bash
    man dhcpd.conf    # Configuration DHCPman dhcpd         # Daemon DHCPman dhcpd-options # Options DHCP disponiblesman dhclient      # Client DHCP
    ```
    

### 16.2 Fichiers de configuration importants

```
/etc/dhcp/dhcpd.conf              # Configuration principale
/etc/default/isc-dhcp-server      # Interface d'écoute
/var/lib/dhcp/dhcpd.leases        # Baux actifs
/var/log/syslog                   # Logs DHCP
/etc/network/interfaces           # Config réseau Debian
```

### 16.3 Commandes de diagnostic avancées

```bash
# Analyser les performances du serveur
sudo dhcpd -t -T  # Test avec trace

# Voir les statistiques détaillées
sudo cat /var/lib/dhcp/dhcpd.leases | grep "^lease" | sort | uniq

# Identifier les clients actifs
sudo grep "DHCPACK" /var/log/syslog | tail -50

# Capturer le trafic DHCP avec détails
sudo tcpdump -i eth0 -vvv port 67 or port 68 -w dhcp-capture.pcap
```

### 16.4 Outils graphiques (optionnels)

Pour une gestion plus visuelle :

```bash
# Webmin (interface web d'administration)
wget http://prdownloads.sourceforge.net/webadmin/webmin_2.0_all.deb
sudo dpkg -i webmin_2.0_all.deb
# Accès : https://votre-serveur:10000

# DHCPStatus (monitoring)
sudo apt install python3-pip
sudo pip3 install dhcpstatus
```

---

## 17. Checklist de mise en production

Avant de déployer en production, validez tous ces points :

### Préproduction

- [ ] La configuration a été testée sur un serveur de test
- [ ] Les plages d'adresses sont validées avec le plan d'adressage
- [ ] Les réservations sont documentées
- [ ] Les durées de bail sont appropriées à l'usage
- [ ] La redondance est en place (si nécessaire)

### Sécurité

- [ ] Le pare-feu est correctement configuré
- [ ] Seuls les ports nécessaires sont ouverts (67-68/UDP)
- [ ] Les logs sont activés et consultables
- [ ] Un système d'alerte est en place
- [ ] Les sauvegardes sont automatisées

### Documentation

- [ ] Le plan d'adressage est à jour
- [ ] Le changelog est créé
- [ ] Les procédures d'intervention sont rédigées
- [ ] Les contacts sont définis
- [ ] La documentation est accessible à l'équipe

### Tests

- [ ] Un client Windows obtient une IP correctement
- [ ] Un client Linux obtient une IP correctement
- [ ] Les paramètres réseau sont corrects (DNS, passerelle)
- [ ] Les réservations fonctionnent
- [ ] Le failover fonctionne (si configuré)
- [ ] Les logs sont correctement générés

### Monitoring

- [ ] La supervision du service est active
- [ ] Les alertes d'utilisation du pool sont configurées
- [ ] La rotation des logs est opérationnelle
- [ ] Les métriques de performance sont suivies

---

## Conclusion

Vous disposez maintenant d'un serveur DHCP pleinement fonctionnel et sécurisé sous Debian. Ce guide couvre :

✅ Installation et configuration complète ✅ Gestion des réservations et des pools d'adresses ✅ Dépannage des problèmes courants ✅ Intégration avec l'infrastructure existante ✅ Bonnes pratiques professionnelles ✅ Scripts et templates prêts à l'emploi

> [!tip] Pour aller plus loin
> 
> - Configurez le DDNS pour la mise à jour automatique du DNS
> - Mettez en place un serveur DHCP secondaire pour la redondance
> - Intégrez le DHCP avec votre solution de monitoring (Zabbix, Nagios, etc.)
> - Explorez les options DHCP avancées (PXE boot, VoIP, etc.)

> [!info] Support et communauté Pour toute question ou problème non couvert par ce guide :
> 
> - Consultez les forums Debian : https://forums.debian.net
> - IRC : #debian sur irc.debian.org
> - Documentation ISC : https://kb.isc.org/docs/isc-dhcp-44-manual-pages

**Bonne administration !** 🚀

---

**Tags Obsidian :** #linux #debian #dhcp #réseau #serveur #infrastructure #tssr #administration-système #isc-dhcp-server