

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

## 🎯 Introduction au télétravail sécurisé {#introduction}

Le télétravail nécessite une infrastructure sécurisée permettant aux employés distants d'accéder aux ressources de l'entreprise comme s'ils étaient sur place. pfSense offre plusieurs solutions VPN adaptées à différents cas d'usage.

> [!info] Pourquoi un VPN pour le télétravail ?
> 
> - **Chiffrement** : Protection des données en transit sur Internet
> - **Authentification** : Vérification de l'identité des utilisateurs distants
> - **Accès contrôlé** : Limitation des ressources accessibles selon les profils
> - **Traçabilité** : Journalisation des connexions et activités

### Types de VPN disponibles sur pfSense

|Type VPN|Usage principal|Avantages|Inconvénients|
|---|---|---|---|
|**OpenVPN**|Télétravail, mobilité|Multi-plateforme, sécurisé, flexible|Configuration plus complexe|
|**IPsec**|Site-to-Site, clients natifs|Performance, intégration OS|Configuration technique|
|**WireGuard**|Performances optimales|Rapide, moderne, simple|Plus récent, moins mature|

> [!tip] Recommandation pour le télétravail **OpenVPN** reste le choix privilégié pour le télétravail grâce à sa compatibilité universelle, sa flexibilité et sa maturité. Il fonctionne sur tous les systèmes d'exploitation et traverse facilement les firewalls.

---

## 🏗️ Architecture VPN pour le télétravail {#architecture-vpn}

### Schéma type d'architecture

```
Internet
   │
   │ Port 1194/UDP (OpenVPN)
   ▼
┌─────────────────┐
│   pfSense FW    │
│  WAN: Public IP │
│  LAN: 10.0.0.1  │
│  VPN: 10.8.0.1  │
└─────────────────┘
   │
   ├─────────────────────────────┐
   │                             │
   ▼                             ▼
Réseau LAN                   Pool VPN
10.0.0.0/24                 10.8.0.0/24
   │                             │
Serveurs/Ressources         Clients distants
```

> [!example] Segmentation réseau typique
> 
> - **LAN** : 10.0.0.0/24 - Réseau interne de l'entreprise
> - **VPN Pool** : 10.8.0.0/24 - Adresses attribuées aux clients VPN
> - **DMZ** : 192.168.100.0/24 - Serveurs accessibles (optionnel)

### Flux de connexion

1. **Client** → Initie la connexion OpenVPN vers l'IP publique
2. **pfSense** → Authentifie l'utilisateur (certificat + login/mot de passe)
3. **Tunnel** → Établissement du tunnel chiffré
4. **Attribution IP** → Le client reçoit une IP du pool VPN
5. **Routage** → Accès aux ressources autorisées via les règles firewall

---

## 🔧 Mise en place d'un VPN distant {#mise-en-place-vpn}

### Étape 1 : Configuration de l'autorité de certification (CA)

> [!info] Pourquoi une CA ? Les certificats permettent une authentification forte basée sur la cryptographie asymétrique, plus sécurisée que les mots de passe seuls.

**Navigation** : `System > Cert. Manager > CAs`

#### Création de la CA

1. Cliquer sur `+ Add`
2. Remplir les champs :

```
Descriptive name: VPN-Company-CA
Method: Create an internal Certificate Authority
Key Type: RSA
Key Length: 2048 bits (minimum) ou 4096 bits (recommandé)
Digest Algorithm: SHA256
Lifetime (days): 3650 (10 ans pour la CA)
Common Name: vpn.entreprise.local CA
Country Code: FR
State or Province: Votre région
City: Votre ville
Organization: Nom de votre entreprise
```

> [!warning] Sécurité de la CA La clé privée de la CA est critique. Une fois la CA créée, exportez et sauvegardez-la dans un lieu sûr (coffre-fort numérique). Si elle est compromise, tous les certificats émis deviennent inutilisables.

### Étape 2 : Création du certificat serveur

**Navigation** : `System > Cert. Manager > Certificates`

1. Cliquer sur `+ Add/Sign`
2. Configuration :

```
Method: Create an internal Certificate
Descriptive name: OpenVPN-Server-Cert
Certificate authority: VPN-Company-CA
Key Type: RSA
Key Length: 2048 bits
Digest Algorithm: SHA256
Lifetime (days): 3650
Common Name: vpn.entreprise.local
Certificate Type: Server Certificate
```

> [!tip] Alternative Names Ajoutez l'IP publique et le nom de domaine dans les "Alternative Names" pour éviter les alertes de certificat.

### Étape 3 : Configuration du serveur OpenVPN

**Navigation** : `VPN > OpenVPN > Servers`

#### Configuration de base

```
Server mode: Remote Access (SSL/TLS + User Auth)
Backend for authentication: Local Database (ou LDAP/RADIUS)
Protocol: UDP (recommandé pour performance)
Device mode: tun
Interface: WAN
Local port: 1194 (port par défaut OpenVPN)
Description: VPN Télétravail
```

> [!info] Pourquoi UDP ? UDP offre de meilleures performances car il n'attend pas d'accusés de réception. TCP peut être utilisé si UDP est bloqué, mais peut causer du "TCP meltdown" (encapsulation TCP dans TCP).

#### Configuration cryptographique

```
TLS Configuration: ☑ Use a TLS Key
  → ☑ Automatically generate a TLS Key
Peer Certificate Authority: VPN-Company-CA
Server certificate: OpenVPN-Server-Cert
DH Parameter Length: 2048 bits
Encryption Algorithm: AES-256-GCM (recommandé)
Auth digest algorithm: SHA256
Hardware Crypto: No Hardware Crypto Acceleration
```

