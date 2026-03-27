

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

## 🌐 Présentation d'OpenVPN

### Qu'est-ce qu'OpenVPN ?

OpenVPN est une solution VPN open-source robuste et flexible qui permet de créer des tunnels sécurisés chiffrés entre des clients distants et le réseau local. Il utilise SSL/TLS pour l'authentification et le chiffrement des données.

> [!info] Pourquoi OpenVPN ?
> 
> - **Sécurité éprouvée** : Utilise des protocoles cryptographiques standards (OpenSSL)
> - **Flexibilité** : Fonctionne sur TCP ou UDP
> - **Compatibilité** : Supporte tous les OS (Windows, Linux, macOS, iOS, Android)
> - **Traversée NAT** : Passe facilement les pare-feux et routeurs

### Modes de fonctionnement

OpenVPN supporte deux modes principaux :

|Mode|Description|Usage typique|
|---|---|---|
|**SSL/TLS**|Utilise des certificats X.509 pour l'authentification|Mode le plus sécurisé, recommandé pour la production|
|**Clé statique**|Utilise une clé partagée pré-générée|Tests rapides, point-à-point simple|

> [!tip] Recommandation Utilisez toujours le mode **SSL/TLS** en production pour bénéficier de l'authentification mutuelle et de la rotation des clés.

### Types de VPN OpenVPN

**Remote Access VPN** (Road Warrior)

- Les clients nomades se connectent au réseau de l'entreprise
- Chaque client reçoit une adresse IP du tunnel VPN
- Configuration la plus courante pour les télétravailleurs

**Site-to-Site VPN**

- Connecte deux réseaux locaux entre eux
- Tous les équipements des deux sites peuvent communiquer
- Alternative à IPsec pour interconnecter des sites distants

### Architecture dans pfSense

```
Internet
    |
    v
[pfSense - Interface WAN]
    |
    +-- Serveur OpenVPN (UDP 1194)
    |
    +-- Certificate Authority (CA)
    |
    +-- Tunnel OpenVPN (ex: 10.0.8.0/24)
    |
    v
[Réseau LAN] (ex: 192.168.1.0/24)
```

> [!info] Composants clés
> 
> - **Certificate Authority (CA)** : Génère et signe les certificats
> - **Certificat serveur** : Identifie le serveur OpenVPN
> - **Certificats clients** : Un par utilisateur/appareil
> - **Interface tunnel** : Réseau virtuel pour les connexions VPN

---

## ⚙️ Configuration du serveur OpenVPN

### Prérequis

Avant de configurer OpenVPN, assurez-vous que :

- pfSense a une adresse IP WAN publique fixe (ou un nom de domaine dynamique)
- Le port choisi (par défaut 1194 UDP) est accessible depuis Internet
- Vous avez créé une Certificate Authority dans pfSense

### Étape 1 : Création de la Certificate Authority (CA)

> [!example] Navigation `System` → `Cert. Manager` → Onglet `CAs` → `Add`

**Configuration de la CA :**

```
Descriptive name: VPN-CA
Method: Create an internal Certificate Authority
Key length: 2048 bits (minimum) ou 4096 bits (recommandé)
Digest Algorithm: SHA256
Lifetime: 3650 days (10 ans)
Common Name: internal-vpn-ca
Country Code: FR
State or Province: Votre région
City: Votre ville
Organization: Nom de votre entreprise
```

> [!warning] Sécurité de la CA La clé privée de la CA est critique. Si elle est compromise, tous les certificats qu'elle a signés deviennent non fiables. pfSense la stocke de manière sécurisée, mais pensez à sauvegarder votre configuration.

### Étape 2 : Création du certificat serveur

> [!example] Navigation `System` → `Cert. Manager` → Onglet `Certificates` → `Add/Sign`

**Configuration du certificat serveur :**

```
Method: Create an internal Certificate
Descriptive name: OpenVPN-Server-Cert
Certificate authority: VPN-CA
Key length: 2048 bits ou 4096 bits
Digest Algorithm: SHA256
Lifetime: 3650 days
Common Name: vpn.votredomaine.com
Certificate Type: Server Certificate
```

> [!tip] Nom commun Utilisez le FQDN ou l'IP publique que les clients utiliseront pour se connecter au serveur.

