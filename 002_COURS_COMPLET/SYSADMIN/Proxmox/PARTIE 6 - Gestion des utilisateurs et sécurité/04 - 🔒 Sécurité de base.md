

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

## Introduction

La sécurité d'un hyperviseur Proxmox est cruciale car il héberge potentiellement des dizaines de machines virtuelles et conteneurs. Une compromission du système hôte expose l'intégralité de votre infrastructure virtuelle. Cette section couvre les quatre piliers essentiels de la sécurité de base : maintenir le système à jour, configurer un pare-feu efficace, sécuriser les communications avec SSL/TLS, et renforcer l'authentification avec la 2FA.

> [!warning] Sécurité en couches La sécurité ne se résume jamais à une seule mesure. Chaque élément de cette section constitue une couche de protection supplémentaire. L'absence d'une seule peut compromettre l'ensemble.

---

## Mise à jour du système

### 🎯 Pourquoi c'est important

Les mises à jour corrigent les vulnérabilités de sécurité découvertes dans le noyau Linux, les bibliothèques système, et Proxmox lui-même. Un système non mis à jour est une porte ouverte aux attaquants exploitant des failles connues et documentées.

### Configuration des dépôts

Proxmox propose deux types de dépôts :

|Type|Accès|Stabilité|Usage recommandé|
|---|---|---|---|
|**Enterprise**|Souscription payante|Production testée|Environnements critiques|
|**No-Subscription**|Gratuit|Stable mais non testé en entreprise|Labs, home-labs, développement|

#### Activer le dépôt No-Subscription

```bash
# Éditer le fichier sources.list pour Proxmox
nano /etc/apt/sources.list.d/pve-no-subscription.list

# Ajouter cette ligne
deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription
```

```bash
# Désactiver le dépôt enterprise (si vous n'avez pas de souscription)
nano /etc/apt/sources.list.d/pve-enterprise.list

# Commenter la ligne en ajoutant # au début
# deb https://enterprise.proxmox.com/debian/pve bookworm pve-enterprise
```

> [!info] Debian Bookworm Proxmox 8.x est basé sur Debian 12 "Bookworm". Utilisez toujours la version correspondant à votre installation Proxmox.

### Mise à jour manuelle

```bash
# Mettre à jour la liste des paquets disponibles
apt update

# Afficher les paquets qui peuvent être mis à jour
apt list --upgradable

# Effectuer la mise à jour complète du système
apt full-upgrade -y

# Nettoyer les paquets obsolètes
apt autoremove -y
apt autoclean
```

> [!tip] Différence entre upgrade et full-upgrade
> 
> - `apt upgrade` : met à jour les paquets sans supprimer ou installer de nouveaux
> - `apt full-upgrade` : peut installer/supprimer des paquets pour résoudre les dépendances (recommandé pour Proxmox)

### Mises à jour automatiques

Pour les environnements non-critiques, vous pouvez automatiser les mises à jour de sécurité :

```bash
# Installer le paquet unattended-upgrades
apt install unattended-upgrades apt-listchanges -y

# Configurer les mises à jour automatiques
dpkg-reconfigure -plow unattended-upgrades
```

Configuration personnalisée :

```bash
nano /etc/apt/apt.conf.d/50unattended-upgrades
```

```bash
# Configuration recommandée pour Proxmox
Unattended-Upgrade::Origins-Pattern {
    "origin=Debian,codename=${distro_codename},label=Debian-Security";
    "origin=Proxmox";
};

# Redémarrage automatique si nécessaire (à 3h du matin)
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "03:00";

# Email de notification (optionnel)
Unattended-Upgrade::Mail "admin@exemple.com";
Unattended-Upgrade::MailReport "on-change";
```

> [!warning] Redémarrages automatiques Sur un serveur de production, le redémarrage automatique peut être problématique. Privilégiez les notifications par email et planifiez les redémarrages manuellement.

### Vérification des mises à jour du noyau

```bash
# Afficher le noyau actuellement utilisé
uname -r

# Lister tous les noyaux installés
dpkg --list | grep pve-kernel

# Vérifier si un redémarrage est nécessaire
[ -f /var/run/reboot-required ] && echo "Redémarrage nécessaire" || echo "Pas de redémarrage requis"
```

### Bonnes pratiques

- **Testez d'abord** : dans un environnement de production, testez les mises à jour sur un serveur de test
- **Snapshot avant MAJ** : créez des snapshots de vos VM critiques avant une mise à jour majeure
- **Planifiez les redémarrages** : les mises à jour du noyau nécessitent un redémarrage, planifiez-les en dehors des heures de production
- **Surveillez les logs** : après une mise à jour, vérifiez `/var/log/apt/history.log` et les logs système

