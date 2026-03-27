

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

## 🎯 Introduction aux passerelles

### Qu'est-ce qu'une passerelle (Gateway) ?

Une passerelle est un point de sortie du réseau local vers d'autres réseaux. Dans pfSense, les passerelles permettent de :

- **Router le trafic** vers Internet ou d'autres réseaux
- **Gérer plusieurs connexions WAN** (multi-WAN)
- **Implémenter la redondance** avec basculement automatique
- **Effectuer le load balancing** entre plusieurs liens
- **Monitorer la disponibilité** des connexions

> [!info] Passerelle par défaut La passerelle par défaut est utilisée pour tout le trafic qui ne correspond à aucune route spécifique. C'est généralement votre connexion Internet principale.

### Types de passerelles dans pfSense

|Type|Description|Utilisation|
|---|---|---|
|**Gateway par défaut**|Passerelle principale du système|Connexion Internet principale|
|**Gateway secondaire**|Passerelle de backup ou alternative|Redondance, multi-WAN|
|**Gateway dynamique**|Obtenue via DHCP ou PPPoE|Connexions dynamiques ISP|
|**Gateway statique**|Configurée manuellement|Réseaux d'entreprise, VPN|

---

## ⚙️ Configuration des passerelles

### Accès à la configuration

**Navigation** : `System` → `Routing` → `Gateways`

Cette page affiche toutes les passerelles configurées et permet de les gérer.

### Création d'une passerelle

#### Étape 1 : Ajouter une nouvelle passerelle

Cliquez sur `+ Add` pour créer une nouvelle passerelle.

#### Étape 2 : Paramètres de base

```
Interface          : Sélectionner l'interface (WAN, LAN, OPT1, etc.)
Address Family     : IPv4 ou IPv6
Name              : Nom descriptif (ex: WAN_GATEWAY, ISP2_GW)
Gateway           : Adresse IP de la passerelle
```

> [!example] Exemple de configuration **Interface** : WAN **Name** : WAN_PRIMARY **Gateway** : 192.168.1.1 **Description** : Passerelle Internet principale - Fibre Orange

#### Étape 3 : Paramètres de monitoring

```
Monitor IP        : IP à ping pour vérifier la disponibilité
                   (par défaut : l'IP de la gateway elle-même)
```

> [!tip] Choix du Monitor IP Utilisez des IP publiques fiables comme :
> 
> - `8.8.8.8` (Google DNS)
> - `1.1.1.1` (Cloudflare DNS)
> - `208.67.222.222` (OpenDNS)
> 
> Ne PAS utiliser l'IP de la gateway elle-même si le modem peut répondre au ping même sans connexion Internet.

#### Étape 4 : Paramètres avancés de monitoring

```
Disable Gateway Monitoring        : Désactiver la surveillance (déconseillé)
Disable Gateway Monitoring Action : Ne pas marquer down si ping échoue

APINGER Settings :
  Probe Interval    : Intervalle entre les pings (défaut: 1 seconde)
  Loss Interval     : Période pour calculer la perte (défaut: 10 pings)
  Time Period       : Période pour calcul de latence (défaut: 60 secondes)
  Alert Interval    : Seuil perte pour alerte (défaut: 10 paquets)
  Delay Interval    : Seuil latence pour alerte (défaut: 500ms)
  Loss Interval     : Seuil perte pour down (défaut: 20 paquets)
```

> [!warning] Monitoring trop agressif Des paramètres de monitoring trop sensibles peuvent causer des basculements intempestifs. Gardez les valeurs par défaut sauf besoins spécifiques.

#### Étape 5 : Options avancées

```
Weight                    : Poids pour load balancing (1-30)
Data Payload              : Taille des paquets ICMP (défaut: 0)
Latency Thresholds       : Seuils de latence personnalisés
Packet Loss Thresholds   : Seuils de perte personnalisés
Use non-local gateway    : Autoriser gateway hors sous-réseau
```

### Configuration d'une passerelle par défaut

