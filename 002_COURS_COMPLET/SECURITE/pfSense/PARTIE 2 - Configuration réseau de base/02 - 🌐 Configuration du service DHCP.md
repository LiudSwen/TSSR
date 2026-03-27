

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

## Introduction au DHCP

Le **DHCP** (Dynamic Host Configuration Protocol) est un protocole réseau qui permet d'attribuer automatiquement des configurations IP aux équipements du réseau. pfSense intègre un serveur DHCP complet basé sur ISC DHCP.

> [!info] Pourquoi utiliser DHCP ?
> 
> - **Automatisation** : Plus besoin de configurer manuellement chaque appareil
> - **Gestion centralisée** : Tous les paramètres réseau au même endroit
> - **Évite les conflits IP** : Le serveur gère l'attribution des adresses
> - **Flexibilité** : Modification rapide de la configuration réseau

### Fonctionnement du processus DHCP

Le processus d'attribution DHCP suit 4 étapes (DORA) :

|Étape|Nom|Description|
|---|---|---|
|1|**Discover**|Le client diffuse une demande sur le réseau|
|2|**Offer**|Le serveur propose une configuration IP|
|3|**Request**|Le client accepte la proposition|
|4|**Acknowledge**|Le serveur confirme l'attribution|

---

## Activation du serveur DHCP

### Accès à la configuration

**Navigation** : `Services > DHCP Server`

Vous verrez un onglet pour chaque interface configurée sur pfSense (LAN, OPT1, DMZ, etc.).

> [!warning] Prérequis important Le serveur DHCP ne peut être activé que sur des interfaces avec une adresse IP statique. Vous ne pouvez pas activer DHCP sur l'interface WAN si elle est configurée en DHCP client.

### Activation du service

Pour activer DHCP sur une interface :

1. Sélectionnez l'onglet de l'interface souhaitée (ex: **LAN**)
2. Cochez la case **Enable DHCP server on LAN interface**
3. La configuration devient alors éditable

> [!example] Exemple : Activation sur l'interface LAN
> 
> ```
> Interface : LAN (192.168.1.1/24)
> ✅ Enable DHCP server on LAN interface
> ```

### Paramètres de base visibles

Une fois activé, vous verrez :

- **Subnet** : Le sous-réseau de l'interface (lecture seule)
- **Subnet mask** : Le masque réseau (lecture seule)
- **Available range** : La plage complète disponible pour DHCP

> [!tip] Astuce pfSense calcule automatiquement la plage disponible en excluant l'adresse réseau, l'adresse de broadcast et l'IP du firewall lui-même.

---

## Configuration des plages d'adresses IP

### Définition de la plage (Range)

La plage DHCP détermine quelles adresses IP seront distribuées dynamiquement aux clients.

**Champs à configurer** :

- **Range from** : Première adresse IP de la plage
- **Range to** : Dernière adresse IP de la plage

> [!example] Exemple de configuration typique
> 
> ```
> Réseau : 192.168.1.0/24
> Gateway : 192.168.1.1 (pfSense)
> 
> Range from : 192.168.1.100
> Range to   : 192.168.1.200
> 
> → 101 adresses disponibles pour attribution dynamique
> ```

### Stratégie de découpage réseau

Il est recommandé de segmenter votre espace d'adressage :

|Plage|Usage|Exemple|
|---|---|---|
|`.1 - .50`|Équipements réseau et serveurs (IP statiques)|192.168.1.1 - 192.168.1.50|
|`.51 - .99`|Réservé pour extension future|192.168.1.51 - 192.168.1.99|
|`.100 - .200`|Pool DHCP dynamique|192.168.1.100 - 192.168.1.200|
|`.201 - .254`|Réservations DHCP statiques|192.168.1.201 - 192.168.1.254|

> [!warning] Erreur courante Ne créez pas une plage DHCP qui englobe toutes les adresses disponibles. Gardez des adresses en dehors du pool pour :
> 
> - Les équipements à IP fixe (serveurs, imprimantes réseau)
> - Les réservations statiques futures
> - Le dépannage (attribution temporaire manuelle)

### Paramètres complémentaires de la plage