### Étape 3 : Configuration du serveur OpenVPN

> [!example] Navigation `VPN` → `OpenVPN` → Onglet `Servers` → `Add`

#### Configuration générale

```
Server mode: Remote Access (SSL/TLS + User Auth)
Protocol: UDP on IPv4 only
Device mode: tun
Interface: WAN
Local port: 1194
```

> [!info] Choix du protocole
> 
> - **UDP** : Plus rapide, recommandé pour la plupart des usages
> - **TCP** : Plus fiable mais plus lent, utile si UDP est bloqué

#### Configuration cryptographique

```
TLS Configuration:
  ☑ Use a TLS Key
  ☑ Automatically generate a TLS Key
  
Peer Certificate Authority: VPN-CA
Server certificate: OpenVPN-Server-Cert

DH Parameter Length: 2048 bits
Encryption Algorithm: AES-256-GCM (128 bit block)
Auth digest algorithm: SHA256 (256-bit)
Hardware Crypto: No Hardware Crypto Acceleration
```

> [!warning] Algorithmes de chiffrement
> 
> - **AES-256-GCM** : Recommandé, offre chiffrement et authentification
> - Évitez les anciens algorithmes comme DES ou Blowfish
> - AES-GCM est plus performant que AES-CBC car il n'a pas besoin d'un digest séparé

#### Configuration du tunnel réseau

```
IPv4 Tunnel Network: 10.0.8.0/24
IPv4 Local network(s): 192.168.1.0/24

Redirect IPv4 Gateway: ☐ (ne cochez pas sauf si vous voulez router tout le trafic)
IPv6 Tunnel Network: (laisser vide si pas d'IPv6)
```

> [!info] Réseau tunnel
> 
> - Choisissez un sous-réseau privé différent de votre LAN
> - Réseaux couramment utilisés : 10.0.8.0/24, 10.8.0.0/24
> - Les clients recevront des IP de ce réseau (ex: 10.0.8.2, 10.0.8.3, etc.)

**IPv4 Local network(s)** : Spécifiez les réseaux auxquels les clients VPN pourront accéder

```
Exemple simple: 192.168.1.0/24
Exemple multiple: 192.168.1.0/24, 10.10.0.0/16
```

#### Options client

```
Concurrent connections: 10 (ou selon vos besoins)
Compression: Compress with LZ4-v2 adaptive compression
Push Compression: ☑
Type-of-Service: ☐
Inter-client communication: ☐ (cochez si les clients doivent se voir entre eux)
Duplicate Connections: ☐
```

> [!tip] Compression La compression LZ4-v2 améliore les performances sur les connexions lentes sans impacter la sécurité contrairement à LZO.

#### DNS et domaine

```
DNS Default Domain: ☑
DNS Server 1: 192.168.1.1 (IP de pfSense ou de votre DNS interne)
DNS Server 2: (optionnel)
DNS Server 3: (optionnel)
```

> [!example] Exemple de configuration DNS
> 
> - Si pfSense est votre serveur DNS : utilisez l'IP LAN de pfSense
> - Pour forcer l'utilisation du DNS interne : 192.168.1.1
> - Pour permettre l'accès à des ressources internes par nom : configurez le DNS interne

#### Options avancées

```
Advanced Configuration:
push "route 192.168.1.0 255.255.255.0"
push "dhcp-option DOMAIN monentreprise.local"

Custom options: (laisser vide sauf besoins spécifiques)
```

> [!warning] Push routes Les routes définies ici seront automatiquement ajoutées sur les clients. Inutile si vous avez déjà défini "IPv4 Local network(s)".

**Verbosity level** : 3 (pour débogage) ou 1 (production)

Sauvegardez la configuration avec `Save`.

### Étape 4 : Configuration de la règle de pare-feu WAN

Le serveur OpenVPN nécessite une règle permettant le trafic entrant sur le port configuré.

> [!example] Navigation `Firewall` → `Rules` → Onglet `WAN` → `Add` (bouton ↑ pour ajouter en haut)

**Configuration de la règle :**

```
Action: Pass
Interface: WAN
Address Family: IPv4
Protocol: UDP
Source: any
Destination: WAN address
Destination Port: 1194
Description: OpenVPN Remote Access Server
```

