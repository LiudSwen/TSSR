

## 📚 Table des matières

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

**NFTables** est le successeur moderne d'iptables, introduit dans le noyau Linux à partir de la version 3.13. Il offre une syntaxe unifiée et simplifiée pour gérer le filtrage de paquets, le NAT et d'autres fonctionnalités réseau.

> [!info] Pourquoi NFTables ?
> 
> - **Syntaxe unifiée** : Une seule commande `nft` pour toutes les opérations
> - **Performance améliorée** : Moins d'appels système, meilleure gestion de la mémoire
> - **Atomicité** : Les modifications sont appliquées en une seule transaction
> - **Compatibilité** : Remplace iptables, ip6tables, arptables et ebtables

---

## 🔍 Vérification de la disponibilité

Avant d'installer nftables, il est crucial de vérifier que votre système dispose des prérequis nécessaires.

### Vérification de la version du noyau

NFTables nécessite un noyau Linux version **3.13 minimum**, mais la version **4.14 ou supérieure** est fortement recommandée pour bénéficier de toutes les fonctionnalités.

```bash
# Vérifier la version du noyau
uname -r
```

> [!example] Sortie attendue
> 
> ```
> 5.10.0-23-amd64
> ```

### Vérification du support noyau

```bash
# Vérifier si le module nf_tables est disponible
lsmod | grep nf_tables

# Si aucune sortie, tenter de charger le module
sudo modprobe nf_tables

# Vérifier à nouveau
lsmod | grep nf_tables
```

> [!tip] Astuce Si le module ne peut pas être chargé, votre noyau ne supporte peut-être pas nftables. Envisagez une mise à jour du système.

### Vérification de la présence d'iptables

```bash
# Identifier si iptables est actuellement utilisé
sudo iptables -L -n -v

# Vérifier le service iptables
sudo systemctl status iptables 2>/dev/null || echo "Service iptables non trouvé"
```

> [!warning] Attention - Cohabitation iptables/nftables Bien que techniquement possible, faire cohabiter iptables et nftables sur le même système peut créer des conflits. Il est recommandé de migrer complètement vers nftables.

---

## 📦 Installation sur Debian/Ubuntu

### Mise à jour du système

Avant toute installation, assurez-vous que votre système est à jour :

```bash
# Mettre à jour la liste des paquets
sudo apt update

# Mettre à jour les paquets installés (optionnel mais recommandé)
sudo apt upgrade -y
```

### Installation du paquet nftables

```bash
# Installer nftables
sudo apt install nftables -y
```

> [!example] Paquets installés L'installation inclut généralement :
> 
> - `nftables` : Le paquet principal
> - `libnftables1` : Les bibliothèques nécessaires
> - Configuration par défaut dans `/etc/nftables.conf`

### Vérification de l'installation

```bash
# Vérifier la version installée
nft --version

# Vérifier l'emplacement de la commande
which nft

# Afficher l'aide rapide
nft --help
```

> [!example] Sortie attendue
> 
> ```
> nftables v0.9.8 (Fearless Fosdick)
> ```

### Gestion d'iptables (migration)

Sur les systèmes Debian/Ubuntu modernes, vous pouvez utiliser `update-alternatives` pour basculer entre iptables-legacy et iptables-nft (backend nftables) :

```bash
# Vérifier la version actuelle d'iptables
sudo update-alternatives --display iptables

# Basculer vers nftables (si disponible)
sudo update-alternatives --set iptables /usr/sbin/iptables-nft
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-nft

# Vérifier le changement
iptables --version
```

> [!info] iptables-nft vs nftables natif
> 
> - `iptables-nft` : Utilise la syntaxe iptables avec le backend nftables
> - `nft` : Commande native avec la nouvelle syntaxe nftables
> 
> Pour un apprentissage optimal, privilégiez la syntaxe native `nft`.

---

## 📦 Installation sur RedHat/CentOS

### Désactivation de firewalld (si nécessaire)

Sur RHEL/CentOS, `firewalld` est souvent actif par défaut. Bien que firewalld puisse utiliser nftables comme backend, nous allons travailler directement avec nftables.

```bash
# Vérifier le statut de firewalld
sudo systemctl status firewalld

# Arrêter firewalld
sudo systemctl stop firewalld

# Désactiver firewalld au démarrage
sudo systemctl disable firewalld

# Masquer le service pour éviter qu'il soit redémarré par d'autres services
sudo systemctl mask firewalld
```

