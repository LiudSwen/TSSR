

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

## 🔑 Politique de gestion des clés

### Qu'est-ce qu'une politique de gestion des clés ?

Une politique de gestion des clés SSH définit l'ensemble des règles, processus et responsabilités concernant le cycle de vie complet des clés SSH dans une organisation : création, stockage, utilisation, rotation et révocation.

> [!info] Pourquoi c'est crucial Les clés SSH sont des secrets d'authentification aussi sensibles que des mots de passe. Sans politique claire, vous risquez :
> 
> - Des clés orphelines (utilisateurs partis, clés restantes)
> - Une compromission difficile à détecter
> - Une absence de traçabilité
> - Une prolifération incontrôlée des accès

### Éléments essentiels d'une politique

#### 1. Standardisation des types de clés

Définissez des standards clairs pour l'organisation :

```bash
# Standard recommandé en 2024/2025
ssh-keygen -t ed25519 -C "utilisateur@domaine.com"

# Alternative pour systèmes legacy
ssh-keygen -t rsa -b 4096 -C "utilisateur@domaine.com"
```

> [!warning] Clés interdites Bannissez explicitement :
> 
> - RSA < 2048 bits
> - DSA (vulnérable)
> - ECDSA (risques backdoor NSA)

#### 2. Convention de nommage

Adoptez une convention claire et systématique :

```bash
# Format recommandé : type_environnement_utilisateur_date
~/.ssh/id_ed25519_prod_jdupont_2025-01
~/.ssh/id_ed25519_dev_jdupont_2025-01
~/.ssh/id_ed25519_backup_server_2025-01
```

**Avantages** :

- Identification rapide du contexte d'usage
- Facilite l'audit et le nettoyage
- Évite les confusions entre environnements

#### 3. Protection par passphrase

```bash
# Création avec passphrase obligatoire
ssh-keygen -t ed25519 -C "admin@entreprise.com"
# Entrez une passphrase forte (20+ caractères)

# Vérifier qu'une clé a une passphrase
ssh-keygen -y -f ~/.ssh/id_ed25519
# Si pas de passphrase = demande directement la clé publique
# Si passphrase = demande d'abord la passphrase
```

> [!tip] Agent SSH pour la convivialité Utilisez `ssh-agent` pour ne saisir la passphrase qu'une fois par session :
> 
> ```bash
> eval $(ssh-agent)
> ssh-add ~/.ssh/id_ed25519
> # Saisir la passphrase une seule fois
> ```

#### 4. Registre centralisé des clés

Maintenez un inventaire actualisé :

|Utilisateur|Clé publique|Serveurs autorisés|Date création|Expiration|Responsable|
|---|---|---|---|---|---|
|j.dupont|SHA256:abc...|prod-web-01, prod-db-01|2025-01-15|2026-01-15|IT Manager|
|m.martin|SHA256:def...|dev-app-01|2025-02-01|2025-08-01|Dev Lead|

**Outils recommandés** :

- Tableau Excel/Google Sheets pour les petites structures
- HashiCorp Vault pour les grandes organisations
- Solutions spécialisées : SSH.COM Universal SSH Key Manager

#### 5. Processus de déploiement

**Workflow standardisé** :

```bash
# 1. Génération par l'utilisateur
ssh-keygen -t ed25519 -C "nom.prenom@entreprise.com"

# 2. Transmission sécurisée de la clé publique
# JAMAIS par email non chiffré !
# Options : ticket système, plateforme sécurisée, en personne

# 3. Validation par l'administrateur
cat cle_publique_recue.pub >> /etc/ssh/cles_validees.txt

# 4. Déploiement sur les serveurs autorisés
ssh admin@serveur "echo 'ssh-ed25519 AAAA...' >> ~/.ssh/authorized_keys"

# 5. Test par l'utilisateur
ssh utilisateur@serveur

# 6. Enregistrement dans le registre
```

> [!warning] Pièges courants
> 
> - **Ne jamais** partager les clés privées
> - **Ne jamais** stocker les clés privées sur des serveurs
> - **Ne jamais** utiliser la même paire pour tous les environnements
> - **Ne jamais** générer les clés côté serveur pour les utilisateurs

### Stockage sécurisé des clés

#### Protection des clés privées

```bash
# Permissions correctes (lecture seule pour le propriétaire)
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub

# Vérification des permissions
ls -la ~/.ssh/
# Doit afficher : -rw------- pour les clés privées
```

#### Options de stockage avancées

**1. Stockage chiffré du disque**

```bash
# Vérifier le chiffrement du disque (Linux)
lsblk -f | grep crypto

# Vérifier FileVault (macOS)
fdesetup status
```

**2. Tokens matériels (YubiKey, etc.)**

```bash
# Générer une clé sur YubiKey
ssh-keygen -t ed25519-sk -C "utilisateur@entreprise.com"

# La clé privée reste dans le token matériel
# Impossible de l'extraire
```

**3. Gestionnaires de secrets d'entreprise**

- AWS Secrets Manager
- Azure Key Vault
- HashiCorp Vault
- CyberArk

### Documentation obligatoire

Chaque politique doit inclure :

1. **Procédures** : comment créer, déployer, révoquer une clé
2. **Responsabilités** : qui fait quoi
3. **Exceptions** : comment gérer les cas particuliers
4. **Sanctions** : conséquences du non-respect
5. **Formation** : onboarding des nouveaux utilisateurs

---

## 🔄 Rotation des clés

### Pourquoi faire tourner les clés SSH ?

> [!info] Principe de sécurité fondamental La rotation des clés limite la fenêtre d'exposition en cas de compromission. Une clé compromise depuis 3 ans donne 3 ans d'accès rétroactif aux logs. Une clé de 3 mois limite les dégâts.

