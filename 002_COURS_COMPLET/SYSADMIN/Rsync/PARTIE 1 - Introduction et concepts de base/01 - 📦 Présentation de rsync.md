

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

## 🔍 Qu'est-ce que rsync

**rsync** (remote sync) est un outil en ligne de commande conçu pour synchroniser et transférer des fichiers et répertoires de manière efficace, aussi bien localement qu'entre des machines distantes.

> [!info] Définition
> rsync est un utilitaire de synchronisation de fichiers qui utilise un algorithme différentiel pour ne transférer que les portions modifiées des fichiers, minimisant ainsi la bande passante nécessaire.

### Principe de fonctionnement

Contrairement aux outils de copie traditionnels qui transfèrent l'intégralité des fichiers, rsync analyse les différences entre la source et la destination :

1. **Compare** les fichiers sources et destinations
2. **Identifie** uniquement les blocs de données modifiés
3. **Transfère** seulement ces différences
4. **Reconstruit** le fichier complet à destination

> [!example] Exemple concret
> Si vous avez un fichier vidéo de 2 Go et que vous modifiez seulement 10 Mo de métadonnées, rsync ne transférera que ces 10 Mo au lieu des 2 Go complets.

### Caractéristiques principales

- **Transfert incrémental** : seules les modifications sont copiées
- **Préservation des attributs** : permissions, propriétaires, horodatages
- **Compression à la volée** : réduit l'utilisation de la bande passante
- **Support du chiffrement** : via SSH pour les transferts sécurisés
- **Synchronisation unidirectionnelle** : de la source vers la destination

---

## 💼 Utilité et cas d'usage courants

rsync est l'outil de prédilection pour de nombreux scénarios en administration système.

### 1. Sauvegardes régulières

> [!tip] Sauvegarde incrémentale
> rsync excelle dans les sauvegardes incrémentales quotidiennes car il ne copie que les fichiers modifiés depuis la dernière exécution.

**Cas d'usage :**
- Sauvegarde de répertoires utilisateurs (`/home`)
- Sauvegarde de bases de données (après export)
- Archivage de logs systèmes
- Copie de sécurité de configurations (`/etc`)

### 2. Synchronisation de serveurs

**Scénarios typiques :**
- Maintien de serveurs miroirs identiques
- Réplication de contenu web entre serveurs
- Synchronisation de partages de fichiers
- Mise à jour de serveurs de développement

### 3. Déploiement d'applications

```bash
# Déploiement de fichiers web vers un serveur de production
rsync -avz --delete /var/www/monsite/ user@serveur-prod:/var/www/monsite/
```

> [!warning] Attention avec --delete
> L'option `--delete` supprime les fichiers à destination qui n'existent plus à la source. À utiliser avec précaution en production !

### 4. Migration de données

- Transfert de données entre serveurs lors de migrations
- Déplacement de volumes importants de fichiers
- Consolidation de stockage

### 5. Distribution de mises à jour

- Diffusion de paquets logiciels
- Mise à jour de dépôts internes
- Distribution de fichiers de configuration

---

## ⚖️ Avantages par rapport à cp, scp, ftp

### Comparaison avec `cp` (copy)

| Critère | cp | rsync |
|---------|-------|--------|
| **Transfert** | Copie complète systématique | Transfert différentiel |
| **Réseau** | Local uniquement | Local + distant |
| **Reprise** | Non supportée | Reprise possible |
| **Vitesse** | Rapide en local | Plus rapide sur fichiers existants |
| **Bande passante** | Non applicable | Optimisée |

> [!example] Cas pratique
> Pour copier un répertoire de 100 Go dont seuls 500 Mo ont changé :
> - **cp** : recopie les 100 Go complets
> - **rsync** : transfère uniquement les 500 Mo modifiés

### Comparaison avec `scp` (secure copy)

| Critère | scp | rsync |
|---------|-----|--------|
| **Algorithme** | Copie complète | Transfert différentiel |
| **Reprise sur erreur** | Recommencer depuis le début | Reprend où c'était arrêté |
| **Compression** | Possible mais basique | Compression optimisée |
| **Synchronisation** | Non | Oui |
| **Performance** | Bonne | Excellente sur fichiers existants |

```bash
# scp transfert tout à chaque fois
scp -r /home/user/data/ serveur:/backup/

# rsync ne transfère que les changements
rsync -avz /home/user/data/ serveur:/backup/data/
```

> [!tip] Quand utiliser scp ?
> scp reste pertinent pour des transferts ponctuels de fichiers uniques ou petits répertoires sans besoin de synchronisation.

### Comparaison avec `ftp` / `sftp`

| Critère | FTP/SFTP | rsync |
|---------|----------|--------|
| **Interface** | Ligne de commande ou GUI | Ligne de commande |
| **Transfert différentiel** | Non | Oui |
| **Automatisation** | Complexe | Simple via scripts |
| **Sécurité** | FTP non chiffré, SFTP chiffré | SSH chiffré |
| **Préservation attributs** | Limitée | Complète |

