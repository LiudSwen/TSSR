

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

## 🎯 Introduction

Le système de résolution de noms DNS (Domain Name System) est essentiel pour traduire les noms de domaine en adresses IP. Sur Debian, la configuration DNS se fait principalement via le fichier `/etc/resolv.conf`, qui définit les serveurs DNS à utiliser pour la résolution de noms.

> [!info] Pourquoi configurer le DNS ?
> 
> - Permet la résolution des noms de domaine en adresses IP
> - Essentiel pour accéder aux sites web et services réseau
> - Peut améliorer la vitesse de navigation selon les serveurs choisis
> - Crucial pour le bon fonctionnement des services système

---

## 📄 Le fichier /etc/resolv.conf

Le fichier `/etc/resolv.conf` est le fichier de configuration central pour la résolution DNS sur les systèmes Linux. Il indique au système quels serveurs DNS interroger et dans quel ordre.

### Structure et syntaxe

Le fichier `/etc/resolv.conf` utilise une syntaxe simple avec une directive par ligne :

```bash
# Fichier /etc/resolv.conf
# Commentaires précédés par #

nameserver 8.8.8.8        # Serveur DNS primaire
nameserver 8.8.4.4        # Serveur DNS secondaire
domain exemple.local      # Domaine local par défaut
search exemple.local lab.local  # Liste de domaines de recherche
options timeout:2 attempts:3    # Options de résolution
```

> [!warning] Ordre des serveurs Les serveurs DNS sont interrogés dans l'ordre de leur apparition. Le système utilisera le premier serveur qui répond, pas nécessairement le plus rapide.

### Directives principales

#### 🔹 nameserver

Définit l'adresse IP d'un serveur DNS à utiliser pour la résolution de noms.

```bash
nameserver 8.8.8.8
nameserver 1.1.1.1
nameserver 192.168.1.1
```

**Caractéristiques :**

- Maximum 3 serveurs DNS peuvent être définis (limitation historique)
- Un serveur par ligne
- IPv4 ou IPv6 acceptés

> [!example] Serveurs DNS populaires
> 
> - **Google DNS** : `8.8.8.8` et `8.8.4.4`
> - **Cloudflare** : `1.1.1.1` et `1.0.0.1`
> - **OpenDNS** : `208.67.222.222` et `208.67.220.220`
> - **Quad9** : `9.9.9.9` et `149.112.112.112`

#### 🔹 domain

Définit le nom de domaine local par défaut. Si un nom d'hôte sans domaine est recherché, ce domaine sera automatiquement ajouté.

```bash
domain monentreprise.local
```

**Utilisation :**

- Si vous tapez `ping serveur`, le système cherchera `serveur.monentreprise.local`
- Utile dans les environnements d'entreprise avec un domaine interne

#### 🔹 search

Liste des domaines à utiliser pour la recherche de noms courts. Alternative plus flexible à `domain`.

```bash
search monentreprise.local lab.monentreprise.local dev.monentreprise.local
```

**Fonctionnement :**

- Si vous tapez `ping serveur`, le système essaiera successivement :
    - `serveur.monentreprise.local`
    - `serveur.lab.monentreprise.local`
    - `serveur.dev.monentreprise.local`
- Maximum 6 domaines et 256 caractères au total

> [!warning] Conflit domain vs search Les directives `domain` et `search` sont mutuellement exclusives. Si les deux sont présentes, seule la dernière sera prise en compte.

#### 🔹 options

Permet de définir diverses options de résolution DNS.

```bash
options timeout:2          # Temps d'attente par requête (défaut: 5 secondes)
options attempts:3         # Nombre de tentatives par serveur (défaut: 2)
options rotate             # Rotation entre les serveurs DNS
options ndots:2            # Nombre de points avant de considérer comme FQDN
options edns0              # Active les extensions DNS
options single-request     # Une requête à la fois (évite certains bugs)
```

**Options courantes expliquées :**

|Option|Description|Valeur par défaut|
|---|---|---|
|`timeout:N`|Délai d'attente en secondes avant de passer au serveur suivant|5|
|`attempts:N`|Nombre de tentatives par serveur DNS|2|
|`rotate`|Répartit la charge entre les serveurs DNS en alternant|Désactivé|
|`ndots:N`|Nombre de points dans un nom avant de le considérer comme complet|1|
|`single-request`|Évite d'envoyer les requêtes A et AAAA simultanément|Désactivé|

