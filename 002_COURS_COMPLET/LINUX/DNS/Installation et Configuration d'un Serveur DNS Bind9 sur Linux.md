
## Table des matières

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

## Contexte et Objectifs

Ce tutoriel vous guidera dans l'installation et la configuration complète d'un serveur DNS autoritaire avec **Bind9** (Berkeley Internet Name Domain) sur un système Linux Debian ou Ubuntu. Bind9 est le serveur DNS le plus utilisé sur Internet et offre une grande flexibilité pour la gestion de zones DNS en environnement professionnel.

**Prérequis :**

- Serveur Debian 11/12 ou Ubuntu 20.04/22.04/24.04
- Accès root ou sudo
- Adresse IP statique configurée
- Connexion Internet active

**Ce que vous allez apprendre :**

- Installation du service Bind9
- Configuration des zones DNS (directe et inverse)
- Sécurisation du serveur DNS
- Tests et validation de la configuration

---

## 1. Préparation du Système

### 1.1 Mise à jour du système

Avant toute installation, il est essentiel de mettre à jour la liste des paquets et le système pour éviter les conflits de dépendances.

```bash
sudo apt update
sudo apt upgrade -y
```

### 1.2 Vérification de l'hostname et de l'IP

Cette étape garantit que votre serveur possède un nom d'hôte correctement configuré, ce qui est crucial pour le DNS.

```bash
hostname
hostname -f
ip addr show
```

> [!info] Information Notez votre adresse IP et votre nom d'hôte. Le hostname système (ex: "debian", "srv01") et le nom DNS (ex: "ns1.entreprise.local") sont deux choses distinctes. Bind9 fonctionne indépendamment du hostname système.

> [!tip] Bonne pratique professionnelle : En environnement d'entreprise, il est recommandé d'utiliser un FQDN comme hostname (ex: `srv-dns.entreprise.local`) pour faciliter l'identification des serveurs dans les logs et respecter les conventions. Commande : `sudo hostnamectl set-hostname srv-dns.entreprise.local`
> 
> **Cependant, ce n'est pas obligatoire pour Bind9.** Si votre serveur a plusieurs rôles, garder un hostname simple comme "debian" ou "srv01" est parfaitement valide.

---

## 2. Installation de Bind9

### 2.1 Installation des paquets

Nous installons trois paquets essentiels :

- **bind9** : le serveur DNS lui-même
- **bind9utils** : utilitaires de diagnostic (named-checkconf, named-checkzone)
- **bind9-doc** : documentation complète

```bash
sudo apt install bind9 bind9utils bind9-doc -y
```

### 2.2 Vérification de l'installation

Cette commande confirme que le service Bind9 est actif et fonctionne correctement.

```bash
sudo systemctl status bind9
```

> [!tip] Astuce : Si le service n'est pas démarré, utilisez `sudo systemctl start bind9` et `sudo systemctl enable bind9` pour un démarrage automatique au boot.

### ✅ Checkpoint : Vérification de l'installation

```bash
# Le service doit être "active (running)"
sudo systemctl is-active bind9

# Vérifier la version installée
named -v
```

---

## 3. Configuration de Base de Bind9

### 3.1 Comprendre l'architecture des fichiers

Les fichiers de configuration Bind9 sont organisés ainsi :

- `/etc/bind/named.conf` : Fichier principal qui inclut les autres
- `/etc/bind/named.conf.options` : Options globales du serveur
- `/etc/bind/named.conf.local` : Déclaration de vos zones locales
- `/etc/bind/named.conf.default-zones` : Zones par défaut (ne pas modifier)
- `/var/cache/bind/` : Répertoire des fichiers de zones

### 3.2 Configuration des options globales

Sauvegardez d'abord le fichier original avant toute modification.

```bash
sudo cp /etc/bind/named.conf.options /etc/bind/named.conf.options.backup
```

Éditez le fichier des options pour sécuriser et optimiser le serveur :

```bash
sudo nano /etc/bind/named.conf.options
```

Remplacez le contenu par la configuration suivante :

```bind
options {
    directory "/var/cache/bind";

    // Configuration des forwarders (serveurs DNS externes)
    // Utilisez les DNS de votre entreprise ou publics (Google, Cloudflare)
    forwarders {
        8.8.8.8;
        8.8.4.4;
        1.1.1.1;
    };

    // Active le mode forward-only : toutes les requêtes non autoritaires
    // sont transférées aux forwarders
    forward only;

    // Désactive les transferts de zone par défaut (sécurité)
    allow-transfer { none; };

    // Autorise les requêtes récursives uniquement depuis votre réseau
    // IMPORTANT : Adaptez cette ligne à votre plage IP
    allow-query { localhost; 192.168.1.0/24; };

    // Active la récursion (nécessaire pour résoudre les noms externes)
    recursion yes;

    // Écoute sur IPv4 uniquement (simplification)
    listen-on { any; };
    listen-on-v6 { none; };

    // Sécurité : limite les informations exposées
    version "Not Disclosed";

    // Désactive les statistiques DNS (performance)
    zone-statistics no;

    // DNSSEC : validation des signatures DNS
    dnssec-validation auto;
};
```

> [!info] Forwarders : optionnels pour réseau local isolé Si votre DNS sert **uniquement** un réseau local **sans accès Internet** (ex: réseau interne isolé, lab), vous pouvez **supprimer** le bloc `forwarders` et la ligne `forward only;`. Dans ce cas, changez aussi `recursion yes;` en `recursion no;` et `dnssec-validation auto;` en `dnssec-validation no;`.
> 
> **Configuration minimale pour réseau isolé :**
> 
> ```bind
> options {
>     directory "/var/cache/bind";
>     allow-transfer { none; };
>     allow-query { localhost; 192.168.1.0/24; };
>     recursion no;
>     listen-on { any; };
>     listen-on-v6 { none; };
>     version "Not Disclosed";
>     dnssec-validation no;
> };
> ```

> [!warning] Configuration Réseau Critique **Modifiez impérativement la ligne `allow-query`** avec votre plage réseau réelle. Exemples :
> 
> - Réseau 10.0.0.0/8 : `allow-query { localhost; 10.0.0.0/8; };`
> - Réseau 172.16.0.0/16 : `allow-query { localhost; 172.16.0.0/16; };`
> - Multiples réseaux : `allow-query { localhost; 192.168.1.0/24; 10.0.0.0/24; };`

> [!info] À propos des forwarders Les forwarders sont des serveurs DNS externes qui résoudront les noms que votre serveur ne gère pas directement (ex: google.com, facebook.com).
> 
> **Quand les utiliser :**
> 
> - Réseau connecté à Internet où les clients doivent résoudre des noms externes
> - DNS de votre FAI, Google DNS (8.8.8.8), Cloudflare (1.1.1.1), Quad9 (9.9.9.9)
> 
> **Quand NE PAS les utiliser :**
> 
> - Réseau local totalement isolé sans accès Internet (lab, réseau interne)
> - DNS qui gère uniquement des zones internes
> - Dans ce cas, supprimez le bloc `forwarders`, la ligne `forward only;` et mettez `recursion no;`

---

## 4. Création d'une Zone DNS Directe

### 4.1 Qu'est-ce qu'une zone directe ?

Une zone DNS directe (forward zone) permet de résoudre un **nom de domaine vers une adresse IP** (ex: `serveur.entreprise.local` → `192.168.1.10`).

### 4.2 Déclaration de la zone

Éditez le fichier de configuration des zones locales :

```bash
sudo nano /etc/bind/named.conf.local
```

Ajoutez la déclaration de votre zone (adaptez le nom de domaine) :