> [!warning] Algorithmes de chiffrement
> 
> - **AES-256-GCM** : Standard moderne, performant et sécurisé
> - Évitez les algorithmes obsolètes comme Blowfish ou DES
> - GCM offre l'authentification intégrée (AEAD)

#### Configuration tunnel

```
IPv4 Tunnel Network: 10.8.0.0/24
IPv6 Tunnel Network: (laisser vide si pas d'IPv6)
Redirect Gateway: ☐ (décoché pour split tunneling)
IPv4 Local network(s): 10.0.0.0/24
  (réseaux accessibles aux clients VPN)
Concurrent connections: 100 (ajuster selon besoins)
Compression: ☐ Disable Compression (recommandé pour sécurité)
Inter-Client Communication: ☐ (décoché par défaut)
Dynamic IP: ☑ Allow connected clients to retain their connections
```

> [!tip] Compression et sécurité La compression est désactivée par défaut depuis les vulnérabilités VORACLE et CRIME. Elle peut faciliter les attaques par analyse du trafic chiffré.

#### Options avancées

```
Custom options:
push "route 10.0.0.0 255.255.255.0"
push "dhcp-option DNS 10.0.0.1"
push "dhcp-option DOMAIN entreprise.local"
topology subnet
```

> [!example] Explication des options
> 
> - **push "route"** : Indique les réseaux accessibles via le VPN
> - **push "dhcp-option DNS"** : Serveur DNS à utiliser (interne)
> - **topology subnet** : Mode moderne, plus simple que net30

### Étape 4 : Règles firewall pour le VPN

> [!info] Deux niveaux de règles nécessaires
> 
> 1. **Interface WAN** : Autoriser les connexions entrantes OpenVPN
> 2. **Interface OpenVPN** : Contrôler l'accès aux ressources internes

#### Règle WAN (autoriser les connexions VPN)

**Navigation** : `Firewall > Rules > WAN`

```
Action: Pass
Interface: WAN
Address Family: IPv4
Protocol: UDP
Source: any
Destination: WAN address
Destination Port: 1194
Description: Autoriser OpenVPN télétravail
```

> [!warning] Sécurité WAN Limitez si possible la source à des plages IP connues (pays, fournisseurs) pour réduire l'exposition aux attaques.

#### Règles OpenVPN (contrôle d'accès)

**Navigation** : `Firewall > Rules > OpenVPN`

**Règle 1 : Accès serveur de fichiers**

```
Action: Pass
Interface: OpenVPN
Protocol: TCP
Source: OpenVPN subnets
Destination: 10.0.0.10 (serveur fichiers)
Destination Port: 445 (SMB)
Description: VPN → Serveur fichiers
```

**Règle 2 : Accès serveur web intranet**

```
Action: Pass
Interface: OpenVPN
Protocol: TCP
Source: OpenVPN subnets
Destination: 10.0.0.20 (intranet)
Destination Port: 443 (HTTPS)
Description: VPN → Intranet
```

**Règle 3 : DNS interne**

```
Action: Pass
Interface: OpenVPN
Protocol: UDP
Source: OpenVPN subnets
Destination: 10.0.0.1 (pfSense)
Destination Port: 53
Description: VPN → DNS interne
```

> [!tip] Principe du moindre privilège Créez des règles spécifiques pour chaque service nécessaire plutôt qu'une règle "pass all". Cela limite les risques en cas de compromission d'un compte VPN.

---

## 🔐 Accès sécurisé aux ressources {#acces-securise-ressources}

### Stratégies de segmentation

> [!info] Philosophie Zero Trust Même les utilisateurs VPN ne devraient avoir accès qu'aux ressources strictement nécessaires à leur travail.

#### Segmentation par profil utilisateur

```
Développeurs (10.8.0.10-10.8.0.49)
  → Serveurs GIT (10.0.0.30)
  → Serveurs DEV (10.0.1.0/24)
  → Base de données DEV (10.0.0.35)

Comptabilité (10.8.0.50-10.8.0.79)
  → Serveur ERP (10.0.0.40)
  → Serveur fichiers RH (10.0.0.11)

Direction (10.8.0.80-10.8.0.99)
  → Tous les serveurs
```

### Mise en œuvre avec alias et règles

**Navigation** : `Firewall > Aliases`

#### Création d'alias pour les groupes

**Alias VPN_Developers**

```
Type: Network(s)
Name: VPN_Developers
Description: Pool IP développeurs
Networks: 10.8.0.10/28
```

**Alias SRV_Development**

```
Type: Network(s)
Name: SRV_Development
Description: Serveurs de développement
Networks: 
  - 10.0.0.30 (GIT)
  - 10.0.1.0/24 (DEV)
  - 10.0.0.35 (DB DEV)
```

#### Règles firewall granulaires

```
Action: Pass
Interface: OpenVPN
Source: VPN_Developers
Destination: SRV_Development
Description: Développeurs → Serveurs DEV uniquement
```

> [!example] Exemple de règles par service Au lieu d'autoriser tout le trafic vers un serveur, autorisez uniquement les ports nécessaires :
> 
> - Port 22 (SSH) pour les développeurs vers les serveurs DEV
> - Port 3306 (MySQL) uniquement depuis les serveurs d'application
> - Port 443 (HTTPS) pour l'intranet

### Journalisation et audit

**Navigation** : `Status > System Logs > Firewall`

> [!tip] Surveillance des accès VPN
> 
> - Activez la journalisation sur toutes les règles OpenVPN critiques
> - Exportez régulièrement les logs vers un serveur syslog
> - Configurez des alertes pour les tentatives d'accès bloquées
> - Analysez périodiquement les patterns de connexion

### Contrôle d'accès basé sur le temps

Ajout dans Custom Options du serveur OpenVPN :

```
# Accès limité aux heures de bureau (optionnel)
# Cette option nécessite un script externe
push "route 10.0.0.0 255.255.255.0"

# Durée de session maximale (86400 = 24h)
reneg-sec 86400
```