> [!tip] Sécurité Pour renforcer la sécurité, vous pouvez limiter la source à des plages d'IP spécifiques si vos utilisateurs ont des IP fixes.

### Étape 5 : Configuration des règles de pare-feu OpenVPN

Par défaut, pfSense ne crée pas de règles pour l'interface OpenVPN. Il faut les ajouter manuellement.

> [!example] Navigation `Firewall` → `Rules` → Onglet `OpenVPN` → `Add`

**Règle de base pour accéder au LAN :**

```
Action: Pass
Interface: OpenVPN
Address Family: IPv4
Protocol: any
Source: OpenVPN subnets
Destination: LAN subnets
Description: Allow VPN clients to LAN
```

**Règle pour accéder à pfSense (DNS, Web GUI, etc.) :**

```
Action: Pass
Interface: OpenVPN
Protocol: any
Source: OpenVPN subnets
Destination: This Firewall (self)
Description: Allow VPN clients to access pfSense services
```

> [!warning] Sécurité des règles
> 
> - Créez des règles spécifiques selon vos besoins (principe du moindre privilège)
> - Évitez les règles "any/any" trop permissives
> - Exemple restrictif : autoriser uniquement le port 445 (SMB) vers un serveur de fichiers

### Vérification du serveur

> [!example] Navigation `Status` → `OpenVPN`

Vous devriez voir votre serveur avec le statut "up".

**Logs du serveur :**

> `Status` → `System Logs` → Onglet `OpenVPN`

```
Exemple de log de démarrage réussi:
MANAGEMENT: TCP Socket listening on [AF_INET]127.0.0.1:port
Diffie-Hellman initialized with 2048 bit key
TLS-Auth MTU parms [ L:1550 D:1212 EF:38 EB:0 ET:0 EL:3 ]
ROUTE_GATEWAY 192.168.1.1/255.255.255.0
Initialization Sequence Completed
```

---

## 🔑 Création des certificats clients

Chaque utilisateur ou appareil nécessite son propre certificat client unique. Cela permet de révoquer un accès spécifique sans affecter les autres utilisateurs.

### Création manuelle d'un certificat client

> [!example] Navigation `System` → `Cert. Manager` → Onglet `Certificates` → `Add/Sign`

**Configuration du certificat :**

```
Method: Create an internal Certificate
Descriptive name: user-john-laptop
Certificate authority: VPN-CA
Key length: 2048 bits ou 4096 bits
Digest Algorithm: SHA256
Lifetime: 3650 days (ou selon votre politique)
Common Name: john.doe
Certificate Type: User Certificate
```

> [!tip] Nommage Utilisez une convention de nommage claire :
> 
> - `user-prenom.nom-appareil` (ex: user-john.doe-laptop)
> - `dept-service-utilisateur` (ex: it-admin-pierre)
> - Cela facilite la gestion et la révocation

### Création via l'assistant User Manager

Une méthode plus intégrée consiste à créer l'utilisateur et son certificat simultanément.

> [!example] Navigation `System` → `User Manager` → Onglet `Users` → `Add`

**Création de l'utilisateur :**

```
Username: john.doe
Password: (définir un mot de passe fort)
Full name: John Doe
Expiration date: (optionnel)
Group Membership: Ajouter à "VPN-Users" (créez ce groupe si nécessaire)

☑ Click to create a user certificate
Descriptive name: cert-john.doe
Certificate authority: VPN-CA
Key length: 2048 bits
Lifetime: 3650
```

> [!info] Authentification Avec `Remote Access (SSL/TLS + User Auth)`, le client doit fournir :
> 
> 1. Son certificat client (fichier .ovpn avec clés intégrées)
> 2. Son nom d'utilisateur et mot de passe pfSense
> 
> C'est une **double authentification** très sécurisée.

### Certificat sans authentification utilisateur

Si vous avez choisi `Remote Access (SSL/TLS)` sans User Auth :

- Seul le certificat est requis pour se connecter
- Plus simple mais moins sécurisé
- La révocation du certificat est le seul moyen de bloquer l'accès

### Vérification des certificats

> [!example] Navigation `System` → `Cert. Manager` → Onglet `Certificates`

Vous devriez voir tous vos certificats :

