
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

## Introduction

DIG (Domain Information Groper) est l'outil de référence pour interroger les serveurs DNS sous Linux. Il remplace avantageusement nslookup et offre des fonctionnalités avancées pour le diagnostic réseau, l'audit de zone DNS et le troubleshooting.

**Pourquoi utiliser DIG ?**

- Sortie détaillée et facilement parsable
- Support complet des types d'enregistrements DNS
- Contrôle précis des requêtes DNS
- Idéal pour les scripts et l'automatisation

> [!info] Prérequis
> 
> - Système : Debian 10+ ou Ubuntu 18.04+
> - Droits : utilisateur standard (root uniquement pour l'installation)
> - Réseau : connectivité vers les serveurs DNS

---

## 1. Installation et vérification

### 1.1 Installation du paquet

DIG fait partie du paquet `dnsutils` (Debian/Ubuntu) ou `bind-tools` sur d'autres distributions.

**Mise à jour des dépôts et installation :**

```bash
sudo apt update
sudo apt install dnsutils -y
```

> [!tip] Alternative rapide Si vous êtes pressé, utilisez `sudo apt install dnsutils -y` directement. L'option `-y` évite la confirmation manuelle.

### 1.2 Vérification de l'installation

**Vérifier la version installée :**

```bash
dig -v
```

**Sortie attendue :**

```
DiG 9.18.x-x
```

> [!check] Checkpoint installation ✅ La commande `dig -v` affiche la version ✅ Aucune erreur "command not found"

---

## 2. Syntaxe de base et structure des requêtes

### 2.1 Syntaxe générale

```bash
dig [@serveur] [domaine] [type] [options]
```

**Paramètres :**

- `@serveur` : Serveur DNS à interroger (optionnel)
- `domaine` : Nom de domaine à résoudre
- `type` : Type d'enregistrement DNS (A, AAAA, MX, NS, etc.)
- `options` : Modificateurs de requête et d'affichage

### 2.2 Requête simple par défaut

**Effectuer une requête A basique :**

```bash
dig google.com
```

**Analyse de la sortie :**

```
; <<>> DiG 9.18.x <<>> google.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 12345
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; QUESTION SECTION:
;google.com.			IN	A

;; ANSWER SECTION:
google.com.		300	IN	A	142.250.201.78

;; Query time: 23 msec
;; SERVER: 8.8.8.8#53(8.8.8.8)
;; WHEN: Sat Dec 13 10:30:00 CET 2025
;; MSG SIZE  rcvd: 55
```

**Sections importantes :**

- **QUESTION** : Requête envoyée
- **ANSWER** : Réponse du serveur
- **Query time** : Temps de réponse
- **SERVER** : Serveur DNS utilisé

> [!info] Serveur DNS par défaut Sans spécifier `@serveur`, DIG utilise les serveurs DNS configurés dans `/etc/resolv.conf`

---

## 3. Interrogation de serveurs DNS spécifiques

### 3.1 Spécifier un serveur DNS

**Interroger Google DNS (8.8.8.8) :**

```bash
dig @8.8.8.8 example.com
```

**Interroger Cloudflare DNS (1.1.1.1) :**

```bash
dig @1.1.1.1 example.com
```

**Interroger un serveur DNS interne :**

```bash
dig @192.168.1.10 intranet.entreprise.local
```

> [!tip] Serveurs DNS publics courants
> 
> - **Google :** 8.8.8.8 / 8.8.4.4
> - **Cloudflare :** 1.1.1.1 / 1.0.0.1
> - **Quad9 :** 9.9.9.9
> - **OpenDNS :** 208.67.222.222 / 208.67.220.220

### 3.2 Comparaison entre serveurs

**Comparer les réponses de deux serveurs DNS :**

```bash
dig @8.8.8.8 example.com +short
dig @1.1.1.1 example.com +short
```

> [!warning] Propagation DNS Si vous observez des réponses différentes, cela peut indiquer une propagation DNS en cours ou un problème de cache.

---

## 4. Types d'enregistrements DNS

### 4.1 Enregistrement A (IPv4)

**Résoudre l'adresse IPv4 d'un domaine :**

```bash
dig example.com A
```

Ou simplement (A est le type par défaut) :

```bash
dig example.com
```

### 4.2 Enregistrement AAAA (IPv6)

**Résoudre l'adresse IPv6 d'un domaine :**

```bash
dig example.com AAAA
```

### 4.3 Enregistrement MX (Mail Exchange)

**Obtenir les serveurs de messagerie d'un domaine :**

```bash
dig example.com MX
```

**Sortie exemple :**

```
;; ANSWER SECTION:
example.com.		3600	IN	MX	10 mail1.example.com.
example.com.		3600	IN	MX	20 mail2.example.com.
```

> [!info] Priorité MX Le nombre (10, 20) indique la priorité. Plus le nombre est bas, plus le serveur est prioritaire.

### 4.4 Enregistrement NS (Name Server)

**Identifier les serveurs DNS autoritaires :**

```bash
dig example.com NS
```

### 4.5 Enregistrement CNAME (Canonical Name)

**Vérifier les alias de domaine :**

```bash
dig www.example.com CNAME
```

### 4.6 Enregistrement TXT

**Consulter les enregistrements texte (SPF, DKIM, vérification) :**

```bash
dig example.com TXT
```

**Cas d'usage courants :**

- Vérification de domaine (Google, Microsoft)
- Configuration SPF pour les emails
- Enregistrements DKIM
- Enregistrements DMARC

### 4.7 Enregistrement SOA (Start of Authority)

**Obtenir les informations de zone DNS :**

```bash
dig example.com SOA
```

**Informations contenues :**

- Serveur DNS principal
- Email de l'administrateur
- Numéro de série de la zone
- Timers de rafraîchissement

### 4.8 Enregistrement PTR (Reverse DNS)

**Effectuer une résolution inverse (IP vers domaine) :**

```bash
dig -x 8.8.8.8
```

Ou en format complet :

```bash
dig 8.8.8.8.in-addr.arpa PTR
```

> [!tip] Reverse DNS Très utile pour identifier l'origine d'une connexion ou vérifier la configuration des serveurs de messagerie.

### 4.9 Requête ANY (tous types)

**Obtenir tous les enregistrements disponibles :**

```bash
dig example.com ANY
```

> [!warning] Restriction ANY De nombreux serveurs DNS modernes limitent ou bloquent les requêtes ANY pour des raisons de sécurité (protection contre les attaques d'amplification).

---

## 5. Options d'affichage et de formatage

### 5.1 Affichage court (+short)

**Obtenir uniquement la réponse, sans détails :**

```bash
dig example.com +short
```

**Sortie :**

```
93.184.216.34
```

> [!tip] Idéal pour les scripts L'option `+short` est parfaite pour capturer uniquement l'IP dans un script bash.

### 5.2 Affichage détaillé (+trace)

**Tracer la résolution DNS complète depuis la racine :**

```bash
dig example.com +trace
```

**Fonctionnement :**

1. Interroge les serveurs racine (.)
2. Interroge les serveurs TLD (.com, .org, etc.)
3. Interroge les serveurs autoritaires du domaine

> [!info] Diagnostic approfondi `+trace` est essentiel pour identifier à quelle étape une résolution DNS échoue.

### 5.3 Désactiver les commentaires (+nocomments)

**Supprimer les lignes de commentaire :**

```bash
dig example.com +nocomments
```

### 5.4 Désactiver les statistiques (+nostats)

**Masquer les statistiques de requête :**

```bash
dig example.com +nostats
```

### 5.5 Combinaison d'options pour un affichage minimal

**Obtenir uniquement la section ANSWER :**

```bash
dig example.com +noall +answer
```

**Obtenir QUESTION et ANSWER :**

```bash
dig example.com +noall +question +answer
```

> [!tip] Options combinées Les options `+noall` et `+answer` sont très utilisées pour un affichage épuré et lisible.

---

## 6. Options de requête avancées

### 6.1 Requête TCP au lieu d'UDP

**Forcer l'utilisation du protocole TCP :**

```bash
dig example.com +tcp
```

> [!info] TCP vs UDP Par défaut, DNS utilise UDP (port 53). TCP est utilisé pour les transferts de zone ou si la réponse UDP dépasse 512 octets.

### 6.2 Désactiver la récursion (+norecurse)

**Effectuer une requête itérative (sans récursion) :**

```bash
dig @8.8.8.8 example.com +norecurse
```

> [!warning] Serveurs autoritaires uniquement Sans récursion, seuls les serveurs autoritaires répondront. Les serveurs récursifs renverront une référence.

### 6.3 Spécifier un port DNS personnalisé

**Interroger un serveur DNS sur un port non standard :**

```bash
dig @192.168.1.10 -p 5353 example.com
```

### 6.4 Timeout et tentatives

**Définir un timeout de 2 secondes :**

```bash
dig example.com +time=2
```

**Limiter à 2 tentatives :**

```bash
dig example.com +tries=2
```

### 6.5 DNSSEC (DNS Security Extensions)

**Vérifier la signature DNSSEC :**

```bash
dig example.com +dnssec
```

**Sortie avec RRSIG :**

```
;; ANSWER SECTION:
example.com.		3600	IN	A	93.184.216.34
example.com.		3600	IN	RRSIG	A 13 2 3600 ...
```

> [!info] Validation DNSSEC La présence d'enregistrements RRSIG indique que le domaine est signé avec DNSSEC.

---

## 7. Requêtes multiples et batch

### 7.1 Requêtes multiples en une commande

**Interroger plusieurs domaines successivement :**

```bash
dig google.com yahoo.com bing.com +short
```

### 7.2 Fichier batch

**Créer un fichier avec une liste de domaines :**

```bash
cat > domains.txt << EOF
google.com
microsoft.com
github.com
EOF
```

**Exécuter DIG sur tous les domaines du fichier :**

```bash
dig -f domains.txt +short
```

> [!tip] Automatisation Les fichiers batch sont parfaits pour auditer plusieurs domaines en une seule commande.

---

## 8. Cas d'usage professionnels

### 8.1 Vérifier la propagation DNS après modification

**Vérifier sur plusieurs serveurs DNS publics :**

```bash
echo "Google DNS:"
dig @8.8.8.8 votredomaine.com +short
echo "Cloudflare DNS:"
dig @1.1.1.1 votredomaine.com +short
echo "Quad9 DNS:"
dig @9.9.9.9 votredomaine.com +short
```

> [!check] Checkpoint propagation ✅ Tous les serveurs renvoient la même IP ✅ La nouvelle IP correspond à celle configurée

### 8.2 Diagnostiquer un problème de messagerie

**Vérifier les enregistrements MX et SPF :**

```bash
echo "=== Enregistrements MX ==="
dig votredomaine.com MX +short

echo "=== Enregistrements SPF ==="
dig votredomaine.com TXT | grep "v=spf1"
```

### 8.3 Identifier un serveur web derrière un CDN

**Résoudre le domaine original via CNAME :**

```bash
dig www.exemple.com CNAME +short
dig cdn.exemple.com A +short
```

### 8.4 Mesurer le temps de réponse DNS

**Script de monitoring simple :**

```bash
for i in {1..10}; do
  dig google.com | grep "Query time"
done
```

### 8.5 Audit de sécurité DNS

**Vérifier DNSSEC et CAA :**

```bash
echo "=== DNSSEC ==="
dig votredomaine.com +dnssec +short

echo "=== CAA Records (Certificate Authority Authorization) ==="
dig votredomaine.com CAA +short
```

> [!warning] Sécurité DNS L'absence de DNSSEC expose à des attaques de type DNS spoofing. Les enregistrements CAA limitent les autorités de certification autorisées.

---

## 9. Troubleshooting courant

### 9.1 Aucune réponse du serveur DNS

**Symptôme :**

```
;; connection timed out; no servers could be reached
```

**Causes possibles :**

- Serveur DNS injoignable (firewall, panne)
- Mauvaise configuration réseau
- Port 53 bloqué

**Solutions :**

```bash
# Tester la connectivité réseau
ping 8.8.8.8

# Vérifier le fichier de configuration DNS
cat /etc/resolv.conf

# Tester avec un autre serveur DNS
dig @1.1.1.1 google.com
```

### 9.2 Réponse SERVFAIL

**Symptôme :**

```
;; ->>HEADER<<- opcode: QUERY, status: SERVFAIL
```

**Causes possibles :**

- Erreur de configuration sur le serveur autoritaire
- Problème DNSSEC
- Zone DNS invalide

**Solutions :**

```bash
# Interroger directement le serveur autoritaire
dig example.com NS +short
dig @ns1.example.com example.com

# Tester sans DNSSEC
dig example.com +cd
```

### 9.3 Réponse NXDOMAIN

**Symptôme :**

```
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN
```

**Signification :** Le domaine n'existe pas.

**Solutions :**

```bash
# Vérifier l'orthographe du domaine
dig exemple.com

# Vérifier si le domaine est enregistré
whois exemple.com

# Tester le domaine parent
dig exemple.com NS
```

### 9.4 Propagation DNS lente

**Vérifier le TTL (Time To Live) :**

```bash
dig example.com +noall +answer
```

> [!info] TTL Un TTL élevé (3600s = 1h, 86400s = 24h) ralentit la propagation. Réduisez-le avant des modifications majeures.

---

## 10. Intégration dans des scripts bash

### 10.1 Récupérer uniquement l'IP

**Script de résolution simple :**

```bash
#!/bin/bash
DOMAIN="example.com"
IP=$(dig +short $DOMAIN | head -n1)

if [ -z "$IP" ]; then
    echo "Erreur : impossible de résoudre $DOMAIN"
    exit 1
else
    echo "$DOMAIN : $IP"
fi
```

### 10.2 Monitoring de disponibilité DNS

**Script de vérification continue :**

```bash
#!/bin/bash
DOMAIN="votreserveur.com"
TARGET_IP="93.184.216.34"

while true; do
    CURRENT_IP=$(dig +short $DOMAIN | head -n1)
    
    if [ "$CURRENT_IP" != "$TARGET_IP" ]; then
        echo "[ALERTE] IP changée : $CURRENT_IP (attendu : $TARGET_IP)"
        # Envoyer une notification (mail, webhook, etc.)
    else
        echo "[OK] $DOMAIN pointe vers $TARGET_IP"
    fi
    
    sleep 300  # Vérifier toutes les 5 minutes
done
```

### 10.3 Export CSV pour audit

**Générer un rapport CSV :**

```bash
#!/bin/bash
echo "Domaine,Type,Valeur,TTL" > dns_audit.csv

DOMAINS="google.com microsoft.com github.com"

for DOMAIN in $DOMAINS; do
    dig +noall +answer $DOMAIN A | awk -v dom="$DOMAIN" '{print dom",A,"$5","$2}' >> dns_audit.csv
done

echo "Rapport généré : dns_audit.csv"
```

---

## 11. Configuration système et optimisation

### 11.1 Fichier de configuration DNS

**Consulter le fichier resolv.conf :**

```bash
cat /etc/resolv.conf
```

**Exemple de configuration :**

```
nameserver 8.8.8.8
nameserver 8.8.4.4
options timeout:2
options attempts:3
```

### 11.2 Cache DNS local avec systemd-resolved

**Vérifier l'état du cache DNS :**

```bash
systemd-resolve --status
```

**Vider le cache DNS local :**

```bash
sudo systemd-resolve --flush-caches
```

### 11.3 Configuration de dnsmasq (cache DNS local)

**Installer dnsmasq :**

```bash
sudo apt install dnsmasq -y
```

**Configuration basique (/etc/dnsmasq.conf) :**

```bash
# Taille du cache
cache-size=1000

# Serveurs DNS upstream
server=8.8.8.8
server=8.8.4.4

# Ne pas transmettre les requêtes pour les domaines locaux
domain-needed
bogus-priv
```

**Redémarrer dnsmasq :**

```bash
sudo systemctl restart dnsmasq
sudo systemctl enable dnsmasq
```

---

## 12. Comparaison DIG vs autres outils

### 12.1 DIG vs nslookup

|Caractéristique|DIG|nslookup|
|---|---|---|
|Sortie détaillée|✅ Oui|❌ Limitée|
|Compatible scripts|✅ Excellent|⚠️ Moyen|
|Options avancées|✅ Nombreuses|❌ Peu|
|Recommandé|✅ Oui|❌ Obsolète|

### 12.2 DIG vs host

**host** : Outil simplifié pour requêtes rapides

```bash
# Équivalent DIG
dig google.com +short

# Avec host
host google.com
```

> [!tip] Choix de l'outil
> 
> - **DIG** : Diagnostic approfondi, scripts, environnement pro
> - **host** : Vérifications rapides en ligne de commande
> - **nslookup** : À éviter (obsolète)

---

## 13. Sécurité et bonnes pratiques

### 13.1 Ne pas exposer d'informations sensibles

> [!warning] Attention aux traces Les requêtes DNS peuvent révéler des informations sur votre infrastructure. Utilisez des VPN ou des tunnels chiffrés pour les audits sensibles.

### 13.2 Validation des sources

**Toujours vérifier les serveurs autoritaires :**

```bash
dig example.com NS +short
dig @ns1.example.com example.com SOA
```

### 13.3 Utiliser DNSSEC quand possible

**Activer la validation DNSSEC :**

```bash
dig example.com +dnssec +multi
```

### 13.4 Journalisation des requêtes critiques

**Rediriger les sorties vers un fichier de log :**

```bash
dig example.com > ~/dns_logs/$(date +%Y%m%d_%H%M%S)_example.log
```

---

## 14. Configuration complète pas à pas

### 14.1 Script d'installation et configuration

```bash
#!/bin/bash
# Script d'installation et configuration DIG
# Auteur : TSSR Team
# Date : 2025-12-13

set -e  # Arrêt en cas d'erreur

echo "=== Installation de DIG (dnsutils) ==="
sudo apt update
sudo apt install dnsutils -y

echo "=== Vérification de l'installation ==="
dig -v

echo "=== Configuration des serveurs DNS préférés ==="
# Backup de la configuration actuelle
sudo cp /etc/resolv.conf /etc/resolv.conf.bak.$(date +%Y%m%d)

# Configuration avec Google DNS et Cloudflare DNS
sudo tee /etc/resolv.conf > /dev/null << EOF
# Configuration DNS - $(date)
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
options timeout:2
options attempts:3
EOF

echo "=== Tests de validation ==="
echo "Test 1 : Résolution simple"
dig google.com +short

echo "Test 2 : Serveur spécifique"
dig @8.8.8.8 cloudflare.com +short

echo "Test 3 : Enregistrement MX"
dig gmail.com MX +short

echo "=== Installation terminée avec succès ==="
```

### 14.2 Template de requêtes personnalisables

```bash
#!/bin/bash
# Template de requêtes DIG personnalisables

# === VARIABLES À PERSONNALISER ===
DOMAIN="[VOTRE_DOMAINE]"              # Ex: example.com
DNS_SERVER="[SERVEUR_DNS]"             # Ex: 8.8.8.8
RECORD_TYPE="[TYPE_ENREGISTREMENT]"    # Ex: A, MX, NS, TXT
OUTPUT_FORMAT="[FORMAT]"               # short, noall +answer, ou vide

# === REQUÊTE PERSONNALISÉE ===
dig @${DNS_SERVER} ${DOMAIN} ${RECORD_TYPE} ${OUTPUT_FORMAT}

# === EXEMPLES D'UTILISATION ===
# Remplacer les variables entre crochets :

# Exemple 1 : Vérifier l'IP d'un domaine sur Google DNS
# DOMAIN="google.com"
# DNS_SERVER="8.8.8.8"
# RECORD_TYPE="A"
# OUTPUT_FORMAT="+short"

# Exemple 2 : Vérifier les MX d'un domaine sur Cloudflare DNS
# DOMAIN="votreentreprise.com"
# DNS_SERVER="1.1.1.1"
# RECORD_TYPE="MX"
# OUTPUT_FORMAT="+noall +answer"

# Exemple 3 : Vérifier les NS d'un domaine (serveur par défaut)
# DOMAIN="votreentreprise.com"
# DNS_SERVER=""  # Serveur par défaut (/etc/resolv.conf)
# RECORD_TYPE="NS"
# OUTPUT_FORMAT=""
```

### 14.3 Checklist de validation post-configuration

> [!check] Checklist complète
> 
> **Installation :**
> 
> - [ ] Paquet `dnsutils` installé
> - [ ] Commande `dig -v` fonctionne
> - [ ] Version affichée correctement
> 
> **Configuration réseau :**
> 
> - [ ] Fichier `/etc/resolv.conf` configuré
> - [ ] Au moins 2 serveurs DNS déclarés
> - [ ] Options timeout et attempts définies
> 
> **Tests fonctionnels :**
> 
> - [ ] Résolution simple (dig google.com) fonctionne
> - [ ] Résolution avec serveur spécifique (@8.8.8.8) fonctionne
> - [ ] Format court (+short) fonctionne
> - [ ] Interrogation de différents types d'enregistrements (A, MX, NS) fonctionne
> 
> **Tests avancés :**
> 
> - [ ] Requête avec +trace fonctionne
> - [ ] Requête inverse (-x) fonctionne
> - [ ] Options combinées (+noall +answer) fonctionnent
> 
> **Performance :**
> 
> - [ ] Temps de réponse < 100ms pour Google DNS
> - [ ] Aucun timeout sur les requêtes standard
> - [ ] Cache DNS local opérationnel (si configuré)

### 14.4 Erreurs courantes lors du copier-coller

> [!warning] Pièges fréquents
> 
> **1. Guillemets typographiques** ❌ Mauvais : `dig "example.com"` (guillemets courbes) ✅ Bon : `dig "example.com"` (guillemets droits)
> 
> **2. Tirets mal copiés** ❌ Mauvais : `dig –short` (tiret long) ✅ Bon : `dig +short` (signe plus, pas tiret)
> 
> **3. Espaces invisibles** Utilisez `cat -A` pour détecter les caractères cachés :
> 
> ```bash
> echo "dig google.com +short" | cat -A
> ```
> 
> **4. Variables non substituées** ❌ Mauvais : `dig $DOMAIN` (variable non définie) ✅ Bon : `DOMAIN="example.com"; dig $DOMAIN`
> 
> **5. Permissions sudo** Certaines opérations nécessitent root :
> 
> ```bash
> sudo dig @192.168.1.1 -p 53 internal.local
> ```
> 
> **6. Caractères spéciaux dans le shell** Échappez les caractères spéciaux :
> 
> ```bash
> dig "*.example.com"  # Guillemets obligatoires pour le wildcard
> ```

---

## 15. Commandes de référence rapide

### Commandes essentielles

```bash
# Résolution basique
dig example.com

# Avec serveur DNS spécifique
dig @8.8.8.8 example.com

# Format court
dig example.com +short

# Type d'enregistrement spécifique
dig example.com MX

# Traçage complet
dig example.com +trace

# Résolution inverse
dig -x 8.8.8.8

# Affichage minimal
dig example.com +noall +answer

# Vérification DNSSEC
dig example.com +dnssec

# Requête sur tous les types
dig example.com ANY

# Avec timeout et tentatives personnalisés
dig example.com +time=3 +tries=2
```

---

## 16. Ressources et documentation

### Documentation officielle

- **Page man :** `man dig`
- **ISC BIND Documentation :** https://bind.isc.org/doc/
- **RFC 1035 :** Standard DNS

### Outils complémentaires

- **whois** : Informations sur l'enregistrement du domaine
- **nmap** : Scan de ports (dont DNS)
- **tcpdump** : Capture de trafic DNS
- **wireshark** : Analyse de protocoles DNS

### Commandes apparentées

```bash
# Informations WHOIS
whois example.com

# Test de résolution via host
host example.com

# Informations sur le domaine
nslookup example.com
```

---

## Conclusion

DIG est l'outil indispensable pour tout technicien réseau ou administrateur système travaillant avec DNS. Sa richesse fonctionnelle et sa flexibilité en font l'outil de référence pour :

- Le diagnostic de problèmes réseau
- L'audit de configuration DNS
- Le monitoring de propagation DNS
- L'automatisation via scripts
- La validation de sécurité (DNSSEC, SPF, DKIM)

**Points clés à retenir :** ✅ Toujours vérifier avec plusieurs serveurs DNS lors du diagnostic ✅ Utiliser `+short` pour les scripts, `+trace` pour le troubleshooting approfondi ✅ Privilégier DIG à nslookup dans un environnement professionnel ✅ Documenter et journaliser les requêtes critiques ✅ Valider DNSSEC pour les domaines sensibles

---

**Mots-clés pour recherche Obsidian :** #dns #dig #résolution #troubleshooting #debian #ubuntu #linux #commande #terminal #réseau #diagnostic #serveur #enregistrement #mx #ns #txt #a #aaaa #cname #soa #ptr #dnssec #propagation #cache #query #autoritaire #récursif