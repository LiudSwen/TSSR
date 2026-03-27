

## Table des matières

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

## Introduction au monitoring

Le monitoring dans pfSense est essentiel pour maintenir un réseau sain et sécurisé. Le tableau de bord constitue votre centre de commandement pour surveiller en temps réel l'état de votre firewall et du réseau.

> [!info] Pourquoi monitorer ?
> 
> - **Détection précoce** : Identifier les problèmes avant qu'ils n'impactent les utilisateurs
> - **Optimisation** : Comprendre les patterns d'utilisation pour améliorer les performances
> - **Sécurité** : Repérer les activités suspectes ou les tentatives d'intrusion
> - **Planification** : Anticiper les besoins en bande passante et ressources

---

## Le tableau de bord pfSense

### Accès au tableau de bord

Le tableau de bord est la première page affichée lors de la connexion à l'interface web de pfSense (`https://IP_PFSENSE`).

**Navigation** : Status → Dashboard

### Structure du tableau de bord

Le tableau de bord est organisé en colonnes (généralement 2) contenant des widgets modulaires. Chaque widget affiche des informations spécifiques sur un aspect du système.

> [!tip] Organisation optimale
> 
> - **Colonne gauche** : Widgets critiques (état système, interfaces, services)
> - **Colonne droite** : Widgets informatifs (trafic, logs, graphiques)

### Gestion des colonnes

Vous pouvez modifier le nombre de colonnes pour adapter l'affichage à votre écran :

1. Cliquez sur l'icône **+** (Ajouter widget) en haut à droite
2. Modifiez le paramètre "Columns" (1 à 4 colonnes)
3. Sauvegardez les modifications

> [!warning] Résolution d'écran Sur les petits écrans, privilégiez 1-2 colonnes pour éviter le défilement horizontal excessif.

---

## Widgets disponibles

### Widgets système essentiels

#### 🖥️ System Information

Affiche les informations générales du système :

|Information|Description|
|---|---|
|**Name**|Nom d'hôte du firewall|
|**Version**|Version de pfSense installée|
|**Platform**|Architecture matérielle (amd64, ARM, etc.)|
|**Serial**|Numéro de série Netgate (si applicable)|
|**Uptime**|Temps depuis le dernier redémarrage|
|**Current date/time**|Date et heure système|
|**DNS servers**|Serveurs DNS configurés|

> [!example] Utilisation pratique Ce widget permet de vérifier rapidement :
> 
> - Si le système est à jour
> - La stabilité (uptime élevé = stable)
> - La configuration DNS en cours

#### 💾 System Activity

Widget en temps réel affichant :

- **CPU usage** : Utilisation du processeur (graphique et pourcentage)
- **Memory usage** : RAM utilisée/disponible
- **Swap usage** : Utilisation de la mémoire d'échange
- **Load average** : Charge système (1, 5, 15 minutes)
- **Processes** : Nombre de processus actifs

```
CPU Usage: 15% (User: 8%, System: 5%, Idle: 85%)
Memory: 2.1 GB / 8 GB (26%)
Swap: 0 / 4 GB (0%)
Load Average: 0.45, 0.38, 0.32
```

> [!warning] Seuils d'alerte
> 
> - **CPU** : >80% de manière continue = investigation requise
> - **Memory** : >90% = risque de ralentissement
> - **Load average** : >nombre de CPU = système surchargé

#### 🌡️ Thermal Sensors

Affiche les températures des composants (si capteurs disponibles) :

- Température CPU
- Température disque
- Température carte mère

> [!info] Disponibilité Ce widget n'apparaît que si le matériel possède des capteurs thermiques compatibles.

### Widgets réseau

#### 🔌 Interfaces

Widget crucial affichant l'état de toutes les interfaces réseau :

|Colonne|Information|
|---|---|
|**Interface**|Nom logique (WAN, LAN, OPT1, etc.)|
|**Status**|État (Up/Down)|
|**IPv4/IPv6**|Adresses IP configurées|
|**MAC**|Adresse physique de l'interface|
|**Media**|Type et vitesse de connexion|
|**In/Out**|Trafic entrant/sortant en temps réel|

> [!example] Lecture du widget
> 
> ```
> WAN    ✓ Up    1.2.3.4/24    [MAC]    1000baseT    ↓ 5.2 Mbps  ↑ 1.1 Mbps
> LAN    ✓ Up    192.168.1.1   [MAC]    1000baseT    ↓ 2.8 Mbps  ↑ 0.5 Mbps
> ```

> [!tip] Diagnostic rapide
> 
> - Interface "Down" = câble débranché ou configuration incorrecte
> - Media à 10/100 Mbps alors que Gigabit attendu = problème de négociation
> - Trafic asymétrique important = potentiel problème réseau

#### 📡 Traffic Graphs

Graphiques en temps réel du trafic réseau par interface :

**Fonctionnalités** :

- Mise à jour automatique (intervalle configurable)
- Échelle automatique ou manuelle
- Affichage In/Out ou combiné
- Export des données

**Configuration du widget** :

```
Update Interval: 1 second (réactivité) à 10 seconds (économie ressources)
Graph Type: SVG (moderne) ou RRD (legacy)
Scale Type: Auto (recommandé) ou Fixed
```

> [!tip] Optimisation affichage
> 
> - Pour surveiller les pics : intervalle 1-2 secondes
> - Pour vue d'ensemble : intervalle 5-10 secondes
> - Échelle fixe : utile pour comparer plusieurs graphiques

#### 🌐 Gateway Status

Surveillance de l'état des passerelles (gateways) :