**Navigation** : `System` → `Routing` → `Gateways` → onglet `Configuration`

Dans la colonne "Default", cochez la gateway qui doit servir de passerelle par défaut.

> [!info] Une seule passerelle par défaut Vous ne pouvez avoir qu'une seule passerelle par défaut par famille d'adresses (une pour IPv4, une pour IPv6).

### Passerelles automatiques vs manuelles

#### Passerelles automatiques

Créées automatiquement par pfSense lors de :

- Configuration d'une interface en DHCP
- Configuration PPPoE/PPTP
- Détection automatique de gateway sur interface statique

> [!warning] Passerelles automatiques Les passerelles automatiques ne peuvent pas être modifiées directement. Pour les personnaliser, créez une passerelle manuelle avec les mêmes paramètres.

#### Passerelles manuelles

Créées manuellement pour :

- Connexions statiques
- Multi-WAN avec contrôle précis
- Routes spécifiques vers d'autres réseaux
- Configuration avancée de monitoring

---

## 🛣️ Routes statiques

### Comprendre le routage

Le routage détermine le chemin que prendra un paquet pour atteindre sa destination. pfSense utilise une table de routage pour prendre ces décisions.

**Navigation** : `System` → `Routing` → `Routes` → onglet `Static Routes`

### Quand utiliser des routes statiques ?

Les routes statiques sont nécessaires dans ces scénarios :

1. **Accès à des sous-réseaux distants** : Réseaux accessibles via un routeur intermédiaire
2. **Réseaux multiples derrière pfSense** : Plusieurs segments réseau connectés
3. **VPN site-to-site** : Routage vers réseaux distants via tunnel
4. **Policy routing** : Forcer certains trafics vers des passerelles spécifiques

> [!example] Cas d'usage typique Votre pfSense est connecté à un réseau 192.168.1.0/24, mais vous devez accéder au réseau 10.0.0.0/24 qui se trouve derrière un autre routeur à l'adresse 192.168.1.254.

### Création d'une route statique

#### Étape 1 : Ajouter une route

Cliquez sur `+ Add` dans l'onglet Static Routes.

#### Étape 2 : Configuration de la route

```
Destination network : Réseau de destination (ex: 10.0.0.0/24)
Gateway            : Passerelle à utiliser pour atteindre ce réseau
Disabled           : Désactiver la route sans la supprimer
Description        : Description de la route
```

> [!example] Exemple de route statique **Destination** : 10.0.0.0/24 **Gateway** : LAN_ROUTER (192.168.1.254) **Description** : Route vers réseau du site distant Paris

#### Comprendre les masques CIDR

|Notation CIDR|Masque de sous-réseau|Nombre d'hôtes|
|---|---|---|
|/32|255.255.255.255|1 (hôte unique)|
|/24|255.255.255.0|254|
|/16|255.255.0.0|65,534|
|/8|255.0.0.0|16,777,214|
|/0|0.0.0.0|Route par défaut|

### Routes et priorités

Si plusieurs routes correspondent à une destination, pfSense utilise :

1. **La route la plus spécifique** (masque le plus long)
2. **La route avec la métrique la plus basse**
3. **La passerelle par défaut** en dernier recours

> [!tip] Route la plus spécifique gagne Une route vers 10.0.1.0/24 sera préférée à 10.0.0.0/16 pour une destination dans 10.0.1.0/24.

### Routes pour réseaux privés

Configuration typique pour accéder aux réseaux privés RFC1918 :

```
192.168.0.0/16  → Gateway: ROUTER_INTERNE
10.0.0.0/8      → Gateway: ROUTER_INTERNE
172.16.0.0/12   → Gateway: ROUTER_INTERNE
```

> [!warning] Éviter les conflits de routes Assurez-vous que vos routes ne créent pas de boucles de routage. Une route mal configurée peut rendre des réseaux inaccessibles.

### Vérification des routes actives

Pour voir les routes actives dans le système :

**Navigation** : `Diagnostics` → `Routes`

Cette page affiche :

