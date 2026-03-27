

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

## 🔐 Authentification par utilisateur/mot de passe

### Pourquoi sécuriser avec authentification ?

Par défaut, un daemon rsync peut être accessible sans authentification, ce qui représente un risque majeur de sécurité. L'authentification empêche les accès non autorisés à vos données.

> [!warning] Attention
> Sans authentification, **n'importe qui** ayant accès au réseau peut lire ou écrire dans vos modules rsync !

### Configuration de l'authentification

L'authentification se configure en deux étapes :

**1. Création du fichier de secrets**

```bash
# Créer le fichier des mots de passe
sudo nano /etc/rsyncd.secrets

# Ajouter les utilisateurs (format : utilisateur:motdepasse)
backup_user:MonM0tDePa$$eF0rt
readonly_user:AutreMotDePasse123
```

**2. Sécurisation du fichier**

```bash
# Permissions strictes OBLIGATOIRES (600)
sudo chmod 600 /etc/rsyncd.secrets

# Propriétaire root
sudo chown root:root /etc/rsyncd.secrets
```

> [!danger] CRITIQUE
> Si les permissions ne sont pas à `600`, rsync **refusera** de démarrer pour des raisons de sécurité !

**3. Activation dans rsyncd.conf**

```bash
[backup]
    path = /srv/backups
    comment = Module de sauvegarde sécurisé
    
    # Fichier contenant les utilisateurs/mots de passe
    secrets file = /etc/rsyncd.secrets
    
    # Liste des utilisateurs autorisés (séparés par des espaces)
    auth users = backup_user, readonly_user
    
    read only = no
```

### Utilisation côté client

```bash
# Le client doit fournir le nom d'utilisateur
rsync -av fichier.txt backup_user@serveur::backup/

# Mot de passe demandé interactivement
Password: ********

# Alternative : fichier de mot de passe client
echo "MonM0tDePa$$eF0rt" > ~/.rsync-password
chmod 600 ~/.rsync-password

# Utilisation sans interaction
rsync -av --password-file=~/.rsync-password \
    fichier.txt backup_user@serveur::backup/
```

> [!tip] Astuce
> Pour l'automatisation (cron), utilisez **toujours** `--password-file` pour éviter les demandes interactives.

### Exemple complet avec plusieurs niveaux d'accès

```bash
# /etc/rsyncd.secrets
admin:Adm1nS3cr3t
backup_user:BackupP@ss2024
lecteur:L3ctur3Only

# /etc/rsyncd.conf
[donnees_completes]
    path = /srv/donnees
    secrets file = /etc/rsyncd.secrets
    auth users = admin
    read only = no
    comment = Accès complet réservé à l'admin

[sauvegarde]
    path = /srv/backups
    secrets file = /etc/rsyncd.secrets
    auth users = backup_user
    read only = no
    comment = Accès en écriture pour les backups

[consultation]
    path = /srv/public
    secrets file = /etc/rsyncd.secrets
    auth users = lecteur
    read only = yes
    comment = Accès lecture seule
```

---

## 🌐 Restrictions d'hôtes

### Principe du filtrage par adresse IP

Les restrictions d'hôtes permettent de limiter l'accès au daemon aux seules machines autorisées, offrant une couche de sécurité supplémentaire.

> [!info] Fonctionnement
> Même avec authentification, vous pouvez bloquer l'accès depuis certaines adresses IP ou sous-réseaux.

### Options de filtrage

| Option | Description | Priorité |
|--------|-------------|----------|
| `hosts allow` | Liste blanche des hôtes autorisés | Autorise d'abord |
| `hosts deny` | Liste noire des hôtes refusés | Refuse ensuite |

### Syntaxes supportées

```bash
# Adresse IP unique
hosts allow = 192.168.1.50

# Plage d'adresses (notation CIDR)
hosts allow = 192.168.1.0/24

# Sous-réseau (notation masque)
hosts allow = 10.0.0.0/255.255.255.0

# Nom de domaine
hosts allow = backup.exemple.com

# Plusieurs entrées (séparées par espaces ou virgules)
hosts allow = 192.168.1.50 192.168.1.51 10.0.0.0/24
```

### Stratégies de filtrage

**Stratégie 1 : Liste blanche (recommandée)**

```bash
[backup]
    path = /srv/backups
    
    # Autoriser uniquement ces IP
    hosts allow = 192.168.1.10 192.168.1.11 192.168.1.0/24
    
    # Bloquer tout le reste (optionnel, implicite)
    hosts deny = *
```

**Stratégie 2 : Liste noire**

```bash
[partage]
    path = /srv/partage
    
    # Bloquer des IP spécifiques
    hosts deny = 192.168.1.99 10.0.0.0/8
    
    # Autoriser tout le reste (par défaut)
```

**Stratégie 3 : Mixte (précis)**

```bash
[donnees]
    path = /srv/donnees
    
    # Autoriser le réseau local sauf une IP
    hosts allow = 192.168.1.0/24
    hosts deny = 192.168.1.66
```