|Indicateur|Signification|
|---|---|
|**Online**|Passerelle accessible et fonctionnelle|
|**Offline**|Passerelle inaccessible|
|**Delay**|Latence moyenne (ping RTT)|
|**Loss**|Pourcentage de paquets perdus|
|**Status**|Alerte si dégradation détectée|

```
WAN_DHCP     Online    Delay: 15ms    Loss: 0%    ✓
WAN_FIBER    Warning   Delay: 250ms   Loss: 2%    ⚠️
```

> [!warning] Seuils critiques
> 
> - **Delay** : >100ms = latence élevée, >500ms = problème sérieux
> - **Loss** : >1% = dégradation, >5% = critique

### Widgets de sécurité et services

#### 🛡️ Services Status

Liste tous les services système avec leur état :

|Service|Description|État normal|
|---|---|---|
|**dhcpd**|Serveur DHCP|Running (si activé)|
|**unbound**|Résolveur DNS|Running|
|**sshd**|Accès SSH|Running/Stopped selon config|
|**ntpd**|Synchronisation horaire|Running|
|**syslogd**|Journalisation système|Running|

**Actions disponibles** :

- ▶️ Start : Démarrer le service
- ⏹️ Stop : Arrêter le service
- 🔄 Restart : Redémarrer le service
- ℹ️ Info : Détails du service

> [!warning] Services critiques Ne jamais arrêter :
> 
> - **syslogd** : perte des logs
> - **unbound** : perte de résolution DNS
> - Services de filtrage : perte de protection

#### 🔥 Firewall Logs

Affiche les dernières entrées des logs du firewall en temps réel :

**Informations affichées** :

- **Act** : Action (Block/Pass)
- **Time** : Horodatage
- **Interface** : Interface concernée
- **Source** : IP:port source
- **Destination** : IP:port destination
- **Protocol** : TCP/UDP/ICMP/etc.

```
Block  12:34:56  WAN   203.0.113.45:54321 → 192.168.1.100:22  TCP
Pass   12:35:01  LAN   192.168.1.50:443   → 8.8.8.8:53       UDP
```

**Configuration** :

- Nombre d'entrées affichées (5, 10, 20, 50)
- Filtrage par interface
- Filtrage par action (Block only, Pass only, All)

> [!tip] Surveillance active Gardez ce widget visible pour détecter :
> 
> - Tentatives de scan de ports
> - Attaques par force brute
> - Trafic suspect répétitif

#### 🔐 IPsec / OpenVPN Status

Widgets dédiés pour surveiller l'état des VPN :

**IPsec** :

- Tunnels actifs/inactifs
- Trafic par tunnel
- État de négociation des SAs (Security Associations)

**OpenVPN** :

- Serveurs/clients actifs
- Utilisateurs connectés
- Adresses IP virtuelles assignées
- Statistiques de bande passante

> [!info] Disponibilité Ces widgets n'apparaissent que si les services VPN correspondants sont configurés.

### Widgets informatifs

#### 📰 RSS Feed

Affiche les actualités pfSense (blog officiel, mises à jour) :

**Utilité** :

- Annonces de sécurité
- Nouvelles versions
- Conseils d'administration

> [!tip] Personnalisation Vous pouvez configurer votre propre flux RSS pour suivre d'autres sources d'information réseau/sécurité.

#### 📸 Picture Widget

Widget personnalisable pour afficher :

- Logo d'entreprise
- Schéma réseau
- Diagramme d'architecture
- Toute image utile

**Configuration** :

1. Uploadez l'image via l'interface
2. Définissez la taille d'affichage
3. Positionnez dans le tableau de bord

---

## Surveillance de l'état système

### Monitoring des ressources matérielles

#### CPU et charge système

**Indicateurs à surveiller** :

1. **CPU Usage** :
    
    - Idle% : Pourcentage de CPU inutilisé (objectif : >50%)
    - System% : Temps kernel (élevé = traitement paquets important)
    - User% : Applications utilisateur
2. **Load Average** :
    
    - Représente le nombre moyen de processus en attente
    - 3 valeurs : 1 min, 5 min, 15 min
    - Interprétation sur un système 4 cœurs :
        - < 4.0 : Normal
        - 4.0-8.0 : Chargé mais acceptable
        - > 8.0 : Surchargé
            