- Toutes les routes dans la table de routage
- L'interface utilisée
- La passerelle
- Les flags de route (U=up, G=gateway, S=static, etc.)

---

## 👥 Groupes de passerelles

Les groupes de passerelles (Gateway Groups) permettent d'implémenter le **failover** (basculement) et le **load balancing** (répartition de charge) entre plusieurs connexions WAN.

**Navigation** : `System` → `Routing` → `Gateway Groups`

### Concepts fondamentaux

#### Tier (Niveau de priorité)

Les tiers définissent la priorité des passerelles dans un groupe :

- **Tier 1** : Passerelle(s) principale(s), utilisée(s) en premier
- **Tier 2** : Passerelle(s) de backup, utilisée(s) si Tier 1 down
- **Tier 3+** : Niveaux de backup supplémentaires

#### Virtual IP

Chaque groupe de passerelles se voit attribuer une adresse IP virtuelle pour le routage interne.

### Configuration d'un groupe de passerelles

#### Étape 1 : Créer le groupe

Cliquez sur `+ Add` dans Gateway Groups.

#### Étape 2 : Paramètres du groupe

```
Group Name          : Nom du groupe (ex: FAILOVER_GROUP, LB_GROUP)
Gateway Priority    : Configuration des tiers pour chaque gateway
Trigger Level       : Seuil pour considérer une gateway down
Description         : Description du groupe
```

> [!example] Configuration Failover **Nom** : FAILOVER_WAN
> 
> **Passerelles** :
> 
> - WAN_PRIMARY : Tier 1
> - WAN_BACKUP : Tier 2
> 
> **Trigger Level** : Packet Loss **Description** : Basculement automatique vers backup si primaire down

#### Étape 3 : Trigger Level (Niveau de déclenchement)

Options disponibles :

|Trigger Level|Description|
|---|---|
|**Member Down**|Basculer uniquement si gateway complètement down|
|**Packet Loss**|Basculer si perte de paquets détectée|
|**High Latency**|Basculer si latence élevée détectée|
|**Packet Loss or High Latency**|Basculer dans les deux cas|

> [!tip] Choix du Trigger Level
> 
> - **Member Down** : Pour basculement conservateur (vraie panne uniquement)
> - **Packet Loss** : Pour basculement rapide en cas de dégradation
> - **High Latency** : Pour applications sensibles à la latence (VoIP, jeux)

### Types de groupes de passerelles

#### 1. Failover (Basculement)

Configuration pour haute disponibilité :

```
WAN_PRIMARY    : Tier 1
WAN_BACKUP     : Tier 2
WAN_BACKUP2    : Tier 3
```

**Comportement** :

- Utilise WAN_PRIMARY tant qu'elle est disponible
- Bascule vers WAN_BACKUP si PRIMARY down
- Revient à PRIMARY quand elle redevient disponible

> [!info] Retour automatique Par défaut, pfSense revient automatiquement à la gateway de tier supérieur quand elle redevient disponible.

#### 2. Load Balancing (Répartition de charge)

Configuration pour distribuer la charge :

```
WAN1    : Tier 1
WAN2    : Tier 1
WAN3    : Tier 1
```

**Comportement** :

- Distribue les connexions entre toutes les gateways de Tier 1
- Si une gateway down, le trafic est redistribué sur les autres
- Répartition basée sur le poids (weight) de chaque gateway

#### 3. Load Balancing avec Failover

Configuration hybride :

```
WAN1    : Tier 1, Weight 3
WAN2    : Tier 1, Weight 2
WAN3    : Tier 2, Weight 1
```

**Comportement** :

- WAN1 et WAN2 en load balancing (60%/40% selon poids)
- WAN3 utilisée uniquement si WAN1 et WAN2 down

### Poids (Weight) dans le load balancing

Le poids détermine la proportion de trafic pour chaque gateway :

> [!example] Calcul de répartition **WAN1** : Weight 5 → 5/(5+3+2) = 50% du trafic **WAN2** : Weight 3 → 3/(5+3+2) = 30% du trafic **WAN3** : Weight 2 → 2/(5+3+2) = 20% du trafic

