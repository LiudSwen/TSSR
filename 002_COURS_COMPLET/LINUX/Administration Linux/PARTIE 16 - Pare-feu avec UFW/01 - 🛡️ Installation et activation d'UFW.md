

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

## Introduction à UFW

**UFW** (Uncomplicated Firewall) est une interface simplifiée pour gérer le pare-feu **iptables** sous Linux. Il a été conçu pour rendre la gestion du pare-feu accessible aux administrateurs systèmes sans nécessiter une expertise approfondie d'iptables.

> [!info] Pourquoi UFW ?
> 
> - **Simplicité** : Syntaxe claire et intuitive comparée à iptables
> - **Sécurité par défaut** : Bloque tout le trafic entrant par défaut
> - **Flexibilité** : Permet des configurations simples comme complexes
> - **Persistance** : Les règles survivent aux redémarrages

> [!warning] Important UFW est une surcouche à iptables. Les règles UFW sont traduites en règles iptables sous le capot. Si vous modifiez directement iptables, vous risquez de créer des conflits avec UFW.

### Cas d'usage typiques

- Serveurs web nécessitant l'ouverture des ports 80/443
- Serveurs SSH devant être protégés contre les attaques par force brute
- Serveurs de bases de données limitant l'accès à certaines IP
- Serveurs de développement nécessitant une configuration rapide

---

## Installation d'UFW

### Vérification de l'installation

Avant d'installer UFW, vérifiez s'il est déjà présent sur votre système :

```bash
# Vérifier si UFW est installé
which ufw

# Vérifier la version installée
ufw version
```

### Installation selon la distribution

#### Sur Ubuntu/Debian

```bash
# Mise à jour des dépôts
sudo apt update

# Installation d'UFW
sudo apt install ufw

# Vérification de l'installation
dpkg -l | grep ufw
```

> [!example] Exemple de sortie
> 
> ```
> ii  ufw  0.36-6  all  program for managing a Netfilter firewall
> ```

#### Sur Fedora/CentOS/RHEL

```bash
# Installation via DNF (Fedora/RHEL 8+)
sudo dnf install ufw

# Ou via YUM (anciennes versions)
sudo yum install ufw

# Activation du service au démarrage
sudo systemctl enable ufw
```

#### Sur Arch Linux

```bash
# Installation via pacman
sudo pacman -S ufw

# Activation du service
sudo systemctl enable ufw.service
```

### Post-installation

Après l'installation, UFW est présent mais **non activé** par défaut. C'est une sécurité pour éviter de vous verrouiller l'accès à votre système.

```bash
# Vérifier le statut après installation
sudo ufw status
```

> [!tip] Bonne pratique Avant d'activer UFW pour la première fois, assurez-vous d'autoriser SSH si vous gérez le serveur à distance, sinon vous risquez de perdre l'accès !

---

## Activation et désactivation

### Activation d'UFW

L'activation d'UFW applique immédiatement toutes les règles configurées et démarre le pare-feu.

```bash
# Activer UFW
sudo ufw enable
```

> [!example] Exemple de sortie
> 
> ```
> Firewall is active and enabled on system startup
> ```

> [!warning] Attention - Risque de verrouillage Si vous êtes connecté en SSH et que vous n'avez pas autorisé le port SSH (22) avant d'activer UFW, vous serez déconnecté et ne pourrez plus vous reconnecter !
> 
> **Solution préventive** :
> 
> ```bash
> # TOUJOURS autoriser SSH avant d'activer UFW
> sudo ufw allow ssh
> # Ou explicitement le port 22
> sudo ufw allow 22/tcp
> # Puis activer
> sudo ufw enable
> ```

#### Comportement à l'activation

Lorsque UFW est activé :

- Toutes les connexions **entrantes** sont **bloquées** par défaut
- Toutes les connexions **sortantes** sont **autorisées** par défaut
- Les connexions établies et liées sont **autorisées** (principe de statefull)
- Les règles définies sont appliquées immédiatement
- UFW se lance automatiquement au démarrage du système

### Désactivation d'UFW

```bash
# Désactiver UFW
sudo ufw disable
```

> [!example] Exemple de sortie
> 
> ```
> Firewall stopped and disabled on system startup
> ```

Lorsque UFW est désactivé :