> [!warning] Limitation de durée La reconnexion automatique est active par défaut. Pour forcer une déconnexion après X heures, ajoutez `explicit-exit-notify` côté serveur.

---

## 👤 Authentification des utilisateurs {#authentification-utilisateurs}

### Méthodes d'authentification disponibles

|Méthode|Sécurité|Complexité|Usage recommandé|
|---|---|---|---|
|**Certificat seul**|Moyenne|Faible|Pas recommandé|
|**Certificat + User/Pass**|Élevée|Moyenne|**Recommandé**|
|**Certificat + User/Pass + OTP**|Très élevée|Élevée|Haute sécurité|

> [!info] Authentification multi-facteurs (MFA) La combinaison certificat + mot de passe offre deux facteurs :
> 
> - **Quelque chose que vous avez** : le certificat
> - **Quelque chose que vous savez** : le mot de passe

### Configuration de l'authentification locale

#### Création d'utilisateurs locaux

**Navigation** : `System > User Manager > Users`

**Ajout d'un utilisateur**

```
Username: jdupont
Password: ************ (12+ caractères, complexe)
Full name: Jean Dupont
Group membership: VPN_Users (créer le groupe si nécessaire)
```

> [!warning] Politique de mots de passe
> 
> - Minimum 12 caractères
> - Majuscules, minuscules, chiffres, symboles
> - Changement régulier (tous les 90 jours)
> - Pas de réutilisation des 5 derniers mots de passe

#### Génération du certificat utilisateur

**Navigation** : `System > Cert. Manager > Certificates`

```
Method: Create an internal Certificate
Descriptive name: jdupont-vpn-cert
Certificate authority: VPN-Company-CA
Key Type: RSA
Key Length: 2048 bits
Lifetime (days): 365 (1 an pour les certificats utilisateurs)
Common Name: jdupont
Certificate Type: User Certificate
```

> [!tip] Gestion du cycle de vie des certificats
> 
> - Renouvelez les certificats avant expiration
> - Révoquez immédiatement les certificats des utilisateurs partis
> - Maintenez une CRL (Certificate Revocation List) à jour

### Configuration de l'authentification LDAP

Pour intégration avec Active Directory ou autre annuaire :

**Navigation** : `System > User Manager > Authentication Servers`

#### Ajout serveur LDAP

```
Descriptive name: AD-Entreprise
Type: LDAP
Hostname or IP address: 10.0.0.50
Port: 389 (ou 636 pour LDAPS)
Transport: Standard TCP (ou SSL/TLS)
Protocol version: 3
Bind credentials:
  - User DN: CN=ldap-reader,OU=Service,DC=entreprise,DC=local
  - Password: **************
Search scope:
  - Base DN: DC=entreprise,DC=local
  - Authentication containers: OU=Users,DC=entreprise,DC=local
```

> [!warning] Sécurité LDAP Utilisez LDAPS (port 636) en production pour chiffrer les échanges. LDAP standard (port 389) transmet les credentials en clair.

#### Configuration du serveur OpenVPN pour LDAP

Modifier le serveur OpenVPN existant :

```
Backend for authentication: AD-Entreprise
```

### Authentification avec OTP (optionnel)

Pour ajouter un troisième facteur (authentification temporelle).

#### Installation du package FreeRADIUS

**Navigation** : `System > Package Manager > Available Packages`

1. Rechercher `freeradius3`
2. Installer le package

#### Configuration FreeRADIUS avec Google Authenticator

**Navigation** : `Services > FreeRADIUS > Users`

```
Username: jdupont
Password: MotDePasseStatique
OTP Secret: JBSWY3DPEHPK3PXP (généré par Google Authenticator)
```

> [!example] Flux d'authentification avec OTP
> 
> 1. Utilisateur entre : `jdupont`
> 2. Mot de passe : `MotDePasseStatique123456` (password + code OTP)
> 3. Le système vérifie :
>     - Certificat valide ✓
>     - Mot de passe statique = "MotDePasseStatique" ✓
>     - Code OTP = "123456" (valide pour 30s) ✓

### Révocation de certificats

En cas de compromission ou départ d'employé :

**Navigation** : `System > Cert. Manager > Certificate Revocation`

1. Sélectionner la CA appropriée
2. Ajouter le certificat à révoquer
3. Le certificat est immédiatement invalide

> [!warning] CRL et clients Les clients OpenVPN doivent être configurés pour vérifier la CRL. Ajoutez dans la configuration serveur :
> 
> ```
> crl-verify /var/etc/openvpn/server1/ca.crl
> ```

---

## 🔀 Split Tunneling {#split-tunneling}

### Concept et utilité

> [!info] Qu'est-ce que le split tunneling ? Le split tunneling permet de router **seulement une partie** du trafic à travers le VPN, tandis que le reste passe directement par la connexion Internet locale du télétravailleur.

### Comparaison Full Tunnel vs Split Tunnel

|Aspect|Full Tunnel|Split Tunnel|
|---|---|---|
|**Trafic VPN**|100% du trafic|Uniquement trafic entreprise|
|**Bande passante**|Élevée côté entreprise|Optimisée|
|**Latence**|Peut être élevée|Minimale pour Internet|
|**Sécurité**|Maximum|Moindre (trafic local non protégé)|
|**Usage**|Haute sécurité|Usage quotidien|

### Configuration du Split Tunneling

#### Dans le serveur OpenVPN

**Navigation** : `VPN > OpenVPN > Servers > Edit`

```
Redirect Gateway: ☐ DÉCOCHÉ
  → Désactive le full tunnel

IPv4 Local network(s): 10.0.0.0/24
  → Seul ce réseau sera routé via VPN
```

#### Routes spécifiques poussées aux clients

