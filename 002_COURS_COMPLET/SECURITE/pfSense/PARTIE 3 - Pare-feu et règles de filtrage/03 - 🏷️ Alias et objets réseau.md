

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

Les **alias** sont des objets nommés qui permettent de regrouper des adresses IP, des réseaux, des ports ou des URLs sous un nom descriptif. Ils constituent un élément fondamental pour créer des règles de pare-feu maintenables et lisibles.

> [!info] Pourquoi utiliser des alias ?
> 
> - **Lisibilité** : Remplacer `192.168.1.0/24` par `LAN_COMPTABILITE`
> - **Maintenabilité** : Modifier un alias met à jour toutes les règles qui l'utilisent
> - **Réutilisabilité** : Utiliser le même alias dans plusieurs règles
> - **Organisation** : Grouper logiquement les éléments réseau

### Avantages principaux

|Avantage|Sans alias|Avec alias|
|---|---|---|
|Modification|Éditer chaque règle individuellement|Modifier l'alias une seule fois|
|Compréhension|IP brutes difficiles à mémoriser|Noms descriptifs explicites|
|Gestion de groupe|Créer une règle par IP|Une règle pour tout le groupe|
|Documentation|Commentaires nécessaires|Nom de l'alias auto-documenté|

---

## Types d'alias

pfSense propose quatre types d'alias principaux, chacun adapté à un usage spécifique.

### Alias IP/Réseaux

Les alias de type **Host(s)** ou **Network(s)** permettent de regrouper des adresses IP ou des réseaux CIDR.

> [!example] Cas d'usage typiques
> 
> - Grouper les serveurs d'un service (`SERVEURS_WEB`, `SERVEURS_DNS`)
> - Définir des zones géographiques (`BUREAUX_PARIS`, `BUREAUX_LYON`)
> - Lister des IPs à bloquer (`BLACKLIST_IPS`)
> - Regrouper des équipements (`IMPRIMANTES`, `CAMERAS`)

#### Types de notation acceptés

```
# Adresses IP individuelles
192.168.1.10
10.0.0.50

# Réseaux CIDR
192.168.1.0/24
10.0.0.0/8

# Plages d'IP
192.168.1.100-192.168.1.200

# Noms d'hôtes (résolution DNS)
serveur.exemple.local

# FQDN (Fully Qualified Domain Name)
www.exemple.com
```

> [!warning] Attention aux FQDN Les alias utilisant des FQDN sont résolus périodiquement par pfSense. Si l'IP du domaine change, l'alias sera mis à jour automatiquement. Cela peut créer des comportements inattendus si le DNS est compromis.

### Alias Ports

Les alias de type **Port(s)** regroupent des numéros de ports TCP/UDP.

> [!example] Cas d'usage typiques
> 
> - Services web : `WEB_PORTS` (80, 443, 8080, 8443)
> - Services mail : `MAIL_PORTS` (25, 587, 465, 993, 995)
> - Ports non-standards : `APPS_CUSTOM_PORTS`
> - Ports à bloquer : `DANGEROUS_PORTS`

#### Syntaxe des ports

```
# Ports individuels
80
443
8080

# Plages de ports
1000:2000
49152:65535

# Combinaison
80
443
8000:8999
```

> [!tip] Convention de nommage Utilisez le suffixe `_PORTS` pour identifier rapidement les alias de ports : `SSH_PORTS`, `RDP_PORTS`, `VOIP_PORTS`

### Alias URLs

Les alias de type **URL (IPs)** ou **URL Table (IPs)** téléchargent des listes d'adresses IP depuis des URLs externes.

> [!info] Différence entre les deux types
> 
> - **URL (IPs)** : Charge la liste en mémoire, limite de ~3000 entrées
> - **URL Table (IPs)** : Utilise une table PF, supporte des millions d'entrées

#### Sources courantes

