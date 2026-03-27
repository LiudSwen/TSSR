
---

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

## 1️⃣ Création de comptes pour SSH

### 🎯 Pourquoi créer des comptes dédiés ?

La création de comptes utilisateurs spécifiques pour SSH est une pratique fondamentale de sécurité. Chaque personne accédant au système doit avoir son propre compte pour :

- Assurer la traçabilité des actions (logs individuels)
- Limiter les privilèges selon les besoins réels
- Faciliter la révocation d'accès sans impacter les autres
- Éviter l'utilisation partagée de comptes root ou génériques

> [!warning] Attention Ne jamais partager un même compte SSH entre plusieurs personnes. Cela rend impossible l'audit de sécurité et la responsabilisation.

### 📝 Création d'un utilisateur standard

```bash
# Créer un nouvel utilisateur avec répertoire home
sudo useradd -m -s /bin/bash username

# Définir un mot de passe (si nécessaire temporairement)
sudo passwd username

# Alternative : créer avec des paramètres complets
sudo useradd -m -s /bin/bash -c "Nom Complet" -G groupes username
```

**Options importantes :**

- `-m` : Crée le répertoire home `/home/username`
- `-s /bin/bash` : Définit le shell par défaut
- `-c "commentaire"` : Ajoute une description (nom complet)
- `-G groupes` : Ajoute l'utilisateur à des groupes supplémentaires
- `-d /chemin/custom` : Définit un répertoire home personnalisé

### 🔑 Configuration pour l'authentification par clé

```bash
# Se connecter en tant que nouvel utilisateur
sudo su - username

# Créer le répertoire .ssh avec les bonnes permissions
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Créer le fichier authorized_keys
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Ajouter la clé publique de l'utilisateur
echo "ssh-rsa AAAAB3NzaC1yc2E... user@machine" >> ~/.ssh/authorized_keys
```

> [!tip] Astuce Utilisez `ssh-copy-id` depuis la machine cliente pour automatiser ce processus :
> 
> ```bash
> ssh-copy-id -i ~/.ssh/id_rsa.pub username@serveur
> ```

### 🛡️ Permissions critiques à respecter

|Élément|Permission|Propriétaire|Pourquoi|
|---|---|---|---|
|`~/.ssh/`|700 (drwx------)|user:user|SSH refuse les répertoires lisibles par d'autres|
|`~/.ssh/authorized_keys`|600 (-rw-------)|user:user|Empêche la modification par d'autres utilisateurs|
|`~/.ssh/config`|600 (-rw-------)|user:user|Protège la configuration client|
|Clé privée|600 (-rw-------)|user:user|SSH refuse les clés lisibles par d'autres|

```bash
# Vérifier et corriger les permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chown -R username:username ~/.ssh
```

> [!warning] Erreur fréquente Des permissions trop ouvertes (644, 755) sur `.ssh` ou `authorized_keys` causeront le rejet de l'authentification par clé, forçant le retour au mot de passe.

### 👤 Création d'un utilisateur système (service)

Pour des services automatisés ou des scripts :

```bash
# Créer un utilisateur sans shell interactif
sudo useradd -r -s /usr/sbin/nologin -d /opt/service service_ssh

# Avec un shell limité pour SFTP uniquement
sudo useradd -m -s /usr/sbin/nologin -d /home/sftp_user sftp_user
```

**Options spécifiques :**

- `-r` : Crée un compte système (UID < 1000)
- `-s /usr/sbin/nologin` : Empêche la connexion shell interactive
- Utile pour les transferts SFTP ou les tunnels SSH uniquement

---

## 2️⃣ Restriction d'accès par utilisateur

### 🎯 Principe de moindre privilège

Chaque utilisateur doit avoir uniquement les droits nécessaires à ses tâches. SSH offre plusieurs mécanismes pour restreindre finement les accès.

### 🔒 Configuration dans sshd_config

```bash
# Éditer la configuration SSH
sudo nano /etc/ssh/sshd_config
```