**Scénarios de compromission** :

- Clé copiée par malware
- Backup non chiffré volé
- Employé malveillant qui part avec une copie
- Clé commitée accidentellement sur GitHub
- Ordinateur portable volé

### Stratégie de rotation

#### Fréquences recommandées

|Type d'accès|Fréquence|Justification|
|---|---|---|
|Accès production critique|3-6 mois|Risque élevé, impact majeur|
|Accès production standard|6-12 mois|Équilibre sécurité/praticité|
|Accès développement|12 mois|Risque modéré|
|Clés administrateur|1-3 mois|Privilèges élevés|
|Clés de service/automation|6 mois|Difficile à changer mais critique|

> [!tip] Astuce pro Alignez les rotations avec d'autres cycles : revues trimestrielles, audits annuels, périodes budgétaires. Cela facilite l'adoption.

#### Processus de rotation

**Méthode avec période de chevauchement** (recommandée) :

```bash
# === PHASE 1 : Génération nouvelle clé ===
ssh-keygen -t ed25519 -C "utilisateur@entreprise.com" -f ~/.ssh/id_ed25519_new

# === PHASE 2 : Ajout de la nouvelle clé (sans supprimer l'ancienne) ===
# Sur chaque serveur
ssh utilisateur@serveur
cat >> ~/.ssh/authorized_keys << 'EOF'
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINouvelleClé... utilisateur@entreprise.com
EOF

# === PHASE 3 : Test de la nouvelle clé ===
ssh -i ~/.ssh/id_ed25519_new utilisateur@serveur
# Vérifier que ça fonctionne !

# === PHASE 4 : Mise à jour config locale ===
# Modifier ~/.ssh/config pour utiliser la nouvelle clé par défaut
Host serveur
    HostName serveur.exemple.com
    User utilisateur
    IdentityFile ~/.ssh/id_ed25519_new

# === PHASE 5 : Période de transition (1-2 semaines) ===
# Les deux clés fonctionnent en parallèle
# Permet de détecter les problèmes

# === PHASE 6 : Suppression ancienne clé ===
# Sur chaque serveur, retirer l'ancienne ligne de authorized_keys
ssh utilisateur@serveur
nano ~/.ssh/authorized_keys
# Supprimer la ligne avec l'ancienne clé

# === PHASE 7 : Archivage sécurisé ===
# Garder trace mais rendre inutilisable
mkdir -p ~/.ssh/archived
mv ~/.ssh/id_ed25519 ~/.ssh/archived/id_ed25519_2024_archived
chmod 000 ~/.ssh/archived/id_ed25519_2024_archived
```

> [!warning] Erreur fatale Ne JAMAIS supprimer l'ancienne clé avant d'avoir vérifié que la nouvelle fonctionne partout. Vous pourriez vous retrouver sans accès !

#### Automatisation de la rotation

**Script de rotation semi-automatisé** :

```bash
#!/bin/bash
# rotate_ssh_keys.sh

set -euo pipefail

USER="admin"
KEY_NAME="id_ed25519"
SERVERS_FILE="/etc/ssh/servers_list.txt"

echo "=== Rotation des clés SSH ==="

# 1. Génération nouvelle clé
echo "Génération de la nouvelle clé..."
ssh-keygen -t ed25519 -C "${USER}@$(hostname)" -f ~/.ssh/${KEY_NAME}_new -N ""

# 2. Déploiement sur tous les serveurs
echo "Déploiement sur les serveurs..."
while IFS= read -r server; do
    echo "  -> $server"
    ssh-copy-id -i ~/.ssh/${KEY_NAME}_new.pub ${USER}@${server}
done < "$SERVERS_FILE"

# 3. Tests
echo "Test des connexions..."
while IFS= read -r server; do
    if ssh -i ~/.ssh/${KEY_NAME}_new -o BatchMode=yes -o ConnectTimeout=5 ${USER}@${server} "echo OK" &>/dev/null; then
        echo "  ✓ $server"
    else
        echo "  ✗ $server - ÉCHEC!"
        exit 1
    fi
done < "$SERVERS_FILE"

# 4. Renommage (l'ancienne devient _old, la nouvelle devient active)
mv ~/.ssh/${KEY_NAME} ~/.ssh/${KEY_NAME}_old
mv ~/.ssh/${KEY_NAME}_new ~/.ssh/${KEY_NAME}
mv ~/.ssh/${KEY_NAME}.pub ~/.ssh/${KEY_NAME}_old.pub
mv ~/.ssh/${KEY_NAME}_new.pub ~/.ssh/${KEY_NAME}.pub

echo "✓ Rotation terminée avec succès"
echo "! Pensez à supprimer les anciennes clés des serveurs après période de test"
```

#### Rotation des clés de service

Les clés utilisées par des scripts/services nécessitent une approche différente :

```bash
# Approche "double clé" pour zéro downtime

# 1. Le service charge deux clés
Host backup-server
    IdentityFile ~/.ssh/service_key_current
    IdentityFile ~/.ssh/service_key_next

# 2. Déployer service_key_next partout
# 3. Attendre 1 cycle complet (ex: 24h pour backup quotidien)
# 4. Vérifier que service_key_next fonctionne dans les logs
# 5. Supprimer service_key_current des serveurs
# 6. Renommer : service_key_next devient service_key_current
```

### Traçabilité de la rotation

Loggez chaque rotation :

```bash
# Exemple de log
echo "$(date -Iseconds),${USER},key_rotation,${KEY_FINGERPRINT},success" >> /var/log/ssh_key_rotation.log

# Format : timestamp,utilisateur,action,empreinte_clé,statut
```

---

## 🔍 Audit régulier des accès

### Objectifs de l'audit

Un audit SSH vise à répondre à :