- Toutes les règles sont retirées d'iptables
- Le trafic n'est plus filtré
- UFW ne démarrera pas au prochain redémarrage

> [!info] Conservation des règles La désactivation d'UFW n'efface **pas** vos règles. Elles sont simplement désactivées et seront réappliquées si vous réactivez UFW.

### Rechargement d'UFW

Pour appliquer des modifications sans désactiver puis réactiver :

```bash
# Recharger UFW (applique les changements)
sudo ufw reload
```

> [!tip] Quand recharger ? Le rechargement est utile après avoir modifié manuellement des fichiers de configuration dans `/etc/ufw/`. Pour les règles ajoutées via la ligne de commande, elles sont appliquées instantanément.

### Réinitialisation complète

Pour supprimer toutes les règles et revenir à la configuration par défaut :

```bash
# Réinitialiser UFW (supprime toutes les règles)
sudo ufw reset
```

> [!warning] Confirmation requise Cette commande vous demandera confirmation car elle supprime **toutes** vos règles personnalisées.

---

## Vérification du statut

### Statut simple

```bash
# Afficher le statut d'UFW (simple)
sudo ufw status
```

> [!example] Exemples de sortie
> 
> **UFW inactif** :
> 
> ```
> Status: inactive
> ```
> 
> **UFW actif sans règles** :
> 
> ```
> Status: active
> ```
> 
> **UFW actif avec règles** :
> 
> ```
> Status: active
> 
> To                         Action      From
> --                         ------      ----
> 22/tcp                     ALLOW       Anywhere
> 80/tcp                     ALLOW       Anywhere
> 22/tcp (v6)                ALLOW       Anywhere (v6)
> 80/tcp (v6)                ALLOW       Anywhere (v6)
> ```

### Statut détaillé (verbose)

```bash
# Afficher le statut détaillé
sudo ufw status verbose
```

> [!example] Exemple de sortie détaillée
> 
> ```
> Status: active
> Logging: on (low)
> Default: deny (incoming), allow (outgoing), disabled (routed)
> New profiles: skip
> 
> To                         Action      From
> --                         ------      ----
> 22/tcp                     ALLOW IN    Anywhere
> 80/tcp                     ALLOW IN    Anywhere
> 22/tcp (v6)                ALLOW IN    Anywhere (v6)
> 80/tcp (v6)                ALLOW IN    Anywhere (v6)
> ```

#### Interprétation du statut verbose

|Élément|Description|
|---|---|
|**Status**|État du pare-feu (active/inactive)|
|**Logging**|Niveau de journalisation (off, low, medium, high, full)|
|**Default incoming**|Politique par défaut pour le trafic entrant|
|**Default outgoing**|Politique par défaut pour le trafic sortant|
|**Default routed**|Politique pour le trafic routé (forwarding)|
|**New profiles**|Comportement lors de l'installation de nouveaux paquets|

> [!info] Politiques par défaut
> 
> - **deny (incoming)** : Tout trafic entrant non explicitement autorisé est bloqué
> - **allow (outgoing)** : Tout trafic sortant est autorisé (le serveur peut initier des connexions)
> - **disabled (routed)** : Le routage/forwarding de paquets est désactivé par défaut

### Statut numéroté

```bash
# Afficher les règles avec leurs numéros
sudo ufw status numbered
```

> [!example] Exemple de sortie
> 
> ```
> Status: active
> 
>      To                         Action      From
>      --                         ------      ----
> [ 1] 22/tcp                     ALLOW IN    Anywhere
> [ 2] 80/tcp                     ALLOW IN    Anywhere
> [ 3] 443/tcp                    ALLOW IN    Anywhere
> [ 4] 22/tcp (v6)                ALLOW IN    Anywhere (v6)
> [ 5] 80/tcp (v6)                ALLOW IN    Anywhere (v6)
> [ 6] 443/tcp (v6)               ALLOW IN    Anywhere (v6)
> ```

> [!tip] Utilité des numéros Les numéros sont essentiels pour supprimer ou insérer des règles à des positions spécifiques. Ils seront utilisés dans les parties suivantes du cours (gestion des règles).

### Vérification au niveau système

```bash
# Vérifier si le service UFW est actif
sudo systemctl status ufw

# Vérifier si UFW démarre au boot
sudo systemctl is-enabled ufw

# Voir les règles iptables générées par UFW
sudo iptables -L -n -v
```