#### Autoriser/Refuser des utilisateurs spécifiques

```bash
# Autoriser uniquement certains utilisateurs
AllowUsers alice bob charlie

# Autoriser avec restriction par IP
AllowUsers alice@192.168.1.* bob@10.0.0.50

# Refuser des utilisateurs spécifiques
DenyUsers guest test root

# Combiner les règles (DenyUsers est évalué en premier)
AllowUsers alice bob
DenyUsers alice@192.168.50.*  # Alice ne peut pas se connecter depuis ce réseau
```

> [!info] Ordre d'évaluation Les règles sont évaluées dans l'ordre : `DenyUsers`, `AllowUsers`, `DenyGroups`, `AllowGroups`. La première correspondance l'emporte.

#### Restrictions par groupes

```bash
# Autoriser uniquement les membres de certains groupes
AllowGroups ssh-users admins

# Refuser des groupes
DenyGroups guests external
```

### 🚪 Restreindre l'accès root

```bash
# Interdire complètement root
PermitRootLogin no

# Permettre root uniquement avec clé (pas de mot de passe)
PermitRootLogin prohibit-password

# Permettre root uniquement pour des commandes forcées
PermitRootLogin forced-commands-only
```

> [!tip] Bonne pratique Utilisez `PermitRootLogin prohibit-password` ou `no`. Connectez-vous avec un compte normal puis utilisez `sudo` pour les tâches administratives.

### 🛠️ Commandes forcées (Forced Commands)

Forcer l'exécution d'une seule commande spécifique pour un utilisateur :

```bash
# Dans ~/.ssh/authorized_keys de l'utilisateur
command="/usr/local/bin/backup.sh" ssh-rsa AAAAB3NzaC1yc2E... backup@server

# Options supplémentaires pour restreindre davantage
no-port-forwarding,no-X11-forwarding,no-agent-forwarding,command="/chemin/script.sh" ssh-rsa AAAAB3...
```

**Options de restriction :**

- `no-port-forwarding` : Désactive le tunneling de ports
- `no-X11-forwarding` : Désactive le transfert X11
- `no-agent-forwarding` : Désactive le transfert d'agent SSH
- `no-pty` : Désactive l'allocation de terminal
- `from="pattern"` : Limite les IP sources autorisées

> [!example] Exemple pratique Utilisateur de backup qui ne peut exécuter qu'un script de sauvegarde :
> 
> ```bash
> no-port-forwarding,no-X11-forwarding,no-pty,command="/usr/local/bin/rsync_backup.sh" ssh-rsa AAAAB3NzaC1yc2EAAAADAQAB... backup@backup-server
> ```

### 🌐 Restriction par adresse IP/réseau

#### Dans sshd_config (global)

```bash
# Match conditionnel par adresse
Match Address 192.168.1.0/24
    AllowUsers alice bob
    PermitRootLogin no

Match Address 10.0.0.0/8
    AllowUsers admin
    PermitRootLogin prohibit-password

# Match par utilisateur ET adresse
Match User charlie Address 203.0.113.*
    PasswordAuthentication yes
```

#### Dans authorized_keys (par clé)

```bash
# Restriction depuis une IP spécifique
from="192.168.1.100" ssh-rsa AAAAB3NzaC1yc2E...

# Restriction depuis un réseau
from="10.0.0.0/24" ssh-rsa AAAAB3NzaC1yc2E...

# Plusieurs sources
from="192.168.1.100,10.0.0.0/24,*.example.com" ssh-rsa AAAAB3NzaC1yc2E...
```

### 🕐 Restrictions temporelles

Avec `Match` et des scripts externes :

```bash
# Autoriser l'accès uniquement pendant les heures ouvrables
Match User consultant
    ForceCommand /usr/local/bin/check_time_access.sh
```

Script `check_time_access.sh` :