> [!tip] Commande rapide de vérification post-MAJ
> 
> ```bash
> pveversion -v  # Affiche les versions de tous les composants Proxmox
> ```

---

## Configuration du pare-feu Proxmox

### 🎯 Pourquoi c'est important

Le pare-feu Proxmox permet de contrôler finement le trafic réseau au niveau du datacenter, du nœud, et de chaque VM/CT individuellement. Il utilise `iptables` en arrière-plan mais offre une interface simplifiée.

### Architecture du pare-feu Proxmox

Proxmox utilise une architecture hiérarchique à trois niveaux :

```
Datacenter (règles globales)
    ↓
Node (règles par nœud Proxmox)
    ↓
VM/CT (règles par machine virtuelle/conteneur)
```

> [!info] Héritage des règles Les règles sont appliquées de haut en bas. Une règle au niveau Datacenter affecte tous les nœuds et toutes les VMs.

### Activation du pare-feu

#### Via l'interface Web

1. **Datacenter** → **Firewall** → **Options**
2. Cocher **Firewall: yes**
3. Cliquer sur **OK**

#### Via la ligne de commande

```bash
# Éditer la configuration du pare-feu du datacenter
nano /etc/pve/firewall/cluster.fw
```

```bash
[OPTIONS]
enable: 1
```

```bash
# Activer le pare-feu sur un nœud spécifique
nano /etc/pve/nodes/NODENAME/host.fw
```

```bash
[OPTIONS]
enable: 1
```

### Groupes de sécurité (Security Groups)

Les groupes permettent de créer des ensembles de règles réutilisables :

```bash
# Éditer les groupes au niveau Datacenter
nano /etc/pve/firewall/cluster.fw
```

```bash
[group SSH-Access]
IN ACCEPT -p tcp -dport 22 -source 192.168.1.0/24

[group Web-Server]
IN ACCEPT -p tcp -dport 80
IN ACCEPT -p tcp -dport 443

[group Management]
IN ACCEPT -p tcp -dport 8006 -source 192.168.1.0/24  # Interface Web Proxmox
```

### Règles de base recommandées

#### Niveau Datacenter

```bash
nano /etc/pve/firewall/cluster.fw
```

```bash
[OPTIONS]
enable: 1
policy_in: DROP      # Par défaut, bloquer tout le trafic entrant
policy_out: ACCEPT   # Autoriser le trafic sortant

[RULES]
# Autoriser loopback
IN ACCEPT -i lo

# Autoriser le ping (ICMP)
IN ACCEPT -p icmp

# Autoriser les connexions établies et apparentées
IN ACCEPT -m conntrack --ctstate ESTABLISHED,RELATED

# SSH depuis le réseau local uniquement
IN ACCEPT -p tcp -dport 22 -source 192.168.1.0/24

# Interface Web Proxmox depuis le réseau local
IN ACCEPT -p tcp -dport 8006 -source 192.168.1.0/24

# Cluster Proxmox (si multi-nœuds)
IN ACCEPT -p tcp -dport 5405:5412 -source 192.168.1.0/24  # Corosync
IN ACCEPT -p udp -dport 5404:5405 -source 192.168.1.0/24  # Corosync
```

> [!warning] Attention au blocage SSH Assurez-vous d'avoir une règle autorisant SSH avant d'activer le pare-feu, sinon vous risquez de vous bloquer l'accès !

#### Niveau VM/Conteneur

```bash
# Exemple pour la VM 100
nano /etc/pve/firewall/100.fw
```

```bash
[OPTIONS]
enable: 1
policy_in: DROP
policy_out: ACCEPT

[RULES]
# Serveur web
GROUP Web-Server

# SSH depuis le réseau de management
IN ACCEPT -p tcp -dport 22 -source 192.168.1.0/24

# Autoriser les connexions établies
IN ACCEPT -m conntrack --ctstate ESTABLISHED,RELATED
```

### Macros Proxmox

Proxmox fournit des macros prédéfinies pour les services courants :

```bash
[RULES]
# Utiliser une macro
IN SSH(ACCEPT) -source 192.168.1.0/24
IN HTTPS(ACCEPT)
IN Ping(ACCEPT)
```

Macros disponibles :