**WINS servers** : Serveurs de résolution NetBIOS (environnements Windows anciens)

- Généralement laissé vide dans les environnements modernes

**DNS servers** : Serveurs DNS fournis aux clients

- Par défaut, pfSense s'ajoute lui-même
- Peut être remplacé par des DNS personnalisés (ex: 8.8.8.8, 1.1.1.1)

**Gateway** : Passerelle par défaut

- Généralement l'IP de l'interface pfSense (rempli automatiquement)
- Peut être modifié pour des topologies particulières

> [!tip] Bonnes pratiques DNS Laissez pfSense comme serveur DNS pour bénéficier de :
> 
> - La résolution des noms locaux (DNS Resolver/Forwarder)
> - Le filtrage DNS si configuré
> - Les logs de requêtes DNS

---

## Baux statiques (DHCP Static Mappings)

### Principe des réservations statiques

Un **bail statique** (static mapping) associe de manière permanente une adresse IP à une adresse MAC spécifique. L'équipement reçoit toujours la même IP via DHCP.

> [!info] Différence avec une IP fixe
> 
> - **IP fixe** : Configurée manuellement sur l'équipement (pas de DHCP)
> - **Réservation DHCP** : L'équipement utilise DHCP mais reçoit toujours la même IP
> 
> Avantage de la réservation : Gestion centralisée dans pfSense, modification facile sans toucher l'équipement

### Création d'une réservation

**Navigation** : Dans la page DHCP Server de l'interface, descendez jusqu'à **DHCP Static Mappings for this Interface**

**Bouton** : Cliquez sur **Add** (ou **⚙️** pour modifier une réservation existante)

#### Paramètres obligatoires

**MAC Address** : Adresse physique de la carte réseau

- Format : `aa:bb:cc:dd:ee:ff` ou `aa-bb-cc-dd-ee-ff`
- Visible dans les logs DHCP actuels de pfSense
- Trouvable sur l'équipement lui-même

**IP Address** : L'adresse IP à attribuer

- Doit être dans le sous-réseau de l'interface
- **Peut être en dehors de la plage DHCP dynamique** (recommandé)

> [!example] Exemple : Réservation pour un serveur
> 
> ```
> MAC Address : 00:0c:29:4a:7b:3f
> IP Address  : 192.168.1.10
> Hostname    : srv-web-intranet
> Description : Serveur web interne - Apache
> ```

#### Paramètres optionnels

**Client Identifier** : Alternative à l'adresse MAC

- Rarement utilisé, sauf pour certains équipements spécifiques

**Hostname** : Nom d'hôte de l'équipement

- Utilisé pour l'enregistrement DNS automatique
- Visible dans les tables ARP et les logs

**Description** : Commentaire libre

- Très utile pour documenter le rôle de l'équipement

**DNS Server** : Serveurs DNS spécifiques pour cet équipement

- Surcharge les DNS par défaut du pool DHCP
- Utile pour diriger certains équipements vers des DNS particuliers

**Gateway** : Passerelle spécifique

- Surcharge la passerelle par défaut
- Utilisé dans des scénarios de routage avancés

**Domain name** : Suffixe de domaine

- Ex: `entreprise.local`

**Domain search list** : Liste de domaines de recherche

- Ex: `entreprise.local, lan.local`

**WINS servers** : Serveurs WINS spécifiques

> [!tip] Enregistrement DNS automatique Si vous activez le DNS Resolver ou Forwarder, les noms d'hôtes des réservations statiques sont automatiquement enregistrés dans le DNS interne. Vous pouvez alors accéder à l'équipement par son nom : `http://srv-web-intranet` au lieu de `http://192.168.1.10`

### Gestion des réservations

**Visualisation** : Toutes les réservations apparaissent dans un tableau sous le formulaire

**Actions disponibles** :

- ✏️ **Éditer** : Modifier la réservation
- ❌ **Supprimer** : Retirer la réservation
- 📋 **Copier** : Dupliquer pour créer rapidement une réservation similaire

**Tri et organisation** :

- Les réservations sont listées par IP
- Utilisez des descriptions claires pour faciliter la gestion