```bash
#!/bin/bash
hour=$(date +%H)
day=$(date +%u)

# Lundi à Vendredi (1-5), 8h-18h
if [ $day -ge 1 ] && [ $day -le 5 ] && [ $hour -ge 8 ] && [ $hour -lt 18 ]; then
    exec $SHELL
else
    echo "Accès autorisé uniquement en semaine de 8h à 18h"
    exit 1
fi
```

### 🔄 Appliquer les modifications

```bash
# Tester la configuration avant de redémarrer
sudo sshd -t

# Si OK, redémarrer SSH
sudo systemctl restart sshd

# Ou sur certains systèmes
sudo service ssh restart
```

> [!warning] Piège courant Testez toujours vos modifications dans une **nouvelle session** SSH sans fermer l'ancienne. Si vous vous verrouillez, vous pourrez corriger depuis la session existante.

---

## 3️⃣ Groupes et politiques d'accès

### 🎯 Gestion par groupes : approche organisée

La gestion par groupes permet de définir des politiques d'accès cohérentes pour des ensembles d'utilisateurs partageant les mêmes besoins.

### 👥 Création et gestion de groupes

```bash
# Créer un groupe SSH dédié
sudo groupadd ssh-users

# Créer des groupes par fonction
sudo groupadd ssh-admins
sudo groupadd ssh-devs
sudo groupadd ssh-readonly

# Ajouter un utilisateur à un groupe
sudo usermod -aG ssh-users alice

# Ajouter un utilisateur à plusieurs groupes
sudo usermod -aG ssh-users,ssh-devs bob

# Voir les groupes d'un utilisateur
groups alice
id alice
```

> [!info] Option -aG `-a` (append) avec `-G` ajoute aux groupes existants sans écraser. Sans `-a`, l'utilisateur serait retiré de tous ses autres groupes !

### 🔐 Politiques d'accès par groupe

#### Configuration de base

```bash
# Dans /etc/ssh/sshd_config

# Autoriser uniquement les membres de groupes spécifiques
AllowGroups ssh-users ssh-admins

# Combiner avec des restrictions utilisateurs
AllowGroups ssh-users
DenyUsers alice  # Alice est exclue même si dans ssh-users
```

#### Configurations avancées par groupe

```bash
# Politique différenciée selon les groupes
Match Group ssh-admins
    AllowTcpForwarding yes
    PermitTunnel yes
    X11Forwarding yes
    MaxSessions 10

Match Group ssh-devs
    AllowTcpForwarding yes
    PermitTunnel no
    X11Forwarding yes
    MaxSessions 5
    ChrootDirectory none

Match Group ssh-readonly
    AllowTcpForwarding no
    PermitTunnel no
    X11Forwarding no
    MaxSessions 2
    ForceCommand /usr/local/bin/readonly-shell.sh
```

### 🏢 Exemple d'organisation par rôles

|Groupe|Accès|Restrictions|Cas d'usage|
|---|---|---|---|
|`ssh-admins`|Complet|Aucune|Administrateurs système|
|`ssh-devs`|Shell + Tunneling|Pas de root direct|Développeurs|
|`ssh-sftp`|SFTP uniquement|Chrooté|Transferts de fichiers|
|`ssh-backup`|Commandes forcées|Scripts spécifiques|Automatisation|
|`ssh-readonly`|Lecture seule|Shell restreint|Consultation/audit|

### 📋 Configuration complète exemple

```bash
# /etc/ssh/sshd_config

# Groupes autorisés globalement
AllowGroups ssh-admins ssh-devs ssh-sftp ssh-readonly

# Administrateurs : accès complet
Match Group ssh-admins
    PermitRootLogin prohibit-password
    AllowTcpForwarding yes
    X11Forwarding yes
    MaxAuthTries 6
    MaxSessions 10

# Développeurs : accès standard
Match Group ssh-devs
    AllowTcpForwarding yes
    X11Forwarding yes
    PermitTunnel no
    MaxSessions 5
    ChrootDirectory none

# SFTP uniquement : utilisateurs isolés
Match Group ssh-sftp
    ForceCommand internal-sftp
    ChrootDirectory /home/%u
    AllowTcpForwarding no
    X11Forwarding no
    PermitTunnel no

# Lecture seule : accès limité
Match Group ssh-readonly
    AllowTcpForwarding no
    X11Forwarding no
    PermitTunnel no
    MaxSessions 2
    PermitTTY yes
```