- VPN-CA (CA)
- OpenVPN-Server-Cert (Server Certificate)
- user-john-laptop (User Certificate)
- etc.

> [!tip] Gestion des certificats
> 
> - Documentez quel certificat appartient à qui
> - Notez les dates d'expiration
> - Révoquez immédiatement les certificats des employés qui quittent l'entreprise

---

## 📦 Export de la configuration client

pfSense inclut un package "OpenVPN Client Export" qui facilite grandement la création des fichiers de configuration client.

### Installation du package

> [!example] Navigation `System` → `Package Manager` → Onglet `Available Packages`

Recherchez "**openvpn-client-export**" et cliquez sur `Install`.

### Utilisation de l'export client

> [!example] Navigation `VPN` → `OpenVPN` → Onglet `Client Export`

#### Configuration de l'export

**Remote Access Server :** Sélectionnez votre serveur OpenVPN configuré précédemment

**Host Name Resolution :**

```
Options:
- Interface IP Address: Utilise l'IP WAN actuelle
- Installation hostname: Spécifiez un FQDN (ex: vpn.monentreprise.com)
- Other: Spécifiez manuellement une IP ou un nom

Recommandation: Utilisez un FQDN avec Dynamic DNS si votre IP WAN change
```

> [!warning] IP dynamique Si votre IP WAN change régulièrement, configurez un Dynamic DNS (DynDNS, No-IP, etc.) et utilisez le nom de domaine au lieu de l'IP.

**Verify Server CN :**

```
Options:
- Automatic - Use verify-x509-name (default) (recommandé)
- Automatic - Use verify-x509-name where possible
- Do not verify server CN

Recommandation: Laissez sur "Automatic" pour vérifier l'identité du serveur
```

**Use Random Local Port :** ☑ (recommandé)

**Certificate Export Options :**

```
- Use Microsoft Certificate Storage instead of local files (Windows uniquement)
- Password Protect Certificate (recommandé pour la sécurité)
```

> [!tip] Protection par mot de passe Si vous cochez "Password Protect Certificate", les clés privées seront chiffrées. L'utilisateur devra entrer ce mot de passe lors de l'import du certificat.

**Use a Proxy :** (laisser vide sauf si vos clients doivent passer par un proxy)

### Export des configurations

Faites défiler jusqu'à la section listant tous les certificats clients.

Pour chaque utilisateur, plusieurs formats d'export sont disponibles :

|Format|Description|Usage|
|---|---|---|
|**Inline Configurations**|Fichier .ovpn unique avec tout intégré|Le plus simple, recommandé|
|**Archive**|Fichier ZIP avec configuration et certificats séparés|Alternative si .ovpn ne fonctionne pas|
|**Windows Installer**|.exe installateur pour Windows|Installation automatique sur Windows|
|**Viscosity Bundle**|Format pour Viscosity (macOS/Windows)|Client commercial populaire|

> [!example] Export recommandé Pour la plupart des cas, utilisez **"Most Clients - Inline"** :
> 
> - Cliquez sur le lien pour le certificat de l'utilisateur concerné
> - Un fichier `pfSense-UDP4-1194-user-john-laptop.ovpn` sera téléchargé
> - Ce fichier contient tout : CA, certificat client, clé privée, configuration

### Structure du fichier .ovpn

Le fichier exporté contient toute la configuration nécessaire :

```
client
dev tun
proto udp4
remote vpn.monentreprise.com 1194
nobind
persist-key
persist-tun
remote-cert-tls server
auth SHA256
cipher AES-256-GCM
verb 3

<ca>
-----BEGIN CERTIFICATE-----
[Certificat de la CA]
-----END CERTIFICATE-----
</ca>

<cert>
-----BEGIN CERTIFICATE-----
[Certificat client]
-----END CERTIFICATE-----
</cert>

<key>
-----BEGIN PRIVATE KEY-----
[Clé privée du client]
-----END PRIVATE KEY-----
</key>

<tls-auth>
-----BEGIN OpenVPN Static key V1-----
[Clé TLS statique]
-----END OpenVPN Static key V1-----
</tls-auth>
key-direction 1
```