Dans **Custom options** :

```
# Routes spécifiques vers les réseaux internes
push "route 10.0.0.0 255.255.255.0"
push "route 10.0.1.0 255.255.255.0"
push "route 192.168.100.0 255.255.255.0"

# DNS interne uniquement pour les domaines entreprise
push "dhcp-option DNS 10.0.0.1"
push "dhcp-option DOMAIN entreprise.local"
```

> [!example] Comportement avec split tunneling
> 
> - Accès à `intranet.entreprise.local` (10.0.0.20) → VIA VPN
> - Accès à `www.google.com` → VIA connexion locale directe
> - Accès à `serveur-fichiers.entreprise.local` (10.0.0.10) → VIA VPN
> - Streaming Netflix → VIA connexion locale directe

### Full Tunnel (pour référence)

Si au contraire, vous souhaitez que **tout** le trafic passe par le VPN :

```
Redirect Gateway: ☑ Force all client-generated traffic through the tunnel
```

> [!warning] Impact du Full Tunnel
> 
> - **Avantage** : Contrôle total du trafic, sécurité maximale
> - **Inconvénient** : Surcharge de la bande passante entreprise, latence accrue pour les services Internet

### Configuration DNS pour Split Tunnel

Le DNS est crucial pour le bon fonctionnement du split tunneling.

#### Option 1 : DNS conditionnel (recommandé)

```
# DNS interne pour domaine entreprise
push "dhcp-option DNS 10.0.0.1"
push "dhcp-option DOMAIN entreprise.local"

# Le client utilisera son DNS local pour les autres domaines
```

#### Option 2 : DNS uniquement interne

```
# Tous les DNS passent par le serveur interne
push "dhcp-option DNS 10.0.0.1"
push "dhcp-option DNS 10.0.0.2"
push "redirect-gateway def1"
```

> [!tip] DNS intelligent Configurez votre serveur DNS interne (Unbound/Bind) pour :
> 
> - Résoudre les noms internes localement
> - Transférer les requêtes externes vers des DNS publics (1.1.1.1, 8.8.8.8)

### Cas d'usage du Split Tunneling

#### Scénario 1 : Télétravail standard

```
✓ Accès aux serveurs internes via VPN
✓ Visioconférence Teams/Zoom via connexion locale (meilleure qualité)
✓ Navigation web via connexion locale
✓ Email Office365 via connexion locale
```

#### Scénario 2 : Accès données sensibles

```
✓ Full tunnel obligatoire
✓ Tout le trafic inspecté
✓ Contrôle DLP (Data Loss Prevention)
✓ Journalisation complète
```

### Vérification côté client

Pour vérifier le routage actif :

**Windows** :

```bash
route print
# Chercher les routes 10.0.0.0
```

**Linux/Mac** :

```bash
netstat -rn | grep 10.8.0
# ou
ip route show
```

> [!example] Table de routage avec split tunnel
> 
> ```
> 0.0.0.0/0        192.168.1.1      (Gateway local - Internet)
> 10.0.0.0/24      10.8.0.1         (Gateway VPN - Réseau entreprise)
> 10.8.0.0/24      10.8.0.1         (Tunnel VPN)
> ```

---

## ✅ Bonnes pratiques {#bonnes-pratiques}

### Sécurité

> [!warning] Checklist sécurité VPN
> 
> - [ ] Certificats avec minimum 2048 bits RSA
> - [ ] Authentification multi-facteurs activée
> - [ ] Algorithme de chiffrement moderne (AES-256-GCM)
> - [ ] TLS 1.3 ou TLS 1.2 minimum
> - [ ] Compression désactivée
> - [ ] Firewall rules selon principe du moindre privilège
> - [ ] Journalisation activée et centralisée
> - [ ] CRL vérifiée et mise à jour
> - [ ] Certificats renouvelés avant expiration
> - [ ] Accès WAN limité géographiquement si possible

### Performance

> [!tip] Optimisation des performances
> 
> - Utilisez UDP plutôt que TCP (sauf blocage)
> - Préférez AES-256-GCM pour équilibre sécurité/performance
> - Ajustez `sndbuf` et `rcvbuf` pour connexions haut débit :
>     
>     ```
>     sndbuf 393216rcvbuf 393216
>     ```
>     
> - Activez le `fast-io` mode pour réduire la latence
> - Dimensionnez correctement votre connexion Internet WAN

### Haute disponibilité

Pour environnement critique :

```
Configuration CARP (HA pfSense)
  ↓
Serveur OpenVPN sur IP virtuelle
  ↓
Basculement automatique en cas de panne
```

> [!info] Synchronisation HA pfSense peut synchroniser automatiquement :
> 
> - Configuration OpenVPN
> - Utilisateurs et certificats
> - Règles firewall
> - Tables d'état

### Gestion des utilisateurs

> [!tip] Cycle de vie des comptes VPN
> 
> **Onboarding** :
> 
> 1. Création compte + certificat
> 2. Export configuration client
> 3. Formation utilisateur (installation, usage)
> 4. Test de connexion initial
> 
> **Vie du compte** : 5. Monitoring des connexions 6. Renouvellement certificat avant expiration 7. Mise à jour mot de passe régulière
> 
> **Offboarding** : 8. Révocation certificat immédiate 9. Désactivation compte 10. Suppression après période de rétention

### Monitoring et alertes

**Navigation** : `Status > OpenVPN`

Surveillez :

- Nombre de connexions actives
- Bande passante utilisée
- Erreurs d'authentification (tentatives d'intrusion)
- Certificats expirant bientôt