- **Qui** a accès à **quoi** ?
- Les accès sont-ils **justifiés** et **à jour** ?
- Y a-t-il des **anomalies** (accès suspects, clés orphelines) ?
- Les **bonnes pratiques** sont-elles respectées ?

> [!info] Fréquence recommandée
> 
> - **Audit léger** : mensuel (vérification automatisée)
> - **Audit approfondi** : trimestriel (revue manuelle)
> - **Audit de crise** : après un incident de sécurité

### Audit des clés autorisées

#### Inventaire des authorized_keys

```bash
# Script d'audit : lister toutes les clés SSH sur un serveur
#!/bin/bash

echo "=== Audit des clés SSH autorisées ==="
echo "Serveur : $(hostname)"
echo "Date : $(date)"
echo ""

for user_home in /home/*; do
    user=$(basename "$user_home")
    auth_keys="$user_home/.ssh/authorized_keys"
    
    if [[ -f "$auth_keys" ]]; then
        echo "--- Utilisateur : $user ---"
        
        # Compter les clés
        key_count=$(grep -v "^#" "$auth_keys" | grep -v "^$" | wc -l)
        echo "Nombre de clés : $key_count"
        
        # Afficher les clés avec leur commentaire et empreinte
        while IFS= read -r key; do
            if [[ ! "$key" =~ ^# ]] && [[ -n "$key" ]]; then
                # Extraire le commentaire (dernier champ)
                comment=$(echo "$key" | awk '{print $NF}')
                
                # Calculer l'empreinte
                fingerprint=$(echo "$key" | ssh-keygen -lf - 2>/dev/null | awk '{print $2}')
                
                echo "  - Empreinte: $fingerprint"
                echo "    Commentaire: $comment"
                
                # Détecter les clés suspectes
                if [[ -z "$comment" ]]; then
                    echo "    ⚠️  WARNING: Pas de commentaire"
                fi
            fi
        done < "$auth_keys"
        
        # Vérifier les permissions
        perms=$(stat -c "%a" "$auth_keys")
        if [[ "$perms" != "600" ]] && [[ "$perms" != "644" ]]; then
            echo "  ⚠️  WARNING: Permissions incorrectes ($perms)"
        fi
        
        echo ""
    fi
done

# Audit du compte root séparément
if [[ -f "/root/.ssh/authorized_keys" ]]; then
    echo "--- Utilisateur : root (⚠️  ACCÈS CRITIQUE) ---"
    key_count=$(grep -v "^#" /root/.ssh/authorized_keys | grep -v "^$" | wc -l)
    echo "Nombre de clés : $key_count"
    
    while IFS= read -r key; do
        if [[ ! "$key" =~ ^# ]] && [[ -n "$key" ]]; then
            fingerprint=$(echo "$key" | ssh-keygen -lf - 2>/dev/null | awk '{print $2}')
            comment=$(echo "$key" | awk '{print $NF}')
            echo "  - $fingerprint ($comment)"
        fi
    done < /root/.ssh/authorized_keys
fi
```

#### Détection des clés orphelines

```bash
# Clés d'utilisateurs qui n'existent plus dans l'organisation
#!/bin/bash

# Liste des utilisateurs actuels de l'AD/LDAP
ACTIVE_USERS="/tmp/active_users.txt"
ldapsearch -x -LLL "(&(objectClass=user)(mail=*))" sAMAccountName | \
    grep "sAMAccountName:" | awk '{print $2}' > "$ACTIVE_USERS"

# Parcourir les authorized_keys et détecter les orphelins
for user_home in /home/*; do
    user=$(basename "$user_home")
    auth_keys="$user_home/.ssh/authorized_keys"
    
    if [[ -f "$auth_keys" ]]; then
        while IFS= read -r key; do
            comment=$(echo "$key" | awk '{print $NF}')
            # Extraire le nom d'utilisateur du commentaire (ex: jean.dupont@entreprise.com)
            key_owner=$(echo "$comment" | cut -d'@' -f1)
            
            if ! grep -q "^${key_owner}$" "$ACTIVE_USERS"; then
                echo "⚠️  CLÉ ORPHELINE détectée !"
                echo "   Serveur: $(hostname)"
                echo "   Compte système: $user"
                echo "   Propriétaire supposé: $key_owner (INTROUVABLE dans l'AD)"
                echo "   Empreinte: $(echo "$key" | ssh-keygen -lf -)"
                echo ""
            fi
        done < <(grep -v "^#" "$auth_keys" | grep -v "^$")
    fi
done
```

### Audit des connexions

#### Analyse des logs SSH

```bash
# Extraire les connexions des 30 derniers jours
#!/bin/bash

echo "=== Rapport de connexions SSH (30 derniers jours) ==="

# Sous Linux (auth.log)
LOG_FILE="/var/log/auth.log"

# Connexions réussies
echo "--- Connexions réussies ---"
grep "Accepted publickey" "$LOG_FILE" | \
    awk '{print $1, $2, $3, $9, $11}' | \
    sort | uniq -c | sort -rn | head -20

echo ""
echo "--- Tentatives échouées ---"
grep "Failed password\|Invalid user" "$LOG_FILE" | \
    awk '{print $1, $2, $3, $11}' | \
    sort | uniq -c | sort -rn | head -20

echo ""
echo "--- Connexions en dehors des heures ouvrables ---"
# Connexions entre 20h et 6h ou le weekend
grep "Accepted publickey" "$LOG_FILE" | \
    awk '{
        hour=substr($3, 1, 2);
        if (hour < 6 || hour > 20) print $0
    }' | tail -10
```

> [!tip] Outils d'analyse de logs
> 
> - **fail2ban** : bannit automatiquement les IP après X échecs
> - **logwatch** : rapports quotidiens par email
> - **OSSEC/Wazuh** : SIEM open-source pour détection d'intrusions
> - **Splunk/ELK** : solutions enterprise pour grandes infrastructures

