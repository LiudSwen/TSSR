

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

## Introduction

La gestion des utilisateurs dans Proxmox VE repose sur un système sophistiqué permettant de contrôler finement les accès aux ressources. Contrairement à un simple système d'authentification Linux, Proxmox propose une architecture multicouche avec plusieurs sources d'authentification (realms), des permissions granulaires, et des mécanismes modernes comme les tokens API.

> [!info] Pourquoi c'est important Une bonne gestion des utilisateurs est cruciale pour :
> 
> - **Sécurité** : Limiter les accès selon le principe du moindre privilège
> - **Audit** : Tracer qui fait quoi sur l'infrastructure
> - **Automatisation** : Utiliser des tokens pour les scripts et l'API
> - **Collaboration** : Permettre à plusieurs administrateurs de travailler ensemble

---

## Realms d'authentification

Un **realm** est un domaine d'authentification qui définit où et comment les identifiants utilisateurs sont stockés et vérifiés. Proxmox supporte quatre types de realms.

### PAM (Pluggable Authentication Modules)

**PAM** correspond au système d'authentification Linux natif du serveur Proxmox.

#### Caractéristiques

- Utilise les utilisateurs Linux standard (`/etc/passwd` et `/etc/shadow`)
- L'utilisateur `root@pam` est créé par défaut avec tous les droits
- Accès direct au système d'exploitation
- Idéal pour les administrateurs système

#### Quand l'utiliser

- Pour les administrateurs ayant besoin d'un accès SSH
- Pour un petit nombre d'utilisateurs privilégiés
- Quand vous voulez synchroniser l'accès Proxmox avec l'accès système

> [!warning] Attention Les utilisateurs PAM ont potentiellement accès au système via SSH. Soyez très sélectif sur qui vous ajoutez dans ce realm.

#### Exemple de création

```bash
# Créer un utilisateur Linux (automatiquement dans le realm PAM)
useradd -m -s /bin/bash admin_proxmox
passwd admin_proxmox

# L'utilisateur sera accessible dans Proxmox comme : admin_proxmox@pam
```

---

### PVE (Proxmox VE)

**PVE** est le realm interne de Proxmox, stocké dans sa propre base de données.

#### Caractéristiques

- Utilisateurs stockés dans `/etc/pve/user.cfg`
- Aucun accès au système d'exploitation sous-jacent
- Gestion complète via l'interface Proxmox
- Parfait pour les utilisateurs ayant besoin uniquement de l'interface web

#### Quand l'utiliser

- Pour des utilisateurs devant gérer des VMs/conteneurs sans accès système
- Pour des comptes de service ou d'automatisation (avec tokens)
- Pour séparer les accès Proxmox des accès système

> [!tip] Bonne pratique Utilisez le realm PVE pour la majorité de vos utilisateurs. Réservez PAM aux vrais administrateurs système.

#### Exemple de création

```bash
# Créer un utilisateur PVE via CLI
pveum user add john@pve --firstname John --lastname Doe --email john@example.com

# Définir un mot de passe
pveum passwd john@pve
```

---

### LDAP

**LDAP** (Lightweight Directory Access Protocol) permet d'intégrer un annuaire d'entreprise existant.

#### Caractéristiques

- Authentification centralisée
- Synchronisation avec l'annuaire d'entreprise
- Support de TLS/SSL pour la sécurité
- Pas de stockage local des mots de passe

#### Configuration

```bash
# Ajouter un realm LDAP
pveum realm add monldap --type ldap \
  --base-dn "dc=example,dc=com" \
  --user-attr uid \
  --server1 ldap.example.com \
  --port 389 \
  --secure 1

# Avec bind (authentification du serveur Proxmox)
pveum realm add monldap --type ldap \
  --base-dn "dc=example,dc=com" \
  --user-attr uid \
  --server1 ldap.example.com \
  --bind-dn "cn=proxmox,dc=example,dc=com" \
  --password "secret123"
```

#### Paramètres importants

|Paramètre|Description|Exemple|
|---|---|---|
|`base-dn`|Point de départ dans l'arbre LDAP|`dc=example,dc=com`|
|`user-attr`|Attribut contenant le nom d'utilisateur|`uid` ou `sAMAccountName`|
|`bind-dn`|DN pour l'authentification serveur|`cn=admin,dc=example,dc=com`|
|`secure`|Utiliser TLS/STARTTLS|`1` pour activer|
|`port`|Port de connexion|`389` (LDAP) ou `636` (LDAPS)|