> [!example] Script de surveillance
> 
> ```bash
> # Vérifier les connexions actives
> /usr/local/sbin/openvpn --status /var/log/openvpn-status.log
> 
> # Alerter si > 90% des slots utilisés
> if [ $ACTIVE_CONNECTIONS -gt 90 ]; then
>     echo "Alerte: Capacité VPN critique" | mail -s "VPN Alert" admin@entreprise.local
> fi
> ```

### Documentation

> [!tip] Documentation essentielle
> 
> - **Procédure de connexion** pour les utilisateurs finaux
> - **Guide de dépannage** (problèmes courants et solutions)
> - **Architecture réseau** (schéma à jour)
> - **Politique d'utilisation** du VPN
> - **Contact support** en cas de problème
> - **Procédure d'urgence** (révocation certificat)

### Sauvegarde

```
Sauvegarde hebdomadaire :
  - Configuration pfSense complète (XML)
  - Clés et certificats CA (chiffrés)
  - Règles firewall
  - Logs (export vers SIEM)
  
Stockage :
  - Site principal (serveur de sauvegarde)
  - Site distant (sécurité)
  - Cloud chiffré (optionnel)
```

> [!warning] Test de restauration Testez régulièrement (trimestriel) la restauration complète de la configuration sur un système de test pour valider l'intégrité des sauvegardes.

### Pièges courants à éviter

> [!warning] Erreurs fréquentes
> 
> **Erreur 1** : Oublier la règle firewall WAN
> 
> - Symptôme : Impossible de se connecter au VPN
> - Solution : Vérifier règle UDP 1194 sur WAN
> 
> **Erreur 2** : Pas de règle sur interface OpenVPN
> 
> - Symptôme : Connecté au VPN mais pas d'accès ressources
> - Solution : Ajouter règles Pass sur interface OpenVPN
> 
> **Erreur 3** : Routes manquantes
> 
> - Symptôme : Certains réseaux inaccessibles
> - Solution : Vérifier `push "route"` dans Custom Options
> 
> **Erreur 4** : DNS non configuré
> 
> - Symptôme : Impossible d'accéder aux ressources par nom
> - Solution : Configurer `push "dhcp-option DNS"`
> 
> **Erreur 5** : Certificat expiré
> 
> - Symptôme : Connexion refusée brutalement
> - Solution : Mettre en place alertes expiration + renouvellement proactif

### Tests et validation

Checklist de validation post-installation :

```
☑ Connexion VPN réussie depuis l'extérieur
☑ Attribution IP du pool VPN correcte
☑ Résolution DNS interne fonctionnelle
☑ Accès serveur fichiers OK
☑ Accès intranet OK
☑ Trafic Internet (si full tunnel) ou local (si split) OK
☑ Déconnexion/reconnexion fonctionne
☑ Logs de connexion présents et corrects
☑ Règles firewall appliquées correctement
☑ Performance acceptable (ping < 50ms vers LAN)
```

---

## 📊 Métriques et KPIs

### Indicateurs à surveiller

|Métrique|Seuil normal|Seuil alerte|
|---|---|---|
|Connexions simultanées|< 70% capacité|> 85% capacité|
|Bande passante VPN|< 80% lien WAN|> 90% lien WAN|
|Latence tunnel|< 50ms|> 100ms|
|Tentatives auth échouées|< 5/jour|> 20/jour|
|Certificats expirant|> 90 jours|< 30 jours|
|Échecs de connexion|< 2%|> 5%|
|Durée session moyenne|4-8h|> 12h (suspect)|

### Dashboard de monitoring

**Navigation** : `Status > Dashboard`

Widgets recommandés :

- OpenVPN Server Status
- Traffic Graphs (interface OpenVPN)
- System Information (CPU, RAM, charge)
- Firewall Logs (interface OpenVPN)

> [!tip] Monitoring avancé Intégrez pfSense avec des solutions comme :
> 
> - **Prometheus + Grafana** : Métriques temps réel
> - **ELK Stack** : Analyse centralisée des logs
> - **PRTG/Zabbix** : Monitoring infrastructure complète
> - **pfSense Status_Monitoring package** : Alertes natives

---

## 🔧 Configuration client OpenVPN

### Export de la configuration client

**Navigation** : `VPN > OpenVPN > Client Export`

> [!info] Package requis Si l'option n'apparaît pas, installez le package `openvpn-client-export` via System > Package Manager

#### Paramètres d'export

```
Remote Access Server: OpenVPN Server (votre serveur)
Host Name Resolution: Other (spécifier votre IP ou domaine)
Hostname: vpn.entreprise.com (ou IP publique)
Verify Server CN: Automatic (Use verify-x509-name)
Use Random Local Port: ☑ (recommandé)
Certificate Export Options:
  - Use Microsoft Certificate Storage (Windows)
```

#### Export pour différentes plateformes

**Windows** :

- Télécharger "Current Windows Installer"
- Fichier .exe avec OpenVPN GUI intégré
- Installation en 1 clic pour l'utilisateur

**macOS** :

- Télécharger "Viscosity Inline Configuration"
- Compatible avec Tunnelblick (gratuit) ou Viscosity (payant)

**Linux** :

- Télécharger "Inline Configuration"
- Fichier .ovpn à utiliser avec OpenVPN CLI

**Android/iOS** :

- Télécharger "Inline Configuration"
- Importer dans OpenVPN Connect app

### Structure du fichier .ovpn

Exemple de configuration client générée :

```
client
dev tun
proto udp
remote vpn.entreprise.com 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
auth SHA256
cipher AES-256-GCM
verb 3

# Authentification certificat + user/pass
auth-user-pass

# Certificat CA intégré
<ca>
-----BEGIN CERTIFICATE-----
MIIDXTCCAkWgAwIBAgIJAKZq...
-----END CERTIFICATE-----
</ca>

# Certificat client intégré
<cert>
-----BEGIN CERTIFICATE-----
MIIDZzCCAk+gAwIBAgIBAjANBgkq...
-----END CERTIFICATE-----
</cert>

# Clé privée client intégrée
<key>
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEF...
-----END PRIVATE KEY-----
</key>

# TLS Auth key
<tls-auth>
-----BEGIN OpenVPN Static key V1-----
6acef03f62675b4b1bbd03bf51f11c58...
-----END OpenVPN Static key V1-----
</tls-auth>
key-direction 1
```