### 🛡️ Politiques de sécurité avancées

#### Limiter les tentatives de connexion par groupe

```bash
Match Group ssh-external
    MaxAuthTries 3
    LoginGraceTime 30

Match Group ssh-internal
    MaxAuthTries 6
    LoginGraceTime 120
```

#### Restrictions réseau par groupe

```bash
# Admins depuis le réseau local uniquement
Match Group ssh-admins Address 192.168.1.0/24
    PermitRootLogin prohibit-password

# Externes avec restrictions fortes
Match Group ssh-external
    PasswordAuthentication no
    PubkeyAuthentication yes
    MaxAuthTries 3
    AllowTcpForwarding no
```

### 🔍 Audit et vérification

```bash
# Lister les membres d'un groupe
getent group ssh-users

# Voir tous les groupes SSH
getent group | grep ssh

# Vérifier la configuration d'un utilisateur
id -Gn alice
groups alice

# Tester la configuration SSH pour un utilisateur
sudo -u alice ssh -T localhost
```

### 📊 Script de gestion des groupes SSH

```bash
#!/bin/bash
# manage_ssh_groups.sh - Gestion simplifiée

case "$1" in
    add-user)
        sudo usermod -aG "$2" "$3"
        echo "Utilisateur $3 ajouté au groupe $2"
        ;;
    remove-user)
        sudo gpasswd -d "$3" "$2"
        echo "Utilisateur $3 retiré du groupe $2"
        ;;
    list-group)
        getent group "$2" | cut -d: -f4
        ;;
    list-user)
        groups "$2"
        ;;
    *)
        echo "Usage: $0 {add-user|remove-user|list-group|list-user} groupe utilisateur"
        exit 1
        ;;
esac
```

> [!tip] Automatisation Créez des scripts pour automatiser l'ajout/retrait d'utilisateurs dans les groupes, garantissant la cohérence des politiques d'accès.

---

## 4️⃣ Révocation d'accès

### 🎯 Importance de la révocation rapide

La révocation d'accès doit être immédiate lors d'un départ, d'une compromission de compte ou d'un changement de rôle. Un accès non révoqué représente une porte d'entrée potentielle.

### 🚫 Désactivation temporaire d'un compte

#### Verrouiller le compte

```bash
# Verrouiller le compte (empêche l'authentification par mot de passe)
sudo usermod -L username

# Vérifier le statut
sudo passwd -S username
# Résultat : username L (Locked)

# Déverrouiller si nécessaire
sudo usermod -U username
```

> [!warning] Limitation Le verrouillage empêche l'authentification par mot de passe mais **PAS** l'authentification par clé SSH !

#### Désactiver complètement l'accès SSH

```bash
# Changer le shell en nologin
sudo usermod -s /usr/sbin/nologin username

# Alternative : changer en /bin/false
sudo usermod -s /bin/false username

# Vérifier
getent passwd username
```

**Différence entre nologin et false :**

- `/usr/sbin/nologin` : Affiche un message avant de refuser
- `/bin/false` : Refuse silencieusement

### ❌ Suppression définitive d'accès

#### Retirer les clés SSH

```bash
# Supprimer toutes les clés autorisées
sudo rm /home/username/.ssh/authorized_keys

# Ou vider le fichier
sudo truncate -s 0 /home/username/.ssh/authorized_keys

# Supprimer une clé spécifique (éditer le fichier)
sudo nano /home/username/.ssh/authorized_keys
# Supprimer la ligne correspondante
```

#### Supprimer l'utilisateur