### Utilisation des groupes de passerelles

Une fois créés, les groupes peuvent être utilisés :

1. **Dans les règles de firewall** : Forcer du trafic spécifique via un groupe
2. **Comme passerelle par défaut** : Pour tout le trafic sortant
3. **Dans le NAT** : Pour source NAT spécifique
4. **Dans les VPN** : Pour router le trafic VPN

**Exemple de règle firewall avec groupe** :

```
Source      : LAN Network
Destination : any
Gateway     : FAILOVER_GROUP
```

---

## 📊 Monitoring des passerelles

Le monitoring permet de surveiller l'état et les performances de vos passerelles en temps réel.

### Dashboard Status

**Navigation** : `Status` → `Dashboard` → Widget `Gateways`

Le widget Gateways affiche :

- **État** de chaque gateway (Online/Offline)
- **RTT** (Round Trip Time) - latence en millisecondes
- **RTTsd** (RTT Standard Deviation) - variation de latence
- **Loss** - pourcentage de perte de paquets

> [!info] Interprétation des valeurs
> 
> - **RTT < 50ms** : Excellent
> - **RTT 50-100ms** : Bon
> - **RTT 100-200ms** : Acceptable
> - **RTT > 200ms** : Problématique
> - **Loss < 1%** : Normal
> - **Loss 1-5%** : Dégradation
> - **Loss > 5%** : Problème sérieux

### Page de statut détaillée

**Navigation** : `Status` → `Gateways`

Cette page fournit des informations détaillées :

```
Gateway Name    : Nom de la gateway
RTT             : Latence moyenne actuelle
RTTsd           : Écart-type de la latence
Loss            : Perte de paquets actuelle
Status          : Online/Offline/Warning
Delay           : Seuil de latence configuré
Loss            : Seuil de perte configuré
Monitor IP      : IP utilisée pour monitoring
```

### Graphiques de monitoring

**Navigation** : `Status` → `Monitoring` (ou `Status` → `RRD Graphs`)

Graphiques disponibles :

1. **Quality** : Latence et perte de paquets dans le temps
2. **Traffic** : Trafic entrant/sortant par interface
3. **Packets** : Nombre de paquets par seconde

> [!tip] Analyse des tendances Consultez régulièrement les graphiques pour :
> 
> - Identifier les patterns de performance
> - Détecter les dégradations progressives
> - Planifier les upgrades de capacité
> - Valider l'efficacité du load balancing

### États des passerelles

|État|Couleur|Description|
|---|---|---|
|**Online**|🟢 Vert|Gateway opérationnelle, ping OK|
|**Warning**|🟡 Jaune|Latence ou perte élevée mais < seuil down|
|**Offline**|🔴 Rouge|Gateway down, seuils dépassés|
|**Pending**|🔵 Bleu|Démarrage, pas encore de données|
|**Gathering data**|⚪ Gris|Collecte des premières statistiques|

### Logs de monitoring

**Navigation** : `Status` → `System Logs` → onglet `Gateways`

Les logs enregistrent :

- Changements d'état des gateways
- Basculements (failover events)
- Alertes de latence ou perte
- Retour en ligne des gateways

> [!example] Exemple de log
> 
> ```
> Jan 10 14:32:18 apinger WAN_PRIMARY: ONLINE (rtt 23.456ms loss 0%)
> Jan 10 14:35:42 apinger WAN_PRIMARY: ALARM latency high (rtt 156ms)
> Jan 10 14:36:01 apinger WAN_PRIMARY: DOWN (loss 100%)
> Jan 10 14:36:02 routing Switching to WAN_BACKUP gateway
> ```

### Alertes et notifications

Configuration des notifications :

**Navigation** : `System` → `Advanced` → onglet `Notifications`

Options disponibles :