> [!warning] Sécurité du fichier .ovpn Ce fichier contient la clé privée du certificat client. Il doit être :
> 
> - Transmis de manière sécurisée (chiffré, jamais par email en clair)
> - Protégé sur le poste client (permissions restrictives)
> - Supprimé en cas de perte/vol du device

### Distribution sécurisée aux utilisateurs

> [!tip] Méthodes de distribution recommandées
> 
> **Option 1 : Portail sécurisé**
> 
> - Upload sur portail HTTPS interne
> - Lien unique à usage limité
> - Expiration après téléchargement
> 
> **Option 2 : Remise en main propre**
> 
> - Clé USB chiffrée
> - Installation accompagnée
> - Vérification identité
> 
> **Option 3 : Email chiffré**
> 
> - GPG/PGP ou S/MIME
> - Archive protégée par mot de passe fort
> - Mot de passe transmis par canal séparé

### Guide utilisateur rapide

Documentation à fournir aux télétravailleurs :

```markdown
# Guide de connexion VPN - Entreprise

## Installation (Windows)

1. Double-cliquer sur le fichier .exe fourni
2. Accepter l'installation d'OpenVPN GUI
3. Le profil de connexion est automatiquement configuré

## Connexion

1. Clic droit sur l'icône OpenVPN (zone de notification)
2. Sélectionner "Entreprise VPN"
3. Cliquer "Connect"
4. Entrer vos identifiants :
   - Username: votre.nom
   - Password: votre mot de passe
5. Attendre la connexion (icône devient verte)

## Vérification

Une fois connecté, vous devez pouvoir :
- Accéder à l'intranet : https://intranet.entreprise.local
- Accéder au serveur fichiers : \\serveur-fichiers\partage

## Déconnexion

1. Clic droit sur l'icône OpenVPN
2. Cliquer "Disconnect"

## Support

En cas de problème : support@entreprise.com ou 01 23 45 67 89
```

---

## 🚨 Dépannage et résolution de problèmes

### Problèmes de connexion

#### Symptôme : "Connection timeout"

> [!example] Diagnostic **Causes possibles** :
> 
> - Règle firewall WAN manquante ou incorrecte
> - Port 1194 UDP bloqué par pare-feu client
> - IP publique incorrecte dans la configuration client
> - Service OpenVPN arrêté sur pfSense

**Solutions** :

```
1. Vérifier le statut du service :
   Status > Services > OpenVPN → doit être "running"

2. Vérifier la règle WAN :
   Firewall > Rules > WAN
   → Règle Pass UDP port 1194 vers WAN address

3. Tester depuis l'extérieur :
   telnet vpn.entreprise.com 1194
   ou
   nmap -sU -p 1194 vpn.entreprise.com

4. Vérifier les logs :
   Status > System Logs > OpenVPN
```

#### Symptôme : "TLS handshake failed"

> [!warning] Erreur d'authentification Problème au niveau des certificats ou de la configuration cryptographique

**Solutions** :

```
1. Vérifier les certificats :
   - Certificat CA non expiré
   - Certificat serveur valide
   - Certificat client valide et correspond à l'utilisateur

2. Vérifier la configuration TLS :
   - TLS Auth key identique serveur/client
   - Version TLS compatible

3. Régénérer les certificats si nécessaire
```

#### Symptôme : "AUTH_FAILED"

> [!info] Échec d'authentification utilisateur Username/password incorrect ou compte désactivé

**Solutions** :

```
1. Vérifier les identifiants de l'utilisateur
2. Status > System Logs > OpenVPN
   → Lire le détail de l'erreur
3. Réinitialiser le mot de passe si nécessaire
4. Vérifier que le compte n'est pas désactivé
5. Si LDAP : tester la connexion au serveur LDAP
```

### Problèmes d'accès aux ressources

#### Symptôme : Connecté au VPN mais pas d'accès aux ressources

> [!example] Diagnostic routage/firewall La connexion VPN est établie mais le trafic est bloqué

**Checklist de vérification** :

```
☐ Interface OpenVPN a des règles firewall ?
  → Firewall > Rules > OpenVPN

☐ Routes poussées aux clients ?
  → VPN > OpenVPN > Servers > Custom Options
  → Vérifier "push route"

☐ Client a bien reçu les routes ?
  → Windows: route print
  → Linux: ip route show
  → Mac: netstat -rn

☐ NAT Outbound configuré ?
  → Firewall > NAT > Outbound
  → Mode: Automatic ou règle manuelle pour OpenVPN

☐ Serveurs de destination accessibles depuis pfSense ?
  → Diagnostics > Ping
  → Tester depuis pfSense vers la ressource
```

**Solution type** :

```
Créer règle sur interface OpenVPN :
  Action: Pass
  Protocol: Any
  Source: OpenVPN subnets
  Destination: LAN subnets
  Description: VPN vers LAN - accès ressources
```

#### Symptôme : DNS ne résout pas les noms internes

> [!info] Problème de résolution DNS Les IP fonctionnent mais pas les noms (ex: intranet.entreprise.local)

**Solutions** :

```
1. Vérifier que le DNS est poussé :
   Custom Options:
   push "dhcp-option DNS 10.0.0.1"

2. Côté client, vérifier les DNS reçus :
   Windows: ipconfig /all
   → Chercher "DNS Servers" sur l'interface OpenVPN

3. Vérifier que pfSense répond aux requêtes DNS :
   Services > DNS Resolver (Unbound)
   → ☑ Listen sur toutes les interfaces
   → Ou spécifiquement sur OpenVPN

4. Tester résolution depuis le client :
   nslookup intranet.entreprise.local
```