|Macro|Ports|Description|
|---|---|---|
|SSH|22/tcp|Secure Shell|
|HTTP|80/tcp|Web non-sécurisé|
|HTTPS|443/tcp|Web sécurisé|
|SMTP|25/tcp|Mail sortant|
|DNS|53/tcp+udp|Résolution DNS|
|MySQL|3306/tcp|Base de données MySQL|
|PostgreSQL|5432/tcp|Base de données PostgreSQL|
|Ping|ICMP echo|Ping ICMP|

### Logging et débogage

```bash
# Activer le logging des paquets bloqués
nano /etc/pve/firewall/cluster.fw
```

```bash
[OPTIONS]
enable: 1
log_level_in: info   # Valeurs possibles: nolog, emerg, alert, crit, err, warning, notice, info, debug
log_level_out: info
```

```bash
# Consulter les logs du pare-feu
tail -f /var/log/pve-firewall.log

# Voir les règles iptables générées
iptables -L -n -v

# Voir les compteurs de paquets
iptables -L -n -v --line-numbers
```

### Tester les règles

```bash
# Depuis un autre serveur, tester SSH
ssh root@IP_PROXMOX

# Tester un port avec netcat
nc -zv IP_PROXMOX 8006

# Scanner les ports ouverts (attention, à faire depuis votre réseau uniquement)
nmap -p 1-1000 IP_PROXMOX
```

> [!tip] Mode simulation Proxmox permet de tester les règles sans les activer. Créez vos règles avec `enable: 0` et vérifiez-les avec `pve-firewall simulate` avant activation.

### Bonnes pratiques

- **Principe du moindre privilège** : n'ouvrez que les ports strictement nécessaires
- **Restriction par IP source** : limitez l'accès SSH et à l'interface Web à votre réseau de management
- **Utilisez des groupes** : centralisez les règles communes dans des groupes réutilisables
- **Documentez vos règles** : ajoutez des commentaires pour expliquer chaque règle
- **Testez avant production** : activez le pare-feu sur une VM de test avant le déploiement global
- **Surveillez les logs** : vérifiez régulièrement `/var/log/pve-firewall.log` pour détecter des tentatives d'intrusion

> [!warning] Cluster multi-nœuds Si vous avez un cluster Proxmox, n'oubliez pas d'autoriser les ports de communication Corosync (5404-5412) entre tous les nœuds, sinon le cluster se fragmentera.

---

## Certificats SSL

### 🎯 Pourquoi c'est important

Par défaut, Proxmox génère un certificat auto-signé lors de l'installation. Ce certificat provoque des alertes dans les navigateurs et n'offre aucune garantie d'authenticité. Utiliser un certificat SSL valide sécurise les communications avec l'interface Web et évite les attaques man-in-the-middle.

### Types de certificats

|Type|Avantages|Inconvénients|Usage|
|---|---|---|---|
|**Auto-signé**|Gratuit, immédiat|Alerte navigateur, pas de validation|Installation initiale uniquement|
|**Let's Encrypt**|Gratuit, reconnu, automatisé|Nécessite domaine public|Production, accès Internet|
|**Certificat commercial**|Support, validation étendue|Payant|Entreprises, besoins spécifiques|
|**CA interne**|Contrôle total, gratuit|Configuration complexe|Environnements internes|

### Certificat auto-signé par défaut

```bash
# Localisation du certificat par défaut
ls -la /etc/pve/local/

# Afficher les informations du certificat actuel
openssl x509 -in /etc/pve/local/pveproxy-ssl.pem -noout -text

# Vérifier la date d'expiration
openssl x509 -in /etc/pve/local/pveproxy-ssl.pem -noout -enddate
```

### Let's Encrypt avec DNS Challenge

#### Configuration via l'interface Web

1. **Datacenter** → **Node** → **System** → **Certificates**
2. Cliquer sur **Add** → **ACME Account**
3. Renseigner votre email
4. Accepter les conditions (TOS)
5. Cliquer sur **Register**

Ensuite, ajouter un domaine :

1. **ACME** → **Add**
2. Choisir **DNS** comme Challenge Type
3. Sélectionner votre provider DNS (Cloudflare, OVH, etc.)
4. Renseigner les credentials API

#### Configuration via CLI

```bash
# Enregistrer un compte ACME
pvenode acme account register default admin@exemple.com

# Configurer un plugin DNS (exemple avec Cloudflare)
pvenode acme plugin add dns cloudflare \
  --api CF_Token=VOTRE_TOKEN \
  --data CF_Account_ID=VOTRE_ACCOUNT_ID

# Ajouter un domaine avec validation DNS
pvenode config set --acme domains=proxmox.exemple.com,plugin=cloudflare

# Obtenir le certificat
pvenode acme cert order
```