#### Détection d'anomalies

```bash
# Détecter les comportements suspects

# 1. Connexions depuis des pays inhabituels
# (nécessite geoip)
grep "Accepted publickey" /var/log/auth.log | \
    awk '{print $11}' | sort -u | \
    xargs -I{} geoiplookup {} | grep -v "France\|Belgium\|Switzerland"

# 2. Connexions en dehors des plages IP autorisées
ALLOWED_RANGES="10.0.0.0/8 192.168.0.0/16"
grep "Accepted publickey" /var/log/auth.log | \
    awk '{print $11}' | sort -u | while read ip; do
        # Vérifier si l'IP est dans une plage autorisée
        # (script simplifié, utiliser un outil comme ipcalc en production)
        echo "Vérifier : $ip"
    done

# 3. Usage de clés rarement utilisées
# (pourrait indiquer une compromission)
ssh-keygen -lf /home/*/.ssh/authorized_keys 2>/dev/null | \
    awk '{print $2}' | sort | uniq > /tmp/all_keys.txt

grep "Accepted publickey" /var/log/auth.log | \
    grep -oP 'SHA256:[a-zA-Z0-9/+]+' | sort | uniq -c | sort -n | head -5
```

### Audit de configuration

#### Vérification de sshd_config

```bash
# Script pour auditer la configuration SSH serveur
#!/bin/bash

echo "=== Audit de configuration SSH ==="

CONFIG="/etc/ssh/sshd_config"
WARNINGS=0

check_setting() {
    local setting=$1
    local expected=$2
    local current=$(grep "^${setting}" "$CONFIG" | awk '{print $2}')
    
    if [[ "$current" == "$expected" ]]; then
        echo "✓ $setting : $current"
    else
        echo "✗ $setting : $current (attendu: $expected)"
        ((WARNINGS++))
    fi
}

# Vérifications critiques
check_setting "PermitRootLogin" "no"
check_setting "PasswordAuthentication" "no"
check_setting "PubkeyAuthentication" "yes"
check_setting "PermitEmptyPasswords" "no"
check_setting "X11Forwarding" "no"
check_setting "MaxAuthTries" "3"

# Vérifier le chiffrement
echo ""
echo "--- Algorithmes de chiffrement ---"
ciphers=$(grep "^Ciphers" "$CONFIG" | cut -d' ' -f2-)
if echo "$ciphers" | grep -q "aes256-gcm"; then
    echo "✓ Chiffrement moderne détecté"
else
    echo "✗ Chiffrement faible ou absent"
    ((WARNINGS++))
fi

# Vérifier les restrictions d'utilisateurs
echo ""
echo "--- Restrictions d'accès ---"
if grep -q "^AllowUsers\|^AllowGroups" "$CONFIG"; then
    echo "✓ Restrictions par utilisateur/groupe activées"
    grep "^AllowUsers\|^AllowGroups" "$CONFIG"
else
    echo "⚠️  Aucune restriction d'accès (tous les utilisateurs peuvent se connecter)"
    ((WARNINGS++))
fi

echo ""
echo "=== Résumé : $WARNINGS avertissement(s) ==="
```

### Reporting et suivi

**Template de rapport d'audit** :

```markdown
# Rapport d'audit SSH - [Date]

## Résumé exécutif
- Serveurs audités : X
- Clés totales : Y
- Anomalies détectées : Z

## Détails par catégorie

### 🔴 Problèmes critiques
- [ ] 3 clés orphelines détectées (employés partis)
- [ ] 1 serveur avec PermitRootLogin=yes

### 🟡 Avertissements
- [ ] 5 clés sans commentaire
- [ ] 2 connexions depuis IP inconnues

### 🟢 Conformité
- ✓ Toutes les clés utilisent ED25519 ou RSA-4096
- ✓ Aucune connexion par mot de passe détectée

## Actions requises
1. Révoquer les 3 clés orphelines (priorité haute)
2. Désactiver PermitRootLogin sur prod-web-03
3. Contacter les propriétaires des clés sans commentaire

## Suivi
- Prochain audit : [Date + 3 mois]
- Responsable : [Nom]
```

---

## 🛡️ Principe du moindre privilège

### Définition et importance

> [!info] Principe de base Chaque utilisateur, processus ou système ne doit avoir accès qu'aux ressources strictement nécessaires à sa fonction. Pas plus, pas moins.

**Appliqué à SSH** :

- Limiter les serveurs accessibles par utilisateur
- Limiter les commandes exécutables
- Limiter les transferts de fichiers
- Limiter les horaires de connexion

**Bénéfices** :

- ⬇️ Réduction de la surface d'attaque
- 🛡️ Limitation des dégâts en cas de compromission
- 📊 Meilleure traçabilité
- ✅ Conformité réglementaire (ISO 27001, RGPD, etc.)

### Restriction d'accès par utilisateur

#### Utilisation de AllowUsers et AllowGroups

```bash
# Dans /etc/ssh/sshd_config

# Méthode 1 : Liste explicite d'utilisateurs
AllowUsers admin bob alice@192.168.1.* devops@10.0.0.0/8

# Méthode 2 : Groupes (recommandé pour grandes organisations)
AllowGroups ssh-users ssh-admins

# Combinaison avec DenyUsers/DenyGroups
DenyUsers guest temp-*
DenyGroups disabled-accounts

# Redémarrer SSH après modification
sudo systemctl reload sshd
```

**Créer des groupes SSH** :

```bash
# Créer un groupe pour les accès SSH
sudo groupadd ssh-users
sudo groupadd ssh-admins

# Ajouter des utilisateurs
sudo usermod -aG ssh-users alice
sudo usermod -aG ssh-admins bob

# Vérifier l'appartenance
groups alice
# alice : alice ssh-users
```