### Problèmes de performance

#### Symptôme : Latence élevée ou déconnexions fréquentes

> [!warning] Performance dégradée

**Diagnostic** :

```
1. Mesurer la latence :
   ping -t 10.8.0.1 (gateway VPN)
   → Latence normale : < 50ms
   → Latence élevée : > 100ms

2. Vérifier la bande passante :
   Status > Traffic Graph
   → Interface OpenVPN
   → Saturation ?

3. Vérifier le CPU de pfSense :
   Status > Dashboard
   → Widget "System Information"
   → CPU usage normal : < 70%
```

**Optimisations** :

```
# Dans Custom Options du serveur OpenVPN
sndbuf 393216
rcvbuf 393216
push "sndbuf 393216"
push "rcvbuf 393216"
fast-io
```

#### Symptôme : Débit faible

> [!tip] Amélioration du débit

**Vérifications** :

```
1. Test de débit sans VPN depuis le client
2. Test de débit avec VPN (speedtest vers serveur interne)
3. Comparer les résultats

Facteurs limitants possibles :
- Connexion Internet client (upload limité)
- Connexion Internet entreprise (download limité)
- CPU pfSense saturé (chiffrement)
- MTU mal configuré
```

**Solutions** :

```
1. Ajuster le MTU (dans Custom Options) :
   tun-mtu 1400
   mssfix 1360

2. Changer l'algorithme de chiffrement :
   AES-128-GCM (plus rapide que AES-256-GCM)
   → Compromis sécurité/performance

3. Utiliser UDP obligatoirement (jamais TCP)

4. Activer AES-NI si supporté par le CPU :
   System > Advanced > Miscellaneous
   → Cryptographic & Thermal Hardware
```

### Logs et diagnostic

#### Lire les logs OpenVPN

**Navigation** : `Status > System Logs > OpenVPN`

> [!example] Interprétation des logs courants

**Connexion réussie** :

```
Jan 10 14:23:45 openvpn[12345]: 192.168.1.100:54321 VERIFY OK: depth=1, CN=vpn.entreprise.local CA
Jan 10 14:23:45 openvpn[12345]: 192.168.1.100:54321 VERIFY OK: depth=0, CN=jdupont
Jan 10 14:23:45 openvpn[12345]: 192.168.1.100:54321 peer info: IV_VER=2.5.8
Jan 10 14:23:46 openvpn[12345]: jdupont/192.168.1.100:54321 MULTI: Learn: 10.8.0.10 -> jdupont
Jan 10 14:23:46 openvpn[12345]: jdupont/192.168.1.100:54321 SENT CONTROL: [jdupont]
```

**Échec d'authentification** :

```
Jan 10 14:25:12 openvpn[12345]: 192.168.1.101:12345 TLS: Initial packet from [AF_INET]192.168.1.101:12345
Jan 10 14:25:15 openvpn[12345]: 192.168.1.101:12345 VERIFY ERROR: depth=0, error=certificate has expired
Jan 10 14:25:15 openvpn[12345]: 192.168.1.101:12345 TLS_ERROR: BIO read tls_read_plaintext error
```

**Problème de routage** :

```
Jan 10 14:30:00 openvpn[12345]: ROUTE: default_gateway=UNDEF
Jan 10 14:30:00 openvpn[12345]: ERROR: Cannot iroute/route to local subnet
```

#### Outils de diagnostic intégrés

**Navigation** : `Diagnostics >`

|Outil|Usage|
|---|---|
|**Ping**|Tester connectivité IP|
|**Traceroute**|Tracer le chemin réseau|
|**Packet Capture**|Capturer le trafic pour analyse|
|**States**|Voir les connexions actives|
|**Test Port**|Vérifier qu'un port est ouvert|

> [!tip] Packet Capture pour VPN
> 
> ```
> Interface: OpenVPN
> Host Address: 10.8.0.10 (adresse client spécifique)
> Protocol: Any
> 
> Lancer la capture puis reproduire le problème
> Télécharger le .pcap et analyser avec Wireshark
> ```

---

## 📱 Mobilité et cas d'usage avancés

### VPN sur smartphone

> [!info] Application recommandée **OpenVPN Connect** (iOS et Android) - Application officielle, gratuite et fiable

**Configuration** :

1. Installer OpenVPN Connect depuis l'App Store / Play Store
2. Transférer le fichier .ovpn via :
    - Email (puis ouvrir avec OpenVPN Connect)
    - AirDrop / Partage de fichiers
    - QR Code (pour petits configs)
3. Importer le profil
4. Se connecter avec username/password

> [!warning] Sécurité mobile
> 
> - Activer le verrouillage biométrique de l'application
> - Ne pas stocker le mot de passe dans l'app (saisie manuelle)
> - Configurer la déconnexion automatique après X minutes d'inactivité

### Reconnexion automatique

Pour maintenir la connexion en cas de changement de réseau (WiFi → 4G) :

**Dans Custom Options serveur** :

```
push "persist-tun"
push "persist-key"
keepalive 10 60
```

**Côté client** (fichier .ovpn) :

```
persist-tun
persist-key
resolv-retry infinite
```

> [!example] Comportement
> 
> - Perte de connexion réseau détectée en 60s max
> - Tentative de reconnexion automatique
> - Le tunnel reste "up" pendant la reconnexion
> - Pas de re-authentification nécessaire (si session active)

### VPN Kill Switch (optionnel)

Empêcher le trafic de sortir si le VPN est déconnecté :

**Windows (OpenVPN GUI)** :