> [!info] Relation avec systemd UFW est géré comme un service systemd. Son activation/désactivation via `ufw enable/disable` modifie également son statut systemd.

### Commandes de diagnostic

```bash
# Afficher la version d'UFW
ufw version

# Voir les logs du pare-feu (si logging activé)
sudo tail -f /var/log/ufw.log

# Vérifier les fichiers de configuration
ls -la /etc/ufw/
```

---

## 🎯 Pièges courants et bonnes pratiques

### ⚠️ Pièges à éviter

|Piège|Conséquence|Solution|
|---|---|---|
|Activer UFW sans autoriser SSH|Perte d'accès à distance|Toujours `sudo ufw allow ssh` avant `ufw enable`|
|Oublier de recharger après modification|Règles non appliquées|`sudo ufw reload` après modification manuelle|
|Désactiver UFW pour tester|Exposition totale du serveur|Utiliser `ufw status numbered` et supprimer règles spécifiques|
|Configurer des règles IPv4 uniquement|Services inaccessibles en IPv6|Vérifier avec `ufw status verbose` la présence de règles (v6)|

### ✅ Bonnes pratiques

> [!tip] Checklist de démarrage
> 
> 1. **Installer** UFW sur le système
> 2. **Configurer** les règles essentielles (SSH en priorité)
> 3. **Vérifier** avec `ufw status numbered` avant activation
> 4. **Activer** UFW avec `ufw enable`
> 5. **Confirmer** l'accès SSH fonctionne toujours
> 6. **Tester** les services autorisés

> [!tip] Sécurité SSH renforcée Pour un serveur exposé sur Internet, considérez :
> 
> ```bash
> # Limiter les tentatives de connexion SSH
> sudo ufw limit ssh
> # Cette règle bloque temporairement les IP avec >6 tentatives en 30 secondes
> ```

> [!tip] Documentation des règles Ajoutez des commentaires dans vos scripts :
> 
> ```bash
> # Serveur Web - HTTP/HTTPS
> sudo ufw allow 80/tcp
> sudo ufw allow 443/tcp
> 
> # Base de données - accès local uniquement
> # (sera configuré dans une partie ultérieure)
> ```

### 🔍 Astuces de diagnostic

```bash
# Afficher uniquement les règles IPv4
sudo ufw status | grep -v "(v6)"

# Compter le nombre de règles actives
sudo ufw status numbered | grep -c "^\["

# Vérifier qu'UFW est bien la seule source de règles iptables
sudo iptables -S | grep -v "ufw"
```

---

## 📝 Récapitulatif

### Commandes essentielles

```bash
# Installation
sudo apt install ufw                    # Ubuntu/Debian
sudo dnf install ufw                    # Fedora/RHEL

# Gestion du pare-feu
sudo ufw enable                         # Activer UFW
sudo ufw disable                        # Désactiver UFW
sudo ufw reload                         # Recharger la configuration
sudo ufw reset                          # Réinitialiser (supprimer toutes les règles)

# Vérification du statut
sudo ufw status                         # Statut simple
sudo ufw status verbose                 # Statut détaillé
sudo ufw status numbered                # Statut avec numéros de règles
ufw version                             # Version d'UFW

# Diagnostic système
sudo systemctl status ufw               # Statut du service
sudo systemctl is-enabled ufw           # Vérifier démarrage auto
```

### Points clés à retenir

- 🔒 UFW applique une **politique de sécurité par défaut** : tout bloquer en entrée, tout autoriser en sortie
- 🚪 **Toujours autoriser SSH** avant d'activer UFW sur un serveur distant
- 📊 Le statut **verbose** donne des informations complètes sur la configuration
- 🔄 Les règles sont **persistantes** et survivent aux redémarrages
- 🎯 UFW gère automatiquement les règles **IPv4 et IPv6**
- ⚙️ La désactivation **conserve** les règles configurées

---

> [!info] Suite du cours Cette partie couvre l'installation et l'activation d'UFW. Les parties suivantes aborderont :
> 
> - La gestion des règles (allow, deny, delete)
> - La configuration avancée (ports, protocoles, IP sources)
> - Les profils d'applications
> - La journalisation et le monitoring