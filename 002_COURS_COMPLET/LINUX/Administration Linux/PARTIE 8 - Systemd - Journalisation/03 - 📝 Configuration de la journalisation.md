

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

La configuration de `journald` permet de contrôler comment les logs système sont stockés, conservés et gérés. Une configuration appropriée garantit un équilibre entre la disponibilité des logs pour le débogage et l'utilisation raisonnable des ressources système.

> [!info] Pourquoi configurer la journalisation ?
> 
> - **Persistance des données** : choisir si les logs survivent aux redémarrages
> - **Optimisation de l'espace** : éviter que les logs ne saturent le disque
> - **Performance système** : limiter l'impact de la journalisation sur les I/O
> - **Conformité** : respecter les politiques de rétention des logs

---

## 💾 Logs persistants vs volatiles

### Comprendre les deux modes

Par défaut, `journald` peut fonctionner en deux modes selon la présence du répertoire `/var/log/journal/` :

|Mode|Stockage|Persistance|Utilisation|
|---|---|---|---|
|**Volatile**|`/run/log/journal/` (RAM)|Non - effacé au reboot|Systèmes avec peu d'espace disque|
|**Persistant**|`/var/log/journal/` (Disque)|Oui - survit aux redémarrages|Serveurs de production|

### Comment fonctionnent-ils ?