```
# Listes de blocage géographiques
https://www.ipdeny.com/ipblocks/data/countries/cn.zone

# Listes anti-spam/malware
https://rules.emergingthreats.net/fwrules/emerging-Block-IPs.txt

# Listes Tor
https://check.torproject.org/torbulkexitlist

# Listes personnalisées
https://mon-serveur.local/custom-blacklist.txt
```

> [!warning] Considérations de sécurité
> 
> - Vérifiez la fiabilité de la source
> - Les listes sont mises à jour automatiquement (configurable)
> - Une liste corrompue peut bloquer tout votre trafic
> - Préférez HTTPS pour éviter les attaques MITM

### Alias URL Table (Ports)

Type spécial permettant de charger des listes de ports depuis une URL.

```
# Format attendu dans le fichier
80
443
8080:8090
3000
```

---

## Création et gestion des alias

### Navigation

**Firewall → Aliases** : Interface de gestion des alias

### Créer un alias - Étape par étape

#### 1. Alias IP - Exemple : Serveurs de production

```
Nom          : SERVEURS_PRODUCTION
Description  : Serveurs critiques en production
Type         : Host(s)

Adresses :
192.168.10.10    (Serveur Web Principal)
192.168.10.11    (Serveur Base de données)
192.168.10.12    (Serveur Application)
192.168.10.20    (Serveur Backup)
```

> [!tip] Noms d'alias
> 
> - Utilisez MAJUSCULES et underscores
> - Préfixez par catégorie : `SRV_`, `NET_`, `USR_`
> - Maximum 32 caractères
> - Pas d'espaces ni caractères spéciaux

#### 2. Alias Ports - Exemple : Services web

```
Nom          : WEB_SERVICES_PORTS
Description  : Tous les ports pour services web
Type         : Port(s)

Ports :
80          (HTTP)
443         (HTTPS)
8080        (HTTP alternatif)
8443        (HTTPS alternatif)
```

#### 3. Alias réseau - Exemple : Réseaux internes

```
Nom          : RESEAUX_INTERNES
Description  : Tous les réseaux privés de l'entreprise
Type         : Network(s)

Réseaux :
192.168.0.0/16      (Plage principale)
10.0.0.0/8          (VPN et services)
172.16.0.0/12       (DMZ et test)
```

#### 4. Alias URL - Exemple : Liste de blocage

```
Nom                    : BLACKLIST_MALWARE
Description            : IPs malveillantes mises à jour quotidiennement
Type                   : URL Table (IPs)

URL                    : https://exemple.com/malware-ips.txt
Fréquence de mise à jour : 1 jour
Description URL        : Liste Emerging Threats
```

### Alias imbriqués (Nested Aliases)

Les alias peuvent contenir d'autres alias, permettant une organisation hiérarchique.

> [!example] Structure hiérarchique
> 
> ```
> # Alias de base
> SRV_WEB_PROD:
>   - 192.168.10.10
>   - 192.168.10.11
> 
> SRV_WEB_TEST:
>   - 192.168.20.10
>   - 192.168.20.11
> 
> # Alias combiné
> SRV_WEB_TOUS:
>   - SRV_WEB_PROD
>   - SRV_WEB_TEST
> ```

> [!warning] Limitations
> 
> - Maximum 3 niveaux d'imbrication
> - Attention aux références circulaires (A → B → A)
> - Peut impacter les performances avec trop de niveaux

### Interface de gestion

#### Visualisation

L'interface affiche pour chaque alias :

- **Nom et description**
- **Type** (Host, Port, URL, etc.)
- **Nombre d'entrées**
- **Utilisation** : Nombre de règles utilisant cet alias
- **Actions** : Éditer, Dupliquer, Supprimer

#### Fonctions utiles

|Fonction|Description|
|---|---|
|**Bulk Import**|Importer plusieurs entrées en une fois|
|**Export**|Exporter les alias (backup/migration)|
|**IP Lookup**|Vérifier si une IP est dans un alias|
|**View**|Voir le contenu détaillé (utile pour URL Tables)|

---

## Utilisation dans les règles

### Intégration dans les règles de filtrage