```bind
// Zone directe pour le domaine entreprise.local
zone "entreprise.local" {
    type master;                              // Ce serveur est autoritaire
    file "/etc/bind/zones/db.entreprise.local"; // Chemin du fichier de zone
    allow-update { none; };                   // Pas de mise à jour dynamique
    allow-query { any; };                     // Accepte les requêtes de tous
};
```

> [!tip] Choix du nom de domaine : Pour un réseau interne, utilisez un domaine se terminant par `.local`, `.lan`, `.internal` ou un sous-domaine de votre domaine public (ex: `lab.monentreprise.fr`).

### 4.3 Création du répertoire des zones

Créez un répertoire dédié pour organiser vos fichiers de zones :

```bash
sudo mkdir -p /etc/bind/zones
```

### 4.4 Création du fichier de zone directe

Créez et éditez le fichier de zone :

```bash
sudo nano /etc/bind/zones/db.entreprise.local
```

Voici un exemple complet de fichier de zone :

```bind
;
; Fichier de zone DNS pour entreprise.local
; 
$TTL    86400                           ; TTL par défaut : 24 heures
@       IN      SOA     ns1.entreprise.local. admin.entreprise.local. (
                        2024121301      ; Serial (format : YYYYMMDDnn)
                        3600            ; Refresh (1 heure)
                        1800            ; Retry (30 minutes)
                        604800          ; Expire (1 semaine)
                        86400 )         ; Negative Cache TTL (24 heures)

; Serveurs de noms (NS Records)
@       IN      NS      ns1.entreprise.local.

; Enregistrement A pour le serveur DNS lui-même
ns1     IN      A       192.168.1.10

; Enregistrements A pour les serveurs
srv-web         IN      A       192.168.1.20
srv-db          IN      A       192.168.1.21
srv-mail        IN      A       192.168.1.22
srv-file        IN      A       192.168.1.23

; Enregistrement A pour les postes clients
pc01            IN      A       192.168.1.100
pc02            IN      A       192.168.1.101

; Alias (CNAME Records)
www             IN      CNAME   srv-web
intranet        IN      CNAME   srv-web
mail            IN      CNAME   srv-mail

; Enregistrement MX pour les emails (optionnel)
@               IN      MX  10  srv-mail.entreprise.local.
```

> [!info] Explication des champs SOA
> 
> - **Serial** : Numéro de version (incrémentez à chaque modification)
> - **Refresh** : Fréquence de vérification des serveurs secondaires
> - **Retry** : Délai avant nouvelle tentative en cas d'échec
> - **Expire** : Durée avant que la zone soit considérée invalide
> - **Negative Cache TTL** : Durée de cache des réponses négatives

> [!warning] Le point final est crucial ! Tous les FQDN doivent se terminer par un point (`.`). Sans ce point, le nom de la zone est automatiquement ajouté. Exemple : `ns1` devient `ns1.entreprise.local.`

> [!tip] Convention du Serial : Utilisez le format `YYYYMMDDnn` où `nn` est un numéro incrémental si vous faites plusieurs modifications le même jour. Ex : `2024121301`, `2024121302`, etc.

---

## 5. Création d'une Zone DNS Inverse

### 5.1 Qu'est-ce qu'une zone inverse ?

Une zone DNS inverse (reverse zone) permet de résoudre une **adresse IP vers un nom de domaine** (ex: `192.168.1.10` → `ns1.entreprise.local`). C'est utilisé pour la vérification par certains services (mail, SSH, etc.).

### 5.2 Déclaration de la zone inverse

Éditez à nouveau le fichier de configuration des zones locales :

```bash
sudo nano /etc/bind/named.conf.local
```

Ajoutez la déclaration de la zone inverse (après votre zone directe) :

```bind
// Zone inverse pour le réseau 192.168.1.0/24
zone "1.168.192.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.192.168.1";
    allow-update { none; };
    allow-query { any; };
};
```