> [!info] rsync vs FTP
> FTP est orienté transfert de fichiers interactif, tandis que rsync est conçu pour l'automatisation et la synchronisation efficace.

### Récapitulatif des avantages de rsync

✅ **Efficacité** : transfert uniquement les différences
✅ **Rapidité** : synchronisations ultérieures très rapides
✅ **Fiabilité** : vérification d'intégrité, reprise sur interruption
✅ **Flexibilité** : nombreuses options de filtrage et préservation
✅ **Sécurité** : utilisation de SSH pour le chiffrement
✅ **Polyvalence** : local, distant, daemon

---

## 🔌 Protocoles supportés

rsync peut fonctionner selon trois modes principaux, chacun adapté à des besoins spécifiques.

### 1. Mode local

Transfert de fichiers sur la même machine.

```bash
# Syntaxe basique locale
rsync [OPTIONS] /source/ /destination/
```

**Caractéristiques :**
- Pas de réseau impliqué
- Accès direct au système de fichiers
- Performances maximales
- Utile pour réorganisation ou sauvegardes locales

> [!example] Utilisation locale
> ```bash
> # Synchroniser deux répertoires sur le même serveur
> rsync -av /data/production/ /backup/production/
> ```

### 2. Mode SSH (remote shell)

Le mode le plus utilisé pour les transferts distants, utilisant SSH comme canal de transport.

```bash
# Push : envoyer vers un serveur distant
rsync [OPTIONS] /source/ user@serveur:/destination/

# Pull : récupérer depuis un serveur distant
rsync [OPTIONS] user@serveur:/source/ /destination/
```

**Avantages :**
- **Chiffrement** : toutes les données sont cryptées
- **Authentification** : utilise les mécanismes SSH (mot de passe ou clé)
- **Simplicité** : pas de configuration serveur spécifique rsync
- **Port standard** : utilise le port SSH (22 par défaut)

> [!tip] Clés SSH recommandées
> Pour l'automatisation, privilégiez l'authentification par clés SSH plutôt que par mot de passe.

**Exemple :**
```bash
# Sauvegarde vers un serveur distant via SSH
rsync -avz -e ssh /home/user/documents/ backup@server.com:/backups/documents/

# Utilisation d'un port SSH personnalisé
rsync -avz -e "ssh -p 2222" /data/ user@serveur:/data/
```

### 3. Mode daemon (rsync natif)

rsync peut fonctionner comme un service (daemon) écoutant sur un port réseau (873 par défaut).

```bash
# Syntaxe avec daemon
rsync [OPTIONS] source user@serveur::module/destination
# ou
rsync [OPTIONS] rsync://user@serveur/module/destination
```

**Caractéristiques :**
- Configuration via `/etc/rsyncd.conf`
- Modules définis côté serveur
- Authentification propre à rsync
- Contrôle d'accès granulaire
- Peut fonctionner avec ou sans chiffrement

> [!warning] Sécurité daemon
> Par défaut, le mode daemon n'est **pas chiffré**. Pour sécuriser, utilisez un tunnel SSH ou VPN.

**Quand l'utiliser :**
- Partage public de fichiers (miroirs de dépôts)
- Contrôle fin des accès par module
- Performance maximale sans surcharge SSH
- Plusieurs points de synchronisation prédéfinis

> [!example] Exemple daemon
> ```bash
> # Connexion à un module rsync public
> rsync -avz rsync://mirror.example.com/debian/ /local/mirror/
> 
> # Avec authentification
> rsync -avz user@backup-server::backup-home/ /home/user/
> ```

### Comparaison des protocoles

| Mode | Port | Chiffrement | Configuration | Usage typique |
|------|------|-------------|---------------|---------------|
| **Local** | - | - | Aucune | Réorganisation locale |
| **SSH** | 22 | ✅ Oui | SSH installé | Sauvegardes distantes sécurisées |
| **Daemon** | 873 | ❌ Non (par défaut) | rsyncd.conf | Miroirs publics, partages internes |

> [!info] Choix du protocole
> - **95% des cas** : utilisez SSH pour sa simplicité et sa sécurité
> - **Performances critiques** : envisagez le mode daemon avec tunnel sécurisé
> - **Local uniquement** : mode local direct

---

## 🎯 Points clés à retenir

> [!tip] Synthèse
> - rsync est l'outil de référence pour la synchronisation efficace de fichiers
> - Il transfère uniquement les différences, économisant temps et bande passante
> - Trois modes d'utilisation : local, SSH (recommandé), daemon
> - Supérieur à cp/scp/ftp pour les synchronisations récurrentes
> - Idéal pour sauvegardes, déploiements, migrations et miroirs

---

*rsync : la synchronisation intelligente de fichiers* 🚀