Les alias peuvent être utilisés dans pratiquement tous les champs d'une règle de pare-feu.

#### Champs compatibles

```
Source :
  - Adresse source : alias IP/Réseau
  - Port source : alias Port

Destination :
  - Adresse destination : alias IP/Réseau
  - Port destination : alias Port
```

> [!example] Règle utilisant des alias
> 
> ```
> Action       : Pass
> Interface    : LAN
> Protocol     : TCP
> Source       : EMPLOYES_BUREAU
> Destination  : SERVEURS_PRODUCTION
> Dest. Port   : WEB_SERVICES_PORTS
> Description  : Accès web pour employés
> ```

### Avantages dans les règles

#### Avant (sans alias)

```
Règle 1 : 192.168.1.10 → 10.0.0.50:80
Règle 2 : 192.168.1.11 → 10.0.0.50:80
Règle 3 : 192.168.1.12 → 10.0.0.50:80
Règle 4 : 192.168.1.10 → 10.0.0.50:443
Règle 5 : 192.168.1.11 → 10.0.0.50:443
Règle 6 : 192.168.1.12 → 10.0.0.50:443
```

#### Après (avec alias)

```
CLIENTS = 192.168.1.10, 192.168.1.11, 192.168.1.12
SERVEUR_WEB = 10.0.0.50
WEB_PORTS = 80, 443

Règle unique : CLIENTS → SERVEUR_WEB:WEB_PORTS
```

### Modification dynamique

> [!tip] Mise à jour en temps réel Lorsque vous modifiez un alias :
> 
> 1. Les changements sont appliqués immédiatement
> 2. Toutes les règles utilisant cet alias sont mises à jour
> 3. Les tables du pare-feu sont rechargées automatiquement
> 4. Aucune interruption de service (rechargement à chaud)

### Opérateurs de négation

Vous pouvez inverser un alias avec l'opérateur `!` (NOT).

```
Source : ! BLACKLIST_IPS
→ Toutes les IPs SAUF celles dans la blacklist

Destination : ! SERVEURS_CRITIQUES
→ Toutes les destinations SAUF les serveurs critiques
```

---

## Importation de listes

### Import en masse (Bulk Import)

Lors de la création/édition d'un alias, utilisez le bouton **"Add"** puis **"Bulk import"**.

#### Format accepté

```
# Commentaires commencent par #
192.168.1.10    # Serveur Web
192.168.1.11    # Serveur DB

# Réseaux CIDR
10.0.0.0/8

# Plages
172.16.0.1-172.16.0.254

# FQDN
serveur.exemple.com
```

> [!tip] Préparation de fichier Préparez vos listes dans un éditeur de texte, une IP/réseau par ligne, puis copiez-collez dans l'interface.

### Import depuis URL

Pour les alias de type URL, configurez :

#### Paramètres de mise à jour

```
URL : https://source.exemple.com/liste.txt
Fréquence : 
  - 1 heure (listes très dynamiques)
  - 12 heures (listes stables)
  - 1 jour (par défaut)
  - 7 jours (listes statiques)
```

#### Format du fichier distant

Le fichier doit contenir une IP ou un réseau par ligne :

```
# Liste de blocage exemple
1.2.3.4
5.6.7.8
10.0.0.0/8
# Commentaires supportés
192.168.1.0/24
```

> [!warning] Problèmes de téléchargement
> 
> - Vérifiez que pfSense peut résoudre le DNS de l'URL
> - Testez la connectivité : **Diagnostics → Ping/Traceroute**
> - Les certificats SSL invalides bloquent le téléchargement
> - Timeout par défaut : 60 secondes

### Forcer une mise à jour manuelle

**Firewall → Aliases → onglet "URLs"**

Cliquez sur l'icône ⟳ pour forcer le rechargement immédiat d'une URL Table.

### Export/Import d'alias

#### Export (backup)

**Diagnostics → Backup & Restore → Backup Configuration**