> [!tip] Bonne pratique Utilisez des groupes plutôt que des listes d'utilisateurs. C'est plus maintenable et plus clair.

#### Restrictions par bloc Match

```bash
# Dans /etc/ssh/sshd_config

# Règles globales strictes
PermitRootLogin no
PasswordAuthentication no

# Exceptions ciblées pour les admins depuis le réseau interne
Match Group ssh-admins Address 10.0.0.0/8
    PermitRootLogin prohibit-password
    X11Forwarding yes

# Restrictions pour les développeurs
Match Group developers
    AllowTcpForwarding no
    X11Forwarding no
    PermitTunnel no
    
# Restrictions pour les comptes de backup
Match User backup-agent
    ForceCommand /usr/local/bin/backup-only.sh
    AllowTcpForwarding no
```

### Restriction des commandes

#### ForceCommand pour limiter les actions

```bash
# Forcer un utilisateur à n'exécuter qu'un script spécifique
Match User backup-user
    ForceCommand /usr/local/bin/backup.sh

# Le script backup.sh
#!/bin/bash
# L'utilisateur ne peut rien faire d'autre que ce backup
rsync -avz /data/ backup-user@backup-server:/backups/
```

#### Utilisation de authorized_keys avec restrictions

```bash
# Dans ~/.ssh/authorized_keys, AVANT la clé publique :

# Restreindre aux commandes rsync seulement
command="/usr/bin/rsync --server --daemon .",no-port-forwarding,no-X11-forwarding,no-agent-forwarding ssh-ed25519 AAAAC3...

# Permettre uniquement les commandes Git
command="/usr/bin/git-shell -c \"$SSH_ORIGINAL_COMMAND\"",no-port-forwarding,no-X11-forwarding ssh-ed25519 AAAAC3...

# Wrapper custom pour validation
command="/usr/local/bin/validate-command.sh",no-pty ssh-ed25519 AAAAC3...
```

**Script de validation de commandes** :

```bash
#!/bin/bash
# /usr/local/bin/validate-command.sh

# Liste des commandes autorisées
ALLOWED_COMMANDS=("ls" "cat" "grep" "tail" "head")

# Extraire la commande demandée
REQUESTED_CMD=$(echo "$SSH_ORIGINAL_COMMAND" | awk '{print $1}')

# Vérifier si autorisée
if [[ " ${ALLOWED_COMMANDS[@]} " =~ " ${REQUESTED_CMD} " ]]; then
    # Logger l'accès
    logger -t ssh-command "User $USER executed: $SSH_ORIGINAL_COMMAND"
    
    # Exécuter
    exec $SSH_ORIGINAL_COMMAND
else
    echo "Commande non autorisée : $REQUESTED_CMD"
    logger -t ssh-command "DENIED - User $USER tried: $SSH_ORIGINAL_COMMAND"
    exit 1
fi
```

### SFTP chrooté (chroot)

Restreindre les utilisateurs SFTP à leur répertoire home :

```bash
# Dans /etc/ssh/sshd_config

# Subsystème SFTP interne (plus sûr que sftp-server externe)
Subsystem sftp internal-sftp

# Configuration pour groupe sftp-only
Match Group sftp-only
    ChrootDirectory /home/%u
    ForceCommand internal-sftp
    AllowTcpForwarding no
    X11Forwarding no
    PermitTunnel no
```

**Préparer les répertoires pour chroot** :

```bash
# Créer un utilisateur SFTP
sudo useradd -m -d /home/sftp-user -s /sbin/nologin sftp-user
sudo groupadd sftp-only
sudo usermod -aG sftp-only sftp-user

# IMPORTANT : Le répertoire chroot doit appartenir à root
sudo chown root:root /home/sftp-user
sudo chmod 755 /home/sftp-user

# Créer un sous-répertoire pour les uploads (propriété utilisateur)
sudo mkdir /home/sftp-user/uploads
sudo chown sftp-user:sftp-user /home/sftp-user/uploads
sudo chmod 755 /home/sftp-user/uploads

# Tester le chroot
sudo systemctl restart sshd
sftp sftp-user@localhost
# L'utilisateur ne peut naviguer qu'dans /home/sftp-user
```