> [!example] Scénario d'utilisation Votre entreprise a 500 employés dans OpenLDAP. Au lieu de créer 500 comptes Proxmox, vous configurez un realm LDAP. Les employés utilisent leurs identifiants habituels : `jdoe@monldap`

---

### Active Directory (AD)

**Active Directory** est le service d'annuaire de Microsoft, très répandu en entreprise.

#### Caractéristiques

- Intégration native avec les environnements Windows
- Support de Kerberos
- Synchronisation automatique des groupes (optionnel)
- Authentification SSO possible

#### Configuration

```bash
# Ajouter un realm Active Directory
pveum realm add medad --type ad \
  --domain example.com \
  --server1 dc1.example.com \
  --server2 dc2.example.com \
  --secure 1

# Avec des options avancées
pveum realm add medad --type ad \
  --domain example.com \
  --server1 dc1.example.com \
  --default 0 \
  --comment "Active Directory entreprise" \
  --tfa type=oath,step=30,digits=6
```

#### Synchronisation des groupes AD

```bash
# Activer la synchronisation des groupes
pveum realm modify medad --sync-defaults-options scope=both

# Synchroniser manuellement
pveum realm sync medad
```

> [!info] Différence LDAP vs AD AD est essentiellement LDAP avec des extensions Microsoft. Proxmox a un type dédié `ad` qui gère automatiquement ces spécificités (Kerberos, schéma AD, etc.)

---

### Comparaison des Realms

|Realm|Stockage|Accès SSH|Cas d'usage principal|Scalabilité|
|---|---|---|---|---|
|**PAM**|`/etc/shadow`|✅ Oui|Admins système|Petite échelle|
|**PVE**|`/etc/pve/user.cfg`|❌ Non|Utilisateurs Proxmox|Moyenne échelle|
|**LDAP**|Serveur LDAP externe|❌ Non|Intégration annuaire|Grande échelle|
|**AD**|Active Directory|❌ Non|Environnement Windows|Grande échelle|

> [!tip] Stratégie recommandée
> 
> - **root@pam** : Compte d'urgence uniquement
> - **admin@pve** : Administrateurs quotidiens
> - **users@ad** : Utilisateurs standards via Active Directory
> - **automation@pve** : Comptes de service avec tokens API

---

## Création d'utilisateurs

### Via l'interface web

#### Navigation

1. **Datacenter** → **Permissions** → **Users**
2. Cliquer sur **Add**
3. Remplir le formulaire

#### Champs importants

|Champ|Description|Obligatoire|
|---|---|---|
|**User name**|Identifiant unique|✅|
|**Realm**|Source d'authentification|✅|
|**Password**|Mot de passe (si PVE/PAM)|Pour PVE/PAM|
|**Group**|Groupe d'appartenance|❌|
|**Expire**|Date d'expiration du compte|❌|
|**Enabled**|Compte actif ou désactivé|✅|
|**First Name**|Prénom|❌|
|**Last Name**|Nom|❌|
|**E-Mail**|Email (pour notifications)|❌|
|**Comment**|Note descriptive|❌|

> [!example] Exemple concret Création d'un utilisateur pour un développeur :
> 
> - User name : `dev_martin@pve`
> - Group : `developers`
> - Expire : 31/12/2025
> - Email : `martin@example.com`
> - Comment : "Accès temporaire projet X"

---

### Via la ligne de commande

#### Commande principale : `pveum`

**pveum** (Proxmox VE User Manager) est l'outil CLI pour gérer les utilisateurs.

```bash
# Syntaxe de base
pveum user add <userid> [OPTIONS]

# Exemples pratiques
pveum user add admin@pve --email admin@example.com --firstname Admin --lastname System

pveum user add developer@pve --groups developers --comment "Dev team" --expire 2025-12-31

pveum user add viewer@pve --enable 0  # Compte créé mais désactivé
```

#### Options disponibles

```bash
# Options complètes
pveum user add <userid> \
  --comment "Description du compte" \
  --email "email@example.com" \
  --enable <1|0>                    # 1=actif, 0=désactivé
  --expire <YYYY-MM-DD>             # Date d'expiration
  --firstname "Prénom" \
  --groups <group1,group2>          # Groupes (séparés par virgules)
  --keys "clé=valeur"               # Métadonnées personnalisées
  --lastname "Nom"
```