> [!warning] Production Dans un environnement de production, évaluez soigneusement l'impact de la désactivation de firewalld. Vous pouvez également configurer firewalld pour utiliser nftables comme backend.

### Installation du paquet nftables

#### Sur RHEL/CentOS 8 et versions ultérieures

```bash
# Installer nftables
sudo dnf install nftables -y
```

#### Sur CentOS 7

```bash
# Activer le dépôt EPEL si nécessaire
sudo yum install epel-release -y

# Installer nftables
sudo yum install nftables -y
```

### Vérification de l'installation

```bash
# Vérifier la version
nft --version

# Vérifier le statut du service
sudo systemctl status nftables

# Lister les fichiers installés
rpm -ql nftables
```

> [!example] Fichiers de configuration
> 
> - Configuration principale : `/etc/sysconfig/nftables.conf`
> - Exemples de règles : `/etc/nftables/`

### Migration depuis iptables

```bash
# Sauvegarder les règles iptables existantes
sudo iptables-save > /tmp/iptables-backup.txt

# Arrêter et désactiver iptables
sudo systemctl stop iptables
sudo systemctl disable iptables

# Pour IPv6
sudo systemctl stop ip6tables
sudo systemctl disable ip6tables
```

> [!tip] Conversion des règles Il existe des outils pour convertir les règles iptables en nftables, mais une réécriture manuelle est souvent plus propre et permet de mieux comprendre la nouvelle syntaxe.

---

## ⚙️ Vérification du service systemd

### Activation et démarrage du service

Une fois nftables installé, vous devez activer et démarrer le service systemd associé.

```bash
# Activer le service au démarrage
sudo systemctl enable nftables

# Démarrer le service immédiatement
sudo systemctl start nftables

# Vérifier le statut du service
sudo systemctl status nftables
```

> [!example] Sortie attendue (service actif)
> 
> ```
> ● nftables.service - nftables
>      Loaded: loaded (/lib/systemd/system/nftables.service; enabled; vendor preset: enabled)
>      Active: active (exited) since Sun 2026-01-18 10:30:45 CET; 2min ago
>      ...
> ```

### Comprendre les états du service

|État|Signification|
|---|---|
|`active (exited)`|Le service a chargé les règles avec succès puis s'est terminé (comportement normal)|
|`inactive (dead)`|Le service n'est pas démarré|
|`failed`|Une erreur s'est produite lors du chargement des règles|

> [!info] Pourquoi "exited" ? Contrairement à un daemon qui reste actif en arrière-plan, le service nftables charge simplement les règles dans le noyau puis se termine. Les règles persistent dans le noyau jusqu'au prochain redémarrage ou modification manuelle.

### Commandes de gestion du service

```bash
# Recharger les règles depuis le fichier de configuration
sudo systemctl reload nftables

# Redémarrer le service (vide puis recharge les règles)
sudo systemctl restart nftables

# Arrêter le service (vide toutes les règles)
sudo systemctl stop nftables

# Voir les logs du service
sudo journalctl -u nftables

# Voir les logs en temps réel
sudo journalctl -u nftables -f
```

### Vérification des règles actives

```bash
# Lister tous les ensembles de règles (rulesets)
sudo nft list ruleset

# Afficher uniquement les tables
sudo nft list tables

# Vérifier si des règles sont chargées
sudo nft list ruleset | wc -l
```

> [!tip] Première vérification Si `nft list ruleset` ne retourne rien, c'est normal ! Par défaut, nftables n'a aucune règle chargée après l'installation. C'est différent d'iptables qui peut avoir des règles par défaut.

### Fichiers de configuration systemd

```bash
# Localiser le fichier de service
systemctl cat nftables

# Fichier de configuration principal (Debian/Ubuntu)
ls -l /etc/nftables.conf

# Fichier de configuration principal (RHEL/CentOS)
ls -l /etc/sysconfig/nftables.conf
```

> [!example] Contenu typique du service systemd
> 
> ```ini
> [Unit]
> Description=nftables
> Documentation=man:nft(8)
> Wants=network-pre.target
> Before=network-pre.target shutdown.target
> 
> [Service]
> Type=oneshot
> RemainAfterExit=yes
> ExecStart=/usr/sbin/nft -f /etc/nftables.conf
> ExecReload=/usr/sbin/nft -f /etc/nftables.conf
> ExecStop=/usr/sbin/nft flush ruleset
> 
> [Install]
> WantedBy=multi-user.target
> ```

### Persistance des règles