> [!info] Providers DNS supportés Proxmox supporte plus de 100 providers DNS via le plugin `acme.sh` : Cloudflare, OVH, AWS Route53, Google Cloud DNS, etc.

### Let's Encrypt avec HTTP Challenge

Pour utiliser le challenge HTTP, votre serveur Proxmox doit être accessible depuis Internet sur le port 80 :

```bash
# Configurer avec HTTP challenge
pvenode config set --acme domains=proxmox.exemple.com

# Obtenir le certificat
pvenode acme cert order

# Le certificat sera automatiquement renouvelé avant expiration
```

> [!warning] Ouverture du port 80 Le HTTP Challenge nécessite que le port 80 soit accessible depuis Internet. Configurez votre NAT/pare-feu en conséquence, ou privilégiez le DNS Challenge.

### Certificat commercial ou CA interne

#### Générer une CSR (Certificate Signing Request)

```bash
# Générer une clé privée et une CSR
openssl req -new -newkey rsa:4096 -nodes \
  -keyout /etc/pve/local/proxmox.key \
  -out /etc/pve/local/proxmox.csr \
  -subj "/C=FR/ST=Nouvelle-Aquitaine/L=Lormont/O=MonEntreprise/CN=proxmox.exemple.com"

# Afficher la CSR (à envoyer à votre CA)
cat /etc/pve/local/proxmox.csr
```

#### Installer le certificat reçu

```bash
# Une fois que vous avez reçu le certificat de votre CA
# Copier le certificat
nano /etc/pve/local/proxmox.pem
# Coller le contenu du certificat

# Copier la chaîne de certification complète
nano /etc/pve/local/proxmox-chain.pem
# Coller les certificats intermédiaires + root CA

# Créer un fichier combiné pour Proxmox
cat /etc/pve/local/proxmox.pem /etc/pve/local/proxmox-chain.pem > /etc/pve/local/pveproxy-ssl.pem

# Copier la clé privée
cp /etc/pve/local/proxmox.key /etc/pve/local/pveproxy-ssl.key

# Définir les permissions correctes
chmod 600 /etc/pve/local/pveproxy-ssl.key
chmod 644 /etc/pve/local/pveproxy-ssl.pem

# Redémarrer le service proxy
systemctl restart pveproxy
```

### Certificat avec SAN (Subject Alternative Names)

Pour un certificat couvrant plusieurs domaines ou nœuds :

```bash
# Créer un fichier de configuration OpenSSL
nano /tmp/san.cnf
```

```bash
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req

[req_distinguished_name]

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = proxmox.exemple.com
DNS.2 = pve1.exemple.com
DNS.3 = pve2.exemple.com
IP.1 = 192.168.1.100
IP.2 = 192.168.1.101
```

```bash
# Générer la CSR avec SAN
openssl req -new -newkey rsa:4096 -nodes \
  -keyout /etc/pve/local/proxmox-san.key \
  -out /etc/pve/local/proxmox-san.csr \
  -config /tmp/san.cnf \
  -subj "/C=FR/ST=Nouvelle-Aquitaine/L=Lormont/O=MonEntreprise/CN=proxmox.exemple.com"
```

### Vérification et renouvellement

```bash
# Vérifier le certificat actuellement utilisé
openssl s_client -connect localhost:8006 -showcerts

# Vérifier la date d'expiration
openssl x509 -in /etc/pve/local/pveproxy-ssl.pem -noout -dates

# Forcer le renouvellement Let's Encrypt
pvenode acme cert renew

# Vérifier le statut du renouvellement automatique
systemctl status pve-daily.timer
systemctl list-timers | grep pve
```

> [!tip] Renouvellement automatique Let's Encrypt configure automatiquement un timer systemd (`pve-daily.timer`) qui renouvelle les certificats 30 jours avant expiration.

### Certificat pour l'API et les VNC

Le même certificat est utilisé pour :

- L'interface Web (port 8006)
- L'API Proxmox
- Les consoles VNC/SPICE des VMs

```bash
# Tester l'accès API avec le certificat
curl -k https://proxmox.exemple.com:8006/api2/json/version

# Sans -k pour vérifier la validité du certificat
curl https://proxmox.exemple.com:8006/api2/json/version
```

### Bonnes pratiques

- **Utilisez Let's Encrypt** : c'est gratuit, automatisé et reconnu par tous les navigateurs
- **DNS Challenge préféré** : évite d'exposer le port 80 et fonctionne derrière NAT
- **Certificats wildcard** : pratiques pour un cluster (`*.exemple.com`)
- **Surveillez les expirations** : configurez des alertes 30 jours avant expiration
- **Sauvegardez les clés** : incluez `/etc/pve/local/*.key` dans vos backups (de manière sécurisée)
- **Testez après installation** : vérifiez que le certificat est valide dans plusieurs navigateurs