#### Définir/modifier un mot de passe

```bash
# Définir un mot de passe (invite interactive)
pveum passwd user@pve

# Non-interactif (pour scripts)
echo "MotDePasse123!" | pveum passwd user@pve
```

> [!warning] Sécurité des mots de passe Évitez de passer les mots de passe en clair dans les commandes (historique shell). Préférez l'invite interactive ou utilisez des tokens API pour l'automatisation.

---

### Modification et suppression

#### Modifier un utilisateur

```bash
# Modifier les informations
pveum user modify john@pve --email newemail@example.com --lastname "Smith"

# Désactiver un compte
pveum user modify john@pve --enable 0

# Ajouter à un groupe
pveum user modify john@pve --groups "developers,testers"

# Définir une expiration
pveum user modify john@pve --expire 2025-06-30
```

#### Supprimer un utilisateur

```bash
# Supprimer un utilisateur
pveum user delete john@pve

# Vérifier avant suppression
pveum user list | grep john
```

> [!tip] Désactivation vs Suppression Préférez **désactiver** un compte (`--enable 0`) plutôt que le supprimer si vous voulez conserver l'historique des actions et pouvoir le réactiver plus tard.

#### Lister les utilisateurs

```bash
# Liste simple
pveum user list

# Format détaillé
pveum user list --full

# Filtrer par realm
pveum user list | grep @pve
```

---

## Groupes

### Concept et utilité

Les **groupes** permettent d'organiser les utilisateurs et d'appliquer des permissions en masse.

#### Pourquoi utiliser des groupes ?

- **Simplification** : Attribuer des droits à un groupe plutôt qu'à chaque utilisateur
- **Cohérence** : Garantir que tous les membres d'une équipe ont les mêmes accès
- **Évolutivité** : Faciliter l'ajout/retrait d'utilisateurs
- **Audit** : Comprendre rapidement les rôles et permissions

> [!example] Scénario réel Vous avez 10 développeurs qui doivent pouvoir créer des VMs de test mais pas modifier la production. Au lieu d'attribuer les permissions 10 fois, créez un groupe `dev-team` avec les bonnes permissions, et ajoutez les utilisateurs dedans.

---

### Gestion des groupes

#### Créer un groupe

```bash
# Via CLI
pveum group add developers --comment "Équipe de développement"

pveum group add admins --comment "Administrateurs infrastructure"

pveum group add viewers --comment "Accès lecture seule"
```

#### Ajouter des utilisateurs à un groupe

```bash
# Lors de la création de l'utilisateur
pveum user add john@pve --groups developers

# Modifier un utilisateur existant
pveum user modify john@pve --groups developers,testers

# IMPORTANT : --groups remplace les groupes existants
# Pour ajouter à un groupe sans écraser, récupérez d'abord la liste actuelle
```

#### Lister les groupes et leurs membres

```bash
# Lister tous les groupes
pveum group list

# Voir les membres d'un groupe (via l'interface web)
# Datacenter → Permissions → Groups → [sélectionner le groupe]

# Via CLI - lister les utilisateurs d'un groupe
pveum user list --full | grep "groups.*developers"
```

#### Supprimer un groupe

```bash
# Supprimer un groupe
pveum group delete developers
```

> [!warning] Suppression de groupe Supprimer un groupe ne supprime pas les utilisateurs membres, mais ils perdent les permissions associées au groupe. Vérifiez les impacts avant suppression.

---

### Structure de groupes recommandée

```bash
# Hiérarchie typique pour une entreprise
pveum group add administrators --comment "Admin complets"
pveum group add operators --comment "Gestion quotidienne VMs"
pveum group add developers --comment "Dev/Test uniquement"
pveum group add viewers --comment "Lecture seule"
pveum group add auditors --comment "Audit et monitoring"
```

|Groupe|Permissions typiques|Cas d'usage|
|---|---|---|
|**administrators**|PVEAdmin sur /|Admins infrastructure|
|**operators**|PVEVMAdmin sur /vms|Gestion VMs production|
|**developers**|PVEVMUser sur /dev|Environnements de dev/test|
|**viewers**|PVEAuditor sur /|Lecture seule, monitoring|
|**auditors**|Audit sur /|Conformité et traçabilité|

---

## Tokens API

### Qu'est-ce qu'un token API