> [!example] Calcul de charge idéale Sur un CPU 4 cœurs :
> 
> - Load average de 2.0 = 50% de capacité utilisée (optimal)
> - Load average de 4.0 = 100% de capacité (limite)
> - Load average de 8.0 = 200% (file d'attente importante)

#### Mémoire

**Types de mémoire** :

|Type|Description|Seuil normal|
|---|---|---|
|**Active**|Mémoire activement utilisée|Variable|
|**Inactive**|Données en cache, libérable|Variable|
|**Wired**|Mémoire système non libérable|< 50%|
|**Free**|Mémoire totalement libre|> 10%|

**Calcul de la mémoire disponible** :

```
Mémoire disponible = Free + Inactive + Cache
```

> [!warning] Utilisation du swap Si swap > 0% de manière persistante :
> 
> - RAM insuffisante
> - Ralentissements possibles
> - Considérez un upgrade matériel

#### Disque et système de fichiers

**Points de surveillance** :

1. **Espace disque** :
    
    - Partition `/` (root) : < 80%
    - Partition `/var` (logs) : < 90%
    - Partition `/tmp` : Variable
2. **État SMART** (si disponible) :
    
    - Erreurs de lecture/écriture
    - Secteurs réalloués
    - Température disque

> [!tip] Accès aux informations disque Diagnostics → Command Prompt → `df -h` pour l'espace Diagnostics → S.M.A.R.T. Status pour l'état des disques

### Monitoring réseau système

#### États de connexion

**Table d'états** (State Table) :

- Nombre de connexions actives
- Limite configurée (States)
- Utilisation en pourcentage

Visualisation : **Diagnostics → States** ou widget "States Summary"

> [!info] Dimensionnement Règle générale :
> 
> - Petit réseau (< 50 users) : 10,000 états
> - Réseau moyen (50-200 users) : 50,000 états
> - Grand réseau (> 200 users) : 100,000+ états

#### Utilisation de la bande passante

**Métriques importantes** :

1. **Bande passante instantanée** :
    
    - Mbps actuels In/Out
    - Visible dans les Traffic Graphs
2. **Patterns d'utilisation** :
    
    - Heures de pointe
    - Croissance tendancielle
    - Pics anormaux

> [!example] Identification de problèmes **Symptôme** : Bande passante WAN saturée à 100% constant **Causes possibles** :
> 
> - Download massif
> - Backup cloud en cours
> - Malware (botnet, cryptomining)
> - Attaque DDoS

### Surveillance des températures

#### Capteurs disponibles

Selon le matériel, pfSense peut monitorer :

- **CPU** : Température du processeur (critique : > 80°C)
- **Carte mère** : Chipset et autres composants
- **Disques** : Température des SSD/HDD (critique : > 60°C)
- **Réseau** : Puces réseau (si capteurs présents)

#### Actions en cas de surchauffe

> [!warning] Température critique Si température > 75°C de manière continue :
> 
> 1. Vérifier la ventilation (poussière, ventilateurs)
> 2. Vérifier la charge système (processus anormaux)
> 3. Considérer un refroidissement amélioré
> 4. Réduire la charge (désactiver services non essentiels temporairement)

---

## Graphiques de trafic

### Types de graphiques

#### Real-Time Traffic Graphs (Tableau de bord)

**Caractéristiques** :

- Mise à jour en temps réel (1-10 secondes)
- Affichage SVG interactif
- Échelle dynamique
- Données non persistantes (perdu au refresh)

**Cas d'usage** :

- Surveillance active pendant un incident
- Vérification immédiate de l'utilisation
- Tests de performance réseau

#### RRD Graphs (Graphiques historiques)

**Navigation** : Status → RRD Graphs

**Données collectées** :

- Trafic par interface (In/Out)
- États de connexion
- Utilisation CPU
- Utilisation mémoire

**Périodes disponibles** :

- Last Hour (1 heure)
- Last Day (1 jour)
- Last Week (1 semaine)
- Last Month (1 mois)
- Last Year (1 année)

> [!info] Résolution des données Plus la période est longue, plus les données sont agrégées :
> 
> - Hour : points toutes les minutes
> - Day : points toutes les 5 minutes
> - Week/Month : points toutes les 30 minutes
> - Year : points toutes les 2 heures

### Configuration des Traffic Graphs

#### Paramètres du widget Traffic Graphs

**Update Interval** :

```
1 second  → Réactivité maximale, charge CPU élevée
2 seconds → Bon compromis pour surveillance active
5 seconds → Recommandé pour usage normal
10 seconds → Vue d'ensemble, économie ressources
```

**Graph Type** :

- **SVG** : Moderne, interactif, recommandé
- **RRD** : Legacy, moins de fonctionnalités

**Interface Filter** :

- Sélectionner les interfaces à afficher
- Limiter pour réduire la charge d'affichage

> [!tip] Optimisation performances Sur un système à faibles ressources :
> 
> - Augmentez l'intervalle de mise à jour (5-10s)
> - Limitez le nombre d'interfaces affichées
> - Préférez les graphiques RRD historiques

### Interprétation des graphiques

#### Patterns normaux

**Trafic résidentiel** :

```
Journée : Pics 18h-23h (streaming, gaming)
Nuit : Faible trafic avec pics ponctuels (mises à jour)
Week-end : Trafic plus étalé sur la journée
```

**Trafic entreprise** :

```
Semaine : Pics 9h-12h et 14h-17h
Pause déjeuner : Baisse notable
Soirée/Week-end : Trafic minimal (sauf services critiques)
```

#### Patterns anormaux à investiguer

> [!warning] Signaux d'alerte
> 
> **Trafic constant et élevé 24/7** :
> 
> - Possible malware, botnet
> - Upload P2P non autorisé
> - Exfiltration de données
> 
> **Pics soudains et répétés** :
> 
> - Attaque DDoS
> - Scan réseau automatisé
> - Boucle réseau (broadcast storm)
> 
> **Déséquilibre In/Out important** :
> 
> - Upload >> Download : serveur non autorisé, fuite de données
> - Download >> Upload : téléchargements massifs

### Export et analyse de données

#### Exportation des graphiques

**Méthodes disponibles** :

1. **Screenshot** :
    
    - Clic droit → Enregistrer l'image
    - Pour rapports visuels
2. **Données brutes** :
    
    - Via packages additionnels (ntopng, Darkstat)
    - Export CSV pour analyse Excel/Python

#### Analyse avancée

> [!tip] Outils complémentaires Pour une analyse approfondie, considérez :
> 
> - **ntopng** : Analyse de trafic par protocole, application, host
> - **Darkstat** : Statistiques réseau détaillées
> - **Bandwidthd** : Graphiques de bande passante par IP
> 
> Installation : System → Package Manager

---

## États des services

### Services système critiques

#### Résolveur DNS (Unbound)

**État normal** : Running

**Fonctions** :

- Résolution de noms de domaine
- Cache DNS local
- Support DNSSEC (si activé)

**Vérification de fonctionnement** :

```
Diagnostics → DNS Lookup
Test : google.com
Résultat attendu : Adresse IP retournée rapidement
```

> [!warning] Service arrêté Si Unbound est arrêté :
> 
> - Aucune résolution DNS possible
> - Pas d'accès Internet (sauf par IP)
> - Les clients ne peuvent naviguer
> 
> **Action** : Redémarrage immédiat requis

#### Serveur DHCP (dhcpd)

**État normal** : Running (si DHCP activé sur les interfaces)

**Fonctions** :

- Attribution automatique d'adresses IP
- Configuration réseau des clients (passerelle, DNS)
- Gestion des baux DHCP

**Vérification** :

```
Status → DHCP Leases
Vérifier : Présence de baux actifs pour les clients connectés
```

> [!info] Multiples instances Un processus dhcpd tourne par interface avec DHCP activé :
> 
> - dhcpd (LAN)
> - dhcpd (OPT1)
> - etc.

#### Serveur NTP (ntpd)

**État normal** : Running

**Importance** :

- Synchronisation horaire précise
- Essentiel pour les logs horodatés
- Requis pour les certificats SSL/TLS
- Critique pour les VPN IPsec

**Vérification de synchronisation** :

```
Status → NTP
Peer Status : Devrait montrer des serveurs synchronisés
Offset : < 100ms idéalement
```

> [!warning] Désynchronisation horaire Impact d'une horloge incorrecte :
> 
> - Logs inexploitables
> - Échecs de connexion VPN
> - Erreurs de certificats SSL
> - Problèmes Kerberos (Active Directory)

#### Service SSH (sshd)

**État** : Running ou Stopped selon configuration

**Sécurité** :

- Accès ligne de commande distant
- Désactivé par défaut (bonne pratique)
- Ne l'activer que si nécessaire

**Configuration** : System → Advanced → Secure Shell

> [!tip] Sécurisation SSH Si SSH activé :
> 
> - Changer le port par défaut (22 → autre)
> - Désactiver authentification par mot de passe (clés uniquement)
> - Limiter l'accès par IP source (règles firewall)
> - Utiliser des clés ED25519 ou RSA 4096 bits

### Services optionnels

#### Proxy Squid

**État** : Running si package installé et configuré

**Fonctions** :

- Proxy HTTP/HTTPS
- Cache web
- Filtrage de contenu

#### Snort/Suricata (IDS/IPS)

**État** : Running si package installé

**Monitoring spécifique** :

- Règles chargées
- Paquets analysés
- Alertes générées

#### Package HAProxy

**État** : Running si configuré

**Utilité** :

- Load balancing
- Reverse proxy
- SSL offloading

> [!info] Services tiers Les packages additionnels ont leurs propres interfaces de monitoring accessibles via leurs menus dédiés.

### Gestion des services depuis le tableau de bord

#### Actions disponibles

**Icônes d'action** :

|Icône|Action|Description|
|---|---|---|
|▶️|Start|Démarrer un service arrêté|
|⏹️|Stop|Arrêter un service en cours|
|🔄|Restart|Redémarrer (arrêt puis démarrage)|
|ℹ️|Info|Détails et configuration du service|

#### Quand redémarrer un service

**Situations courantes** :

1. **Après modification de configuration** :
    
    - Changement DNS → Restart Unbound
    - Modification DHCP → Restart dhcpd
    - Changement firewall → Reload filter (automatique généralement)
2. **En cas de dysfonctionnement** :
    
    - Service en état "crashed"
    - Réponses anormales du service
    - Consommation excessive de ressources
3. **Maintenance préventive** :
    
    - Redémarrage périodique de services à long uptime
    - Application de patchs ou mises à jour

> [!warning] Services interdépendants Certains services dépendent d'autres :
> 
> - Unbound peut dépendre de DHCP (pour enregistrer les clients locaux)
> - OpenVPN peut dépendre de Unbound (résolution DNS)
> 
> Redémarrer dans l'ordre de dépendance si nécessaire.

### Dépannage des services

#### Service ne démarre pas

**Diagnostic** :

1. **Vérifier les logs** :
    
    ```
    Status → System Logs → System
    Filtrer par nom du service
    ```
    
2. **Problèmes courants** :
    

|Symptôme|Cause possible|Solution|
|---|---|---|
|dhcpd ne démarre pas|Conflit de configuration|Vérifier les pools DHCP (pas de chevauchement)|
|Unbound échoue|Port 53 déjà utilisé|Désactiver le DNS forwarder (dnsmasq)|
|sshd refuse de démarrer|Configuration invalide|Vérifier System → Advanced → Secure Shell|

> [!example] Conflit de port **Erreur** : "Cannot bind to port 53"
> 
> **Cause** : Deux services tentent d'utiliser le même port
> 
> **Solution** :
> 
> 1. Services → DNS Resolver → Désactiver
> 2. Ou Services → DNS Forwarder → Désactiver
> 3. Garder un seul service DNS actif

#### Service en état "crashed"

**Actions de récupération** :

1. Tentative de redémarrage manuel
2. Si échec persistant :
    - Vérifier les logs détaillés
    - Vérifier l'espace disque disponible
    - Vérifier la mémoire disponible
3. En dernier recours : reboot système (si service critique)

> [!tip] Logs détaillés Pour des logs plus verbeux :
> 
> - Certains services permettent d'augmenter le niveau de log
> - Vérifier Status → System Logs → System (onglet Settings)
> - Temporairement activer le mode debug si disponible

---

## Personnalisation avancée

### Ajout et suppression de widgets

#### Ajouter un widget

1. Cliquer sur le bouton **+ (Add Widget)** en haut à droite
2. Sélectionner le widget souhaité dans la liste déroulante
3. Cliquer sur **Add** ou glisser-déposer
4. Le widget apparaît dans la première colonne

#### Supprimer un widget

1. Cliquer sur l'icône **✕ (Close)** dans l'en-tête du widget
2. Confirmation : le widget disparaît immédiatement

> [!info] Widgets obligatoires Certains widgets (System Information) ne peuvent pas être supprimés car jugés essentiels.

### Organisation et positionnement

#### Réorganisation par glisser-déposer

**Méthode** :

1. Cliquer et maintenir sur l'en-tête du widget
2. Déplacer vers la position souhaitée
3. Relâcher pour fixer la position

**Organisation multi-colonnes** :

- Déplacer entre les colonnes
- Ordre vertical au sein d'une colonne
- Sauvegarde automatique de la disposition

> [!tip] Organisation efficace **Disposition recommandée pour une vue opérateur** :
> 
> **Colonne 1 (gauche)** :
> 
> - System Information
> - Interfaces
> - Services Status
> 
> **Colonne 2 (droite)** :
> 
> - Traffic Graphs
> - Firewall Logs
> - Gateway Status

### Configuration spécifique des widgets

#### Widget Traffic Graphs - Options avancées

**Paramètres disponibles** :

```
Update Interval: 1-10 seconds
Graph Type: SVG / RRD
Inverse: Inverser l'affichage In/Out
Show axis: Afficher les axes et graduations
Interface: Filtrer par interface spécifique
```

**Personnalisation visuelle** :

- Couleurs personnalisables (selon le thème)
- Échelle logarithmique vs linéaire
- Affichage de la légende

#### Widget Firewall Logs - Filtres

**Options de filtrage** :

|Filtre|Options|Usage|
|---|---|---|
|**Interface**|Any, WAN, LAN, OPTx|Isoler le trafic d'une interface|
|**Action**|Any, Pass, Block, Reject|Voir seulement les blocages ou passages|
|**Lines**|5, 10, 20, 50|Nombre de lignes affichées|

> [!example] Surveillance de sécurité Configuration optimale pour détecter les menaces :
> 
> - Interface : WAN
> - Action : Block
> - Lines : 20
> 
> Permet de voir rapidement les tentatives d'intrusion bloquées.

#### Widget Services - Personnalisation

**Filtrage des services affichés** :

- Afficher tous les services
- Masquer certains services non pertinents
- Ordre d'affichage personnalisable

### Thèmes et apparence

#### Thèmes disponibles

pfSense propose plusieurs thèmes via **System → General Setup** :

|Thème|Caractéristiques|
|---|---|
|**pfSense-dark**|Thème sombre, repose les yeux|
|**pfSense**|Thème clair par défaut|
|**Red**|Variante rouge|
|**Blue**|Variante bleue|

> [!tip] Économie d'énergie Le thème dark réduit la consommation d'énergie sur les écrans OLED et améliore le confort visuel lors de sessions prolongées.

#### Adaptation responsive

Le tableau de bord s'adapte automatiquement :

- **Desktop** : Affichage complet multi-colonnes
- **Tablet** : 1-2 colonnes selon orientation
- **Mobile** : 1 colonne, widgets empilés verticalement

### Sauvegarde de la configuration du tableau de bord

#### Export de la disposition

La disposition du tableau de bord est sauvegardée automatiquement dans la configuration globale de pfSense.

**Méthode de sauvegarde complète** :

1. Diagnostics → Backup & Restore
2. Backup Configuration → Download configuration as XML
3. Conserver le fichier en lieu sûr

> [!info] Portabilité La configuration du tableau de bord est incluse dans le backup complet de pfSense. En restaurant une configuration, vous récupérez votre disposition personnalisée.

#### Réinitialisation du tableau de bord

**Pour revenir à la configuration par défaut** :

1. Supprimer tous les widgets personnalisés
2. Ou restaurer une configuration pfSense vierge
3. Les widgets par défaut réapparaissent automatiquement

---

## Bonnes pratiques

### Surveillance quotidienne

#### Checklist matinale (5 minutes)

> [!tip] Routine de vérification **Chaque début de journée** :
> 
> 1. **System Activity** :
>     - ✓ CPU < 80%
>     - ✓ Memory < 90%
>     - ✓ Aucun swap utilisé
> 2. **Interfaces** :
>     - ✓ Toutes les interfaces critiques "Up"
>     - ✓ Adresses IP correctes
> 3. **Services Status** :
>     - ✓ Tous les services critiques "Running"
>     - ✓ Aucun service en état "crashed"
> 4. **Gateway Status** :
>     - ✓ Passerelles "Online"
>     - ✓ Latence acceptable (< 50ms)
>     - ✓ Perte de paquets < 1%
> 5. **Firewall Logs** :
>     - ✓ Pas d'activité suspecte massive
>     - ✓ Pas de nouvelles sources de scan

#### Surveillance hebdomadaire (15 minutes)

**Actions recommandées** :

1. **Analyser les graphiques RRD** :
    
    - Tendances de bande passante sur 7 jours
    - Identifier les pics anormaux
    - Vérifier la croissance du trafic
2. **Vérifier l'espace disque** :
    
    - Diagnostics → Command Prompt → `df -h`
    - Nettoyer les logs si nécessaire
3. **Réviser les états de connexion** :
    
    - Diagnostics → States
    - Vérifier que l'utilisation reste < 80% de la limite
4. **Examiner les logs système** :
    
    - Status → System Logs → System
    - Rechercher erreurs ou warnings répétitifs

### Optimisation des performances de monitoring

#### Réduction de la charge CPU

**Si le tableau de bord consomme trop de ressources** :

|Action|Impact|Économie CPU|
|---|---|---|
|Augmenter l'intervalle de mise à jour (5-10s)|Léger|~10%|
|Réduire le nombre de widgets Traffic Graphs|Moyen|~20%|
|Désactiver les widgets inutilisés|Variable|Variable|
|Passer de SVG à RRD graphs|Faible|~5%|

> [!warning] Équilibre performance/visibilité Ne sacrifiez pas la visibilité critique pour économiser des ressources. Si le CPU est constamment surchargé par le monitoring, c'est le signe d'un matériel sous-dimensionné.

#### Gestion de la mémoire

**Widgets gourmands en mémoire** :

- Traffic Graphs (données en cache)
- Firewall Logs (buffer des entrées)
- Services avec logs actifs

**Optimisations** :

```
Firewall Logs : Limiter à 10-20 lignes au lieu de 50
Traffic Graphs : 1 graphique par interface critique seulement
RRD Graphs : Privilégier la consultation à la demande vs affichage permanent
```

### Alerting et notifications

#### Surveillance passive vs active

**Surveillance passive** (tableau de bord) :

- ✓ Nécessite une vérification manuelle régulière
- ✓ Pas de configuration complexe
- ✗ Peut manquer des incidents hors heures ouvrées

**Surveillance active** (recommandé en production) :

- ✓ Alertes automatiques par email/SMS
- ✓ Détection 24/7
- ✗ Nécessite configuration supplémentaire (packages)

> [!tip] Packages d'alerting Pour mettre en place des alertes automatiques :
> 
> - **Monit** : Monitoring système avec alertes email
> - **Zabbix Agent** : Intégration avec Zabbix
> - **SNMP** : Monitoring via outils tiers (Nagios, PRTG, LibreNMS)
> 
> Installation : System → Package Manager

#### Événements à surveiller prioritairement

**Alertes critiques** :

|Événement|Seuil|Action requise|
|---|---|---|
|Interface down|Immédiat|Investigation urgente|
|Gateway offline|> 5 min|Vérifier connectivité FAI|
|Service crashed|Immédiat|Redémarrage + analyse logs|
|CPU > 90%|> 10 min|Identifier processus gourmand|
|Memory > 95%|> 5 min|Investigation mémoire leak|
|Disk > 90%|Immédiat|Nettoyage logs|

**Alertes d'avertissement** :

|Événement|Seuil|Action|
|---|---|---|
|Latence élevée|> 100ms persistant|Vérifier qualité lien|
|Perte paquets|> 2%|Investigation réseau|
|CPU > 70%|> 30 min|Planifier upgrade|
|States > 80%|Persistant|Augmenter limite|

### Documentation et procédures

#### Tenir un journal de bord

**Informations à documenter** :

1. **Baseline de performance** :
    
    - CPU moyen en heures creuses/pleines
    - Bande passante typique
    - Nombre d'états moyen
    - Memory usage normal
2. **Incidents et résolutions** :
    
    - Date/heure de l'incident
    - Symptômes observés sur le tableau de bord
    - Actions entreprises
    - Résolution et leçons apprises
3. **Modifications de configuration** :
    
    - Date de changement
    - Raison du changement
    - Impact observé sur les métriques

> [!example] Template d'incident
> 
> ```
> Date : 2026-01-10 14:30
> Symptôme : CPU à 95%, bande passante WAN saturée
> Observation : Traffic Graph montre upload massif constant
> Investigation : Diagnostics → States → IP 192.168.1.45 avec 5000+ états
> Cause : Malware sur poste utilisateur
> Action : Blocage temporaire de l'IP, nettoyage du poste
> Résolution : 15:00 - CPU revenu à 15%, trafic normal
> Prévention : Ajout règle IDS pour détecter ce pattern
> ```

#### Création de dashboards spécialisés

**Via des navigateurs multiples ou profils** :

1. **Dashboard Sécurité** :
    
    - Firewall Logs (Block only)
    - IPsec/OpenVPN Status
    - Services Status (VPN, IDS/IPS)
    - Gateway Status
2. **Dashboard Performance** :
    
    - System Activity
    - Traffic Graphs (toutes interfaces)
    - States Summary
    - RRD Graphs link
3. **Dashboard Utilisateur** :
    
    - Services Status (DHCP, DNS)
    - Interfaces (LAN seulement)
    - DHCP Leases
    - Information minimale

> [!info] Multi-écrans Pour un NOC (Network Operations Center) :
> 
> - Écran 1 : Dashboard principal complet
> - Écran 2 : RRD Graphs en plein écran (Status → RRD Graphs)
> - Écran 3 : Logs en temps réel (Status → System Logs)

### Intégration avec outils externes

#### Export de métriques

**Protocoles et méthodes** :

1. **SNMP** (Simple Network Management Protocol) :
    
    - Services → SNMP → Activer
    - Permet la collecte par Nagios, PRTG, Zabbix, LibreNMS
    - Métriques : CPU, RAM, interfaces, températures
2. **Syslog distant** :
    
    - Status → System Logs → Settings → Remote Logging
    - Centralisation des logs sur serveur Syslog/Graylog/Splunk
3. **API REST** (via packages) :
    
    - Accès programmatique aux données
    - Automatisation de la collecte

> [!tip] Monitoring centralisé Pour gérer plusieurs pfSense :
> 
> - Déployer un serveur LibreNMS ou Zabbix
> - Activer SNMP sur tous les pfSense
> - Créer des dashboards centralisés
> - Alertes unifiées pour toute l'infrastructure

#### Scripts de monitoring personnalisés

**Accès aux données via CLI** :

```bash
# État des interfaces
pfctl -si

# Statistiques de trafic
netstat -ibn

# États de connexion
pfctl -ss

# Charge système
top -d 1
```

**Automatisation** :

- Créer des scripts shell pour collecter ces données
- Scheduler via cron (Services → Cron)
- Exporter vers InfluxDB/Prometheus pour graphiques Grafana

### Maintenance préventive basée sur le monitoring

#### Signaux d'alerte pour maintenance

**Indicateurs de vieillissement** :

|Signe|Signification|Action|
|---|---|---|
|CPU baseline en augmentation|Charge croissante|Planifier upgrade CPU/réseau|
|Memory baseline croissante|Memory leak possible|Redémarrages préventifs périodiques|
|Disk usage augmente rapidement|Logs excessifs|Rotation logs plus agressive|
|Température en hausse|Ventilation dégradée|Nettoyage physique|

#### Planning de maintenance

**Maintenance mensuelle** :

1. **Nettoyage** :
    
    - Rotation manuelle des logs si nécessaire
    - Suppression des états obsolètes (Diagnostics → States → Reset States)
    - Vérification espace disque
2. **Vérification matérielle** :
    
    - Températures dans les normes
    - Aucun message SMART warning
    - Ventilateurs fonctionnels
3. **Mise à jour** :
    
    - Vérifier disponibilité updates (System → Update)
    - Planifier fenêtre de maintenance
    - Backup avant update

**Maintenance trimestrielle** :

1. **Analyse de tendances** :
    
    - Comparer RRD graphs sur 3 mois
    - Identifier patterns de croissance
    - Ajuster ressources si nécessaire
2. **Audit de configuration** :
    
    - Réviser règles firewall inutilisées
    - Nettoyer DHCP static mappings obsolètes
    - Vérifier pertinence des services activés
3. **Tests de charge** :
    
    - Vérifier comportement sous charge
    - Tester failover (si multi-WAN)
    - Valider sauvegardes de configuration

> [!warning] Fenêtre de maintenance Toujours planifier les opérations de maintenance :
> 
> - Heures creuses (nuit/week-end)
> - Notification aux utilisateurs
> - Backup configuration récent
> - Plan de rollback préparé
> - Accès physique au serveur si possible

---

## Pièges courants

### Erreurs de configuration

#### Widgets mal configurés

> [!warning] Problèmes fréquents
> 
> **Traffic Graph affiche "No data"** :
> 
> - Cause : Interface sélectionnée inexistante ou down
> - Solution : Vérifier le filtre d'interface du widget
> 
> **Services Status vide** :
> 
> - Cause : Aucun service configuré/actif
> - Solution : Normal si installation minimale, ajouter services si besoin
> 
> **Gateway Status n'apparaît pas** :
> 
> - Cause : Aucune gateway monitoring configurée
> - Solution : System → Routing → Gateways → Activer monitoring

#### Surcharge d'informations

**Symptôme** : Tableau de bord illisible, trop de widgets

**Conséquence** :

- Informations critiques noyées
- Charge CPU/RAM inutile
- Temps de chargement élevé

**Solution** :

- Limiter à 6-8 widgets maximum
- Prioriser les widgets critiques
- Créer plusieurs "vues" via profils utilisateur différents

### Mauvaise interprétation des données

#### Load Average mal compris

> [!example] Erreur fréquente **Fausse alerte** : "Load average 2.5 = système surchargé !"
> 
> **Réalité** : Sur un système 4 cœurs, 2.5 = 62.5% d'utilisation (NORMAL)
> 
> **Règle** : Divisez le load average par le nombre de cœurs CPU pour obtenir le % réel d'utilisation.

#### Mémoire "faible" mais normale

**Confusion** : "Free memory à 10%, système à court de RAM !"

**Explication** :

- Unix/Linux utilise la RAM "libre" comme cache
- C'est une OPTIMISATION, pas un problème
- La vraie métrique : Available memory (Free + Cache + Inactive)

**Vérification** :

```
Memory Usage : 7.2 GB / 8 GB (90%) ← Semble critique
Details:
  Active: 3.5 GB
  Inactive: 2.8 GB (libérable)
  Cache: 0.9 GB (libérable)
  Free: 0.8 GB
  
Available = 0.8 + 2.8 + 0.9 = 4.5 GB ← En réalité 56% disponible !
```

### Négligence de la surveillance

#### "Tableau de bord toujours ouvert = surveillance active"

> [!warning] Fausse sécurité Avoir le tableau de bord affiché H24 ne garantit PAS :
> 
> - Que quelqu'un regarde effectivement
> - La détection d'incidents nocturnes
> - L'alerte en cas de problème
> 
> **Solution** : Implémenter de vraies alertes automatiques (email, SNMP, Monit)

#### Ignorer les tendances long terme

**Erreur** : Se concentrer uniquement sur l'état instantané

**Risque** :

- Manquer une dégradation progressive
- Croissance non anticipée (saturation soudaine)
- Usure matérielle non détectée

**Solution** :

- Consulter les RRD Graphs hebdomadairement
- Comparer mois par mois
- Documenter les baselines

### Performance et stabilité

#### Trop de graphiques en temps réel

**Symptôme** : CPU élevé constant, interface lente

**Cause** : 5+ widgets Traffic Graphs avec update à 1 seconde

**Impact** :

- Charge CPU inutile (15-25%)
- Latence interface web
- Ressources détournées du filtrage

**Solution** :

```
Avant : 6 graphiques × 1 seconde = 6 req/s
Après : 2 graphiques × 5 secondes = 0.4 req/s
Économie : ~93% de requêtes en moins
```

#### Logs excessifs saturant le disque

**Scénario** : Firewall Logs widget + logging intensif

**Résultat** :

- `/var` partition pleine
- pfSense ne peut plus écrire de logs
- Risque de crash de services

**Prévention** :

1. Status → System Logs → Settings
2. Limiter la taille des logs (500 KB par fichier)
3. Activer la rotation automatique
4. Envisager syslog distant pour archivage long terme

---

## Astuces avancées

### Raccourcis et navigation rapide

#### Raccourcis clavier

|Raccourci|Action|
|---|---|
|`Alt + Shift + F`|Focus sur la barre de recherche|
|`Ctrl + F5`|Rafraîchir sans cache|
|`Esc`|Fermer dialogue/popup|

#### Favoris navigateur

**URLs directes utiles** :

```
https://pfsense.local/status.php                  → Dashboard
https://pfsense.local/status_graph.php            → Traffic Graphs
https://pfsense.local/status_rrd_graph.php        → RRD Graphs  
https://pfsense.local/diag_logs_filter.php        → Firewall Logs
https://pfsense.local/status_dhcp_leases.php      → DHCP Leases
https://pfsense.local/diag_system_activity.php    → System Activity
```

> [!tip] Marque-pages organisés Créer un dossier "pfSense Monitoring" avec ces liens pour accès rapide aux sections critiques.

### Utilisation de plusieurs sessions

#### Multi-fenêtres pour surveillance complète

**Configuration écran large** :

```
Fenêtre 1 (gauche) : Dashboard principal
Fenêtre 2 (centre) : Status → RRD Graphs (auto-refresh)
Fenêtre 3 (droite) : Diagnostics → States Summary
```

**Mode plein écran** :

- F11 dans le navigateur
- Masquer barres d'outils
- Widgets essentiels seulement
- Idéal pour affichage mural NOC

### Automatisation du monitoring

#### Auto-refresh navigateur

**Extensions navigateur recommandées** :

1. **Auto Refresh** (Chrome/Firefox) :
    
    - Configurer refresh toutes les 30-60 secondes
    - Spécifique à l'onglet Dashboard
    - Permet surveillance passive prolongée
2. **Tab Reloader** :
    
    - Refresh multiple onglets
    - Rotation automatique entre onglets

> [!warning] Attention aux sessions L'auto-refresh peut causer des timeouts de session. Augmenter le timeout dans System → Advanced → Admin Access → Session Timeout.

#### Scripts de vérification santé

**Exemple : Check santé via curl** :

```bash
#!/bin/bash
# health_check.sh - Vérification état pfSense

PFSENSE="https://192.168.1.1"
USER="admin"
PASS="password"

# Récupérer état des services (nécessite API ou parsing HTML)
curl -k -u "$USER:$PASS" "$PFSENSE/status_services.php" | \
  grep -i "stopped\|crashed" && \
  echo "ALERTE: Service down!" | mail -s "pfSense Alert" admin@domain.com

# Vérifier CPU > 90%
# ... (parsing du dashboard ou SNMP)
```

> [!info] Alternatives professionnelles Pour une solution robuste, préférer :
> 
> - SNMP + Nagios/Zabbix
> - API REST via packages
> - Solutions commerciales (pfSense+, Netgate SG appliances)

### Personnalisation CSS (avancé)

#### Modifier l'apparence des widgets

**Via System → Advanced → Admin Access → Custom CSS** :

```css
/* Augmenter taille police des graphiques */
.traffic-graph {
  font-size: 14px;
}

/* Mettre en évidence services critiques */
.service-stopped {
  background-color: #ff000020 !important;
  border-left: 4px solid red;
}

/* Améliorer lisibilité tableaux */
.table-striped tr:hover {
  background-color: #f5f5f5;
}
```

> [!warning] Support non garanti Les modifications CSS personnalisées peuvent être écrasées lors des mises à jour pfSense. À utiliser avec précaution.

### Intégration avec Grafana

**Pour des dashboards avancés** :

1. **Activer SNMP** sur pfSense
2. **Installer Telegraf** (collecteur SNMP)
3. **Configurer InfluxDB** (stockage time-series)
4. **Créer dashboards Grafana** :
    - Graphiques avancés
    - Alertes configurables
    - Visualisations personnalisées
    - Corrélation multi-sources

**Avantages** :

- Historique long terme (années)
- Dashboards partagés
- Alertes sophistiquées
- Corrélation avec autres systèmes

---

## Résumé des points clés

> [!tip] À retenir absolument
> 
> **Configuration du tableau de bord** :
> 
> - ✓ Personnalisez selon vos besoins critiques
> - ✓ Limitez le nombre de widgets (6-8 max)
> - ✓ Organisez par priorité (critique = haut/gauche)
> 
> **Surveillance quotidienne** :
> 
> - ✓ Vérifiez System Activity (CPU, RAM)
> - ✓ Contrôlez l'état des Interfaces
> - ✓ Assurez-vous que les Services critiques tournent
> - ✓ Surveillez les Gateways
> 
> **Interprétation des métriques** :
> 
> - ✓ Load average ÷ nombre de cœurs = % utilisation réel
> - ✓ Mémoire "disponible" ≠ mémoire "libre"
> - ✓ Consultez les RRD Graphs pour les tendances
> 
> **Maintenance** :
> 
> - ✓ Analysez les graphiques hebdomadaires
> - ✓ Documentez les baselines de performance
> - ✓ Mettez en place des alertes automatiques
> - ✓ Planifiez les maintenances préventives
> 
> **Escalade** :
> 
> - ✓ Tableau de bord = surveillance de base
> - ✓ Pour production : SNMP + monitoring dédié (Nagios/Zabbix)
> - ✓ Pour analyse poussée : Grafana + InfluxDB

---

**📚 Fin du cours : Tableau de bord et monitoring**

_Ce cours couvre les fondamentaux du monitoring via l'interface pfSense. Pour des besoins avancés (alerting automatique, corrélation multi-systèmes, rétention long terme), explorez les solutions de monitoring tierces compatibles SNMP._