Sélectionnez uniquement la section **Aliases** pour un export ciblé.

#### Import (restauration)

**Diagnostics → Backup & Restore → Restore Configuration**

Uploadez le fichier XML contenant les alias.

> [!tip] Migration entre pfSense Cette méthode est idéale pour migrer des alias d'un pfSense à un autre sans recréer manuellement.

---

## Bonnes pratiques

### 1. Convention de nommage cohérente

Adoptez une nomenclature standardisée dans toute l'organisation.

```
Préfixes recommandés :
NET_    : Réseaux (NET_LAN_BUREAUX, NET_DMZ)
SRV_    : Serveurs (SRV_WEB, SRV_DNS)
GRP_    : Groupes d'utilisateurs (GRP_ADMINS, GRP_INVITES)
BL_     : Blacklists (BL_MALWARE, BL_PAYS)
WL_     : Whitelists (WL_PARTENAIRES)
PORTS_  : Ports (PORTS_WEB, PORTS_MAIL)
```

### 2. Documentation systématique

Remplissez TOUJOURS le champ **Description** de manière claire.

> [!example] Bonnes descriptions
> 
> ```
> ✅ "Serveurs web de production - datacenter Paris"
> ✅ "Ports autorisés pour accès SSH administratif"
> ✅ "IPs bloquées - liste Emerging Threats mise à jour quotidiennement"
> 
> ❌ "serveurs"
> ❌ "liste"
> ❌ "test"
> ```

### 3. Organisation logique

Regroupez les alias par fonction ou zone réseau.

```
Structure recommandée :
├── Réseaux internes
│   ├── NET_LAN_PRODUCTION
│   ├── NET_LAN_BUREAUX
│   └── NET_DMZ
├── Serveurs
│   ├── SRV_WEB_ALL
│   ├── SRV_MAIL_ALL
│   └── SRV_DNS_ALL
├── Services (ports)
│   ├── PORTS_WEB
│   ├── PORTS_MAIL
│   └── PORTS_ADMIN
└── Sécurité
    ├── BL_MALWARE_IPS
    ├── BL_PAYS_BLOQUES
    └── WL_PARTENAIRES
```

### 4. Revue régulière

Planifiez des audits périodiques de vos alias.

> [!tip] Checklist de maintenance
> 
> - [ ] Supprimer les alias inutilisés (colonne "In use by")
> - [ ] Vérifier les URL Tables toujours accessibles
> - [ ] Mettre à jour les descriptions obsolètes
> - [ ] Contrôler les alias avec trop d'entrées (performances)
> - [ ] Valider la pertinence des listes de blocage

### 5. Éviter les alias trop larges

Ne créez pas d'alias contenant des milliers d'entrées si ce n'est pas nécessaire.

```
❌ ALIAS_TOUS_INTERNET : 0.0.0.0/0
→ Utilisez plutôt "any" dans les règles

✅ ALIAS_SERVEURS_CRITIQUES : 5-10 IPs spécifiques
→ Maintient les performances optimales
```

### 6. Tester avant de bloquer

Avec les URL Tables de blocage :

```
Phase 1 : Créer l'alias sans l'utiliser dans les règles
Phase 2 : Vérifier le contenu (View)
Phase 3 : Créer une règle de LOG (non-blocante)
Phase 4 : Analyser les logs pendant 24-48h
Phase 5 : Activer le blocage si validé
```

### 7. Backup avant modifications majeures

> [!warning] Sécurité Avant de modifier des alias utilisés dans de nombreuses règles, exportez votre configuration complète.

---

## Pièges courants

### 1. ❌ Oublier les impacts en cascade

**Problème** : Modifier un alias utilisé dans 50 règles sans vérifier l'impact.

**Solution** :

- Vérifiez la colonne "In use by" avant modification
- Utilisez **Firewall → Rules** et cherchez l'alias avec Ctrl+F
- Testez avec une règle de LOG avant de bloquer

### 2. ❌ Alias circulaires

**Problème** :