> [!warning] Cluster et certificats Dans un cluster Proxmox, chaque nœud a son propre certificat. Vous devez configurer Let's Encrypt sur chaque nœud individuellement, ou utiliser un certificat wildcard.

---

## Authentification à deux facteurs (2FA)

### 🎯 Pourquoi c'est important

L'authentification à deux facteurs ajoute une couche de sécurité critique en exigeant, en plus du mot de passe, une preuve de possession d'un appareil (smartphone, clé de sécurité). Même si un mot de passe est compromis, l'attaquant ne pourra pas accéder au système sans le second facteur.

### Types de 2FA supportés par Proxmox

|Type|Méthode|Avantages|Inconvénients|
|---|---|---|---|
|**TOTP**|Application (Google Authenticator, Authy)|Gratuit, facile|Dépendant du téléphone|
|**WebAuthn**|Clé de sécurité physique (YubiKey)|Très sécurisé, résistant au phishing|Coût matériel|
|**U2F**|Ancienne norme de clé physique|Compatible anciennes clés|Obsolète, préférer WebAuthn|

### Configuration TOTP (Time-based One-Time Password)

#### Pour un utilisateur local (PAM)

Via l'interface Web :

1. Se connecter en tant qu'utilisateur
2. Cliquer sur son nom en haut à droite → **TFA**
3. Cliquer sur **Add** → **TOTP**
4. Scanner le QR code avec une application d'authentification :
    - Google Authenticator (iOS/Android)
    - Microsoft Authenticator (iOS/Android)
    - Authy (iOS/Android/Desktop)
    - FreeOTP (iOS/Android)
5. Entrer le code généré pour valider
6. **Sauvegarder les codes de récupération** affichés

> [!warning] Codes de récupération Les codes de récupération sont votre seule solution si vous perdez accès à votre application 2FA. Sauvegardez-les dans un endroit sûr (gestionnaire de mots de passe, coffre physique).

#### Via la ligne de commande

```bash
# Générer TOTP pour l'utilisateur root
pveum user tfa add root@pam --type totp

# La commande génère un QR code ASCII à scanner
# Vous pouvez aussi récupérer l'URI otpauth:// pour l'importer manuellement
```

### Configuration WebAuthn (Clé de sécurité)

WebAuthn est la norme moderne remplaçant U2F, supportant les clés de sécurité comme YubiKey, Titan Security Key, ou Solokeys.

#### Enregistrer une clé WebAuthn

Via l'interface Web :

1. Se connecter en tant qu'utilisateur
2. Cliquer sur son nom → **TFA**
3. Cliquer sur **Add** → **WebAuthn**
4. Donner un nom descriptif à la clé (ex: "YubiKey Bureau")
5. Cliquer sur **Register**
6. Insérer et toucher votre clé de sécurité physique
7. La clé est maintenant enregistrée

#### Via la ligne de commande

```bash
# Ajouter WebAuthn pour un utilisateur
pveum user tfa add root@pam --type webauthn --challenge "nom-de-la-cle"

# Cette commande retourne un challenge que vous devez résoudre avec votre clé
```

> [!tip] Enregistrer plusieurs clés Enregistrez au moins 2 clés WebAuthn (une principale, une de secours) pour éviter de vous retrouver bloqué si vous perdez votre clé principale.

### Gérer les facteurs d'authentification

#### Lister les TFA configurés

```bash
# Lister les TFA d'un utilisateur
pveum user tfa list root@pam

# Afficher les détails d'un TFA spécifique
pveum user tfa show root@pam TFA_ID
```

#### Supprimer un TFA

Via l'interface Web :

1. Se connecter → Nom d'utilisateur → **TFA**
2. Sélectionner le TFA à supprimer
3. Cliquer sur **Remove**

Via CLI :

```bash
# Supprimer un TFA spécifique
pveum user tfa delete root@pam TFA_ID

# ATTENTION : ne supprimez pas votre dernier TFA si vous n'avez pas de secours !
```

> [!warning] Risque de verrouillage Si vous supprimez tous vos TFA et que la 2FA est obligatoire, vous ne pourrez plus vous connecter. Gardez toujours un moyen de récupération (codes de récupération ou accès console physique).

### Forcer la 2FA pour certains utilisateurs ou groupes

#### Au niveau utilisateur