> [!warning] Attention aux conflits Si vous attribuez une IP dans la plage DHCP dynamique, assurez-vous qu'elle n'est pas déjà attribuée à un autre client. Privilégiez l'attribution en dehors de la plage dynamique.

### Cas d'usage courants

|Équipement|Raison de la réservation|
|---|---|
|**Serveurs**|Nécessitent une IP fixe pour les accès réseaux|
|**Imprimantes réseau**|Configuration des postes de travail|
|**Caméras IP**|Accès direct pour visionnage|
|**NAS**|Partages réseau stables|
|**Points d'accès WiFi**|Administration et monitoring|
|**Équipements domotique**|Intégration dans les systèmes de contrôle|

---

## Options DHCP avancées

### Durée des baux (Lease Time)

La durée du bail détermine combien de temps un client peut utiliser une IP avant de devoir la renouveler.

**Default lease time** : Durée par défaut (7200 secondes = 2 heures) **Maximum lease time** : Durée maximale (86400 secondes = 24 heures)

> [!info] Renouvellement automatique Les clients tentent de renouveler leur bail à 50% de sa durée. Un bail de 2h sera renouvelé après 1h automatiquement.

#### Choix de la durée

|Environnement|Durée recommandée|Raison|
|---|---|---|
|**Réseau stable** (bureau, domicile)|24h - 7 jours|Moins de trafic DHCP, stabilité|
|**Réseau dynamique** (WiFi public)|1h - 4h|Libération rapide des IPs|
|**Réseau de test**|30min - 1h|Changements fréquents|

> [!tip] Impact sur les performances Des baux trop courts génèrent du trafic réseau inutile. Des baux trop longs peuvent épuiser le pool d'adresses dans un environnement très dynamique.

### Options DHCP additionnelles

pfSense permet d'envoyer des **options DHCP** personnalisées aux clients.

**Accès** : Section **Additional BOOTP/DHCP Options** en bas de la page

#### Structure d'une option DHCP

Chaque option est composée de :

- **Number** : Numéro de l'option (0-255)
- **Type** : Type de données
- **Value** : La valeur à transmettre

**Types disponibles** :

|Type|Description|Exemple|
|---|---|---|
|**Text**|Chaîne de caractères|Nom de domaine|
|**String**|Chaîne hexadécimale|Valeurs binaires|
|**Boolean**|True/False|Activation/désactivation|
|**Unsigned Integer 8/16/32**|Nombre entier|Durées, priorités|
|**IP Address**|Adresse IPv4|Serveurs NTP, TFTP|

> [!example] Options DHCP courantes
> 
> **Option 42** - Serveur NTP
> 
> ```
> Number : 42
> Type   : IP Address or host
> Value  : 192.168.1.1
> ```
> 
> **Option 66** - Serveur TFTP (boot réseau)
> 
> ```
> Number : 66
> Type   : Text
> Value  : tftp.entreprise.local
> ```
> 
> **Option 150** - Serveur TFTP (téléphonie IP Cisco)
> 
> ```
> Number : 150
> Type   : IP Address or host
> Value  : 192.168.1.50
> ```

### Serveur TFTP intégré

pfSense peut servir de serveur TFTP pour le démarrage réseau (PXE boot).