```bash
# Supprimer l'utilisateur en gardant son home
sudo userdel username

# Supprimer l'utilisateur ET son répertoire home
sudo userdel -r username

# Forcer la suppression même si connecté
sudo userdel -f username

# Vérifier que l'utilisateur est supprimé
getent passwd username
# Aucun résultat = supprimé
```

> [!tip] Bonne pratique Avant de supprimer un compte, archivez son répertoire home pour conserver les données et logs :
> 
> ```bash
> sudo tar -czf /backup/username-$(date +%Y%m%d).tar.gz /home/username
> sudo userdel -r username
> ```

### 🔒 Révocation dans des configurations avancées

#### Retirer des groupes SSH

```bash
# Retirer d'un groupe spécifique
sudo gpasswd -d username ssh-users

# Vérifier les groupes restants
groups username

# Retirer de TOUS les groupes secondaires
sudo usermod -G "" username
```

#### Révocation avec DenyUsers

```bash
# Éditer /etc/ssh/sshd_config
sudo nano /etc/ssh/sshd_config

# Ajouter l'utilisateur à la liste
DenyUsers username compromised_user

# Redémarrer SSH
sudo systemctl restart sshd
```

> [!info] Avantage Cette méthode empêche immédiatement l'accès sans modifier le compte utilisateur. Utile pour une révocation temporaire ou d'urgence.

### 🚨 Révocation d'urgence (compromission)

#### Procédure complète

```bash
# 1. Bloquer immédiatement l'accès SSH
echo "DenyUsers username" | sudo tee -a /etc/ssh/sshd_config
sudo systemctl restart sshd

# 2. Verrouiller le compte
sudo usermod -L username
sudo usermod -s /usr/sbin/nologin username

# 3. Terminer toutes les sessions actives
sudo pkill -u username
sudo pkill -9 -u username  # Force kill si nécessaire

# 4. Vérifier qu'aucune session n'est active
who | grep username
ps aux | grep "^username"

# 5. Supprimer les clés SSH
sudo rm -rf /home/username/.ssh/

# 6. Audit des actions récentes
sudo lastlog -u username
sudo last username
sudo grep username /var/log/auth.log
```

### 📋 Checklist de révocation

> [!example] Liste de contrôle
> 
> - [ ] Ajouter à `DenyUsers` dans sshd_config
> - [ ] Redémarrer le service SSH
> - [ ] Verrouiller le compte avec `usermod -L`
> - [ ] Changer le shell en `/usr/sbin/nologin`
> - [ ] Terminer les sessions actives avec `pkill`
> - [ ] Supprimer ou vider `~/.ssh/authorized_keys`
> - [ ] Retirer des groupes SSH pertinents
> - [ ] Archiver le répertoire home si nécessaire
> - [ ] Documenter la révocation (qui, quand, pourquoi)
> - [ ] Auditer les logs pour détecter d'éventuels accès suspects

### 🔐 Révocation de clés spécifiques

#### Identifier une clé compromise

```bash
# Afficher toutes les clés avec empreintes
ssh-keygen -lf /home/username/.ssh/authorized_keys

# Exemple de sortie :
# 2048 SHA256:xxxxxxxxxxxxx user@machine (RSA)
# 4096 SHA256:yyyyyyyyyyyyy user@laptop (RSA)
```

#### Supprimer une clé spécifique

```bash
# Éditer le fichier
sudo nano /home/username/.ssh/authorized_keys

# Ou utiliser sed pour supprimer par pattern
sudo sed -i '/user@machine/d' /home/username/.ssh/authorized_keys

# Vérifier
cat /home/username/.ssh/authorized_keys
```

### 📊 Audit post-révocation

```bash
# Vérifier les dernières connexions
sudo last username | head -20

# Vérifier les tentatives d'authentification
sudo grep "username" /var/log/auth.log | tail -50

# Sur systemd
sudo journalctl -u sshd | grep username | tail -50

# Vérifier les fichiers récemment modifiés
sudo find /home/username -type f -mtime -7 -ls

# Vérifier les processus toujours actifs
ps aux | grep "^username"
```

### 🔄 Réactivation d'un compte