```bash
# Forcer la 2FA pour un utilisateur spécifique
pveum user modify admin@pam --tfa-type oath

# Rendre la 2FA optionnelle
pveum user modify admin@pam --tfa-type any
```

#### Au niveau du realm (domaine d'authentification)

Vous pouvez configurer la 2FA au niveau d'un realm entier (PAM, LDAP, AD) :

1. **Datacenter** → **Permissions** → **Realms**
2. Sélectionner le realm (ex: `pam`)
3. **Edit** → Onglet **TFA**
4. Configurer les options :
    - **TFA**: activé/désactivé
    - **Default**: type par défaut (TOTP, WebAuthn)
    - **Required**: rend la 2FA obligatoire

```bash
# Via CLI - forcer TOTP pour tous les utilisateurs PAM
pveum realm modify pam --tfa-type oath
```

### Codes de récupération (Recovery Keys)

Les codes de récupération permettent de se connecter si vous perdez accès à votre 2FA.

#### Générer des codes de récupération

```bash
# Générer des codes de récupération pour un utilisateur
pveum user tfa add root@pam --type recovery

# La commande affiche une liste de codes à usage unique
# Exemple :
# af8e-b2c4-d5e6-f7a8
# c9d0-e1f2-a3b4-c5d6
# (etc.)
```

> [!info] Usage unique Chaque code de récupération ne peut être utilisé qu'une seule fois. Une fois tous les codes épuisés, générez-en de nouveaux.

#### Utiliser un code de récupération

Lors de la connexion :

1. Entrer le nom d'utilisateur et mot de passe
2. Quand le prompt 2FA apparaît, entrer un code de récupération au lieu du code TOTP

### Exemples de configuration par profil

#### Administrateur (sécurité maximale)

```bash
# TOTP + WebAuthn + Codes de récupération
pveum user tfa add root@pam --type totp
pveum user tfa add root@pam --type webauthn --challenge "yubikey-bureau"
pveum user tfa add root@pam --type webauthn --challenge "yubikey-secours"
pveum user tfa add root@pam --type recovery
```

#### Utilisateur standard

```bash
# TOTP uniquement avec codes de récupération
pveum user tfa add user@pam --type totp
pveum user tfa add user@pam --type recovery
```

### Connexion avec 2FA activée

1. Naviguer vers `https://proxmox.exemple.com:8006`
2. Entrer le nom d'utilisateur et mot de passe
3. Une seconde invite apparaît demandant le code 2FA
4. Entrer le code à 6 chiffres de votre application TOTP
    - Ou insérer et toucher votre clé WebAuthn
    - Ou utiliser un code de récupération

> [!tip] Cocher "Remember for 30 days" L'option "Save TFA login" permet de ne pas redemander le 2FA sur ce navigateur pendant 30 jours. À éviter sur les machines partagées.

### Bonnes pratiques

- **TOTP + WebAuthn** : utilisez les deux pour une sécurité optimale
- **Codes de récupération** : générez-les immédiatement après l'activation de la 2FA et stockez-les en lieu sûr
- **Plusieurs clés WebAuthn** : enregistrez au moins 2 clés physiques (une principale + une de backup)
- **Applications 2FA avec backup cloud** : Authy synchronise entre appareils, contrairement à Google Authenticator
- **Testez avant de forcer** : testez la 2FA sur votre compte avant de l'imposer à tous les utilisateurs
- **Documentation** : documentez les procédures de récupération pour votre équipe
- **Audit régulier** : vérifiez périodiquement les TFA configurés et supprimez ceux qui ne sont plus utilisés

### Dépannage 2FA

#### Problème : code TOTP refusé

```bash
# Vérifier l'heure système (crucial pour TOTP)
timedatectl status

# Synchroniser avec un serveur NTP si nécessaire
timedatectl set-ntp true

# Vérifier la synchronisation
ntpq -p
```

> [!info] Décalage horaire TOTP est basé sur l'heure. Un décalage de plus de 30 secondes entre le serveur et l'appareil génère des codes invalides. Utilisez NTP pour synchroniser l'heure.

#### Problème : clé WebAuthn non reconnue

```bash
# Vérifier que le paquet libpam-webauthn est installé
dpkg -l | grep webauthn

# Vérifier les logs
journalctl -u pveproxy -f

# Tester la clé dans les logs système
tail -f /var/log/syslog | grep webauthn
```

#### Problème : verrouillage complet (perte de tous les TFA)

Si vous n'avez plus accès à aucun TFA et n'avez pas de codes de récupération :