> [!warning] Sécurité du fichier .ovpn Ce fichier contient la clé privée du client. Traitez-le comme un mot de passe :
> 
> - Transmettez-le de manière sécurisée (pas par email non chiffré)
> - Le client doit le stocker en sécurité
> - Supprimez-le des téléchargements après l'avoir importé

### Distribution aux clients

**Méthodes sécurisées de distribution :**

1. **En personne** : Copie sur clé USB
2. **Email chiffré** : Utilisez PGP ou S/MIME
3. **Plateforme de transfert sécurisé** : OnionShare, Firefox Send
4. **Portail web avec authentification** : Serveur interne sécurisé

**Instructions pour les clients :**

```markdown
Instructions de connexion VPN :

1. Installez un client OpenVPN :
   - Windows : OpenVPN GUI (https://openvpn.net/community-downloads/)
   - macOS : Tunnelblick (https://tunnelblick.net/)
   - Linux : sudo apt install openvpn
   - Android : OpenVPN for Android (Google Play)
   - iOS : OpenVPN Connect (App Store)

2. Importez le fichier .ovpn fourni

3. Connectez-vous avec vos identifiants pfSense
   - Username : votre.nom
   - Password : votre mot de passe

4. Vérifiez votre connexion en accédant à des ressources internes
```

### Révocation d'un certificat

Si un certificat doit être révoqué (appareil perdu, employé parti, etc.) :

> [!example] Navigation `System` → `Cert. Manager` → Onglet `Certificates`

1. Trouvez le certificat à révoquer
2. Cliquez sur l'icône ✏️ (Edit)
3. Faites défiler vers le bas
4. Cliquez sur `Revoke Certificate`
5. Confirmez

> [!warning] Après révocation
> 
> - Le certificat apparaîtra comme "Revoked" dans la liste
> - Les connexions existantes avec ce certificat seront interrompues
> - Le client ne pourra plus se reconnecter
> - Créez un nouveau certificat si l'utilisateur a besoin d'un nouvel accès

### Renouvellement des certificats

Les certificats ont une durée de vie limitée (ex: 10 ans). Avant expiration :

1. Créez un nouveau certificat pour l'utilisateur
2. Exportez la nouvelle configuration
3. Transmettez-la à l'utilisateur
4. Une fois la nouvelle configuration testée, révoquez l'ancien certificat

> [!tip] Monitoring des expirations
> 
> - Vérifiez régulièrement les dates d'expiration dans `Cert. Manager`
> - Créez un rappel 6 mois avant l'expiration des certificats importants
> - Documentez votre processus de renouvellement

---

## 🎯 Bonnes pratiques

### Sécurité

> [!warning] Points critiques
> 
> - **Jamais de clé statique** en production
> - **Toujours TLS + User Auth** pour Remote Access
> - **Mots de passe forts** pour les comptes utilisateurs
> - **Révocation immédiate** des certificats compromis
> - **Sauvegarde** de la CA et des certificats serveur

### Performance

> [!tip] Optimisations
> 
> - **UDP** est plus rapide que TCP pour VPN
> - **AES-GCM** offre de meilleures performances que AES-CBC
> - **Compression LZ4-v2** améliore les débits sur connexions lentes
> - Dimensionnez le nombre de connexions selon vos besoins réels

### Administration

> [!info] Organisation
> 
> - **Nommage cohérent** des certificats (user-prenom.nom-appareil)
> - **Documentation** : qui a quel certificat, sur quel appareil
> - **Groupes d'utilisateurs** pour faciliter la gestion
> - **Logs réguliers** : vérifiez qui se connecte et quand
> - **Tests périodiques** de connexion VPN

### Réseau

```
Recommandations topologiques :
- Réseau tunnel distinct du LAN (ex: 10.0.8.0/24 vs 192.168.1.0/24)
- Règles firewall spécifiques par service accessible
- Split tunneling si tout le trafic Internet ne doit pas passer par le VPN
- DNS interne configuré pour résolution des noms locaux
```

---

## ⚠️ Pièges courants

### Le client ne peut pas se connecter

**Vérifications à effectuer :**

1. **Règle pare-feu WAN** : existe-t-elle ? Est-elle en position Pass ?
2. **Port forwarding** : si pfSense est derrière un autre routeur
3. **IP/FQDN dans .ovpn** : correspond-il à l'adresse réelle ?
4. **Logs OpenVPN** : consultez `Status` → `System Logs` → `OpenVPN`