> [!warning] Ordre de traitement
> 1. Vérification de `hosts allow` → si match, **autorisé**
> 2. Vérification de `hosts deny` → si match, **refusé**
> 3. Si aucun match → **comportement par défaut** (autorisé si pas de hosts allow)

### Exemples pratiques

**Cas 1 : Serveur de backup accessible uniquement depuis le LAN**

```bash
[backup_local]
    path = /backup
    secrets file = /etc/rsyncd.secrets
    auth users = backup_user
    
    # Uniquement réseau local
    hosts allow = 192.168.0.0/16
    hosts deny = *
    
    read only = no
```

**Cas 2 : Accès depuis plusieurs sites distants**

```bash
[sync_multi_sites]
    path = /srv/sync
    
    # Sites Paris, Lyon, Marseille
    hosts allow = 10.1.0.0/24 10.2.0.0/24 10.3.0.0/24
    hosts deny = *
```

**Cas 3 : Bloquer une IP problématique**

```bash
[public_data]
    path = /srv/public
    
    # Bloquer un client malveillant
    hosts deny = 203.0.113.50
    
    # Le reste du monde peut accéder
```

---

## 📖 Mode read-only

### Utilité du mode lecture seule

Le mode `read only` empêche toute modification des données sur le serveur. Les clients peuvent uniquement **télécharger** (pull), jamais **envoyer** (push).

> [!info] Quand l'utiliser ?
> - Distribution de fichiers publics
> - Partage de documentation
> - Miroirs de données
> - Protection contre les modifications accidentelles

### Configuration

```bash
[miroir_public]
    path = /srv/public
    comment = Données publiques en lecture seule
    
    # Active la lecture seule
    read only = yes
    
    # Optionnel : accessible sans authentification
    auth users =
```

### Comportements selon la configuration

| Configuration | Client peut lire ? | Client peut écrire ? |
|---------------|-------------------|---------------------|
| `read only = yes` | ✅ Oui | ❌ Non |
| `read only = no` | ✅ Oui | ✅ Oui |
| Non spécifié | ✅ Oui | ❌ Non (défaut) |

### Exemples de configuration

**Exemple 1 : Distribution de logiciels**

```bash
[repository]
    path = /srv/repo/packages
    comment = Dépôt de paquets logiciels
    read only = yes
    
    # Accessible à tout le réseau local
    hosts allow = 192.168.0.0/16
```

**Exemple 2 : Module avec accès différenciés**

```bash
# Fichier /etc/rsyncd.secrets
admin:AdminPass123
user:UserPass456

# Configuration
[donnees]
    path = /srv/donnees
    secrets file = /etc/rsyncd.secrets
    
    # Utilisateurs en lecture seule
    auth users = user
    read only = yes

[donnees_rw]
    path = /srv/donnees
    secrets file = /etc/rsyncd.secrets
    
    # Admin en lecture/écriture
    auth users = admin
    read only = no
```

> [!tip] Astuce
> Créez **deux modules distincts** pointant vers le même `path` pour offrir des accès différenciés !

**Exemple 3 : Vérification côté client**

```bash
# Tentative d'envoi vers module read-only
rsync -av local/ serveur::miroir_public/

# Résultat :
# ERROR: module is read only
# rsync error: syntax or usage error (code 1)
```

---

## 🔒 Chroot

### Qu'est-ce que le chroot ?

Le **chroot** (change root) emprisonne le daemon rsync dans un répertoire spécifique, l'empêchant d'accéder au reste du système de fichiers. C'est une protection supplémentaire contre les accès non autorisés.

> [!info] Concept
> Même si un attaquant contourne l'authentification, il ne peut accéder qu'au contenu du répertoire chroot, pas au système complet.

### Configuration de base

```bash
[backup_securise]
    path = /backups
    comment = Sauvegarde avec chroot
    
    # Active le chroot sur /srv/rsync-jail
    use chroot = yes
    
    # Optionnel : spécifier le répertoire racine
    # (par défaut : utilise le 'path' comme racine)
```

### Fonctionnement détaillé

**Sans chroot :**

```bash
[donnees]
    path = /srv/data
    use chroot = no

# Le daemon peut théoriquement accéder à :
# /srv/data (configuré)
# /etc, /var, /home, etc. (reste du système)
```

**Avec chroot :**

```bash
[donnees]
    path = /data
    use chroot = yes

# Le daemon est enfermé dans /srv/rsync-jail
# Il voit /data mais c'est en réalité /srv/rsync-jail/data
# Il ne peut pas sortir de cette "prison"
```

> [!warning] Attention aux chemins
> Avec `use chroot = yes`, le `path` devient **relatif** à la racine du chroot !

### Préparation de l'environnement chroot

Pour fonctionner correctement, le chroot nécessite une structure minimale :