- **Email** : Notifications par email (nécessite SMTP configuré)
- **Growl** : Notifications desktop (legacy)
- **Slack** : Webhooks Slack
- **SMTP** : Configuration du serveur mail

> [!tip] Notifications critiques Configurez les notifications pour être alerté immédiatement en cas de :
> 
> - Basculement de gateway
> - Gateway principale offline
> - Toutes gateways down (perte totale de connectivité)

### Commandes de diagnostic

Outils intégrés pour tester les gateways :

#### Ping

**Navigation** : `Diagnostics` → `Ping`

Test de connectivité basique :

```
Host     : 8.8.8.8
Count    : 5
Interface: WAN
```

#### Traceroute

**Navigation** : `Diagnostics` → `Traceroute`

Affiche le chemin réseau complet :

```
Host        : google.com
Max hops    : 30
Protocol    : ICMP
```

> [!tip] Diagnostic de routage Utilisez traceroute pour :
> 
> - Vérifier que le trafic utilise la bonne gateway
> - Identifier où se produit une perte de paquets
> - Diagnostiquer les problèmes de routage

---

## ⚠️ Pièges courants et bonnes pratiques

### Pièges courants

#### 1. Monitor IP mal choisi

❌ **Erreur** : Utiliser l'IP de la gateway du modem

```
Monitor IP: 192.168.1.1 (IP du modem)
```

**Problème** : Le modem peut répondre même sans connexion Internet

✅ **Solution** : Utiliser une IP publique fiable

```
Monitor IP: 8.8.8.8 ou 1.1.1.1
```

#### 2. Monitoring trop sensible

❌ **Erreur** : Paramètres trop agressifs

```
Alert Interval: 2 paquets
Loss Interval: 5 paquets
```

**Problème** : Basculements intempestifs sur micro-coupures

✅ **Solution** : Garder les valeurs par défaut ou augmenter

```
Alert Interval: 10 paquets
Loss Interval: 20 paquets
```

#### 3. Oublier de définir une gateway par défaut

❌ **Erreur** : Plusieurs gateways configurées, aucune par défaut

**Problème** : Le trafic sans route spécifique ne sait pas où aller

✅ **Solution** : Toujours avoir une gateway par défaut cochée

#### 4. Routes statiques en conflit

❌ **Erreur** : Routes qui se chevauchent

```
Route 1: 10.0.0.0/8    → Gateway A
Route 2: 10.1.0.0/16   → Gateway B
```

**Problème** : Comportement imprévisible pour 10.1.0.0/16

✅ **Solution** : Vérifier qu'il n'y a pas de chevauchement ou comprendre la priorité

#### 5. Load balancing pour trafic nécessitant IP stable

❌ **Erreur** : Load balancer tout le trafic

```
Gateway Group: LB_ALL (WAN1 + WAN2)
Default Gateway: LB_ALL
```

**Problème** : VPN, services bancaires, etc. peuvent bloquer les changements d'IP

✅ **Solution** : Règles spécifiques pour trafic sensible

```
Règle VPN      : Gateway = WAN1 uniquement
Règle Banking  : Gateway = WAN1 uniquement
Reste          : Gateway = LB_GROUP
```

#### 6. Ne pas tester le failover

❌ **Erreur** : Configurer et oublier

**Problème** : Découvrir que ça ne marche pas pendant une vraie panne

✅ **Solution** : Tester régulièrement

```
1. Débrancher WAN principale
2. Vérifier que le trafic bascule
3. Vérifier les logs
4. Rebrancher et vérifier le retour
```

### Bonnes pratiques

#### 1. Nomenclature cohérente

Adoptez une convention de nommage claire :

```
Gateways:
  WAN_PRIMARY
  WAN_BACKUP
  ISP2_FIBER
  VPN_SITE_PARIS

Groups:
  FAILOVER_INTERNET
  LB_WAN_BOTH
  BACKUP_ONLY

Routes:
  ROUTE_PARIS_10.0.0.0
  ROUTE_LYON_172.16.0.0
```

#### 2. Documentation des configurations

Utilisez les champs Description :