```bash
# Accès console physique ou IPMI requis
# Se connecter en root localement

# Désactiver temporairement la 2FA pour l'utilisateur
pveum user modify root@pam --delete tfa-type

# Ou supprimer tous les TFA de l'utilisateur
pveum user tfa delete root@pam --force

# Se reconnecter à l'interface Web et reconfigurer la 2FA
```

> [!warning] Accès physique requis Cette procédure de récupération nécessite un accès physique au serveur ou via IPMI. C'est pourquoi les codes de récupération sont si importants !

### Intégration avec LDAP/Active Directory

Pour un environnement d'entreprise avec authentification centralisée :

```bash
# Configurer un realm LDAP avec 2FA
pveum realm add monldap --type ldap \
  --base-dn "dc=exemple,dc=com" \
  --bind-dn "cn=proxmox,ou=services,dc=exemple,dc=com" \
  --server "ldap.exemple.com" \
  --port 636 \
  --secure 1 \
  --tfa-type oath

# Les utilisateurs LDAP devront configurer leur TOTP individuellement
```

### Monitoring et audit de la 2FA

```bash
# Lister tous les utilisateurs avec 2FA activée
pveum user list | grep -A 5 "tfa"

# Vérifier les tentatives de connexion échouées
grep "authentication failure" /var/log/auth.log

# Suivre les connexions avec 2FA
tail -f /var/log/auth.log | grep "pam_tfa"

# Statistiques sur l'utilisation de la 2FA
journalctl -u pveproxy | grep -i "tfa"
```

### Script de vérification de la sécurité 2FA

```bash
#!/bin/bash
# Script : check-2fa-status.sh
# Vérifier le statut 2FA de tous les utilisateurs

echo "=== Audit 2FA Proxmox ==="
echo "Date: $(date)"
echo ""

# Lister tous les utilisateurs
pveum user list | grep "^userid" | awk '{print $2}' | while read user; do
    echo "Utilisateur: $user"
    
    # Vérifier si 2FA est configuré
    tfa_count=$(pveum user tfa list "$user" 2>/dev/null | grep -c "^id:")
    
    if [ "$tfa_count" -gt 0 ]; then
        echo "  ✓ 2FA activé ($tfa_count facteur(s))"
        pveum user tfa list "$user" | grep "type:" | sed 's/^/    /'
    else
        echo "  ✗ 2FA non configuré - RISQUE DE SÉCURITÉ"
    fi
    echo ""
done

echo "=== Fin de l'audit ==="
```

```bash
# Rendre le script exécutable et l'exécuter
chmod +x check-2fa-status.sh
./check-2fa-status.sh
```

### Politique de sécurité 2FA recommandée

#### Pour les environnements de production

```
┌─────────────────────────────────────────────────┐
│ Rôle              │ 2FA Requis │ Type recommandé │
├───────────────────┼────────────┼─────────────────┤
│ Administrateurs   │ Obligatoire│ TOTP + WebAuthn │
│ Opérateurs        │ Obligatoire│ TOTP            │
│ Utilisateurs read │ Recommandé │ TOTP            │
│ Comptes service   │ Non        │ Clé API         │
└─────────────────────────────────────────────────┘
```

> [!tip] Comptes de service Pour les scripts et automatisations, utilisez des API tokens au lieu de comptes utilisateurs avec 2FA. Cela évite les problèmes d'authentification automatisée.

### Créer un API Token (alternative à 2FA pour scripts)

```bash
# Créer un token API pour automatisation
pveum user token add automation@pam monitoring \
  --privsep 0 \
  --expire 0

# La commande retourne le token (à sauvegarder précieusement)
# Format: PVEAPIToken=automation@pam!monitoring=xxxxx-xxxx-xxxx-xxxx

# Utiliser le token dans un script
curl -k -H "Authorization: PVEAPIToken=automation@pam!monitoring=xxxxx-xxxx-xxxx-xxxx" \
  https://proxmox.exemple.com:8006/api2/json/nodes
```

> [!info] Tokens vs mots de passe Les API tokens sont préférables aux mots de passe pour les scripts car ils peuvent être révoqués individuellement sans changer le mot de passe de l'utilisateur.

---

## 📊 Récapitulatif et checklist de sécurité

### Checklist de sécurisation complète