Un **token API** est une clé d'authentification permettant d'accéder à l'API Proxmox sans utiliser de mot de passe.

#### Avantages des tokens

- **Sécurité** : Pas besoin de stocker des mots de passe dans les scripts
- **Révocabilité** : On peut révoquer un token sans changer le mot de passe
- **Granularité** : Chaque token peut avoir ses propres permissions
- **Traçabilité** : Les actions sont liées au token utilisé
- **Expiration** : Possibilité de définir une date d'expiration

> [!info] Cas d'usage typiques
> 
> - Scripts d'automatisation (backups, déploiements)
> - Intégrations avec des outils CI/CD
> - Applications tierces accédant à Proxmox
> - Monitoring et alerting

---

### Création et gestion

#### Types de tokens

Proxmox propose deux types de tokens :

1. **Tokens avec vérification des privilèges** (par défaut)
    - Héritent des permissions de l'utilisateur parent
    - Limités aux droits de l'utilisateur
2. **Tokens sans vérification des privilèges** (`--privsep 0`)
    - Peuvent avoir leurs propres permissions
    - Indépendants des droits de l'utilisateur parent

#### Créer un token via l'interface web

1. **Datacenter** → **Permissions** → **API Tokens**
2. Cliquer sur **Add**
3. Choisir l'utilisateur parent
4. Définir le Token ID
5. Décocher "Privilege Separation" si besoin de permissions distinctes
6. Copier le secret généré (affiché une seule fois !)

#### Créer un token via CLI

```bash
# Syntaxe de base
pveum user token add <userid> <tokenid> [OPTIONS]

# Token avec vérification des privilèges (hérite des droits de l'utilisateur)
pveum user token add automation@pve backup-token \
  --comment "Token pour scripts de backup" \
  --expire 2025-12-31

# Token sans vérification (permissions indépendantes)
pveum user token add automation@pve deploy-token \
  --privsep 0 \
  --comment "Token déploiement automatisé"

# Le secret est affiché dans la sortie - SAUVEGARDEZ-LE !
# Exemple de sortie :
# ┌──────────┬──────────────────────────────────────┐
# │ key      │ value                                │
# ├──────────┼──────────────────────────────────────┤
# │ full-tokenid │ automation@pve!backup-token      │
# │ info     │ {...}                                │
# │ value    │ xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx │
# └──────────┴──────────────────────────────────────┘
```

> [!warning] Secret du token - Attention ! Le secret du token n'est affiché qu'UNE SEULE FOIS lors de la création. Si vous le perdez, vous devrez créer un nouveau token. Stockez-le de manière sécurisée (coffre-fort de mots de passe, secrets manager).

#### Options disponibles

```bash
--comment "Description"          # Description du token
--expire <YYYY-MM-DD>            # Date d'expiration
--privsep <1|0>                  # 1=hérite des droits, 0=permissions distinctes
```

---

### Utilisation des tokens

#### Format du token

Un token complet se compose de :

```
<userid>!<tokenid>=<secret>

Exemple :
automation@pve!backup-token=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

#### Utilisation avec curl

```bash
# Définir les variables
PROXMOX_HOST="192.168.1.100"
TOKEN_ID="automation@pve!backup-token"
TOKEN_SECRET="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Exemple de requête GET
curl -k -H "Authorization: PVEAPIToken=${TOKEN_ID}=${TOKEN_SECRET}" \
  https://${PROXMOX_HOST}:8006/api2/json/nodes

# Exemple de requête POST (créer une VM)
curl -k -X POST \
  -H "Authorization: PVEAPIToken=${TOKEN_ID}=${TOKEN_SECRET}" \
  -H "Content-Type: application/json" \
  -d '{"vmid": 100, "name": "test-vm", "memory": 2048}' \
  https://${PROXMOX_HOST}:8006/api2/json/nodes/proxmox/qemu
```

#### Utilisation avec Python (proxmoxer)

```bash
# Installer la bibliothèque
pip install proxmoxer requests

# Script Python
```

```python
from proxmoxer import ProxmoxAPI

proxmox = ProxmoxAPI(
    'proxmox.example.com',
    user='automation@pve',
    token_name='backup-token',
    token_value='xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx',
    verify_ssl=False
)

# Lister les VMs
for vm in proxmox.nodes('proxmox').qemu.get():
    print(f"VM {vm['vmid']}: {vm['name']}")