> [!warning] Important - Persistance Contrairement à certaines configurations iptables, avec nftables :
> 
> - Les modifications manuelles via `nft` ne sont **PAS persistantes** après un redémarrage
> - Pour rendre les règles persistantes, vous devez les écrire dans `/etc/nftables.conf`
> - Ou utiliser `nft list ruleset > /etc/nftables.conf` pour sauvegarder l'état actuel

```bash
# Sauvegarder les règles actuelles
sudo nft list ruleset | sudo tee /etc/nftables.conf

# Tester le chargement du fichier de configuration
sudo nft -f /etc/nftables.conf

# Vérifier la syntaxe sans appliquer
sudo nft -c -f /etc/nftables.conf
```

---

## ⚠️ Pièges courants

### 1. Règles non persistantes

> [!warning] Piège fréquent **Problème** : Vous ajoutez des règles avec `nft add ...` mais elles disparaissent après un redémarrage.
> 
> **Solution** : Toujours sauvegarder dans `/etc/nftables.conf` ou utiliser un système de gestion de configuration.

```bash
# ❌ Mauvaise pratique (non persistant)
sudo nft add table inet filter

# ✅ Bonne pratique
sudo nft add table inet filter
sudo nft list ruleset > /etc/nftables.conf
```

### 2. Conflit avec iptables

> [!warning] Conflit de règles **Problème** : Avoir à la fois iptables et nftables actifs peut créer des comportements imprévisibles.
> 
> **Solution** : Choisir un seul système de pare-feu.

```bash
# Vérifier les règles iptables existantes
sudo iptables -L -n

# Si des règles existent, décider de migrer ou désactiver
sudo systemctl stop iptables
sudo systemctl disable iptables
```

### 3. Service qui ne démarre pas

> [!warning] Erreur de syntaxe **Problème** : `systemctl start nftables` échoue.
> 
> **Diagnostic** :

```bash
# Vérifier les logs
sudo journalctl -u nftables -n 50

# Tester manuellement le fichier de configuration
sudo nft -c -f /etc/nftables.conf

# Vérifier la syntaxe ligne par ligne
sudo nft -f /etc/nftables.conf
```

### 4. Perte de connexion SSH

> [!warning] Blocage réseau **Problème** : Appliquer des règles restrictives sans autoriser SSH peut vous bloquer l'accès distant.
> 
> **Prévention** :

```bash
# Toujours tester avec une tâche cron qui réinitialise les règles
echo "sudo nft flush ruleset" | at now + 5 minutes

# Ou utiliser une session screen/tmux avec un timeout
timeout 300 bash -c 'sleep 300; sudo nft flush ruleset' &
```

### 5. Mauvais ordre des règles

> [!tip] Ordre d'évaluation **Rappel** : Contrairement à certaines configurations iptables avec des chaînes par défaut, nftables évalue les règles **dans l'ordre** où elles apparaissent. Une règle permissive placée avant une règle restrictive peut annuler l'effet de cette dernière.

```bash
# ❌ Mauvais ordre (bloque tout, même SSH autorisé après)
nft add rule inet filter input drop
nft add rule inet filter input tcp dport 22 accept

# ✅ Bon ordre
nft add rule inet filter input tcp dport 22 accept
nft add rule inet filter input drop
```

### 6. Oubli du module noyau

> [!warning] Module non chargé **Problème** : `nft` retourne "Error: Could not process rule: No such file or directory"
> 
> **Solution** :

```bash
# Charger le module
sudo modprobe nf_tables

# Vérifier
lsmod | grep nf_tables

# Rendre permanent (Debian/Ubuntu)
echo "nf_tables" | sudo tee -a /etc/modules

# Rendre permanent (RHEL/CentOS)
echo "nf_tables" | sudo tee -a /etc/modules-load.d/nftables.conf
```

---

## 🎓 Bonnes pratiques

> [!tip] Recommandations
> 
> 1. **Toujours sauvegarder** avant de modifier des règles en production
> 2. **Tester d'abord** avec `nft -c -f` pour vérifier la syntaxe
> 3. **Documenter vos règles** avec des commentaires dans `/etc/nftables.conf`
> 4. **Utiliser des scripts** pour des configurations complexes
> 5. **Monitorer les logs** après chaque changement : `journalctl -u nftables -f`
> 6. **Conserver une règle de fallback** pour SSH en cas de problème

---

_Ce document couvre l'installation et la configuration de base de nftables. Les concepts avancés comme la création de tables, chaînes, et règles spécifiques seront abordés dans les modules suivants._