```
ALIAS_A contient ALIAS_B
ALIAS_B contient ALIAS_A
→ Erreur de configuration
```

**Solution** : Maintenez une hiérarchie claire sans références croisées.

### 3. ❌ FQDN dans environnements critiques

**Problème** : Un alias contient `serveur.exemple.com`, le DNS est compromis.

**Solution** :

- Privilégiez les IPs pour les infrastructures critiques
- Utilisez FQDN uniquement pour les services externes changeants
- Surveillez les logs de résolution DNS

### 4. ❌ URL Tables non vérifiées

**Problème** : Une URL Table de blocage contient accidentellement vos IPs internes.

**Symptômes** :

- Perte de connectivité soudaine
- Services inaccessibles sans raison apparente

**Solution** :

```
1. Téléchargez manuellement le fichier
2. Vérifiez qu'il ne contient pas vos réseaux
3. Utilisez des listes de sources fiables uniquement
4. Implémentez des whitelists de sécurité
```

### 5. ❌ Performances avec URL Tables massives

**Problème** : URL Table de 5 millions d'IPs, pfSense ralentit.

**Solution** :

- Utilisez **URL Table (IPs)** au lieu de **URL (IPs)** pour grandes listes
- Limitez à 1-2 grandes URL Tables maximum
- Envisagez des solutions comme pfBlockerNG pour géo-blocage massif
- Augmentez la RAM si nécessaire

### 6. ❌ Ports en double

**Problème** :

```
PORTS_WEB : 80, 443
PORTS_HTTPS : 443
Règle : destination PORTS_WEB OR PORTS_HTTPS
→ Le port 443 est évalué deux fois
```

**Solution** : Évitez les doublons, utilisez des alias mutuellement exclusifs.

### 7. ❌ Modifications sans sauvegarde

**Problème** : Suppression accidentelle d'un alias utilisé partout.

**Symptômes** : Règles cassées, icônes d'erreur ⚠️ dans les règles.

**Solution** :

- **Diagnostics → Backup & Restore** avant toute modification importante
- pfSense garde 30 versions de config par défaut
- Restaurez via **Config History** si erreur

### 8. ❌ Syntaxe incorrecte dans Bulk Import

**Problème** :

```
192.168.1.1 - 192.168.1.10    # Espaces autour du tiret
192.168.1.0 /24               # Espace avant /24
```

**Solution** : Respectez la syntaxe stricte :

```
192.168.1.1-192.168.1.10      # Pas d'espaces
192.168.1.0/24                # Collé
```

### 9. ❌ Confusion Host vs Network

**Problème** : Utiliser type **Host(s)** pour `10.0.0.0/8`.

**Impact** : Fonctionne, mais sémantiquement incorrect et source de confusion.

**Solution** :

- **Host(s)** : IPs individuelles ou FQDN
- **Network(s)** : Réseaux CIDR

### 10. ❌ Oublier la négation dans les règles

**Problème** : Créer `BLACKLIST` mais oublier le `!` dans la règle.

```
Source : BLACKLIST          # ❌ Autorise UNIQUEMENT la blacklist
Source : ! BLACKLIST        # ✅ Bloque la blacklist
```

**Solution** : Doublez la vérification lors de l'utilisation de listes de blocage.

---

> [!tip] Astuce finale Les alias sont la colonne vertébrale d'une configuration pfSense maintenable. Investissez du temps dans leur organisation dès le départ, vous gagnerez des heures de maintenance par la suite.

> [!info] Commandes shell utiles (avancées) Depuis **Diagnostics → Command Prompt**, shell :
> 
> ```bash
> # Lister tous les alias
> pfctl -t
> 
> # Afficher le contenu d'un alias
> pfctl -t NOM_ALIAS -T show
> 
> # Nombre d'entrées dans un alias
> pfctl -t NOM_ALIAS -T show | wc -l
> 
> # Vérifier si une IP est dans un alias
> pfctl -t NOM_ALIAS -T test 192.168.1.10
> ```