**TFTP Server** : IP du serveur TFTP (généralement l'IP de pfSense) **Boot file name** : Nom du fichier de boot (ex: `pxelinux.0`)

> [!info] Cas d'usage TFTP
> 
> - Déploiement d'OS par réseau (PXE)
> - Configuration de téléphones IP
> - Boot d'équipements sans disque dur

### Deny unknown clients

**Option** : `Deny unknown clients`

Lorsqu'activée, seuls les équipements avec une réservation statique peuvent obtenir une IP via DHCP.

> [!warning] Usage avec précaution Cette option transforme votre DHCP en "liste blanche". Tout nouvel équipement devra être ajouté manuellement avant de pouvoir accéder au réseau. Utile pour la sécurité, contraignant pour la flexibilité.

### Ignore denied MACs

**Option** : `Ignore denied MACs`

Utilisée conjointement avec une liste d'adresses MAC à ignorer. Les équipements listés ne recevront jamais d'IP.

> [!tip] Alternative à Deny unknown Plutôt que de bloquer tout sauf la liste blanche, vous pouvez créer une liste noire d'équipements à exclure du DHCP.

### Dynamic DNS (DDNS)

pfSense peut mettre à jour automatiquement un serveur DNS externe lorsqu'il attribue une IP via DHCP.

**Champs disponibles** :

- **Enable registration of DHCP client names in DNS**
- **DDNS Domain** : Domaine à mettre à jour
- **DDNS Domain Primary** : Serveur DNS primaire
- **DDNS Domain Key Name** : Nom de clé pour l'authentification TSIG

> [!info] Utilité du DDNS Permet aux équipements DHCP d'être accessibles par nom DNS même avec des IP dynamiques. Principalement utilisé dans des infrastructures avec Active Directory ou serveurs DNS externes.

### NTP Servers

**NTP servers** : Liste de serveurs de temps à fournir aux clients

Les clients synchroniseront leur horloge avec ces serveurs.

> [!example] Configuration NTP
> 
> ```
> NTP Server 1 : 192.168.1.1 (pfSense lui-même)
> NTP Server 2 : 0.fr.pool.ntp.org
> ```

### Network booting (PXE)

Configuration complète pour le démarrage réseau :

**Next Server** : IP du serveur TFTP **Default BIOS file name** : Fichier pour BIOS legacy **UEFI 32 bit file name** : Fichier pour UEFI 32 bits **UEFI 64 bit file name** : Fichier pour UEFI 64 bits

> [!tip] Déploiement moderne Avec UEFI devenu standard, concentrez-vous sur la configuration UEFI 64 bits. Le boot BIOS reste nécessaire pour les vieux équipements.

---

## Bonnes pratiques

### 🎯 Planification de l'adressage

- **Documentez** votre plan d'adressage avant de configurer DHCP
- **Segmentez** clairement : statiques, dynamiques, réservations
- **Prévoyez** de l'espace pour l'évolution future

### 🔒 Sécurité

- Utilisez des réservations DHCP plutôt que des IPs fixes quand possible
- Activez `Deny unknown clients` sur les réseaux sensibles (DMZ, serveurs)
- Surveillez les logs DHCP pour détecter les équipements inconnus

### 📊 Monitoring

- Consultez régulièrement `Status > DHCP Leases` pour voir les attributions actives
- Vérifiez que votre pool n'est pas saturé
- Documentez chaque réservation statique avec une description claire

### ⚡ Performance

- Ajustez les durées de bail selon votre environnement
- Dans les réseaux stables, privilégiez des baux longs (24h+)
- Dans les WiFi publics, utilisez des baux courts (1-2h)

### 📝 Documentation

Maintenez un document séparé listant :

- Le plan d'adressage de chaque VLAN/interface
- Les réservations DHCP avec leur justification
- Les options DHCP personnalisées et leur usage

> [!tip] Backup de configuration Les configurations DHCP sont incluses dans la sauvegarde de configuration pfSense (`Diagnostics > Backup & Restore`). Sauvegardez régulièrement, surtout après des modifications importantes.

### 🔄 Dépannage rapide

**Problème** : Un client ne reçoit pas d'IP

Vérifications :

1. Le serveur DHCP est-il activé sur l'interface ?
2. Le client est-il dans le bon VLAN/réseau ?
3. La plage DHCP est-elle épuisée ? (vérifiez `Status > DHCP Leases`)
4. Y a-t-il des règles firewall bloquant DHCP (ports UDP 67/68) ?

**Problème** : Une réservation ne fonctionne pas

Vérifications :

1. L'adresse MAC est-elle correcte ? (vérifiez la casse et le format)
2. L'IP est-elle dans le bon sous-réseau ?
3. Le client a-t-il renouvelé son bail ? (redémarrez la carte réseau ou l'équipement)

---

> [!info] 💡 Résumé Le service DHCP de pfSense est un outil puissant qui simplifie grandement la gestion réseau. Une configuration bien pensée avec des réservations statiques pour les équipements importants et un pool dynamique dimensionné correctement vous permettra de maintenir un réseau stable et facilement administrable.