```

#### Utilisation avec Ansible

```yaml
# Dans votre inventory ou playbook
---
- hosts: localhost
  vars:
    proxmox_api_host: "proxmox.example.com"
    proxmox_api_token_id: "automation@pve!deploy-token"
    proxmox_api_token_secret: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  
  tasks:
    - name: Créer une VM
      community.general.proxmox_kvm:
        api_host: "{{ proxmox_api_host }}"
        api_token_id: "{{ proxmox_api_token_id }}"
        api_token_secret: "{{ proxmox_api_token_secret }}"
        node: proxmox
        vmid: 100
        name: ansible-vm
        memory: 2048
        cores: 2
        state: present
```

---

### Gestion des tokens existants

#### Lister les tokens

```bash
# Lister tous les tokens d'un utilisateur
pveum user token list automation@pve

# Affichage format tableau
┌──────────────┬─────────┬────────┬──────────┐
│ tokenid      │ comment │ expire │ privsep  │
├──────────────┼─────────┼────────┼──────────┤
│ backup-token │ Backups │ never  │ 1        │
└──────────────┴─────────┴────────┴──────────┘
```

#### Supprimer un token

```bash
# Supprimer un token spécifique
pveum user token remove automation@pve backup-token

# Confirmer la suppression
pveum user token list automation@pve
```

#### Modifier un token

```bash
# Modifier le commentaire ou l'expiration
pveum user token modify automation@pve backup-token \
  --comment "Token backup - nouvelle description" \
  --expire 2026-12-31

# Note : On ne peut PAS modifier le secret. Pour changer le secret, 
# il faut supprimer et recréer le token.
```

---

### Bonnes pratiques tokens API

> [!tip] Sécurité
> 
> - **Rotation régulière** : Changez les tokens tous les 6-12 mois
> - **Principe du moindre privilège** : Créez des tokens avec uniquement les permissions nécessaires
> - **Un token par usage** : Script de backup = un token, déploiement = un autre token
> - **Expiration** : Définissez toujours une date d'expiration
> - **Stockage sécurisé** : Utilisez des secrets managers (Vault, AWS Secrets Manager, etc.)

> [!warning] À éviter ❌ Commiter les tokens dans Git  
> ❌ Utiliser le même token partout  
> ❌ Tokens sans expiration pour des tests temporaires  
> ❌ Tokens avec `--privsep 0` sans raison valable  
> ❌ Partager des tokens entre plusieurs personnes/scripts

#### Exemple de gestion structurée

```bash
# Créer des tokens spécialisés
pveum user token add automation@pve backup-daily \
  --comment "Backup quotidien - expire fin année" \
  --expire 2025-12-31

pveum user token add automation@pve monitoring \
  --comment "Zabbix monitoring - lecture seule" \
  --expire 2025-12-31

pveum user token add automation@pve ci-deployment \
  --comment "GitLab CI pour déploiements" \
  --privsep 0 \
  --expire 2025-06-30

# Documenter dans un fichier README.md de l'équipe :
# - backup-daily : utilisé par scripts backup.sh (cron quotidien)
# - monitoring : utilisé par Zabbix (agent actif)
# - ci-deployment : GitLab CI pipeline (projets dev/staging uniquement)
```

---

## 🎯 Points clés à retenir

1. **Realms** : Choisissez le bon realm selon le contexte
    
    - PAM pour admins système avec accès SSH
    - PVE pour utilisateurs Proxmox standard
    - LDAP/AD pour intégration entreprise
2. **Utilisateurs** : Créez des comptes avec le minimum de privilèges
    
    - Définissez des expirations pour les comptes temporaires
    - Désactivez plutôt que supprimer pour conserver l'historique
3. **Groupes** : Organisez vos utilisateurs en groupes logiques
    
    - Permissions par groupe, pas par utilisateur individuel
    - Structure hiérarchique claire
4. **Tokens API** : Utilisez des tokens pour toute automatisation
    
    - Un token par usage/script
    - Rotation régulière
    - Stockage sécurisé des secrets

> [!tip] Checklist de sécurité ✅ root@pam désactivé pour usage quotidien  
> ✅ Comptes admin dans le realm PVE  
> ✅ Groupes créés pour chaque rôle  
> ✅ Tokens API avec expiration pour scripts  
> ✅ Documentation des tokens et leurs usages  
> ✅ Révision trimestrielle des accès