> [!info] Format de la zone inverse Pour le réseau `192.168.1.0/24`, la zone inverse est `1.168.192.in-addr.arpa` (l'adresse est inversée).
> 
> - 10.0.0.0/24 → `0.0.10.in-addr.arpa`
> - 172.16.0.0/16 → `16.172.in-addr.arpa`

### 5.3 Création du fichier de zone inverse

Créez le fichier de zone inverse :

```bash
sudo nano /etc/bind/zones/db.192.168.1
```

> [!info] Nommage du fichier Le nom `db.192.168.1` est une convention classique, mais vous pouvez utiliser n'importe quel nom explicite comme `db.reverse.entreprise.local` ou `reverse-lan`. L'important est que le chemin corresponde à celui déclaré dans `named.conf.local`.

Contenu du fichier :

```bind
;
; Fichier de zone inverse pour 192.168.1.0/24
;
$TTL    86400
@       IN      SOA     ns1.entreprise.local. admin.entreprise.local. (
                        2024121301      ; Serial
                        3600            ; Refresh
                        1800            ; Retry
                        604800          ; Expire
                        86400 )         ; Negative Cache TTL

; Serveur de noms
@       IN      NS      ns1.entreprise.local.

; Enregistrements PTR (IP vers nom)
10      IN      PTR     ns1.entreprise.local.
20      IN      PTR     srv-web.entreprise.local.
21      IN      PTR     srv-db.entreprise.local.
22      IN      PTR     srv-mail.entreprise.local.
23      IN      PTR     srv-file.entreprise.local.
100     IN      PTR     pc01.entreprise.local.
101     IN      PTR     pc02.entreprise.local.
```

> [!tip] Astuce PTR Dans une zone inverse, vous n'indiquez que le dernier octet de l'IP. Pour `192.168.1.10`, vous écrivez simplement `10`.

---

## 6. Vérification et Application de la Configuration

### 6.1 Vérification de la syntaxe

Bind9 fournit des outils pour vérifier la syntaxe avant de redémarrer le service (évite les erreurs).

**Vérifier la configuration globale :**

```bash
sudo named-checkconf
```

> [!info] Résultat attendu Si tout est correct, cette commande ne retourne aucun message. Tout message d'erreur indique un problème à corriger.

**Vérifier le fichier de zone directe :**

```bash
sudo named-checkzone entreprise.local /etc/bind/zones/db.entreprise.local
```

**Vérifier le fichier de zone inverse :**

```bash
sudo named-checkzone 1.168.192.in-addr.arpa /etc/bind/zones/db.192.168.1
```

> [!success] Résultat attendu Vous devriez voir : `zone entreprise.local/IN: loaded serial 2024121301` et `OK`

> [!warning] Erreurs courantes
> 
> - `missing final ';'` : il manque un point-virgule
> - `bad owner name` : erreur dans un nom de domaine (souvent le point final manquant)
> - `expected quoted string` : guillemets manquants ou mal placés

### 6.2 Ajustement des permissions

Assurez-vous que Bind9 peut lire les fichiers de zones :

```bash
sudo chown -R bind:bind /etc/bind/zones/
sudo chmod 640 /etc/bind/zones/*
```

### 6.3 Redémarrage du service

Une fois toutes les vérifications passées, redémarrez Bind9 :

```bash
sudo systemctl restart bind9
```

Vérifiez qu'il n'y a pas d'erreurs :

```bash
sudo systemctl status bind9
```

> [!warning] Si le service ne démarre pas Consultez les logs pour identifier l'erreur :
> 
> ```bash
> sudo journalctl -xeu bind9
> # ou
> sudo tail -f /var/log/syslog | grep named
> ```

### ✅ Checkpoint : Service opérationnel

```bash
# Le service doit être actif
sudo systemctl is-active bind9

# Vérifier l'écoute sur le port 53
sudo ss -tulnp | grep :53
```

---

## 7. Tests et Validation du DNS

### 7.1 Installation des outils de test

Installez les utilitaires DNS pour tester votre serveur :

```bash
sudo apt install dnsutils -y
```

### 7.2 Tests de résolution directe

**Test avec nslookup :**

```bash
nslookup srv-web.entreprise.local 127.0.0.1
```

**Test avec dig (plus détaillé) :**

```bash
dig @127.0.0.1 srv-web.entreprise.local
```

> [!success] Résultat attendu Vous devriez voir l'adresse IP `192.168.1.20` dans la section ANSWER.

### 7.3 Tests de résolution inverse

```bash
dig @127.0.0.1 -x 192.168.1.20
```

> [!success] Résultat attendu Vous devriez voir `srv-web.entreprise.local.` dans la réponse PTR.

### 7.4 Test des CNAME

```bash
dig @127.0.0.1 www.entreprise.local
```

> [!success] Résultat attendu Vous verrez deux réponses : le CNAME pointant vers `srv-web.entreprise.local` et l'enregistrement A final.

### 7.5 Test de résolution externe

Vérifiez que votre serveur peut résoudre des noms externes (via les forwarders) :

```bash
dig @127.0.0.1 google.com
```

### ✅ Checkpoint : Validation complète

Tous les tests ci-dessus doivent retourner des résultats corrects sans erreur `SERVFAIL` ou `NXDOMAIN`.

---

## 8. Configuration du Firewall

### 8.1 Autoriser le port DNS

Si vous utilisez UFW (firewall par défaut Ubuntu/Debian) :

```bash
sudo ufw allow 53/tcp
sudo ufw allow 53/udp
sudo ufw status
```

Si vous utilisez iptables directement :

```bash
sudo iptables -A INPUT -p tcp --dport 53 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 53 -j ACCEPT
sudo iptables-save
```

> [!info] Ports DNS Le DNS utilise principalement UDP sur le port 53. TCP est utilisé pour les transferts de zone et les réponses volumineuses.

---

## 9. Configuration des Clients

### 9.1 Configuration manuelle sur Linux

Éditez le fichier de configuration réseau :

```bash
sudo nano /etc/resolv.conf
```

Ajoutez votre serveur DNS en premier :

```
nameserver 192.168.1.10
nameserver 8.8.8.8
```

> [!warning] resolv.conf peut être écrasé Sur les systèmes utilisant NetworkManager ou systemd-resolved, ce fichier est généré automatiquement. Pour une configuration permanente :
> 
> - **NetworkManager** : Configurez via l'interface graphique ou `/etc/NetworkManager/conf.d/`
> - **systemd-resolved** : Éditez `/etc/systemd/resolved.conf`

### 9.2 Configuration sur Windows

1. Ouvrir les **Paramètres réseau**
2. Aller dans **Propriétés de la carte réseau**
3. Sélectionner **Protocole Internet version 4 (TCP/IPv4)**
4. Cliquer sur **Propriétés**
5. Sélectionner **Utiliser l'adresse de serveur DNS suivante**
6. Entrer : `192.168.1.10` comme serveur DNS préféré

### 9.3 Test depuis un client

```bash
ping srv-web.entreprise.local
nslookup srv-web.entreprise.local
```

---

## 10. Sécurisation Avancée

### 10.1 Configuration des ACL (Access Control Lists)

Les ACL permettent de définir des groupes d'IPs pour simplifier la configuration. Éditez le fichier options :

```bash
sudo nano /etc/bind/named.conf.options
```

Ajoutez en début de fichier (avant le bloc `options`) :

```bind
// Définition des réseaux autorisés
acl "reseaux-internes" {
    localhost;
    localnets;
    192.168.1.0/24;
    10.0.0.0/24;
};

options {
    // ... reste de la configuration ...
    allow-query { reseaux-internes; };
    allow-recursion { reseaux-internes; };
};
```

### 10.2 Protection contre le DNS Amplification

Limitez la taille des réponses DNS pour éviter les attaques DDoS :

```bind
options {
    // ... configuration existante ...
    
    // Limite la taille des réponses UDP
    max-udp-size 512;
    
    // Limite le taux de requêtes
    rate-limit {
        responses-per-second 10;
        window 5;
    };
};
```

### 10.3 Journalisation pour l'audit

Activez les logs détaillés pour le monitoring et le dépannage :

```bash
sudo nano /etc/bind/named.conf.local
```

Ajoutez à la fin :

```bind
// Configuration de la journalisation
logging {
    channel query_log {
        file "/var/log/bind/query.log" versions 3 size 5m;
        severity info;
        print-category yes;
        print-severity yes;
        print-time yes;
    };
    
    category queries { query_log; };
};
```

Créez le répertoire de logs :

```bash
sudo mkdir -p /var/log/bind
sudo chown bind:bind /var/log/bind
sudo systemctl restart bind9
```

---

## 11. Maintenance et Dépannage

### 11.1 Commandes de diagnostic essentielles

**Vérifier les zones chargées :**

```bash
sudo rndc status
```

**Recharger la configuration sans redémarrage :**

```bash
sudo rndc reload
```

**Recharger une zone spécifique :**

```bash
sudo rndc reload entreprise.local
```

**Vider le cache DNS :**

```bash
sudo rndc flush
```

**Afficher les statistiques :**

```bash
sudo rndc stats
cat /var/cache/bind/named.stats
```

### 11.2 Consultation des logs

```bash
# Logs en temps réel
sudo tail -f /var/log/syslog | grep named

# Logs spécifiques Bind9
sudo journalctl -u bind9 -f

# Logs des requêtes (si configuré)
sudo tail -f /var/log/bind/query.log
```

### 11.3 Problèmes courants et solutions

**Le service ne démarre pas :**

```bash
# Vérifier la syntaxe
sudo named-checkconf
sudo named-checkzone entreprise.local /etc/bind/zones/db.entreprise.local

# Consulter les logs détaillés
sudo journalctl -xeu bind9
```

**Résolution DNS lente :**

- Vérifier les forwarders configurés
- Tester la latence vers les forwarders : `ping 8.8.8.8`
- Vérifier la configuration réseau du serveur

**SERVFAIL dans les réponses :**

- Vérifier la connectivité Internet
- Tester les forwarders : `dig @8.8.8.8 google.com`
- Vérifier les permissions sur les fichiers de zones

> [!tip] Mode debug Pour un diagnostic approfondi, activez le mode debug :
> 
> ```bash
> sudo rndc trace 3
> # Reproduire le problème
> sudo rndc notrace
> # Consulter les logs
> ```

---

## 12. Configuration Complète Pas à Pas

### 12.1 Script d'installation automatisé

Voici un script complet qui automatise l'installation et la configuration de base. **Lisez et adaptez les variables avant exécution.**

```bash
#!/bin/bash
#
# Script d'installation et configuration Bind9
# Auteur : Votre nom
# Date : 2024-12-13
#

# ============================================
# VARIABLES À PERSONNALISER
# ============================================

# Configuration du domaine
DOMAIN="entreprise.local"
REVERSE_ZONE="1.168.192.in-addr.arpa"
NETWORK="192.168.1"

# IP du serveur DNS
DNS_SERVER_IP="192.168.1.10"
DNS_SERVER_NAME="ns1"

# Réseau autorisé (format CIDR)
ALLOWED_NETWORK="192.168.1.0/24"

# Forwarders (DNS externes)
FORWARDER1="8.8.8.8"
FORWARDER2="8.8.4.4"

# Serial pour les zones (format YYYYMMDDnn)
SERIAL=$(date +%Y%m%d01)

# ============================================
# VÉRIFICATIONS PRÉALABLES
# ============================================

echo "=== Installation et Configuration Bind9 ==="
echo ""

# Vérifier les droits root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Ce script doit être exécuté en tant que root (sudo)"
    exit 1
fi

# Vérifier la connectivité Internet
if ! ping -c 1 8.8.8.8 &> /dev/null; then
    echo "❌ Pas de connexion Internet détectée"
    exit 1
fi

echo "✅ Vérifications préalables OK"
echo ""

# ============================================
# INSTALLATION
# ============================================

echo "📦 Mise à jour du système..."
apt update -qq
apt upgrade -y -qq

echo "📦 Installation de Bind9 et utilitaires..."
apt install -y bind9 bind9utils bind9-doc dnsutils

# ============================================
# SAUVEGARDE DES FICHIERS ORIGINAUX
# ============================================

echo "💾 Sauvegarde des configurations par défaut..."
cp /etc/bind/named.conf.options /etc/bind/named.conf.options.backup.$(date +%Y%m%d)
cp /etc/bind/named.conf.local /etc/bind/named.conf.local.backup.$(date +%Y%m%d)

# ============================================
# CONFIGURATION DES OPTIONS
# ============================================

echo "⚙️  Configuration de named.conf.options..."

cat > /etc/bind/named.conf.options <<EOF
acl "reseaux-internes" {
    localhost;
    localnets;
    ${ALLOWED_NETWORK};
};

options {
    directory "/var/cache/bind";

    // Forwarders (serveurs DNS externes)
    forwarders {
        ${FORWARDER1};
        ${FORWARDER2};
    };
    forward only;

    // Sécurité
    allow-transfer { none; };
    allow-query { reseaux-internes; };
    allow-recursion { reseaux-internes; };

    // Écoute réseau
    listen-on { any; };
    listen-on-v6 { none; };

    // Options diverses
    recursion yes;
    version "Not Disclosed";
    dnssec-validation auto;
};
EOF

# ============================================
# CRÉATION DU RÉPERTOIRE DES ZONES
# ============================================

echo "📁 Création du répertoire des zones..."
mkdir -p /etc/bind/zones

# ============================================
# CONFIGURATION DES ZONES
# ============================================

echo "⚙️  Configuration de named.conf.local..."

cat > /etc/bind/named.conf.local <<EOF
//
// Configuration des zones locales
//

// Zone directe
zone "${DOMAIN}" {
    type master;
    file "/etc/bind/zones/db.${DOMAIN}";
    allow-update { none; };
    allow-query { any; };
};

// Zone inverse
zone "${REVERSE_ZONE}" {
    type master;
    file "/etc/bind/zones/db.${NETWORK}";
    allow-update { none; };
    allow-query { any; };
};

// Journalisation
logging {
    channel query_log {
        file "/var/log/bind/query.log" versions 3 size 5m;
        severity info;
        print-time yes;
    };
    category queries { query_log; };
};
EOF

# ============================================
# CRÉATION DE LA ZONE DIRECTE
# ============================================

echo "📝 Création du fichier de zone directe..."

cat > /etc/bind/zones/db.${DOMAIN} <<EOF
;
; Fichier de zone DNS pour ${DOMAIN}
; Généré automatiquement le $(date)
;
\$TTL    86400
@       IN      SOA     ${DNS_SERVER_NAME}.${DOMAIN}. admin.${DOMAIN}. (
                        ${SERIAL}       ; Serial
                        3600            ; Refresh
                        1800            ; Retry
                        604800          ; Expire
                        86400 )         ; Negative Cache TTL

; Serveur de noms
@       IN      NS      ${DNS_SERVER_NAME}.${DOMAIN}.

; Enregistrement A pour le serveur DNS
${DNS_SERVER_NAME}     IN      A       ${DNS_SERVER_IP}

; Ajoutez vos enregistrements supplémentaires ci-dessous
; Exemple :
; srv-web    IN      A       ${NETWORK}.20
; www        IN      CNAME   srv-web
EOF

# ============================================
# CRÉATION DE LA ZONE INVERSE
# ============================================

echo "📝 Création du fichier de zone inverse..."

cat > /etc/bind/zones/db.${NETWORK} <<EOF
;
; Fichier de zone inverse pour ${NETWORK}.0/24
; Généré automatiquement le $(date)
;
\$TTL    86400
@       IN      SOA     ${DNS_SERVER_NAME}.${DOMAIN}. admin.${DOMAIN}. (
                        ${SERIAL}       ; Serial
                        3600            ; Refresh
                        1800            ; Retry
                        604800          ; Expire
                        86400 )         ; Negative Cache TTL

; Serveur de noms
@       IN      NS      ${DNS_SERVER_NAME}.${DOMAIN}.

; Enregistrement PTR pour le serveur DNS
$(echo ${DNS_SERVER_IP} | cut -d. -f4)      IN      PTR     ${DNS_SERVER_NAME}.${DOMAIN}.

; Ajoutez vos enregistrements PTR supplémentaires ci-dessous
; Exemple :
; 20     IN      PTR     srv-web.${DOMAIN}.
EOF

# ============================================
# PERMISSIONS ET LOGS
# ============================================

echo "🔒 Configuration des permissions..."
chown -R bind:bind /etc/bind/zones/
chmod 640 /etc/bind/zones/*

mkdir -p /var/log/bind
chown bind:bind /var/log/bind

# ============================================
# VÉRIFICATION DE LA SYNTAXE
# ============================================

echo "🔍 Vérification de la syntaxe..."

if ! named-checkconf; then
    echo "❌ Erreur dans la configuration générale"
    exit 1
fi

if ! named-checkzone ${DOMAIN} /etc/bind/zones/db.${DOMAIN}; then
    echo "❌ Erreur dans la zone directe"
    exit 1
fi

if ! named-checkzone ${REVERSE_ZONE} /etc/bind/zones/db.${NETWORK}; then
    echo "❌ Erreur dans la zone inverse"
    exit 1
fi

echo "✅ Syntaxe validée"

# ============================================
# CONFIGURATION DU FIREWALL
# ============================================

echo "🔥 Configuration du firewall..."

if command -v ufw &> /dev/null; then
    ufw allow 53/tcp
    ufw allow 53/udp
    echo "✅ Règles UFW ajoutées"
else
    echo "⚠️  UFW non installé, configurez manuellement votre firewall"
fi

# ============================================
# REDÉMARRAGE ET ACTIVATION
# ============================================

echo "🔄 Redémarrage du service Bind9..."
systemctl restart bind9

if systemctl is-active --quiet bind9; then
    echo "✅ Service Bind9 démarré avec succès"
else
    echo "❌ Échec du démarrage de Bind9"
    journalctl -xeu bind9 --no-pager | tail -20
    exit 1
fi

systemctl enable bind9
echo "✅ Service Bind9 activé au démarrage"

# ============================================
# TESTS AUTOMATISÉS
# ============================================

echo ""
echo "🧪 Tests de validation..."
echo ""

sleep 2

# Test de résolution directe
echo -n "Test résolution directe (${DNS_SERVER_NAME}.${DOMAIN})... "
if dig @127.0.0.1 ${DNS_SERVER_NAME}.${DOMAIN} +short | grep -q "${DNS_SERVER_IP}"; then
    echo "✅"
else
    echo "❌"
fi

# Test de résolution inverse
echo -n "Test résolution inverse (${DNS_SERVER_IP})... "
if dig @127.0.0.1 -x ${DNS_SERVER_IP} +short | grep -q "${DNS_SERVER_NAME}.${DOMAIN}"; then
    echo "✅"
else
    echo "❌"
fi

# Test de résolution externe
echo -n "Test résolution externe (google.com)... "
if dig @127.0.0.1 google.com +short | grep -q "[0-9]"; then
    echo "✅"
else
    echo "❌"
fi

# ============================================
# RÉSUMÉ DE LA CONFIGURATION
# ============================================

echo ""
echo "============================================"
echo "🎉 Installation terminée avec succès !"
echo "============================================"
echo ""
echo "📋 Résumé de la configuration :"
echo "   - Domaine : ${DOMAIN}"
echo "   - Serveur DNS : ${DNS_SERVER_NAME}.${DOMAIN} (${DNS_SERVER_IP})"
echo "   - Zone inverse : ${REVERSE_ZONE}"
echo "   - Réseau autorisé : ${ALLOWED_NETWORK}"
echo ""
echo "📁 Fichiers importants :"
echo "   - Configuration : /etc/bind/named.conf.options"
echo "   - Zones : /etc/bind/named.conf.local"
echo "   - Zone directe : /etc/bind/zones/db.${DOMAIN}"
echo "   - Zone inverse : /etc/bind/zones/db.${NETWORK}"
echo "   - Logs : /var/log/bind/query.log"
echo ""
echo "🔧 Commandes utiles :"
echo "   - Statut : systemctl status bind9"
echo "   - Recharger : sudo rndc reload"
echo "   - Logs : sudo journalctl -fu bind9"
echo "   - Test : dig @127.0.0.1 ${DNS_SERVER_NAME}.${DOMAIN}"
echo ""
echo "⚠️  N'oubliez pas de :"
echo "   1. Ajouter vos enregistrements DNS dans les fichiers de zones"
echo "   2. Incrémenter le Serial à chaque modification"
echo "   3. Recharger la configuration : sudo rndc reload"
echo "   4. Configurer vos clients pour utiliser ce DNS"
echo ""
```

> [!warning] Attention avant exécution
> 
> - **Testez d'abord sur une VM de test**, pas en production
> - **Sauvegardez** votre configuration existante
> - **Adaptez les variables** en début de script à votre environnement
> - **Vérifiez** que l'IP du serveur correspond bien à celle configurée

### 12.2 Template de configuration avec variables

Utilisez ce template pour créer rapidement de nouveaux enregistrements DNS :

```bash
# ============================================
# TEMPLATE D'ENREGISTREMENTS DNS
# ============================================

# Variables à personnaliser
DOMAIN="entreprise.local"
SERIAL="2024121302"  # Incrémenter à chaque modification

# ============================================
# ENREGISTREMENTS À AJOUTER
# ============================================

# Format général : nom IN type valeur

# --- SERVEURS ---
srv-web          IN      A       192.168.1.20
srv-db           IN      A       192.168.1.21
srv-mail         IN      A       192.168.1.22
srv-file         IN      A       192.168.1.23
srv-backup       IN      A       192.168.1.24

# --- POSTES CLIENTS ---
pc-[UTILISATEUR]    IN      A       192.168.1.[100-199]

# --- ALIAS (CNAME) ---
www              IN      CNAME   srv-web
intranet         IN      CNAME   srv-web
webmail          IN      CNAME   srv-mail
ftp              IN      CNAME   srv-file

# --- ENREGISTREMENTS MX (Mail) ---
@                IN      MX  10  srv-mail.[DOMAINE].

# --- ENREGISTREMENTS TXT (SPF, DKIM, etc.) ---
@                IN      TXT     "v=spf1 mx ~all"

# ============================================
# ZONE INVERSE CORRESPONDANTE
# ============================================

# Format : dernier_octet IN PTR nom_complet.
20      IN      PTR     srv-web.[DOMAINE].
21      IN      PTR     srv-db.[DOMAINE].
22      IN      PTR     srv-mail.[DOMAINE].
23      IN      PTR     srv-file.[DOMAINE].
24      IN      PTR     srv-backup.[DOMAINE].
```

### 12.3 Checklist de validation post-configuration

Utilisez cette checklist pour valider que tout fonctionne correctement :

- [ ] **Installation**
    
    - [ ] Bind9 installé : `dpkg -l | grep bind9`
    - [ ] Service actif : `systemctl is-active bind9`
    - [ ] Démarrage auto : `systemctl is-enabled bind9`
- [ ] **Configuration de base**
    
    - [ ] Syntaxe validée : `named-checkconf`
    - [ ] Zones validées : `named-checkzone [zone] [fichier]`
    - [ ] Forwarders configurés dans `/etc/bind/named.conf.options`
    - [ ] ACL réseau correcte : `allow-query` adapté à votre réseau
- [ ] **Fichiers de zones**
    
    - [ ] Zone directe existe : `/etc/bind/zones/db.[domaine]`
    - [ ] Zone inverse existe : `/etc/bind/zones/db.[réseau]`
    - [ ] Serial incrémenté à chaque modification
    - [ ] Tous les FQDN se terminent par un point (`.`)
    - [ ] Permissions correctes : `ls -l /etc/bind/zones/`
- [ ] **Tests de résolution**
    
    - [ ] Test local : `dig @127.0.0.1 [nom]`
    - [ ] Test réseau : `dig @[IP_serveur] [nom]`
    - [ ] Résolution directe fonctionne : `nslookup [nom]`
    - [ ] Résolution inverse fonctionne : `nslookup [IP]`
    - [ ] CNAME fonctionnent : `dig [alias]`
    - [ ] Résolution externe : `dig @[IP_serveur] google.com`
- [ ] **Sécurité**
    
    - [ ] Firewall configuré : port 53 TCP/UDP ouvert
    - [ ] Zone transfers désactivés : `allow-transfer { none; }`
    - [ ] Récursion limitée au réseau local
    - [ ] Version Bind masquée : `version "Not Disclosed"`
- [ ] **Monitoring**
    
    - [ ] Logs actifs : `tail -f /var/log/bind/query.log`
    - [ ] Pas d'erreur dans syslog : `grep named /var/log/syslog`
    - [ ] Service supervisé : `systemctl status bind9`
- [ ] **Clients**
    
    - [ ] Au moins un client configuré pour utiliser ce DNS
    - [ ] Test depuis le client : `nslookup [nom] [IP_DNS]`
    - [ ] Navigation fonctionnelle sur les alias (www, intranet, etc.)

### 12.4 Erreurs fréquentes lors du copier-coller

> [!warning] Pièges à éviter

**1. Le point final manquant**

```bind
# ❌ INCORRECT
@       IN      NS      ns1.entreprise.local

# ✅ CORRECT
@       IN      NS      ns1.entreprise.local.
```

**2. Oubli d'incrémenter le Serial**

```bind
# À chaque modification, TOUJOURS incrémenter le Serial
# Sinon, les serveurs secondaires ne détectent pas le changement
2024121301  →  2024121302
```

**3. Espaces vs Tabulations**

```bind
# Les fichiers de zones sont sensibles aux espaces
# Utilisez des TAB ou des espaces, mais soyez cohérent
ns1     IN      A       192.168.1.10
# Ne mélangez pas : ns1<TAB>IN<SPACE>A<TAB>192.168.1.10
```

**4. Copier-coller avec sauts de ligne Windows**

```bash
# Si vous copiez depuis Windows, convertissez les fins de ligne
sudo apt install dos2unix
sudo dos2unix /etc/bind/zones/db.entreprise.local
```

**5. Guillemets et caractères spéciaux**

```bind
# ❌ INCORRECT (guillemets courbes depuis Word/Google Docs)
@       IN      TXT     "v=spf1 mx ~all"

# ✅ CORRECT (guillemets droits)
@       IN      TXT     "v=spf1 mx ~all"
```

**6. Mauvaise indentation dans named.conf**

```bind
# ❌ INCORRECT
zone "entreprise.local" {
type master;
file "/etc/bind/zones/db.entreprise.local";
};

# ✅ CORRECT (indentation cohérente)
zone "entreprise.local" {
    type master;
    file "/etc/bind/zones/db.entreprise.local";
};
```

**7. Chemins de fichiers incorrects**

```bash
# Vérifiez TOUJOURS que les chemins existent
ls -l /etc/bind/zones/db.entreprise.local
# Vérifiez les permissions
namei -l /etc/bind/zones/db.entreprise.local
```

---

## 13. Annexes et Ressources

### 13.1 Commandes de référence rapide

```bash
# === GESTION DU SERVICE ===
sudo systemctl start bind9          # Démarrer
sudo systemctl stop bind9           # Arrêter
sudo systemctl restart bind9        # Redémarrer
sudo systemctl status bind9         # Statut
sudo systemctl enable bind9         # Activer au boot

# === VALIDATION ===
sudo named-checkconf                                    # Vérifier config globale
sudo named-checkzone [zone] [fichier]                  # Vérifier une zone
sudo named-compilezone -o - [zone] [fichier]           # Compiler et afficher

# === CONTRÔLE DYNAMIQUE (rndc) ===
sudo rndc reload                    # Recharger toute la config
sudo rndc reload [zone]             # Recharger une zone
sudo rndc flush                     # Vider le cache
sudo rndc status                    # Statut détaillé
sudo rndc dumpdb -cache             # Dump du cache
sudo rndc querylog on/off           # Activer/désactiver log requêtes

# === TESTS DNS ===
dig @[IP] [nom]                     # Test complet
dig @[IP] [nom] +short              # Résultat court
dig @[IP] -x [IP]                   # Test inverse
nslookup [nom] [IP_DNS]             # Test simple
host [nom] [IP_DNS]                 # Test rapide

# === MONITORING ===
sudo tail -f /var/log/syslog | grep named              # Logs en direct
sudo journalctl -u bind9 -f                            # Journald en direct
sudo ss -tulnp | grep :53                              # Vérifier port 53
sudo netstat -tulnp | grep named                       # Vérifier écoute réseau

# === STATISTIQUES ===
sudo rndc stats                                        # Générer statistiques
cat /var/cache/bind/named.stats                        # Voir statistiques
```

### 13.2 Structure des types d'enregistrements DNS

|Type|Description|Format|Exemple|
|---|---|---|---|
|**A**|IPv4 vers nom|`nom IN A ip`|`srv IN A 192.168.1.10`|
|**AAAA**|IPv6 vers nom|`nom IN AAAA ipv6`|`srv IN AAAA 2001:db8::1`|
|**CNAME**|Alias|`alias IN CNAME cible`|`www IN CNAME srv-web`|
|**PTR**|IP vers nom (reverse)|`octet IN PTR nom.`|`10 IN PTR srv.dom.`|
|**MX**|Serveur mail|`@ IN MX prio nom.`|`@ IN MX 10 mail.dom.`|
|**NS**|Serveur DNS|`@ IN NS nom.`|`@ IN NS ns1.dom.`|
|**TXT**|Texte libre|`nom IN TXT "texte"`|`@ IN TXT "v=spf1..."`|
|**SRV**|Service|`_srv._proto IN SRV...`|`_ldap._tcp IN SRV...`|

### 13.3 Glossaire des termes DNS

|Terme|Définition|
|---|---|
|**Zone autoritaire**|Zone dont le serveur possède les données originales (master)|
|**Zone de transfert**|Copie d'une zone depuis un serveur master vers un slave|
|**Forwarder**|Serveur DNS externe qui résout les requêtes non-locales|
|**Récursion**|Capacité à résoudre complètement un nom en interrogeant d'autres serveurs|
|**TTL**|Time To Live - durée de cache d'un enregistrement (en secondes)|
|**Serial**|Numéro de version de la zone (incrémenté à chaque modification)|
|**FQDN**|Fully Qualified Domain Name - nom complet avec domaine (ex: srv.dom.local.)|
|**Reverse DNS**|Résolution IP → Nom (zone in-addr.arpa)|
|**Glue Record**|Enregistrement A nécessaire quand le NS est dans sa propre zone|
|**DNSSEC**|Sécurisation DNS par signatures cryptographiques|

### 13.4 Valeurs TTL recommandées

|Type d'enregistrement|TTL recommandé|Justification|
|---|---|---|
|**NS**|86400 (24h)|Rarement modifié|
|**MX**|3600 (1h)|Peut changer en cas de problème mail|
|**A (serveurs)**|3600 (1h)|Infrastructure stable|
|**A (workstations)**|300 (5min)|Changent plus fréquemment|
|**CNAME**|3600 (1h)|Généralement stable|
|**TXT (SPF/DKIM)**|3600 (1h)|Configuration mail stable|

> [!tip] Astuce pour les migrations Avant une migration serveur, réduisez le TTL à 300s (5 minutes) 24h à l'avance pour faciliter le basculement.

### 13.5 Liens et documentation

**Documentation officielle :**

- [Bind9 ARM (Administrator Reference Manual)](https://bind9.readthedocs.io/)
- [ISC Knowledge Base](https://kb.isc.org/docs/aa-00913)

**RFC importantes :**

- RFC 1034 : Domain Names - Concepts and Facilities
- RFC 1035 : Domain Names - Implementation and Specification
- RFC 2782 : DNS SRV Records
- RFC 4033-4035 : DNSSEC

**Outils en ligne :**

- [DNS Checker](https://dnschecker.org/) : Vérifier propagation DNS
- [MX Toolbox](https://mxtoolbox.com/) : Tests DNS complets
- [DNSViz](https://dnsviz.net/) : Visualisation DNSSEC

**Communauté :**

- [Server Fault](https://serverfault.com/questions/tagged/bind) : Q&A pour admins sys
- [/r/sysadmin](https://reddit.com/r/sysadmin) : Communauté Reddit

---

## 14. Scénarios d'Usage Courants

### 14.1 Ajouter un nouveau serveur web

**Étapes complètes :**

1. Éditez la zone directe :

```bash
sudo nano /etc/bind/zones/db.entreprise.local
```

2. Ajoutez l'enregistrement (AVANT de fermer le fichier, notez le nouveau Serial) :

```bind
; Incrémenter le Serial : 2024121301 → 2024121302
srv-web2        IN      A       192.168.1.25
```

3. Éditez la zone inverse :

```bash
sudo nano /etc/bind/zones/db.192.168.1
```

4. Ajoutez le PTR correspondant :

```bind
; Incrémenter le Serial ici aussi
25      IN      PTR     srv-web2.entreprise.local.
```

5. Validez et rechargez :

```bash
sudo named-checkzone entreprise.local /etc/bind/zones/db.entreprise.local
sudo named-checkzone 1.168.192.in-addr.arpa /etc/bind/zones/db.192.168.1
sudo rndc reload
```

6. Testez :

```bash
dig @127.0.0.1 srv-web2.entreprise.local
dig @127.0.0.1 -x 192.168.1.25
```

### 14.2 Créer un round-robin DNS (load balancing basique)

Pour répartir la charge entre plusieurs serveurs web :

```bind
; Zone directe - Plusieurs enregistrements A pour le même nom
www     IN      A       192.168.1.20
www     IN      A       192.168.1.25
www     IN      A       192.168.1.26
```

> [!info] Comportement du round-robin Le serveur DNS répondra avec les IPs dans un ordre rotatif. Ce n'est PAS un vrai load balancing (pas de health check), mais ça répartit basiquement la charge.

### 14.3 Configurer un sous-domaine délégué

Pour déléguer `lab.entreprise.local` à un autre serveur DNS :

```bind
; Zone entreprise.local
lab     IN      NS      ns-lab.entreprise.local.
ns-lab  IN      A       192.168.2.10
```

### 14.4 Migration d'un serveur (changement d'IP)

**Procédure recommandée :**

1. **J-1 : Réduire le TTL**

```bind
; Passer le TTL de 3600 à 300
srv-web         300     IN      A       192.168.1.20
```

2. **J0 : Changer l'IP**

```bind
srv-web         300     IN      A       192.168.1.30
```

3. **J+1 : Remonter le TTL**

```bind
srv-web         3600    IN      A       192.168.1.30
```

---

## 15. Cas d'Usage Avancés

### 15.1 Configuration d'un serveur DNS secondaire (slave)

**Sur le serveur primaire (master) :**

```bind
# /etc/bind/named.conf.local
zone "entreprise.local" {
    type master;
    file "/etc/bind/zones/db.entreprise.local";
    allow-transfer { 192.168.1.11; };  // IP du secondaire
    notify yes;
};
```

**Sur le serveur secondaire (slave) :**

```bind
# /etc/bind/named.conf.local
zone "entreprise.local" {
    type slave;
    file "/var/cache/bind/db.entreprise.local";
    masters { 192.168.1.10; };  // IP du primaire
};
```

### 15.2 Split DNS (vues internes/externes)

Pour avoir des réponses différentes selon l'origine de la requête :

```bind
# /etc/bind/named.conf.local
acl "interne" {
    192.168.1.0/24;
};

view "vue-interne" {
    match-clients { interne; };
    zone "entreprise.local" {
        type master;
        file "/etc/bind/zones/interne/db.entreprise.local";
    };
};

view "vue-externe" {
    match-clients { any; };
    zone "entreprise.local" {
        type master;
        file "/etc/bind/zones/externe/db.entreprise.local";
    };
};
```

### 15.3 Activer DNSSEC

> [!warning] Complexité élevée DNSSEC est complexe et nécessite une maintenance régulière (rotation des clés). Assurez-vous d'en avoir besoin.

**Génération des clés :**

```bash
cd /etc/bind/zones
dnssec-keygen -a RSASHA256 -b 2048 -n ZONE entreprise.local
dnssec-keygen -a RSASHA256 -b 2048 -f KSK -n ZONE entreprise.local
```

**Signature de la zone :**

```bash
dnssec-signzone -o entreprise.local db.entreprise.local
```

**Modification de la configuration :**

```bind
zone "entreprise.local" {
    type master;
    file "/etc/bind/zones/db.entreprise.local.signed";
    allow-update { none; };
};
```

---

## 16. Configuration Multi-Serveurs DNS (Master/Slave)

### 16.1 Architecture Master/Slave

Dans un réseau professionnel, il est recommandé d'avoir **au moins deux serveurs DNS** pour assurer la **haute disponibilité** et la **répartition de charge**. L'architecture Master/Slave (ou Primary/Secondary) est la solution standard.

**Principe de fonctionnement :**

```
┌─────────────────────┐         ┌─────────────────────┐
│   DNS Master        │         │   DNS Slave         │
│   (Primary)         │────────>│   (Secondary)       │
│   172.16.10.10      │  Auto   │   172.16.10.11      │
│                     │  Sync   │                     │
│ - Gère les zones    │         │ - Copie les zones   │
│ - Modifications ici │         │ - Lecture seule     │
│ - Notifie le slave  │         │ - Backup du master  │
└─────────────────────┘         └─────────────────────┘
         ↑                               ↑
         └───────────┬───────────────────┘
                     │
              ┌──────┴──────┐
              │   Clients   │
              │ (Round robin│
              │  DNS query) │
              └─────────────┘
```

**Avantages :**

- ✅ Haute disponibilité : si le master tombe, le slave continue de répondre
- ✅ Répartition de charge : les clients alternent entre les deux DNS
- ✅ Synchronisation automatique : les modifications se propagent seules
- ✅ Backup temps réel : le slave est une copie constante

### 16.2 Configuration du Serveur Master (Primary)

**Configuration des options (/etc/bind/named.conf.options) :**

```bind
options {
    directory "/var/cache/bind";
    
    // Autoriser le transfert de zone vers le(s) slave(s)
    allow-transfer { 172.16.10.11; };  // IP du slave
    
    // Notification automatique des slaves lors de modifications
    notify yes;
    
    allow-query { localhost; 172.16.10.0/24; };
    recursion no;
    listen-on { any; };
    listen-on-v6 { none; };
    version "Not Disclosed";
};
```

**Déclaration des zones (/etc/bind/named.conf.local) :**

```bind
// Zone directe
zone "entreprise.local" {
    type master;
    file "/etc/bind/zones/db.entreprise.local";
    allow-transfer { 172.16.10.11; };
    notify yes;
    also-notify { 172.16.10.11; };  // Notification explicite
};

// Zone inverse
zone "10.16.172.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.172.16.10";
    allow-transfer { 172.16.10.11; };
    notify yes;
    also-notify { 172.16.10.11; };
};
```

**Fichier de zone - IMPORTANT : Déclarer les deux NS :**

```bind
# /etc/bind/zones/db.entreprise.local
$TTL    86400
@       IN      SOA     ns1.entreprise.local. admin.entreprise.local. (
                        2024121301      ; Serial
                        3600            ; Refresh
                        1800            ; Retry
                        604800          ; Expire
                        86400 )         ; Negative Cache TTL

; Déclarer LES DEUX serveurs de noms
@       IN      NS      ns1.entreprise.local.
@       IN      NS      ns2.entreprise.local.

; Enregistrements A pour les serveurs DNS
ns1     IN      A       172.16.10.10
ns2     IN      A       172.16.10.11

; Reste de vos enregistrements
srv-web         IN      A       172.16.10.20
www             IN      CNAME   srv-web
```

> [!warning] Ne pas oublier le deuxième NS Si vous déclarez un slave mais que vous n'ajoutez pas son enregistrement NS dans la zone, les clients ne l'utiliseront pas automatiquement. Les deux NS doivent être présents dans le SOA.

### 16.3 Configuration du Serveur Slave (Secondary)

**Configuration des options (/etc/bind/named.conf.options) :**

```bind
options {
    directory "/var/cache/bind";
    
    // Le slave ne transfère à personne
    allow-transfer { none; };
    
    allow-query { localhost; 172.16.10.0/24; };
    recursion no;
    listen-on { any; };
    listen-on-v6 { none; };
    version "Not Disclosed";
};
```

**Déclaration des zones (/etc/bind/named.conf.local) :**

```bind
// Zone directe
zone "entreprise.local" {
    type slave;                                      // ← Type SLAVE
    file "/var/cache/bind/db.entreprise.local";     // ← Stockage dans cache
    masters { 172.16.10.10; };                       // ← IP du master
};

// Zone inverse
zone "10.16.172.in-addr.arpa" {
    type slave;
    file "/var/cache/bind/db.172.16.10";
    masters { 172.16.10.10; };
};
```

> [!info] Emplacement des fichiers sur le Slave Les fichiers de zones sur le slave sont stockés dans `/var/cache/bind/` et non `/etc/bind/zones/`. Ils sont générés automatiquement lors du transfert de zone et ne doivent **jamais être modifiés manuellement**.

**Démarrage et vérification du Slave :**

```bash
# Redémarrer le service
sudo systemctl restart bind9

# Vérifier que le transfert de zone a fonctionné
ls -la /var/cache/bind/
# Vous devriez voir : db.entreprise.local et db.172.16.10

# Consulter les logs de transfert
sudo journalctl -u bind9 | grep "transfer of"
# Résultat attendu : "transfer of 'entreprise.local' from 172.16.10.10#53: Transfer completed"
```

### 16.4 Configuration des Clients

Les clients doivent être configurés avec **les deux serveurs DNS** :

**Linux (/etc/resolv.conf) :**

```
nameserver 172.16.10.10
nameserver 172.16.10.11
```

**Windows (Propriétés TCP/IPv4) :**

- Serveur DNS préféré : `172.16.10.10`
- Serveur DNS auxiliaire : `172.16.10.11`

> [!tip] Comportement des clients Les clients interrogent d'abord le DNS préféré. Si celui-ci ne répond pas (timeout ~2-5 secondes), ils basculent automatiquement sur le DNS auxiliaire. C'est ainsi que la haute disponibilité est assurée.

### 16.5 Workflow de Modification des Zones

**Procédure à suivre pour toute modification :**

1. **Modifier UNIQUEMENT sur le serveur Master**
    
    ```bash
    sudo nano /etc/bind/zones/db.entreprise.local
    ```
    
2. **TOUJOURS incrémenter le Serial**
    
    ```bind
    # Avant
    2024121301  ; Serial
    
    # Après
    2024121302  ; Serial
    ```
    
3. **Valider la syntaxe**
    
    ```bash
    sudo named-checkzone entreprise.local /etc/bind/zones/db.entreprise.local
    ```
    
4. **Recharger sur le Master**
    
    ```bash
    sudo rndc reload entreprise.local
    ```
    
5. **Le Slave se met à jour automatiquement** (grâce à `notify yes`)
    
    ```bash
    # Sur le slave, vérifier la mise à jour
    sudo journalctl -u bind9 -f
    # Vous verrez : "received notify for zone 'entreprise.local'"
    ```
    

> [!warning] Ne JAMAIS modifier directement sur le Slave Toute modification sur le slave sera écrasée lors du prochain transfert de zone depuis le master. Le slave est **strictement en lecture seule**.

### 16.6 Commandes de Gestion Multi-Serveurs

**Sur le Master :**

```bash
# Forcer la notification des slaves
sudo rndc notify entreprise.local

# Vérifier le statut des transferts
sudo rndc status

# Voir les statistiques de transfert
sudo rndc stats
cat /var/cache/bind/named.stats | grep -i transfer
```

**Sur le Slave :**

```bash
# Forcer un transfert de zone manuel
sudo rndc retransfer entreprise.local

# Vérifier la dernière mise à jour
sudo rndc zonestatus entreprise.local

# Consulter les logs de transfert
sudo journalctl -u bind9 | grep "transfer of"
```

### 16.7 Tests de Validation Multi-Serveurs

**Test de résolution sur les deux serveurs :**

```bash
# Interroger le Master
dig @172.16.10.10 srv-web.entreprise.local +short

# Interroger le Slave
dig @172.16.10.11 srv-web.entreprise.local +short

# Les deux doivent retourner la même réponse
```

**Test de basculement (haute disponibilité) :**

```bash
# Arrêter le Master
sudo systemctl stop bind9  # Sur le master

# Tester depuis un client
nslookup srv-web.entreprise.local
# Le client doit basculer automatiquement sur le slave et obtenir une réponse
```

**Test de synchronisation :**

```bash
# Sur le Master : ajouter un enregistrement temporaire
echo "test-sync    IN    A    172.16.10.99" | sudo tee -a /etc/bind/zones/db.entreprise.local

# Incrémenter le Serial et recharger
sudo nano /etc/bind/zones/db.entreprise.local  # Serial: 2024121302 → 2024121303
sudo rndc reload entreprise.local

# Sur le Slave : attendre 5-10 secondes puis tester
dig @172.16.10.11 test-sync.entreprise.local +short
# Doit retourner : 172.16.10.99
```

### 16.8 Configuration avec 3+ Serveurs DNS

Pour ajouter plusieurs slaves (architecture à 3+ serveurs) :

**Sur le Master :**

```bind
# /etc/bind/named.conf.local
zone "entreprise.local" {
    type master;
    file "/etc/bind/zones/db.entreprise.local";
    allow-transfer { 172.16.10.11; 172.16.10.12; 172.16.10.13; };
    notify yes;
    also-notify { 172.16.10.11; 172.16.10.12; 172.16.10.13; };
};
```

**Fichier de zone - Déclarer tous les NS :**

```bind
@       IN      NS      ns1.entreprise.local.
@       IN      NS      ns2.entreprise.local.
@       IN      NS      ns3.entreprise.local.

ns1     IN      A       172.16.10.10
ns2     IN      A       172.16.10.11
ns3     IN      A       172.16.10.12
```

**Chaque slave supplémentaire a la même configuration :**

```bind
# Sur ns2, ns3, ns4...
zone "entreprise.local" {
    type slave;
    file "/var/cache/bind/db.entreprise.local";
    masters { 172.16.10.10; };  // Tous pointent vers le master
};
```

> [!tip] Architecture recommandée en production
> 
> - **PME** : 1 Master + 1 Slave (minimum viable)
> - **Entreprise moyenne** : 1 Master + 2 Slaves (tolérance de panne élevée)
> - **Grande entreprise** : 1 Master + 3+ Slaves répartis géographiquement

### 16.9 Dépannage Multi-Serveurs

**Le Slave ne reçoit pas les mises à jour :**

```bash
# Vérifier la connectivité réseau
ping 172.16.10.10  # Depuis le slave vers le master

# Vérifier le port 53 TCP (transfert de zone utilise TCP)
telnet 172.16.10.10 53

# Vérifier les ACL du master
sudo named-checkconf  # Sur le master
sudo grep allow-transfer /etc/bind/named.conf.local

# Forcer un transfert manuel
sudo rndc retransfer entreprise.local  # Sur le slave
```

**Erreur "transfer of zone denied" :**

```bash
# Sur le Master, vérifier que l'IP du slave est autorisée
sudo nano /etc/bind/named.conf.local
# Vérifier : allow-transfer { 172.16.10.11; };

# Recharger la config
sudo rndc reconfig
```

**Serial non incrémenté :**

```bash
# Le slave ne détectera pas de changement si le Serial n'augmente pas
# Vérifier le Serial sur le Master
sudo grep Serial /etc/bind/zones/db.entreprise.local

# Incrémenter manuellement et recharger
sudo rndc reload entreprise.local
```

### ✅ Checkpoint : Architecture Multi-Serveurs Fonctionnelle

- [ ] Master et Slave installés et configurés
- [ ] Zones déclarées sur le Master avec `type master`
- [ ] Zones déclarées sur le Slave avec `type slave`
- [ ] `allow-transfer` configuré sur le Master avec IP du Slave
- [ ] Les deux serveurs NS déclarés dans les fichiers de zones
- [ ] Enregistrements A pour ns1 et ns2 présents
- [ ] Transfert de zone réussi (fichiers présents dans `/var/cache/bind/` sur le slave)
- [ ] Test de résolution sur les deux serveurs : OK
- [ ] Test de synchronisation après modification : OK
- [ ] Clients configurés avec les deux DNS

---

## 17. Conclusion

Vous disposez maintenant d'un serveur DNS Bind9 pleinement fonctionnel et sécurisé. Ce guide couvre :

✅ Installation et configuration de base  
✅ Création de zones directes et inverses  
✅ Sécurisation et optimisation  
✅ Tests et validation  
✅ Maintenance et dépannage  
✅ Scénarios d'usage courants

**Prochaines étapes recommandées :**

1. **Mettre en place un serveur secondaire** pour la redondance
2. **Automatiser les sauvegardes** des fichiers de zones
3. **Configurer un monitoring** (Nagios, Zabbix, Prometheus)
4. **Documenter votre infrastructure DNS** dans un wiki
5. **Former les équipes** à la gestion courante du DNS

> [!tip] Bonnes pratiques en production
> 
> - Toujours tester les modifications sur un environnement de développement
> - Documenter chaque changement dans un registre de modifications
> - Mettre en place des alertes sur le service Bind9
> - Effectuer des sauvegardes régulières automatisées
> - Auditer régulièrement la sécurité de votre configuration

**Tags pour recherche Obsidian :**  
#dns #bind9 #debian #ubuntu #réseau #serveur #administration #linux #tutorial #tssr #infrastructure #sysadmin