### Exemples de configuration

#### Configuration simple (réseau domestique)

```bash
# Configuration DNS basique pour une connexion Internet
nameserver 8.8.8.8
nameserver 8.8.4.4
```

#### Configuration entreprise

```bash
# Configuration pour un environnement d'entreprise
nameserver 192.168.1.10      # Serveur DNS interne primaire
nameserver 192.168.1.11      # Serveur DNS interne secondaire
nameserver 8.8.8.8           # DNS externe en backup
search entreprise.local
options timeout:2 attempts:3
```

#### Configuration optimisée pour la performance

```bash
# Configuration avec rotation et délais réduits
nameserver 1.1.1.1
nameserver 8.8.8.8
nameserver 9.9.9.9
options timeout:1 attempts:2 rotate
```

#### Configuration avec IPv6

```bash
# Configuration mixte IPv4/IPv6
nameserver 2001:4860:4860::8888  # Google DNS IPv6
nameserver 8.8.8.8               # Google DNS IPv4
nameserver 2606:4700:4700::1111  # Cloudflare DNS IPv6
nameserver 1.1.1.1               # Cloudflare DNS IPv4
```

> [!tip] Vérifier la configuration Après modification, testez avec :
> 
> ```bash
> # Vérifier la résolution DNS
> nslookup google.com
> dig google.com
> host google.com
> 
> # Vérifier le contenu du fichier
> cat /etc/resolv.conf
> ```

---

## 🔄 Différences avec Ubuntu

Bien que Debian et Ubuntu partagent la même base, leur gestion du DNS diffère significativement, ce qui peut causer de la confusion lors du passage d'une distribution à l'autre.

### Gestion du DNS

#### 🔸 Sur Debian "pure"

Sur Debian classique, `/etc/resolv.conf` est un **fichier statique** :

```bash
# Configuration directe dans /etc/resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4
```

**Caractéristiques :**

- Modifications directes dans `/etc/resolv.conf`
- Configuration manuelle ou via les scripts du gestionnaire réseau
- Pas de service intermédiaire par défaut
- Configuration persistante après redémarrage si correctement définie

**Vérification :**

```bash
# Vérifier si c'est un fichier réel ou un lien symbolique
ls -la /etc/resolv.conf
# Résultat attendu : -rw-r--r-- (fichier normal)
```

#### 🔸 Sur Ubuntu (versions récentes)

Sur Ubuntu moderne, `/etc/resolv.conf` est un **lien symbolique** géré par `systemd-resolved` :

```bash
# /etc/resolv.conf pointe vers un fichier géré automatiquement
lrwxrwxrwx 1 root root 39 /etc/resolv.conf -> ../run/systemd/resolve/stub-resolv.conf
```

**Caractéristiques :**

- `/etc/resolv.conf` est régénéré automatiquement
- Utilise un résolveur DNS local (127.0.0.53)
- Configuration via Netplan ou NetworkManager
- Modifications directes écrasées au redémarrage

**Contenu typique :**

```bash
# This is /run/systemd/resolve/stub-resolv.conf managed by systemd-resolved
nameserver 127.0.0.53
options edns0 trust-ad
search .
```

> [!warning] Piège Ubuntu Modifier directement `/etc/resolv.conf` sur Ubuntu ne sert à rien ! Le fichier sera automatiquement recréé. Il faut configurer via Netplan ou désactiver systemd-resolved.

### Tableau comparatif

|Aspect|Debian|Ubuntu|
|---|---|---|
|**Type de fichier**|Fichier statique|Lien symbolique|
|**Service DNS**|Aucun par défaut|systemd-resolved|
|**Configuration**|Directe dans resolv.conf|Via Netplan/NetworkManager|
|**Modification directe**|✅ Persistante|❌ Écrasée|
|**DNS local**|Non (sauf installation manuelle)|Oui (127.0.0.53)|
|**Cache DNS**|Non par défaut|Oui (systemd-resolved)|
|**Philosophie**|Contrôle manuel|Automatisation|

### Implications pratiques

#### 🔹 Configuration sur Debian

Pour configurer le DNS de manière persistante sur Debian, vous devez utiliser les fichiers de configuration réseau :

**Avec configuration réseau traditionnelle (/etc/network/interfaces) :**