> [!warning] Erreurs courantes avec chroot
> 
> - Le répertoire chroot **doit** appartenir à root (pas à l'utilisateur)
> - Permissions du chroot : 755 ou plus restrictif
> - Les fichiers de l'utilisateur doivent être dans un **sous-répertoire**
> - Sinon : "fatal: bad ownership or modes for chroot"

### Restrictions par adresse IP

```bash
# Dans /etc/ssh/sshd_config

# Autoriser SSH uniquement depuis le réseau interne
Match Address 10.0.0.0/8,172.16.0.0/12,192.168.0.0/16
    PasswordAuthentication yes
    
Match Address !10.0.0.0/8,!172.16.0.0/12,!192.168.0.0/16
    PasswordAuthentication no
    AllowUsers admin-urgent

# Ou dans authorized_keys
from="192.168.1.0/24,10.0.0.5" ssh-ed25519 AAAAC3...
```

### Sudo et élévation de privilèges

Au lieu de donner accès root direct, utilisez sudo avec restrictions :

```bash
# /etc/sudoers.d/ssh-users

# Développeur peut redémarrer uniquement le service web
developer ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx
developer ALL=(ALL) NOPASSWD: /usr/bin/systemctl status nginx

# Opérateur peut lire les logs mais pas les modifier
operator ALL=(ALL) NOPASSWD: /usr/bin/tail /var/log/*
operator ALL=(ALL) NOPASSWD: /usr/bin/grep * /var/log/*
operator ALL=(ALL) NOPASSWD: /usr/bin/less /var/log/*

# Admin backup peut uniquement gérer les backups
backup-admin ALL=(ALL) NOPASSWD: /usr/local/bin/backup.sh
backup-admin ALL=(ALL) NOPASSWD: /usr/bin/rsync

# Toujours logger les commandes sudo
Defaults log_output
Defaults!/usr/bin/sudoreplay !log_output
```

> [!tip] Validation de sudoers Toujours utiliser `visudo` pour éditer les fichiers sudo :
> 
> ```bash
> sudo visudo -f /etc/sudoers.d/ssh-users
> # Détecte les erreurs de syntaxe avant sauvegarde
> ```

### Journalisation détaillée

Activer le logging verbeux pour les comptes à privilèges :

```bash
# Dans /etc/ssh/sshd_config
LogLevel VERBOSE

# Pour audit encore plus détaillé
Match Group ssh-admins
    LogLevel DEBUG2

# Logs des sessions (enregistrement de toutes les frappes)
# Nécessite module auditd
```

**Enregistrement de session avec script** :

```bash
# Dans ~/.ssh/authorized_keys ou dans un wrapper
command="script -q -a -f /var/log/ssh-sessions/$USER-$(date +%Y%m%d-%H%M%S).log -c 'bash -l'" ssh-ed25519 AAAAC3...
```

---

## 🏢 Séparation des environnements

### Pourquoi séparer les environnements ?

> [!info] Principe de défense en profondeur La séparation des environnements (dev, staging, production) crée des barrières de sécurité. Une compromission en développement ne doit pas permettre d'atteindre la production.

**Risques sans séparation** :

- Clé de dev compromise → accès production
- Erreur humaine (commande destructrice sur mauvais serveur)
- Malware sur poste développeur → propagation
- Données sensibles exposées en environnement de test

### Stratégie de séparation des clés

#### Une paire de clés par environnement

```bash
# Structure recommandée
~/.ssh/
├── id_ed25519_prod          # Production
├── id_ed25519_prod.pub
├── id_ed25519_staging       # Pré-production
├── id_ed25519_staging.pub
├── id_ed25519_dev           # Développement
├── id_ed25519_dev.pub
├── id_ed25519_personal      # Projets personnels
├── id_ed25519_personal.pub
└── config                   # Configuration centrale
```

**Générer les clés séparées** :

```bash
# Production (passphrase forte obligatoire)
ssh-keygen -t ed25519 -C "admin-prod@entreprise.com" -f ~/.ssh/id_ed25519_prod

# Staging
ssh-keygen -t ed25519 -C "admin-staging@entreprise.com" -f ~/.ssh/id_ed25519_staging

# Dev
ssh-keygen -t ed25519 -C "dev@entreprise.com" -f ~/.ssh/id_ed25519_dev
```

> [!warning] Règle d'or Une clé SSH ne doit **JAMAIS** avoir accès à plusieurs environnements. Pas d'exception.

#### Configuration SSH par environnement

```bash
# ~/.ssh/config

# ========== PRODUCTION (Rouge) ==========
Host prod-* *.prod.entreprise.com
    User admin
    IdentityFile ~/.ssh/id_ed25519_prod
    IdentitiesOnly yes
    # Sécurité maximale
    StrictHostKeyChecking yes
    UserKnownHostsFile ~/.ssh/known_hosts_prod
    # Alertes visuelles
    PermitLocalCommand yes
    LocalCommand echo -e "\033[41m\033[97m ENVIRONNEMENT PRODUCTION \033[0m"

Host prod-db-*
    User db-admin
    IdentityFile ~/.ssh/id_ed25519_prod
    Port 2222
    ProxyJump bastion-prod.entreprise.com

# ========== STAGING (Orange) ==========
Host staging-* *.staging.entreprise.com
    User admin
    IdentityFile ~/.ssh/id_ed25519_staging
    IdentitiesOnly yes
    StrictHostKeyChecking yes
    UserKnownHostsFile ~/.ssh/known_hosts_staging
    LocalCommand echo -e "\033[43m\033[30m ENVIRONNEMENT STAGING \033[0m"

# ========== DÉVELOPPEMENT (Vert) ==========
Host dev-* *.dev.entreprise.com localhost
    User developer
    IdentityFile ~/.ssh/id_ed25519_dev
    IdentitiesOnly yes
    StrictHostKeyChecking accept-new
    UserKnownHostsFile ~/.ssh/known_hosts_dev
    LocalCommand echo -e "\033[42m\033[30m ENVIRONNEMENT DEV \033[0m"

# ========== Projets personnels ==========
Host github.com gitlab.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes
```

> [!tip] Alertes visuelles Le `LocalCommand` affiche un bandeau coloré à la connexion :
> 
> - 🔴 Rouge = Production (danger)
> - 🟠 Orange = Staging (attention)
> - 🟢 Vert = Dev (sécurisé)

### Séparation réseau

#### Bastion hosts (Jump servers)

Les serveurs de production ne doivent pas être directement accessibles :

```bash
# Architecture recommandée :
# [Votre PC] → [Bastion Prod] → [Serveurs Prod]
#           → [Bastion Staging] → [Serveurs Staging]
#           → [Accès Direct] → [Serveurs Dev]

# Configuration avec ProxyJump
Host prod-web-01
    HostName 10.0.1.10
    User admin
    IdentityFile ~/.ssh/id_ed25519_prod
    ProxyJump bastion-prod.entreprise.com

Host bastion-prod.entreprise.com
    HostName bastion.prod.entreprise.com
    User bastion-user
    IdentityFile ~/.ssh/id_ed25519_prod
    Port 22
    # Le bastion peut avoir des restrictions supplémentaires
    ForwardAgent no
```

**Sécuriser le bastion** :

```bash
# Sur le serveur bastion : /etc/ssh/sshd_config

# Le bastion ne fait que relayer, pas de shell interactif
Match User bastion-user
    PermitTTY no
    X11Forwarding no
    PermitTunnel no
    AllowAgentForwarding no
    AllowTcpForwarding yes
    ForceCommand echo 'Bastion - Connexion relayée uniquement'

# Logging détaillé
LogLevel VERBOSE

# Restrictions par IP source
Match Address !203.0.113.0/24
    DenyUsers *
```

#### VPN et segmentation réseau

```bash
# Les environnements doivent être sur des VLANs/VPCs séparés

# Production : 10.0.0.0/16 (VPC isolé, accès VPN obligatoire)
# Staging : 10.1.0.0/16 (VPC séparé)
# Dev : 10.2.0.0/16 (accès plus ouvert)

# Règles firewall entre environnements
# Production → Staging : INTERDIT
# Production → Dev : INTERDIT
# Staging → Production : INTERDIT (sauf backup one-way)
# Dev → Production : INTERDIT
```

### Séparation des données

#### Copies de production vers staging/dev

```bash
# Script d'anonymisation pour staging/dev
#!/bin/bash

# JAMAIS de copie directe de prod → dev !
# Toujours anonymiser les données sensibles

# 1. Dump de production
pg_dump production_db > /tmp/prod_dump.sql

# 2. Anonymisation
sed -i 's/[a-zA-Z0-9._%+-]\+@[a-zA-Z0-9.-]\+\.[a-zA-Z]\{2,\}/anonyme@exemple.com/g' /tmp/prod_dump.sql

# Anonymiser les noms (remplacer par des données factices)
python3 /usr/local/bin/anonymize_data.py /tmp/prod_dump.sql

# 3. Import en staging
psql staging_db < /tmp/prod_dump.sql

# 4. Nettoyage
shred -vfz /tmp/prod_dump.sql
```

> [!warning] RGPD et données personnelles Copier des données de production vers dev/staging peut violer le RGPD. Anonymisez **toujours** les données personnelles.

### Gestion des secrets par environnement

#### Coffres-forts séparés

```bash
# Utiliser un gestionnaire de secrets avec séparation stricte

# Avec HashiCorp Vault
vault read secret/prod/ssh-keys
vault read secret/staging/ssh-keys
vault read secret/dev/ssh-keys

# Avec AWS Secrets Manager
aws secretsmanager get-secret-value --secret-id prod/ssh-key --region us-east-1
aws secretsmanager get-secret-value --secret-id staging/ssh-key --region us-west-2

# Avec Azure Key Vault
az keyvault secret show --vault-name prod-vault --name ssh-key
az keyvault secret show --vault-name staging-vault --name ssh-key
```

#### Variables d'environnement

```bash
# Ne JAMAIS hardcoder les chemins de clés dans les scripts

# ❌ MAUVAIS
ssh -i ~/.ssh/id_ed25519_prod admin@serveur

# ✅ BON
ssh -i "${SSH_KEY_PROD}" admin@serveur

# Définir les variables selon l'environnement
export SSH_KEY_PROD=~/.ssh/id_ed25519_prod
export SSH_KEY_STAGING=~/.ssh/id_ed25519_staging
export SSH_KEY_DEV=~/.ssh/id_ed25519_dev
```

### Politique de déploiement

#### Workflow de promotion du code

```bash
# Déploiement doit toujours suivre ce chemin :
# Dev → Staging → Production
# JAMAIS : Dev → Production directement

# Exemple avec Git et clés SSH séparées

# 1. Développement
git clone git@github.com:entreprise/app.git
# Utilise automatiquement id_ed25519_personal (voir config SSH)

# 2. Déploiement en dev
ssh dev-app-01 "cd /app && git pull && systemctl restart app"
# Utilise id_ed25519_dev

# 3. Merge vers staging (après tests)
git checkout staging
git merge develop
git push origin staging

# 4. Déploiement en staging
ssh staging-app-01 "cd /app && git pull && systemctl restart app"
# Utilise id_ed25519_staging

# 5. Validation en staging (tests complets)

# 6. Merge vers production (après validation)
git checkout main
git merge staging
git push origin main

# 7. Déploiement en production (avec approbation)
ssh prod-app-01 "cd /app && git pull && systemctl restart app"
# Utilise id_ed25519_prod
```

### Audit de la séparation

#### Vérifier qu'aucune clé n'a accès multi-environnements

```bash
#!/bin/bash
# check_key_separation.sh

echo "=== Audit de séparation des environnements ==="

# Extraire les empreintes de toutes les clés locales
declare -A key_fingerprints

for keyfile in ~/.ssh/id_*; do
    [[ -f "$keyfile" ]] || continue
    [[ "$keyfile" == *.pub ]] && continue
    
    fingerprint=$(ssh-keygen -lf "$keyfile" 2>/dev/null | awk '{print $2}')
    key_fingerprints["$keyfile"]="$fingerprint"
done

# Vérifier sur tous les serveurs
PROD_SERVERS="prod-web-01 prod-db-01"
STAGING_SERVERS="staging-app-01"
DEV_SERVERS="dev-web-01 dev-db-01"

echo "Analyse des clés déployées..."

for keyfile in "${!key_fingerprints[@]}"; do
    fingerprint="${key_fingerprints[$keyfile]}"
    echo ""
    echo "Clé : $keyfile ($fingerprint)"
    
    found_in_prod=0
    found_in_staging=0
    found_in_dev=0
    
    # Chercher dans prod
    for server in $PROD_SERVERS; do
        if ssh "$server" "grep -q '$fingerprint' ~/.ssh/authorized_keys" 2>/dev/null; then
            echo "  ✓ Trouvée en PRODUCTION ($server)"
            found_in_prod=1
        fi
    done
    
    # Chercher dans staging
    for server in $STAGING_SERVERS; do
        if ssh "$server" "grep -q '$fingerprint' ~/.ssh/authorized_keys" 2>/dev/null; then
            echo "  ✓ Trouvée en STAGING ($server)"
            found_in_staging=1
        fi
    done
    
    # Chercher dans dev
    for server in $DEV_SERVERS; do
        if ssh "$server" "grep -q '$fingerprint' ~/.ssh/authorized_keys" 2>/dev/null; then
            echo "  ✓ Trouvée en DEV ($server)"
            found_in_dev=1
        fi
    done
    
    # Détecter les violations
    total=$((found_in_prod + found_in_staging + found_in_dev))
    if [ $total -gt 1 ]; then
        echo "  🚨 VIOLATION : Cette clé a accès à plusieurs environnements !"
    fi
done
```

### Restrictions organisationnelles

#### Matrice d'accès

|Rôle|Dev|Staging|Production|
|---|---|---|---|
|Développeur|✅ Lecture/Écriture|❌|❌|
|DevOps|✅ Lecture/Écriture|✅ Lecture/Écriture|✅ Lecture uniquement|
|Admin Sys|✅ Lecture|✅ Lecture/Écriture|✅ Lecture/Écriture|
|Manager|❌|✅ Lecture|✅ Lecture|
|Support N1|✅ Lecture|❌|❌|

> [!tip] Implémentation Utilisez les groupes LDAP/AD mappés aux groupes SSH pour automatiser ces restrictions.

#### Procédure d'accès d'urgence à la production

```bash
# Breakglass procedure (bris de glace)

# 1. Clé d'urgence stockée dans un coffre physique
# 2. Procédure documentée et approuvée
# 3. Nécessite 2 personnes (séparation des devoirs)

# Script de demande d'accès d'urgence
#!/bin/bash

echo "🚨 ACCÈS D'URGENCE À LA PRODUCTION 🚨"
echo "Cette action est loggée et auditée."
echo ""
read -p "Votre nom : " name
read -p "Raison de l'accès : " reason
read -p "Numéro de ticket : " ticket

# Logger la demande
logger -t emergency-access "USER=$name REASON=$reason TICKET=$ticket"

# Notification aux admins
mail -s "🚨 Accès d'urgence demandé" admins@entreprise.com <<EOF
Utilisateur : $name
Raison : $reason
Ticket : $ticket
Heure : $(date)
EOF

echo "Demande enregistrée. En attente d'approbation..."
```

---

## 🎯 Synthèse et checklist

### Checklist de sécurité SSH

> [!example] Checklist complète

**Politique de gestion des clés :**

- [ ] Types de clés standardisés (ED25519 recommandé)
- [ ] Convention de nommage appliquée
- [ ] Passphrases obligatoires sur les clés sensibles
- [ ] Registre centralisé des clés maintenu à jour
- [ ] Processus de déploiement documenté
- [ ] Stockage sécurisé (chiffrement disque minimum)

**Rotation des clés :**

- [ ] Fréquence définie par type d'accès
- [ ] Processus de rotation avec période de chevauchement
- [ ] Automatisation partielle ou totale en place
- [ ] Logs de rotation conservés

**Audit régulier :**

- [ ] Audit mensuel automatisé
- [ ] Audit trimestriel approfondi
- [ ] Détection des clés orphelines
- [ ] Analyse des logs de connexion
- [ ] Vérification de la configuration serveurs
- [ ] Rapports produits et suivis

**Principe du moindre privilège :**

- [ ] AllowUsers/AllowGroups configurés
- [ ] Restrictions par bloc Match appliquées
- [ ] ForceCommand utilisé pour comptes à usage unique
- [ ] SFTP chrooté pour utilisateurs externes
- [ ] Sudo restreint (pas de root direct)
- [ ] Logging verbeux activé

**Séparation des environnements :**

- [ ] Une paire de clés par environnement
- [ ] Configuration SSH (~/.ssh/config) avec séparation claire
- [ ] Bastions/jump servers pour production
- [ ] Segmentation réseau (VLANs/VPCs)
- [ ] Pas de clé multi-environnements (vérifié)
- [ ] Données anonymisées pour staging/dev
- [ ] Workflow de déploiement : dev → staging → prod

### Indicateurs de santé SSH

Surveillez ces métriques :

```bash
# Nombre de clés orphelines
# Cible : 0

# Âge moyen des clés
# Cible : < 6 mois pour production

# Taux de clés sans passphrase
# Cible : 0% pour production, < 20% pour dev

# Délai moyen de révocation
# Cible : < 24h après départ employé

# Nombre de violations de séparation environnements
# Cible : 0

# Taux de conformité configuration SSH
# Cible : 100%
```

---

## 📚 Points clés à retenir

> [!tip] Les 10 commandements SSH
> 
> 1. **Une clé, un usage** - Pas de clé multi-environnements
> 2. **Rotation régulière** - Les clés vieillissent et peuvent être compromises
> 3. **Audit permanent** - Ce qui n'est pas mesuré ne peut être amélioré
> 4. **Moindre privilège** - Donnez le minimum, toujours
> 5. **Séparation stricte** - Production isolée à tout prix
> 6. **Passphrase forte** - Une clé sans passphrase = mot de passe en clair
> 7. **Traçabilité totale** - Qui, quoi, quand, où, pourquoi
> 8. **Documentation vivante** - Politique à jour et accessible
> 9. **Automatisation** - L'humain fait des erreurs, pas les scripts
> 10. **Culture sécurité** - Former et sensibiliser constamment

---

_Fin de la partie : Administration et bonnes pratiques - Bonnes pratiques de sécurité_