> [!example] Mode volatile (par défaut si /var/log/journal/ n'existe pas)
> 
> ```bash
> # Les logs sont stockés en mémoire vive
> ls /run/log/journal/
> # Sortie : <machine-id>/
> 
> # Après un reboot, tous les logs sont perdus
> ```

> [!example] Mode persistant
> 
> ```bash
> # Créer le répertoire pour activer la persistance
> sudo mkdir -p /var/log/journal/
> sudo systemd-tmpfiles --create --prefix /var/log/journal
> 
> # Vérifier que journald utilise bien le stockage persistant
> sudo systemctl restart systemd-journald
> journalctl --verify
> ```

### Le paramètre Storage

Le comportement de stockage est contrôlé par la directive `Storage=` dans la configuration :

```bash
Storage=volatile    # Force le stockage en mémoire
Storage=persistent  # Force le stockage sur disque
Storage=auto        # Persistant si /var/log/journal/ existe, sinon volatile
Storage=none        # Désactive journald (utilise syslog uniquement)
```

> [!warning] Attention au mode "none" En mode `Storage=none`, journald ne conserve AUCUN log. Assurez-vous qu'un autre système de logging (rsyslog, syslog-ng) prend le relais.

> [!tip] Astuce pour les systèmes embarqués Sur des systèmes avec stockage limité (Raspberry Pi, IoT), utilisez `Storage=volatile` avec `RuntimeMaxUse=` pour limiter l'utilisation de la RAM.

---

## ⚙️ Configuration dans /etc/systemd/journald.conf

### Structure du fichier

Le fichier principal de configuration est `/etc/systemd/journald.conf`. Il utilise le format INI avec une section `[Journal]`.

```bash
# Voir la configuration actuelle
sudo cat /etc/systemd/journald.conf

# Ou avec les valeurs par défaut incluses
systemd-analyze cat-config systemd/journald.conf
```

> [!info] Configuration modulaire Vous pouvez créer des fichiers de configuration supplémentaires dans `/etc/systemd/journald.conf.d/*.conf` qui surchargent la configuration principale. Cette approche facilite la gestion et les mises à jour.

### Directives essentielles

#### 1. Mode de stockage

```bash
[Journal]
# Mode de stockage (auto, persistent, volatile, none)
Storage=persistent

# Compression des logs (oui par défaut)
Compress=yes

# Sceller les logs (protection contre modification)
Seal=yes
```

#### 2. Transfert vers syslog

```bash
[Journal]
# Transférer les logs vers le socket syslog traditionnel
ForwardToSyslog=no

# Transférer vers la console (pour messages critiques)
ForwardToConsole=no

# Transférer vers le wall (tous les utilisateurs)
ForwardToWall=yes
```

> [!tip] Coexistence avec rsyslog Si vous utilisez rsyslog, laissez `ForwardToSyslog=yes` pour que les deux systèmes fonctionnent ensemble. Sinon, désactivez-le pour éviter la duplication.

#### 3. Limitation de débit (rate limiting)

```bash
[Journal]
# Nombre maximum de messages par intervalle (par service)
RateLimitIntervalSec=30s
RateLimitBurst=10000

# Exemple : maximum 10000 messages toutes les 30 secondes
```

> [!warning] Protection contre le spam de logs Le rate limiting empêche un service défectueux de saturer les logs et le système. Les messages excédentaires sont droppés avec un avertissement.

#### 4. Séparation des logs par utilisateur

```bash
[Journal]
# Créer des journaux séparés pour chaque utilisateur
SplitMode=uid

# Autres valeurs possibles :
# - none : tous les logs dans un seul journal
# - login : un journal par session de connexion
```

### Exemple de configuration complète

```bash
[Journal]
# === STOCKAGE ===
Storage=persistent
Compress=yes
Seal=yes

# === TRANSFERT ===
ForwardToSyslog=no
ForwardToKMsg=no
ForwardToConsole=no
ForwardToWall=yes

# === LIMITATIONS ===
# Limite de débit
RateLimitIntervalSec=30s
RateLimitBurst=10000

# Taille maximale des messages
MaxLevelStore=debug
MaxLevelSyslog=debug
MaxLevelKMsg=notice
MaxLevelConsole=info
MaxLevelWall=emerg

# === ORGANISATION ===
SplitMode=none

# === SYNCHRONISATION ===
# Synchroniser sur disque toutes les 5 minutes ou après 100 messages
SyncIntervalSec=5m
```

### Appliquer les modifications

```bash
# Vérifier la syntaxe du fichier
sudo systemd-analyze verify systemd-journald.service

# Redémarrer journald pour appliquer la configuration
sudo systemctl restart systemd-journald

# Vérifier que le service fonctionne correctement
sudo systemctl status systemd-journald

# Voir la configuration active (avec valeurs par défaut)
journalctl -u systemd-journald -n 50
```

> [!warning] Redémarrage de journald Le redémarrage de journald est généralement sans impact, mais quelques messages de log peuvent être perdus pendant la transition. Privilégiez une maintenance planifiée.

---

## 💿 Gestion de l'espace disque des logs

### Comprendre les limites d'espace

La gestion de l'espace est cruciale pour éviter que les logs ne saturent le système. `journald` propose plusieurs directives pour contrôler l'utilisation du disque.

### Directives de limitation

#### 1. Limites pour le stockage persistant

```bash
[Journal]
# === LIMITES ABSOLUES ===
# Taille maximale totale des logs sur disque
SystemMaxUse=4G

# Laisser au moins cette quantité d'espace libre
SystemKeepFree=1G

# Taille maximale d'un fichier journal individuel
SystemMaxFileSize=128M

# Nombre maximum de fichiers journaux archivés
SystemMaxFiles=100
```

> [!info] Comment ça fonctionne ? `journald` respecte la limite la plus restrictive entre `SystemMaxUse` et `SystemKeepFree`. Si le disque a 10 Go libres et `SystemKeepFree=1G`, les logs peuvent utiliser jusqu'à 9 Go (sauf si `SystemMaxUse` est plus bas).

#### 2. Limites pour le stockage volatile (RAM)

```bash
[Journal]
# === LIMITES EN MÉMOIRE ===
# Taille maximale totale des logs en RAM
RuntimeMaxUse=256M

# Laisser au moins cette quantité de RAM libre
RuntimeKeepFree=512M

# Taille maximale d'un fichier journal en RAM
RuntimeMaxFileSize=32M

# Nombre maximum de fichiers en RAM
RuntimeMaxFiles=100
```

> [!tip] Recommandations pour RuntimeMaxUse
> 
> - Serveurs avec beaucoup de RAM : 512M - 1G
> - Systèmes de bureau : 128M - 256M
> - Systèmes embarqués : 32M - 64M

### Durée de rétention

```bash
[Journal]
# Conserver les logs pendant 3 mois maximum
MaxRetentionSec=3month

# Supprimer les logs plus vieux que 2 semaines
MaxFileSec=2week
```

> [!example] Unités de temps acceptées
> 
> - `s`, `sec`, `second` : secondes
> - `min`, `minute` : minutes
> - `h`, `hour` : heures
> - `d`, `day` : jours
> - `week` : semaines
> - `month` : mois (30 jours)
> - `year` : années (365 jours)

### Exemple de configuration pour différents scénarios

#### Serveur de production avec audit long terme

```bash
[Journal]
Storage=persistent
SystemMaxUse=20G
SystemKeepFree=5G
SystemMaxFileSize=256M
MaxRetentionSec=1year
Compress=yes
```

#### Système avec espace limité

```bash
[Journal]
Storage=persistent
SystemMaxUse=500M
SystemKeepFree=500M
SystemMaxFileSize=50M
MaxRetentionSec=1month
Compress=yes
```

#### Système embarqué (logs volatiles)

```bash
[Journal]
Storage=volatile
RuntimeMaxUse=64M
RuntimeKeepFree=128M
RuntimeMaxFileSize=8M
Compress=yes
```

### Commandes de maintenance

```bash
# Voir l'utilisation actuelle du disque par les logs
journalctl --disk-usage

# Nettoyer les logs manuellement
# Conserver seulement les 2 derniers jours
sudo journalctl --vacuum-time=2d

# Limiter à 500M maximum
sudo journalctl --vacuum-size=500M

# Conserver seulement les 10 fichiers les plus récents
sudo journalctl --vacuum-files=10

# Vérifier l'intégrité des fichiers journaux
sudo journalctl --verify

# Rotation manuelle des logs
sudo systemctl kill --signal=SIGUSR2 systemd-journald
```

> [!tip] Automatisation du nettoyage Les limites de configuration sont appliquées automatiquement par `journald`. Vous n'avez besoin de `--vacuum-*` que pour un nettoyage ponctuel ou urgent.

### Surveiller l'espace disque

```bash
# Vérifier l'espace utilisé par les journaux
du -sh /var/log/journal/

# Voir les fichiers journaux
ls -lh /var/log/journal/*/

# Statistiques détaillées par journal
journalctl --header

# Afficher la taille de chaque fichier journal
find /var/log/journal/ -name "*.journal" -exec du -h {} \;
```

---

## ⚠️ Pièges courants

> [!warning] Piège 1 : Oublier de créer /var/log/journal/ Si vous configurez `Storage=persistent` mais que le répertoire n'existe pas, `journald` basculera en mode auto (volatile). Créez toujours le répertoire et redémarrez le service.

> [!warning] Piège 2 : Limites trop restrictives Des limites trop basses (`SystemMaxUse=100M` sur un serveur actif) peuvent causer une rotation excessive et la perte de logs importants. Adaptez selon l'activité du système.

> [!warning] Piège 3 : Ignorer SystemKeepFree Ne pas définir `SystemKeepFree` peut permettre aux logs de remplir complètement le disque, causant des dysfonctionnements système graves. Toujours laisser au moins 10% d'espace libre.

> [!warning] Piège 4 : Désactiver la compression `Compress=no` peut multiplier par 5-10 l'espace utilisé par les logs. Gardez la compression activée sauf raison spécifique (analyse en temps réel).

> [!warning] Piège 5 : Oublier de redémarrer journald Les modifications de configuration ne sont appliquées qu'après `systemctl restart systemd-journald`. Vérifiez toujours avec `journalctl --disk-usage` après modification.

> [!warning] Piège 6 : Rate limiting trop strict Un `RateLimitBurst` trop faible peut masquer des problèmes critiques. En cas de problème, les messages seront droppés avec seulement un avertissement générique.

---

## ✅ Bonnes pratiques

### 1. Planification de la capacité

```bash
# Estimer l'utilisation actuelle
journalctl --disk-usage

# Observer la croissance sur une semaine
watch -n 3600 'journalctl --disk-usage'

# Adapter les limites selon les besoins réels + 30% de marge
```

### 2. Configuration modulaire

```bash
# Créer un fichier de configuration personnalisé
sudo mkdir -p /etc/systemd/journald.conf.d/
sudo nano /etc/systemd/journald.conf.d/custom.conf

# Contenu :
[Journal]
SystemMaxUse=5G
MaxRetentionSec=3month
```

> [!tip] Avantage de la configuration modulaire Les fichiers dans `.conf.d/` ne sont pas écrasés lors des mises à jour système. Vos paramètres personnalisés restent intacts.

### 3. Surveillance proactive

```bash
# Ajouter une alerte si les logs dépassent 80% de SystemMaxUse
# (à intégrer dans votre monitoring)
current_size=$(journalctl --disk-usage | grep -oP '\d+\.\d+[GM]')
```

### 4. Documentation de la configuration

```bash
# Ajouter des commentaires explicatifs
[Journal]
# Logs conservés 6 mois pour conformité réglementaire
MaxRetentionSec=6month

# Limite à 10G pour éviter saturation du disque /var (50G total)
SystemMaxUse=10G
```

### 5. Tester avant de déployer

```bash
# Sur un système de test, vérifier l'impact de la configuration
sudo systemd-analyze verify systemd-journald.service
sudo systemctl restart systemd-journald
sudo systemctl status systemd-journald

# Observer pendant 24-48h avant déploiement en production
```

### 6. Stratégie de rétention adaptée

|Type de système|SystemMaxUse|MaxRetentionSec|Justification|
|---|---|---|---|
|Serveur web|5-10G|3-6 mois|Analyse des incidents, conformité|
|Base de données|10-20G|6-12 mois|Audit, troubleshooting complexe|
|Desktop|1-2G|1 mois|Usage personnel, espace limité|
|IoT/Embarqué|100-500M|1 semaine|Ressources très limitées|
|Développement|2-5G|2 semaines|Rotation rapide, tests fréquents|

### 7. Sauvegardes des logs critiques

```bash
# Exporter les logs importants avant rotation
sudo journalctl --since "7 days ago" --priority=err \
  > /backup/critical-logs-$(date +%F).txt

# Ou créer un script de sauvegarde périodique
```

> [!tip] Astuce pour l'archivage long terme Pour une rétention > 1 an, exportez périodiquement les logs vers un système d'archivage externe (S3, NFS) plutôt que d'augmenter `SystemMaxUse` indéfiniment.

---

## 🎓 Résumé des concepts clés

|Concept|Fichier|Directive clé|Impact|
|---|---|---|---|
|**Persistance**|`/var/log/journal/`|`Storage=persistent`|Logs survivent aux reboots|
|**Volatilité**|`/run/log/journal/`|`Storage=volatile`|Logs en RAM, perdus au reboot|
|**Limite disque**|`journald.conf`|`SystemMaxUse=`|Espace max pour les logs|
|**Espace libre**|`journald.conf`|`SystemKeepFree=`|Espace disque à préserver|
|**Rétention**|`journald.conf`|`MaxRetentionSec=`|Durée de conservation|
|**Compression**|`journald.conf`|`Compress=yes`|Économie d'espace (5-10x)|
|**Rate limiting**|`journald.conf`|`RateLimitBurst=`|Protection contre spam|

---

_Configuration maîtrisée = système stable et traçable_ 🚀