```
□ Mises à jour système
  □ Dépôts configurés (no-subscription ou enterprise)
  □ Première mise à jour complète effectuée
  □ Mises à jour automatiques configurées (si approprié)
  □ Procédure de mise à jour documentée
  
□ Pare-feu
  □ Pare-feu activé au niveau Datacenter
  □ Pare-feu activé au niveau Node
  □ Règles SSH limitées au réseau de management
  □ Interface Web (8006) limitée au réseau de management
  □ Politique par défaut INPUT: DROP configurée
  □ Ports cluster autorisés (si multi-nœuds)
  □ Groupes de sécurité créés pour services communs
  □ Logging activé et vérifié
  
□ Certificats SSL
  □ Certificat auto-signé remplacé
  □ Let's Encrypt configuré OU certificat commercial installé
  □ Renouvellement automatique vérifié
  □ Certificat valide dans tous les navigateurs
  □ Certificats pour tous les nœuds (si cluster)
  
□ Authentification 2FA
  □ 2FA activée pour compte root
  □ 2FA activée pour tous les administrateurs
  □ Codes de récupération générés et sauvegardés
  □ Au moins 2 méthodes 2FA configurées (TOTP + WebAuthn)
  □ Politique 2FA documentée
  □ Procédure de récupération testée
  □ API tokens créés pour les scripts/automatisations
```

### Commandes de vérification rapide

```bash
#!/bin/bash
# Script de vérification rapide de la sécurité

echo "=== Vérification Sécurité Proxmox ==="
echo ""

# Version Proxmox
echo "Version Proxmox:"
pveversion -v | head -1
echo ""

# Dernière mise à jour
echo "Dernière mise à jour système:"
stat /var/log/apt/history.log | grep Modify
echo ""

# Pare-feu actif ?
echo "Statut pare-feu:"
if grep -q "enable: 1" /etc/pve/firewall/cluster.fw 2>/dev/null; then
    echo "✓ Pare-feu Datacenter: ACTIF"
else
    echo "✗ Pare-feu Datacenter: INACTIF"
fi
echo ""

# Certificat SSL
echo "Certificat SSL:"
openssl x509 -in /etc/pve/local/pveproxy-ssl.pem -noout -subject -dates 2>/dev/null
echo ""

# 2FA root
echo "2FA root@pam:"
tfa_count=$(pveum user tfa list root@pam 2>/dev/null | grep -c "^id:")
if [ "$tfa_count" -gt 0 ]; then
    echo "✓ 2FA activée ($tfa_count facteur(s))"
else
    echo "✗ 2FA non configurée"
fi
echo ""

echo "=== Fin de la vérification ==="
```

### Niveaux de sécurité recommandés

#### Niveau 1 : Sécurité de base (minimum vital)

- ✅ Mises à jour régulières
- ✅ Pare-feu activé avec règles SSH restrictives
- ✅ Certificat SSL valide (Let's Encrypt)
- ✅ Mots de passe forts

**Pour : Home-labs, environnements de test**

#### Niveau 2 : Sécurité renforcée (production standard)

- ✅ Tout du niveau 1
- ✅ 2FA obligatoire pour administrateurs (TOTP)
- ✅ Pare-feu avec groupes de sécurité
- ✅ Logging et monitoring activés
- ✅ Procédure de backup des configurations

**Pour : PME, production non-critique**

#### Niveau 3 : Sécurité maximale (haute disponibilité)

- ✅ Tout du niveau 2
- ✅ 2FA multi-méthodes (TOTP + WebAuthn)
- ✅ Certificats commerciaux avec validation étendue
- ✅ Authentification centralisée (LDAP/AD)
- ✅ Audit et compliance réguliers
- ✅ Segmentation réseau (VLANs)
- ✅ IDS/IPS sur le réseau

**Pour : Entreprises, données sensibles, conformité réglementaire**

### Ressources pour aller plus loin

> [!tip] Documentation officielle
> 
> - Proxmox VE Administration Guide - Security : https://pve.proxmox.com/pve-docs/chapter-pveum.html
> - Proxmox Firewall : https://pve.proxmox.com/wiki/Firewall
> - Let's Encrypt avec Proxmox : https://pve.proxmox.com/wiki/Certificate_Management

### Prochaines étapes dans votre apprentissage

Une fois cette section maîtrisée, vous devriez être capable de :

- ✅ Maintenir un système Proxmox à jour de manière sécurisée
- ✅ Configurer un pare-feu efficace multi-niveaux
- ✅ Déployer et gérer des certificats SSL/TLS
- ✅ Implémenter et administrer l'authentification 2FA

Les sujets de sécurité complémentaires qui relèvent d'autres parties du cours :

- Gestion avancée des utilisateurs et permissions (Partie : Gestion des utilisateurs)
- Backup et restauration sécurisée (Partie : Sauvegarde)
- Haute disponibilité et résilience (Partie : Clustering)
- Chiffrement des données (Partie : Stockage avancé)

---

**📚 Fin de la section Sécurité de base**