```bash
# Éditer /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.168.1.100
    netmask 255.255.255.0
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8 8.8.4.4  # Configuration DNS ici
    dns-search exemple.local
```

**Puis :**

```bash
# Appliquer la configuration
sudo systemctl restart networking
# ou
sudo ifdown eth0 && sudo ifup eth0
```

**Modification manuelle directe :**

```bash
# Éditer directement (fonctionne mais peut être écrasé par certains services)
sudo nano /etc/resolv.conf

# Rendre immuable pour empêcher les modifications (optionnel)
sudo chattr +i /etc/resolv.conf
# Pour retirer la protection :
# sudo chattr -i /etc/resolv.conf
```

#### 🔹 Configuration sur Ubuntu

Sur Ubuntu, il faut passer par Netplan (à partir d'Ubuntu 17.10) :

```yaml
# Éditer /etc/netplan/01-netcfg.yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
        search:
          - exemple.local
```

**Appliquer :**

```bash
sudo netplan apply
```

**Alternative : Désactiver systemd-resolved (pour utiliser le mode Debian) :**

```bash
# Désactiver systemd-resolved
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved

# Supprimer le lien symbolique
sudo rm /etc/resolv.conf

# Créer un fichier statique
sudo nano /etc/resolv.conf
# Ajouter les serveurs DNS souhaités

# Rendre immuable
sudo chattr +i /etc/resolv.conf
```

> [!tip] Identifier rapidement votre système
> 
> ```bash
> # Vérifier si systemd-resolved est actif
> systemctl status systemd-resolved
> 
> # Vérifier le type de fichier resolv.conf
> file /etc/resolv.conf
> 
> # Voir la vraie cible du lien
> readlink -f /etc/resolv.conf
> ```

---

## ✅ Bonnes pratiques

### 🔹 Ordre des serveurs DNS

```bash
# Bon : DNS interne d'abord, puis externes
nameserver 192.168.1.10    # DNS interne (Active Directory, services internes)
nameserver 192.168.1.11    # DNS interne secondaire
nameserver 8.8.8.8         # DNS externe en backup

# Attention : L'inverse peut causer des problèmes de résolution interne
```

> [!tip] Pourquoi cet ordre ? Les serveurs internes connaissent vos ressources locales et peuvent résoudre les noms internes. Les DNS externes servent de secours pour Internet.

### 🔹 Limiter le nombre de serveurs

```bash
# Maximum recommandé : 3 serveurs
nameserver 1.1.1.1
nameserver 8.8.8.8
nameserver 9.9.9.9

# Éviter : trop de serveurs ralentit la résolution
```

### 🔹 Utiliser des DNS fiables et rapides

**Critères de choix :**

- Latence faible depuis votre localisation
- Disponibilité (uptime)
- Respect de la vie privée
- Support IPv6 si nécessaire

```bash
# Tester la latence
ping -c 4 8.8.8.8
ping -c 4 1.1.1.1

# Comparer les temps de résolution
time nslookup google.com 8.8.8.8
time nslookup google.com 1.1.1.1
```

### 🔹 Documentation

```bash
# Toujours documenter les configurations spécifiques
# /etc/resolv.conf
# Configuration DNS pour serveur de production
# Modifié le 2024-01-15 par admin
# DNS internes : 192.168.1.10-11 (AD controllers)
# DNS externe : 8.8.8.8 (backup Internet)
nameserver 192.168.1.10
nameserver 192.168.1.11
nameserver 8.8.8.8
search entreprise.local
```

### 🔹 Sauvegardes

```bash
# Avant toute modification
sudo cp /etc/resolv.conf /etc/resolv.conf.backup.$(date +%Y%m%d)

# Vérifier les sauvegardes
ls -lh /etc/resolv.conf*
```

---

## ⚠️ Pièges courants

### 🔸 Fichier écrasé par des services réseau

**Problème :** Vos modifications disparaissent après un redémarrage ou une reconnexion réseau.

**Cause :** DHCP, NetworkManager, ou d'autres services réseau recréent le fichier.

**Solution Debian :**

```bash
# Option 1 : Configurer via /etc/network/interfaces
sudo nano /etc/network/interfaces
# Ajouter : dns-nameservers 8.8.8.8 8.8.4.4

# Option 2 : Rendre le fichier immuable
sudo chattr +i /etc/resolv.conf

# Vérifier
lsattr /etc/resolv.conf
# Résultat attendu : ----i---------e---- /etc/resolv.conf
```

**Solution Ubuntu :**

```bash
# Configurer via Netplan
sudo nano /etc/netplan/01-netcfg.yaml
sudo netplan apply
```

### 🔸 Limite de 3 serveurs DNS non respectée

**Problème :** Vous ajoutez plus de 3 serveurs DNS, mais seuls les 3 premiers sont utilisés.

```bash
# ❌ Mauvais : seuls les 3 premiers seront utilisés
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
nameserver 9.9.9.9     # Ignoré !
nameserver 208.67.222.222  # Ignoré !
```

**Solution :** Gardez uniquement les 3 meilleurs serveurs.

### 🔸 Confusion entre domain et search

**Problème :** Utilisation simultanée de `domain` et `search`.

```bash
# ❌ Mauvais : conflit entre les deux directives
domain exemple.local
search autre.local lab.local  # Seule cette ligne sera effective
```

**Solution :**

```bash
# ✅ Bon : utiliser uniquement search (plus flexible)
search exemple.local autre.local lab.local
```

### 🔸 DNS local 127.0.0.53 sans systemd-resolved

**Problème :** Copier une configuration Ubuntu sur Debian sans adapter.

```bash
# ❌ Ne fonctionnera pas sur Debian sans systemd-resolved
nameserver 127.0.0.53
```

**Solution :** Utiliser de vrais serveurs DNS :

```bash
# ✅ Bon pour Debian
nameserver 8.8.8.8
nameserver 1.1.1.1
```

### 🔸 Permissions incorrectes

**Problème :** Le fichier n'est pas lisible par tous les processus.

```bash
# Vérifier les permissions
ls -l /etc/resolv.conf
# Devrait être : -rw-r--r-- (644)

# Corriger si nécessaire
sudo chmod 644 /etc/resolv.conf
sudo chown root:root /etc/resolv.conf
```

### 🔸 Syntaxe invalide

**Problème :** Erreurs de syntaxe qui empêchent la résolution DNS.

```bash
# ❌ Mauvais : virgules, plusieurs serveurs par ligne
nameserver 8.8.8.8, 8.8.4.4

# ❌ Mauvais : guillemets inutiles
nameserver "8.8.8.8"

# ✅ Bon : un serveur par ligne, pas de ponctuation superflue
nameserver 8.8.8.8
nameserver 8.8.4.4
```

### 🔸 Oubli de tester après modification

**Problème :** Modifications non testées qui cassent la résolution DNS.

**Solution :** Toujours tester :

```bash
# Tester la résolution de noms
nslookup google.com

# Tester avec dig pour plus de détails
dig google.com

# Tester la connectivité générale
ping -c 3 google.com

# Vérifier quel serveur DNS est utilisé
dig +short google.com
```

> [!warning] Sécurité Gardez toujours un accès SSH ou console ouvert lors de modifications réseau critiques. Une mauvaise configuration DNS peut vous couper de votre serveur !

---

## 🎯 Astuces avancées

### Déboguer les problèmes DNS

```bash
# Voir quelle configuration est active
resolvectl status  # Sur Ubuntu avec systemd-resolved
cat /etc/resolv.conf  # Sur Debian

# Tester un serveur DNS spécifique
dig @8.8.8.8 google.com
nslookup google.com 1.1.1.1

# Vider le cache DNS (si systemd-resolved est actif)
sudo resolvectl flush-caches

# Tracer la résolution DNS
dig +trace google.com
```

### Forcer l'utilisation d'un DNS spécifique temporairement

```bash
# Pour une commande unique
host google.com 8.8.8.8

# Pour une session entière (temporaire)
export RES_OPTIONS="nameserver 8.8.8.8"
```

### Vérifier la rapidité des serveurs DNS

```bash
# Script simple pour comparer les temps de réponse
for dns in 8.8.8.8 1.1.1.1 9.9.9.9; do
  echo "Test de $dns :"
  time dig @$dns google.com > /dev/null
done
```

---

> [!info] Résumé La configuration DNS sur Debian repose principalement sur `/etc/resolv.conf`, un fichier statique simple mais puissant. Contrairement à Ubuntu qui utilise systemd-resolved, Debian privilégie une approche plus directe et manuelle. Comprendre ces différences est essentiel pour éviter les pièges courants lors de l'administration de systèmes mixtes.