```
# Dans le fichier .ovpn, ajouter :
block-outside-dns
route-nopull
route 0.0.0.0 0.0.0.0 vpn_gateway
```

> [!warning] Attention Le Kill Switch en full tunnel peut bloquer tout accès Internet si le VPN se déconnecte. Réservé aux environnements très sécurisés.

### Connexions simultanées multiples devices

Stratégie pour utilisateurs avec plusieurs devices (PC, laptop, smartphone) :

**Option 1 : Un certificat par device**

```
Certificats :
- jdupont-laptop
- jdupont-desktop
- jdupont-phone

Avantages :
✓ Traçabilité précise
✓ Révocation granulaire
✓ Conformité audit
```

**Option 2 : Un certificat partagé**

```
Certificat :
- jdupont (utilisé sur tous les devices)

Avantages :
✓ Gestion simplifiée
✓ Moins de certificats à renouveler

Inconvénients :
✗ Moins de traçabilité
✗ Révocation affecte tous les devices
```

> [!tip] Recommandation Utiliser un certificat par device pour les environnements professionnels. Cela facilite l'audit et permet une révocation ciblée en cas de perte/vol d'un seul appareil.

---

## 🎓 Récapitulatif et points clés

### Configuration minimale fonctionnelle

> [!example] Checklist de déploiement rapide
> 
> **Côté pfSense** :
> 
> 1. ✅ CA créée + certificat serveur généré
> 2. ✅ Serveur OpenVPN configuré (UDP 1194, AES-256-GCM)
> 3. ✅ Pool VPN défini (ex: 10.8.0.0/24)
> 4. ✅ Règle firewall WAN (Pass UDP 1194)
> 5. ✅ Règles firewall OpenVPN (Pass vers ressources)
> 6. ✅ Routes poussées (push "route 10.0.0.0 255.255.255.0")
> 7. ✅ DNS configuré (push "dhcp-option DNS")
> 
> **Côté utilisateur** : 8. ✅ Compte créé + certificat client généré 9. ✅ Configuration client exportée (.ovpn) 10. ✅ OpenVPN client installé 11. ✅ Test de connexion réussi

### Différences clés : Split vs Full Tunnel

|Critère|Split Tunnel|Full Tunnel|
|---|---|---|
|**Configuration**|`Redirect Gateway: ☐`|`Redirect Gateway: ☑`|
|**Trafic Internet**|Direct|Via VPN|
|**Bande passante**|Économisée|Élevée|
|**Latence Internet**|Normale|Augmentée|
|**Sécurité**|Moindre|Maximale|
|**Cas d'usage**|Télétravail standard|Données sensibles|

### Authentification : niveaux de sécurité

```
Niveau 1 : Certificat seul
  → Faible (pas recommandé)
  → Uniquement "quelque chose que vous avez"

Niveau 2 : Certificat + User/Password
  → Standard (recommandé pour la plupart)
  → "Quelque chose que vous avez" + "Quelque chose que vous savez"

Niveau 3 : Certificat + User/Password + OTP
  → Maximum (haute sécurité)
  → Trois facteurs d'authentification
  → Recommandé pour accès critiques (finance, RH, direction)
```

### Maintenance régulière

> [!tip] Tâches de maintenance VPN
> 
> **Hebdomadaire** :
> 
> - Vérifier les logs pour anomalies
> - Contrôler le nombre de connexions actives
> 
> **Mensuel** :
> 
> - Analyser les tentatives d'authentification échouées
> - Vérifier l'utilisation de la bande passante VPN
> - Audit des comptes actifs vs. inactifs
> 
> **Trimestriel** :
> 
> - Test de restauration de configuration
> - Vérification des certificats expirant dans 90 jours
> - Revue des règles firewall OpenVPN
> - Audit des accès utilisateurs
> 
> **Annuel** :
> 
> - Renouvellement des certificats utilisateurs
> - Mise à jour de la documentation
> - Test de continuité d'activité (HA)
> - Formation rappel utilisateurs

### Évolutions et améliorations futures

Une fois le VPN fonctionnel, considérez ces améliorations :

```
Phase 1 : Déploiement de base
  → VPN opérationnel avec authentification certificat + password

Phase 2 : Renforcement sécurité
  → Ajout MFA (OTP)
  → Intégration LDAP/AD
  → Segmentation réseau avancée

Phase 3 : Haute disponibilité
  → Configuration CARP/HA
  → Load balancing multi-serveurs
  → Redondance WAN

Phase 4 : Monitoring avancé
  → SIEM centralisé
  → Alertes automatiques
  → Dashboards temps réel
  → Analyse comportementale
```

---

## 🎯 Conclusion

Le télétravail sécurisé via OpenVPN sur pfSense offre une solution robuste, flexible et économique pour connecter les employés distants aux ressources de l'entreprise.

**Points forts de cette solution** :

- ✅ Sécurité éprouvée (chiffrement AES-256, authentification multi-facteurs)
- ✅ Compatibilité universelle (Windows, macOS, Linux, iOS, Android)
- ✅ Flexibilité (split ou full tunnel selon les besoins)
- ✅ Contrôle granulaire (règles firewall par utilisateur/groupe)
- ✅ Évolutivité (de quelques utilisateurs à plusieurs centaines)
- ✅ Coût maîtrisé (solution open source)

**Prochaines étapes suggérées** :

1. Déployer une infrastructure de test
2. Former les équipes IT
3. Piloter avec un groupe restreint d'utilisateurs
4. Déployer progressivement
5. Surveiller et ajuster

> [!info] Documentation complémentaire Pour approfondir certains aspects mentionnés (LDAP, Haute Disponibilité, CARP, etc.), référez-vous aux autres sections du cours pfSense qui couvrent ces sujets en détail.

---

_Fin du document - Version 1.0 - Janvier 2026_