```bash
# Créer la jail
sudo mkdir -p /srv/rsync-jail/{data,tmp}

# Permissions appropriées
sudo chmod 755 /srv/rsync-jail
sudo chmod 1777 /srv/rsync-jail/tmp  # sticky bit pour /tmp

# Créer l'utilisateur système pour rsync
sudo useradd -r -s /bin/false rsync

# Propriétaire des données
sudo chown -R rsync:rsync /srv/rsync-jail/data
```

### Configuration complète avec chroot

```bash
# /etc/rsyncd.conf
uid = rsync
gid = rsync

[backup]
    path = /data
    comment = Backup avec chroot
    use chroot = yes
    
    # Authentification
    secrets file = /etc/rsyncd.secrets
    auth users = backup_user
    
    # Restrictions
    hosts allow = 192.168.1.0/24
    read only = no
    
    # Le daemon s'exécutera dans /srv/rsync-jail
    # et verra /data comme racine
```

> [!example] Exemple concret
> - Chemin réel : `/srv/rsync-jail/data/fichier.txt`
> - Chemin vu par rsync : `/data/fichier.txt`
> - Le daemon ne peut pas accéder à `/etc` ou `/home`

### Cas où désactiver le chroot

Il existe des situations légitimes pour `use chroot = no` :

```bash
[logs_systeme]
    path = /var/log
    use chroot = no
    read only = yes
    
    # Nécessaire pour accéder aux vrais chemins système
    # Mais en LECTURE SEULE pour la sécurité
```

> [!warning] Désactivation du chroot
> Désactivez le chroot **uniquement** si absolument nécessaire, et combinez avec :
> - `read only = yes`
> - Authentification forte
> - Restrictions d'hôtes strictes

### Avantages et limitations

**Avantages :**
- ✅ Isolation complète du système
- ✅ Protection contre les chemins traversants (`../../../etc/passwd`)
- ✅ Limitation des dégâts en cas de compromission

**Limitations :**
- ⚠️ Configuration plus complexe
- ⚠️ Nécessite une structure de répertoires dédiée
- ⚠️ Peut compliquer l'accès à plusieurs emplacements

---

## 🛡️ Synthèse des bonnes pratiques

### Configuration minimale sécurisée

```bash
# /etc/rsyncd.conf
uid = rsync
gid = rsync
log file = /var/log/rsyncd.log

[backup_securise]
    # Chemin et description
    path = /data
    comment = Sauvegarde sécurisée
    
    # Authentification obligatoire
    secrets file = /etc/rsyncd.secrets
    auth users = backup_user
    
    # Restrictions réseau
    hosts allow = 192.168.1.0/24
    hosts deny = *
    
    # Isolation système
    use chroot = yes
    
    # Contrôle d'accès
    read only = no
```

### Checklist de sécurisation

> [!tip] Checklist
> - [ ] Authentification activée (`auth users` + `secrets file`)
> - [ ] Fichier secrets en permissions 600
> - [ ] Filtrage par IP (`hosts allow` / `hosts deny`)
> - [ ] Chroot activé (`use chroot = yes`)
> - [ ] UID/GID non-root configurés
> - [ ] `read only = yes` pour les modules publics
> - [ ] Logs activés (`log file`)
> - [ ] Firewall configuré (port 873)

### Niveaux de sécurité progressifs

**Niveau 1 - Basique :**
```bash
[public]
    path = /srv/public
    read only = yes
```

**Niveau 2 - Intermédiaire :**
```bash
[semi_public]
    path = /srv/semi_public
    read only = yes
    hosts allow = 192.168.0.0/16
```

**Niveau 3 - Sécurisé :**
```bash
[donnees]
    path = /data
    use chroot = yes
    secrets file = /etc/rsyncd.secrets
    auth users = data_user
    hosts allow = 192.168.1.50
    read only = no
```

**Niveau 4 - Maximum :**
```bash
[critique]
    path = /data
    use chroot = yes
    secrets file = /etc/rsyncd.secrets
    auth users = admin_user
    hosts allow = 192.168.1.10
    hosts deny = *
    read only = no
    
    # Options additionnelles
    max connections = 2
    timeout = 300
```

### Tableau récapitulatif

| Mécanisme | Protection contre | Difficulté | Recommandation |
|-----------|------------------|------------|----------------|
| Authentification | Accès anonyme | Facile | **Obligatoire** |
| Hosts allow/deny | Accès réseau non autorisé | Facile | **Fortement recommandé** |
| Read-only | Modifications non désirées | Facile | Selon besoin |
| Chroot | Accès système | Moyenne | **Recommandé** |

> [!example] Configuration de production type
> Pour un serveur de backup professionnel, activez **toutes** ces protections. La sécurité doit primer sur la simplicité.

---

## 🎯 Points clés à retenir

1. **Authentification** : Toujours utiliser `secrets file` avec permissions 600
2. **Filtrage réseau** : Privilégier `hosts allow` (liste blanche)
3. **Read-only** : Activer par défaut, désactiver uniquement si nécessaire
4. **Chroot** : Utiliser pour isoler le daemon du système
5. **Défense en profondeur** : Combiner plusieurs mécanismes de sécurité