### Le client se connecte mais ne peut rien atteindre

**Vérifications :**

1. **Règles OpenVPN interface** : existent-elles ?
2. **Routes poussées** : le client reçoit-il les bonnes routes ?
3. **Vérification sur le client** :
    
    ```bash
    # Windowsroute print# Linux/macOSnetstat -rn
    ```
    
4. **Gateway** : le trafic VPN utilise-t-il la bonne passerelle ?

### Problème de DNS

**Symptômes :** Les clients VPN peuvent accéder par IP mais pas par nom

**Solutions :**

- Vérifiez que le DNS est bien poussé dans la config serveur OpenVPN
- Testez manuellement : `nslookup serveur.local 192.168.1.1`
- Sur Windows, vérifiez l'ordre des adaptateurs réseau

### Déconnexions fréquentes

**Causes possibles :**

- **Timeout keepalive** : ajoutez dans Advanced Configuration :
    
    ```
    keepalive 10 60
    ```
    
- **Changement IP client** : réseaux mobiles
- **Firewall intermédiaire** : bloque les paquets UDP

**Solution TCP alternative :**

- Créez un second serveur OpenVPN en TCP sur le port 443
- Les clients peuvent basculer si UDP ne fonctionne pas

### Certificat révoqué non effectif

**Problème :** Le client peut encore se connecter après révocation

**Solution :**

- Redémarrez le service OpenVPN : `Status` → `Services` → Restart OpenVPN
- Vérifiez que la CRL (Certificate Revocation List) est à jour

---

## 🔧 Astuces avancées

### Attribuer des IP fixes aux clients

> [!example] Navigation `VPN` → `OpenVPN` → Onglet `Client Specific Overrides` → `Add`

```
Server: Votre serveur OpenVPN
Common Name: john.doe (CN du certificat client)
IPv4 Tunnel Network: 10.0.8.10/32
Description: John Doe - IP fixe
```

Le client recevra toujours la même IP (10.0.8.10).

### Rediriger tout le trafic Internet via le VPN

Dans la configuration serveur, cochez :

```
Redirect IPv4 Gateway: ☑ Force all client-generated IPv4 traffic through the tunnel
```

**Conséquences :**

- Tout le trafic Internet du client passe par pfSense
- Utile pour appliquer les politiques de filtrage web
- Peut ralentir la connexion selon la bande passante

### Créer des règles granulaires

Exemple : Autoriser uniquement l'accès à un serveur de fichiers spécifique

```
Action: Pass
Interface: OpenVPN
Protocol: TCP
Source: OpenVPN subnets
Destination: Single host - 192.168.1.50
Destination Port: 445 (SMB)
Description: VPN access to file server only
```

### Logs détaillés pour débogage

Augmentez la verbosité temporairement :

```
Verbosity level: 5
```

Puis consultez les logs en temps réel :

```bash
# Via SSH sur pfSense
tail -f /var/log/openvpn.log
```

### Export automatisé

Pour des déploiements massifs, utilisez l'API pfSense ou des scripts pour :

- Créer plusieurs utilisateurs
- Générer leurs certificats
- Exporter automatiquement les configurations

### Monitoring des connexions actives

> [!example] Navigation `Status` → `OpenVPN`

Affiche :

- Clients connectés
- Adresses IP virtuelles attribuées
- Bytes envoyés/reçus
- Durée de connexion

**Déconnecter un client :** Cliquez sur l'icône 🗑️ pour forcer la déconnexion.

### Intégration avec RADIUS/LDAP

Pour une authentification centralisée :

> [!example] Navigation `System` → `User Manager` → Onglet `Authentication Servers`

Ajoutez votre serveur RADIUS ou LDAP, puis :

- Dans la config serveur OpenVPN, sélectionnez ce serveur d'authentification
- Les utilisateurs s'authentifient avec leurs credentials d'entreprise
- Pas besoin de créer des comptes locaux dans pfSense

---

**🎓 Ce cours couvre maintenant l'intégralité du service VPN OpenVPN dans pfSense, de la configuration initiale à l'export client et la gestion avancée.**