```
Gateway WAN_PRIMARY:
  "Fibre Orange 1Gb/s - IP Fixe 203.0.113.45 - Contact: 3900"

Route vers 10.0.0.0/24:
  "Réseau site distant Paris - via VPN IPsec - Contact: admin@paris.local"

Group FAILOVER_INTERNET:
  "Basculement auto Fibre→4G - Trigger: Packet Loss - Testé: 2025-01-10"
```

#### 3. Monitoring proactif

Configurez une surveillance complète :

```
✓ Notifications email pour changements d'état
✓ Vérification hebdomadaire des graphiques
✓ Test mensuel du failover
✓ Documentation des incidents
✓ Revue trimestrielle des performances
```

#### 4. Stratégie de gateway groups

Choisissez la stratégie selon vos besoins :

**Pour haute disponibilité maximale** :

```
WAN_PRIMARY : Tier 1
WAN_BACKUP  : Tier 2
WAN_BACKUP2 : Tier 3
Trigger: Member Down (conservateur)
```

**Pour performance maximale** :

```
WAN1 : Tier 1, Weight 1
WAN2 : Tier 1, Weight 1
Trigger: Packet Loss (agressif)
```

**Pour équilibre** :

```
WAN1 : Tier 1, Weight 2
WAN2 : Tier 1, Weight 1
WAN3 : Tier 2, Weight 1
Trigger: Packet Loss or High Latency
```

#### 5. Sécurité des routes

Évitez d'exposer des réseaux internes :

```
❌ Route publique: 192.168.1.0/24 → WAN
✅ Routes uniquement vers interfaces internes
✅ Vérifier que le NAT est actif pour WAN
```

#### 6. Performance du monitoring

Adaptez les paramètres selon la charge :

```
Petit réseau (< 10 utilisateurs):
  Probe Interval: 1s (défaut)
  
Réseau moyen (10-100 utilisateurs):
  Probe Interval: 2s
  
Grand réseau (> 100 utilisateurs):
  Probe Interval: 5s
  Alert/Loss Intervals: augmentés proportionnellement
```

#### 7. Backup de configuration

Sauvegardez régulièrement :

**Navigation** : `Diagnostics` → `Backup & Restore`

```
✓ Backup avant tout changement de routing
✓ Export mensuel de la config complète
✓ Test de restauration semestriel
✓ Documentation des versions
```

---

## 🎯 Résumé des points clés

> [!info] Points essentiels
> 
> - **Passerelles** : Points de sortie vers autres réseaux, nécessitent monitoring
> - **Monitor IP** : Utilisez des IP publiques fiables (8.8.8.8, 1.1.1.1)
> - **Routes statiques** : Nécessaires pour accéder à des réseaux non-directement connectés
> - **Gateway Groups** : Permettent failover et load balancing
> - **Tiers** : Définissent la priorité (Tier 1 = prioritaire)
> - **Trigger Level** : Détermine quand basculer (Member Down = conservateur, Packet Loss = agressif)
> - **Monitoring** : Vérifiez régulièrement les graphiques et logs
> - **Tests** : Testez vos configurations de failover régulièrement
> - **Documentation** : Documentez tout dans les champs Description

> [!warning] Erreurs à éviter absolument
> 
> - Monitor IP pointant vers le modem local
> - Pas de gateway par défaut définie
> - Load balancing de services nécessitant IP stable (VPN, banque)
> - Routes statiques en conflit
> - Oublier de tester le failover avant une vraie panne
> - Paramètres de monitoring trop agressifs causant des basculements intempestifs

> [!tip] Astuces de pro
> 
> - Créez des gateway groups même pour un seul WAN (facilite l'ajout futur)
> - Utilisez Weight pour prioriser les liens plus rapides en load balancing
> - Consultez les logs de gateways après chaque incident
> - Créez des règles firewall spécifiques pour le trafic critique
> - Documentez vos choix de configuration dans les descriptions
> - Planifiez des fenêtres de maintenance pour tester le failover