Si besoin de réactiver un accès précédemment révoqué :

```bash
# 1. Retirer de DenyUsers
sudo nano /etc/ssh/sshd_config
# Commenter ou supprimer la ligne

# 2. Redémarrer SSH
sudo systemctl restart sshd

# 3. Déverrouiller le compte
sudo usermod -U username

# 4. Restaurer un shell valide
sudo usermod -s /bin/bash username

# 5. Régénérer ou restaurer les clés SSH
sudo -u username ssh-keygen -t ed25519 -f /home/username/.ssh/id_ed25519

# 6. Réajouter aux groupes nécessaires
sudo usermod -aG ssh-users username
```

### 🛡️ Bonnes pratiques de révocation

> [!tip] Recommandations
> 
> - **Révocation immédiate** : Ne pas attendre pour révoquer un accès compromis ou inutile
> - **Documentation** : Tenir un registre des révocations (qui, quand, raison)
> - **Processus automatisé** : Créer des scripts pour standardiser la révocation
> - **Audit régulier** : Vérifier mensuellement les comptes actifs et supprimer les inutilisés
> - **Notifications** : Alerter l'équipe de sécurité lors de révocations d'urgence
> - **Double vérification** : Toujours vérifier qu'aucune session n'est active après révocation

### 🔍 Script de révocation automatisé

```bash
#!/bin/bash
# revoke_ssh_access.sh - Révocation complète

if [ $# -ne 1 ]; then
    echo "Usage: $0 username"
    exit 1
fi

USERNAME=$1

echo "=== Révocation d'accès SSH pour $USERNAME ==="

# 1. Ajouter à DenyUsers
echo "DenyUsers $USERNAME" | sudo tee -a /etc/ssh/sshd_config
sudo systemctl restart sshd
echo "✓ Ajouté à DenyUsers"

# 2. Verrouiller le compte
sudo usermod -L "$USERNAME"
sudo usermod -s /usr/sbin/nologin "$USERNAME"
echo "✓ Compte verrouillé"

# 3. Terminer les sessions
sudo pkill -u "$USERNAME"
sleep 2
sudo pkill -9 -u "$USERNAME" 2>/dev/null
echo "✓ Sessions terminées"

# 4. Supprimer les clés
sudo rm -f "/home/$USERNAME/.ssh/authorized_keys"
echo "✓ Clés SSH supprimées"

# 5. Vérification finale
if ps aux | grep "^$USERNAME" > /dev/null 2>&1; then
    echo "⚠ ATTENTION : Processus toujours actifs pour $USERNAME"
else
    echo "✓ Aucun processus actif"
fi

echo ""
echo "=== Révocation terminée pour $USERNAME ==="
echo "N'oubliez pas de documenter cette action !"
```

---

## 🎓 Résumé des bonnes pratiques

> [!tip] Points clés à retenir
> 
> **Création de comptes :**
> 
> - Un compte par personne, jamais de partage
> - Permissions strictes : 700 pour `.ssh`, 600 pour les fichiers
> - Privilégier l'authentification par clé
> 
> **Restrictions d'accès :**
> 
> - Appliquer le principe de moindre privilège
> - Utiliser `AllowUsers`/`AllowGroups` plutôt que tout autoriser
> - Désactiver root ou limiter à `prohibit-password`
> - Combiner restrictions IP et groupes pour une défense en profondeur
> 
> **Gestion par groupes :**
> 
> - Organiser les utilisateurs par rôles et responsabilités
> - Définir des politiques cohérentes par groupe
> - Auditer régulièrement les appartenances
> 
> **Révocation :**
> 
> - Révoquer immédiatement en cas de départ ou compromission
> - Suivre une procédure complète et documentée
> - Vérifier l'absence de sessions actives
> - Conserver les logs pour audit post-incident

---

_📚 Ce document couvre la gestion des utilisateurs et des accès SSH. Pour une sécurité complète, ces pratiques doivent être combinées avec d'autres mesures de sécurité SSH._