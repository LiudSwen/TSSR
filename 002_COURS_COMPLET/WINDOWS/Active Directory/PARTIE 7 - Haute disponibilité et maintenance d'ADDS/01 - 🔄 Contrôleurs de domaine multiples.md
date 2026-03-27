

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

## 🖥️ Contrôleurs de domaine multiples

### Qu'est-ce qu'un environnement multi-DC ?

Un environnement Active Directory en production contient **toujours plusieurs contrôleurs de domaine** (DC) pour assurer la haute disponibilité et la tolérance aux pannes. Chaque DC contient une copie complète et modifiable de la base de données AD.

> [!info] Pourquoi plusieurs DC ?
> 
> - **Haute disponibilité** : Si un DC tombe, les autres continuent de fonctionner
> - **Répartition de charge** : Les authentifications et requêtes sont distribuées
> - **Tolérance aux pannes** : Aucun point de défaillance unique (SPOF)
> - **Performance géographique** : Un DC proche améliore les temps de réponse

### Principe du modèle multi-maître

Active Directory utilise un modèle de **réplication multi-maître** :

- Tous les DC sont égaux et peuvent recevoir des modifications
- Les changements effectués sur un DC sont répliqués vers tous les autres
- Il n'y a pas de "DC principal" pour les opérations courantes

```
DC1 ──────┐
          ├──► Réplication bidirectionnelle
DC2 ──────┤
          ├──► Toutes les modifications se propagent
DC3 ──────┘
```

> [!warning] Attention aux conflits Si deux modifications contradictoires sont faites simultanément sur deux DC différents, AD utilise des mécanismes de résolution de conflits basés sur les timestamps et numéros de version.

### Rôles FSMO

Bien que le modèle soit multi-maître, certaines opérations critiques nécessitent un **maître unique**. Ce sont les rôles FSMO (Flexible Single Master Operations) :

|Rôle|Portée|Fonction|
|---|---|---|
|**Schema Master**|Forêt|Gère les modifications du schéma AD|
|**Domain Naming Master**|Forêt|Gère l'ajout/suppression de domaines|
|**RID Master**|Domaine|Distribue les pools de RID aux DC|
|**PDC Emulator**|Domaine|Synchronisation temps, changements mots de passe prioritaires|
|**Infrastructure Master**|Domaine|Maintient les références entre domaines|

> [!tip] Bonnes pratiques FSMO
> 
> - Placez Schema Master et Domain Naming Master sur le même DC
> - Le PDC Emulator doit être sur un DC performant et bien connecté
> - N'installez pas l'Infrastructure Master sur un DC qui est aussi serveur de catalogue global (sauf si tous les DC sont GC)

### Vérifier les rôles FSMO

```powershell
# Voir tous les rôles FSMO de la forêt
Get-ADForest | Select-Object SchemaMaster, DomainNamingMaster

# Voir les rôles FSMO du domaine
Get-ADDomain | Select-Object RIDMaster, PDCEmulator, InfrastructureMaster

# Avec Netdom (ligne de commande classique)
netdom query fsmo
```

### Transférer un rôle FSMO

```powershell
# Transférer le rôle PDC Emulator vers DC02
Move-ADDirectoryServerOperationMasterRole -Identity "DC02" -OperationMasterRole PDCEmulator

# Transférer plusieurs rôles en une fois
Move-ADDirectoryServerOperationMasterRole -Identity "DC02" `
    -OperationMasterRole RIDMaster, InfrastructureMaster, PDCEmulator
```

> [!warning] Saisie vs Transfert
> 
> - **Transfert** : opération propre quand le DC source est disponible
> - **Saisie** : opération forcée quand le DC source est HS (utiliser `ntdsutil`)

---

## 🔄 Réplication entre contrôleurs de domaine

### Principe de la réplication AD

La réplication AD est le processus de **synchronisation des modifications** de la base de données entre tous les contrôleurs de domaine. Elle garantit que tous les DC ont une vue cohérente de l'annuaire.

> [!info] Ce qui est répliqué
> 
> - Objets AD (utilisateurs, groupes, ordinateurs, OU, etc.)
> - Attributs des objets
> - Suppressions d'objets
> - Modifications du schéma
> - Configuration de la forêt

### Mécanisme de réplication par attribut

AD réplique au niveau de l'**attribut**, pas de l'objet complet :

- Si vous modifiez le numéro de téléphone d'un utilisateur, seul cet attribut est répliqué
- Chaque attribut possède un **numéro de version** (USN - Update Sequence Number)
- Un attribut modifié multiple fois n'est répliqué qu'avec sa dernière valeur

```
Utilisateur: Jean Dupont
├─ displayName (USN: 15432) ──► Répliqué si USN distant < 15432
├─ telephoneNumber (USN: 18901) ──► Répliqué si modifié récemment
└─ mail (USN: 12045) ──► Non répliqué si déjà à jour
```

> [!example] Exemple de réplication
> 
> 1. Vous modifiez l'email d'un utilisateur sur DC1
> 2. DC1 incrémente l'USN de l'attribut `mail`
> 3. DC1 notifie ses partenaires de réplication
> 4. DC2 et DC3 demandent les changements ayant un USN > leur dernier USN connu
> 5. Seul l'attribut `mail` modifié est transféré

### Types de réplication

#### Réplication intra-site (même site AD)

- **Déclenchement** : Par notification de changement
- **Délai** : Quasi immédiat (15 secondes par défaut après une modification)
- **Compression** : Aucune (LAN rapide)
- **Topologie** : Anneau bidirectionnel optimisé

```powershell
# Forcer une réplication intra-site immédiate
repadmin /syncall /AdeP

# Synchroniser depuis un DC spécifique
repadmin /replicate DC02 DC01 "DC=contoso,DC=com"
```

#### Réplication inter-sites (entre sites AD différents)

- **Déclenchement** : Selon planification (par défaut toutes les 180 minutes)
- **Délai** : Contrôlé par l'administrateur
- **Compression** : Activée (économie de bande passante WAN)
- **Topologie** : Contrôlée par les liens de sites

> [!tip] Différence clé **Intra-site** = rapide, non compressé, temps réel **Inter-sites** = planifié, compressé, optimisé pour WAN

### Partitions de réplication

Active Directory divise les données en **partitions** (naming contexts) répliquées indépendamment :

|Partition|Contenu|Portée de réplication|
|---|---|---|
|**Configuration**|Structure forêt, sites, liens|Tous les DC de la forêt|
|**Schéma**|Définitions classes et attributs|Tous les DC de la forêt|
|**Domaine**|Objets du domaine (users, groups, computers)|Tous les DC du domaine|
|**Application**|Données DNS AD-intégré, etc.|Scope défini (domaine, forêt, ou personnalisé)|

```powershell
# Voir les partitions répliquées sur un DC
Get-ADReplicationPartner -Target "DC01"

# Vérifier l'état de réplication d'une partition spécifique
repadmin /showrepl DC01 "DC=contoso,DC=com"
```

### Attributs de réplication

Chaque objet et attribut possède des métadonnées de réplication :

- **USN** (Update Sequence Number) : Numéro séquentiel local au DC
- **USN propagé** : Plus haut USN connu du partenaire
- **Version** : Incrément à chaque modification d'attribut
- **Timestamp** : Date/heure de la dernière modification
- **Serveur d'origine** : DC qui a effectué la modification

```powershell
# Voir les métadonnées de réplication d'un objet
Get-ADReplicationAttributeMetadata -Object "CN=Jean Dupont,OU=Users,DC=contoso,DC=com" `
    -Server DC01

# Affichage détaillé avec repadmin
repadmin /showobjmeta DC01 "CN=Jean Dupont,OU=Users,DC=contoso,DC=com"
```

> [!warning] Résolution de conflits Si deux DC modifient le même attribut simultanément :
> 
> 1. L'attribut avec le **numéro de version le plus élevé** gagne
> 2. En cas d'égalité, le **timestamp le plus récent** gagne
> 3. En cas d'égalité parfaite, le **GUID du DC le plus élevé** gagne

### Vérifier l'état de réplication

```powershell
# Vue d'ensemble de la réplication dans le domaine
repadmin /replsummary

# Afficher tous les partenaires de réplication
repadmin /showrepl

# Vérifier les erreurs de réplication
repadmin /showrepl * /csv | ConvertFrom-Csv | Where-Object {$_.`Last replication result` -ne 0}

# Avec PowerShell (plus lisible)
Get-ADReplicationFailure -Target "DC01"
Get-ADReplicationUpToDatenessVectorTable -Target "DC01"
```

### Forcer la réplication

```powershell
# Forcer la réplication de toutes les partitions depuis tous les partenaires
repadmin /syncall DC01 /APed

# Options utiles :
# /A = toutes les partitions
# /P = push (notifier les partenaires)
# /e = entreprise (toute la forêt)
# /d = identifier les serveurs par DN

# Forcer une réplication spécifique entre deux DC
repadmin /replicate DC02 DC01 "DC=contoso,DC=com"
```

> [!tip] Surveillance continue Utilisez des outils comme **Active Directory Replication Status Tool** (gratuit Microsoft) ou des solutions de monitoring (PRTG, Nagios) pour surveiller la réplication en continu.

---

## 🗺️ Topologie de réplication

### Qu'est-ce que la topologie de réplication ?

La topologie de réplication définit **quels DC répliquent avec quels autres DC** et comment les données circulent dans l'infrastructure AD.

> [!info] Objectif de la topologie
> 
> - Garantir que tous les DC reçoivent les modifications
> - Minimiser le trafic réseau redondant
> - Optimiser le temps de convergence (délai avant que tous les DC soient synchronisés)
> - S'adapter aux contraintes réseau (bande passante, latence, coût)

### Knowledge Consistency Checker (KCC)

Le **KCC** est un processus automatique qui s'exécute sur chaque DC et génère la topologie de réplication :

- S'exécute toutes les **15 minutes** par défaut
- Crée automatiquement les **objets de connexion** entre DC
- Optimise la topologie pour garantir la résilience
- S'adapte aux changements (ajout/suppression de DC, modification de sites)

```powershell
# Forcer le KCC à recalculer la topologie immédiatement
repadmin /kcc DC01

# Vérifier les objets de connexion créés par le KCC
Get-ADReplicationConnection -Filter * | Where-Object {$_.ReplicateFromDirectoryServer -like "*"}
```

> [!tip] Fonctionnement du KCC Le KCC génère une topologie en **anneau bidirectionnel** au sein d'un site, avec des connexions supplémentaires pour la redondance (généralement 3 connexions par DC).

### Topologie intra-site

Au sein d'un même site AD, le KCC crée une topologie optimisée :

```
Topologie en anneau avec redondance :

    DC1 ←──────→ DC2
     ↑  ╲      ╱  ↑
     │    ╲  ╱    │
     │      ╳      │
     │    ╱  ╲    │
     ↓  ╱      ╲  ↓
    DC4 ←──────→ DC3
    
Chaque DC a au moins 2 partenaires
Maximum 3 sauts pour atteindre n'importe quel DC
```

Caractéristiques :

- **Nombre maximum de sauts** : 3 (pour un site de taille raisonnable)
- **Partenaires par DC** : Minimum 2, généralement 3
- **Latence de réplication** : Quelques secondes à minutes

### Topologie inter-sites

Entre sites AD, la topologie est basée sur les **liens de sites** et les **serveurs têtes de pont** (bridgehead servers) :

- Un ou plusieurs DC de chaque site sont désignés comme **têtes de pont**
- Seules les têtes de pont répliquent entre sites
- Les têtes de pont répliquent ensuite vers les autres DC de leur site

```
Site Paris                          Site Lyon
┌─────────────────┐                ┌─────────────────┐
│  DC-PAR-01      │                │  DC-LYO-01      │
│  DC-PAR-02 ←────┼────(WAN)───────┼────→ DC-LYO-02  │
│  DC-PAR-03      │   Bridgehead   │  DC-LYO-03      │
└─────────────────┘    Servers     └─────────────────┘
```

> [!info] Serveur tête de pont Le KCC sélectionne automatiquement les têtes de pont en fonction :
> 
> - De la disponibilité du DC
> - De la connectivité réseau
> - De la charge (il peut y avoir plusieurs têtes de pont par site)

### Objets de connexion

Les **connection objects** représentent les liens de réplication entre DC :

```powershell
# Voir tous les objets de connexion d'un DC
Get-ADReplicationConnection -Filter * -Server DC01

# Voir les détails d'un objet de connexion
Get-ADReplicationConnection -Identity "connection-dc01-dc02" | Format-List

# Créer manuellement un objet de connexion (rare, généralement automatique)
New-ADReplicationConnection -Name "Manual-DC01-to-DC03" `
    -ReplicateFromDirectoryServer DC03 `
    -InterSiteTransportProtocol IP
```

Propriétés importantes :

- **fromServer** : DC source
- **Schedule** : Planification (inter-sites uniquement)
- **Options** : Comportements spéciaux
- **generatedBy** : KCC (automatique) ou manuel

> [!warning] Connexions manuelles Les connexions créées manuellement **ne sont pas gérées par le KCC**. Le KCC peut créer des connexions redondantes mais ne supprimera jamais vos connexions manuelles. À utiliser avec parcimonie !

### Vérifier la topologie de réplication

```powershell
# Vue graphique de la topologie (nécessite l'outil Sites and Services)
# Active Directory Sites and Services > NTDS Settings > clic droit > Propriétés

# Ligne de commande : afficher la topologie complète
repadmin /bridgeheads
repadmin /showrepl * /csv > replication-topology.csv

# Vérifier les connexions inter-sites
Get-ADReplicationSiteLink -Filter *

# Tester la connectivité de réplication
dcdiag /test:replications
```

### Optimiser la topologie

```powershell
# Désactiver la compression inter-sites (si bande passante élevée)
Set-ADReplicationSiteLink -Identity "Paris-Lyon" -ReplicationSchedule $null

# Modifier le coût d'un lien de sites (influence le routage)
Set-ADReplicationSiteLink -Identity "Paris-Lyon" -Cost 100

# Désigner manuellement un serveur tête de pont préféré
# (dans Sites and Services, NTDS Settings > clic droit > Properties > Bridgehead)
```

> [!tip] Bonnes pratiques topologie
> 
> - Laissez le KCC gérer la topologie intra-site (il est très efficace)
> - Configurez correctement les liens de sites pour l'inter-sites
> - Ne créez des connexions manuelles que pour des besoins très spécifiques
> - Surveillez les serveurs têtes de pont (ils gèrent tout le trafic inter-sites)

---

## 🌍 Sites et liens de sites

### Qu'est-ce qu'un site AD ?

Un **site Active Directory** est un regroupement logique d'ordinateurs basé sur la **connectivité réseau physique**. Un site représente une ou plusieurs sous-réseaux IP bien connectés (généralement un LAN).

> [!info] Pourquoi créer des sites ?
> 
> - **Optimiser la réplication** : Différencier LAN (rapide) et WAN (lent)
> - **Authentification proche** : Les clients utilisent un DC du même site
> - **Économiser la bande passante** : Contrôler la réplication inter-sites
> - **Services localisés** : DFS, impression, applications utilisent des ressources proches

### Relation sites / sous-réseaux / DC

```
Concept AD          ↔️  Réalité réseau
─────────────────────────────────────────
Site "Paris"       ↔️  LAN du siège (192.168.10.0/24)
  └─ Subnet 1      ↔️  192.168.10.0/24
  └─ DC-PAR-01     ↔️  Serveur physique
  └─ DC-PAR-02     ↔️  Serveur physique

Site "Lyon"        ↔️  LAN agence (192.168.20.0/24)
  └─ Subnet 2      ↔️  192.168.20.0/24
  └─ DC-LYO-01     ↔️  Serveur physique
```

> [!warning] Important Les sites AD sont basés sur les **sous-réseaux IP**, pas sur la géographie. Un poste détermine son site en comparant son IP aux sous-réseaux déclarés dans AD.

### Créer et gérer des sites

```powershell
# Créer un nouveau site
New-ADReplicationSite -Name "Lyon"

# Créer un sous-réseau et l'associer à un site
New-ADReplicationSubnet -Name "192.168.20.0/24" -Site "Lyon"

# Voir tous les sites
Get-ADReplicationSite -Filter *

# Voir les sous-réseaux d'un site
Get-ADReplicationSubnet -Filter * | Where-Object {$_.Site -eq "CN=Lyon,CN=Sites,CN=Configuration,DC=contoso,DC=com"}

# Déplacer un DC vers un autre site
Move-ADDirectoryServer -Identity "DC-LYO-01" -Site "Lyon"
```

> [!tip] Bonnes pratiques sites
> 
> - Créez un site pour chaque emplacement géographique avec DC
> - Déclarez tous vos sous-réseaux (même sans DC) pour éviter le "Default-First-Site-Name"
> - Renommez le site par défaut "Default-First-Site-Name" en quelque chose de significatif

### Qu'est-ce qu'un lien de sites ?

Un **site link** (lien de sites) définit la connectivité entre deux ou plusieurs sites et contrôle la réplication inter-sites.

Propriétés d'un lien de sites :

- **Sites connectés** : Quels sites sont reliés
- **Coût** : Préférence de chemin (plus bas = préféré)
- **Fréquence de réplication** : Intervalle entre réplications (défaut : 180 min)
- **Planification** : Quand la réplication est autorisée (défaut : 24h/24)

```powershell
# Créer un lien de sites
New-ADReplicationSiteLink -Name "Paris-Lyon" `
    -SitesIncluded "Paris","Lyon" `
    -Cost 100 `
    -ReplicationFrequencyInMinutes 180

# Voir tous les liens de sites
Get-ADReplicationSiteLink -Filter *

# Modifier un lien de sites
Set-ADReplicationSiteLink -Identity "Paris-Lyon" `
    -Cost 50 `
    -ReplicationFrequencyInMinutes 60
```

### Coût et routage

Le **coût** détermine le chemin préféré quand plusieurs routes existent :

```
Exemple multi-sites :

Paris (100)─────Lyon
  │              │
  │(150)    (50) │
  │              │
Marseille────────┘
      (100)

Chemin Paris → Marseille :
- Direct : Coût 150
- Via Lyon : Coût 100 + 50 = 150
→ Les deux chemins sont équivalents, AD peut utiliser l'un ou l'autre

Si on baisse Paris-Lyon à 80 :
- Via Lyon : Coût 80 + 50 = 130 → Préféré !
```

> [!tip] Définir les coûts Basez le coût sur :
> 
> - La **bande passante** (moins de bande passante = coût plus élevé)
> - La **latence** (plus de latence = coût plus élevé)
> - Le **coût financier** (liaison payante = coût élevé)

### Planification de réplication

La planification contrôle **quand** la réplication peut avoir lieu :

```powershell
# Créer une planification personnalisée (réplication seulement la nuit)
$schedule = New-Object -TypeName System.DirectoryServices.ActiveDirectory.ActiveDirectorySchedule
$schedule.ResetSchedule()  # Tout bloquer
$schedule.SetDailySchedule("Twenty:Zero:Zero", "Zero:Zero", "Six:Zero:Zero", "Zero:Zero")  # 20h-6h

# Appliquer à un lien de sites
Set-ADReplicationSiteLink -Identity "Paris-Lyon" -Schedule $schedule

# Réplication 24h/24 (défaut)
Set-ADReplicationSiteLink -Identity "Paris-Lyon" -Schedule $null
```

> [!warning] Impact de la planification Une planification restrictive retarde les modifications importantes (comme la réinitialisation de mots de passe). Utilisez avec prudence !

### Site Link Bridge

Par défaut, AD utilise le **bridging** automatique : tous les liens de sites sont transitifs.

```
Si bridging activé (défaut) :
Paris ─── Lyon ─── Marseille
→ Paris peut répliquer avec Marseille via Lyon automatiquement

Si bridging désactivé :
Il faut créer un Site Link Bridge explicite pour connecter Paris-Lyon-Marseille
```

```powershell
# Désactiver le bridging automatique (rare)
Set-ADReplicationSite -Identity "Paris" -AutomaticInterSiteTopologyGenerationEnabled $false

# Créer un Site Link Bridge manuel
New-ADReplicationSiteLinkBridge -Name "Europe-Bridge" `
    -SiteLinksIncluded "Paris-Lyon","Lyon-Marseille"
```

> [!info] Quand désactiver le bridging ? Uniquement si votre réseau n'est **pas entièrement routé** (cas très rare avec firewalls stricts entre sites).

### Vérifier la couverture des sites

```powershell
# Vérifier qu'un sous-réseau est déclaré
nltest /dsgetsite

# Voir quel site correspond à une IP
nltest /server:DC01 /dsaddresstosite:192.168.20.15

# Lister tous les DC d'un site
Get-ADDomainController -Filter * | Where-Object {$_.Site -eq "Lyon"}

# Afficher les détails d'un site
Get-ADReplicationSite -Identity "Lyon" -Properties *
```

### Diagnostic des problèmes de sites

```powershell
# Vérifier la configuration des sites et liens
dcdiag /test:topology

# Tester la connectivité inter-sites
dcdiag /test:intersite

# Afficher la topologie de réplication inter-sites
repadmin /bridgeheads
repadmin /showrepl * /csv | ConvertFrom-Csv | Where-Object {$_.`Source DSA Site` -ne $_.`Destination DSA Site`}

# Simuler le choix de site d'un client
nltest /dsgetdc:contoso.com /site:Lyon
```

> [!tip] Configuration type **Petite entreprise (2-3 sites)** :
> 
> - Un site par emplacement
> - Liens de sites directs entre tous les sites
> - Réplication toutes les 60-180 minutes
> - Pas de planification restrictive
> 
> **Grande entreprise (10+ sites)** :
> 
> - Topologie hub-and-spoke (sites agences → site central)
> - Coûts différenciés selon bande passante
> - Planifications pour économiser les liaisons WAN coûteuses
> - Plusieurs têtes de pont pour la redondance

---

## 🔒 RODC (Read-Only Domain Controller)

### Qu'est-ce qu'un RODC ?

Un **Read-Only Domain Controller** est un contrôleur de domaine en **lecture seule** qui contient une copie de la base de données Active Directory mais n'accepte aucune modification.

> [!info] Cas d'usage d'un RODC
> 
> - **Agences distantes** avec sécurité physique faible
> - **Sites avec personnel IT limité ou non formé**
> - **DMZ** ou zones à risque
> - **Sites avec liaisons WAN instables** (réplication unidirectionnelle)

### Différences RODC vs DC standard

|Caractéristique|DC standard (writable)|RODC (read-only)|
|---|---|---|
|**Écriture**|Oui, accepte les modifications|Non, rejette les écritures|
|**Réplication**|Bidirectionnelle|Unidirectionnelle (reçoit uniquement)|
|**Mots de passe**|Tous les mots de passe|Cache partiel et contrôlé|
|**Rôles FSMO**|Peut héberger les rôles|Ne peut jamais héberger de rôle FSMO|
|**DNS**|Peut héberger zones AD-intégrées en écriture|Zones DNS en lecture seule uniquement|
|**Administration**|Complète|Délégation d'administration locale possible|

### Fonctionnement de la réplication

Un RODC réplique **uniquement depuis** des DC en écriture :

```
DC en écriture ────► RODC
(Paris)            (Agence)

- Le RODC tire les modifications depuis le DC
- Le RODC ne pousse jamais de modifications
- Le DC en écriture ne réplique jamais depuis le RODC
```

Si un utilisateur tente une modification sur un RODC :

1. Le RODC rejette la demande
2. Le RODC redirige le client vers un DC en écriture (via LDAP referral)
3. Le client contacte le DC en écriture pour effectuer la modification

> [!warning] Latence WAN Les modifications nécessitent toujours un aller-retour vers un DC en écriture. Pour des sites distants avec latence élevée, cela peut impacter l'expérience utilisateur.

### Credential Caching (mise en cache des mots de passe)

Par défaut, un RODC **ne stocke aucun mot de passe**. Pour permettre l'authentification locale, vous devez configurer le caching :

#### Password Replication Policy (PRP)

La PRP contrôle quels comptes peuvent avoir leur mot de passe mis en cache :

- **Allowed RODC Password Replication Group** : Comptes autorisés
- **Denied RODC Password Replication Group** : Comptes explicitement refusés (prioritaire)

```powershell
# Voir la PRP d'un RODC
Get-ADDomainControllerPasswordReplicationPolicy -Identity "RODC-AGE-01"

# Ajouter un compte au groupe autorisé
Add-ADGroupMember -Identity "Allowed RODC Password Replication Group" `
    -Members "CN=Jean Dupont,OU=Users,DC=contoso,DC=com"

# Voir quels mots de passe sont actuellement cachés sur le RODC
Get-ADDomainControllerPasswordReplicationPolicyUsage -Identity "RODC-AGE-01"

# Forcer le pré-peuplement du cache pour des comptes spécifiques
Sync-ADObject -Object "CN=Jean Dupont,OU=Users,DC=contoso,DC=com" `
    -Destination "RODC-AGE-01" `
    -PasswordOnly
```

> [!tip] Configuration PRP typique
> 
> 1. Créez un groupe "Users-Agence-Lyon"
> 2. Ajoutez les utilisateurs locaux à ce groupe
> 3. Ajoutez le groupe au "Allowed RODC Password Replication Group"
> 4. Les utilisateurs peuvent s'authentifier localement, même si le WAN tombe

> [!warning] Sécurité du cache Un RODC compromis expose uniquement les mots de passe mis en cache, pas tous les mots de passe du domaine. Limitez le cache aux comptes vraiment nécessaires !

### Délégation d'administration locale

Vous pouvez déléguer l'administration d'un RODC à un utilisateur ou groupe **sans lui donner les privilèges Domain Admins** :

```powershell
# Déléguer l'administration d'un RODC à un groupe local
Set-ADAccountControl -Identity "RODC-AGE-01$" `
    -ManagedBy "CN=Admins Agence Lyon,OU=Groups,DC=contoso,DC=com"

# Voir qui administre un RODC
Get-ADComputer -Identity "RODC-AGE-01" -Properties ManagedBy | Select-Object Name, ManagedBy
```

Les administrateurs délégués peuvent :

- Redémarrer le RODC
- Gérer les services locaux
- Consulter les logs

Ils ne peuvent **pas** :

- Modifier le schéma ou la configuration AD
- Créer/modifier des objets dans AD
- Administrer d'autres DC

> [!tip] Cas d'usage Idéal pour déléguer à un technicien sur site la maintenance basique sans risque pour l'AD global.

### Installer un RODC

```powershell
# Prérequis : Préparer la forêt pour les RODC (une seule fois)
# Nécessite niveau fonctionnel Windows Server 2008 minimum
adprep /rodcprep

# Installer le rôle AD DS
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

# Promouvoir en RODC
Install-ADDSDomainController `
    -DomainName "contoso.com" `
    -SiteName "Lyon" `
    -ReadOnlyReplica `
    -Credential (Get-Credential) `
    -InstallDns `
    -Force

# Avec pré-création du compte RODC (staged installation)
# Étape 1 : Créer le compte RODC depuis un DC en écriture
Add-ADDSReadOnlyDomainControllerAccount `
    -DomainControllerAccountName "RODC-AGE-01" `
    -DomainName "contoso.com" `
    -SiteName "Lyon" `
    -DelegatedAdministratorAccountName "Admins Agence Lyon"

# Étape 2 : Sur le serveur distant, attacher au compte pré-créé
Install-ADDSDomainController `
    -DomainName "contoso.com" `
    -UseExistingAccount `
    -Credential (Get-Credential) `
    -Force
```

> [!info] Installation par étapes (staged) Avantages :
> 
> - Le compte RODC est créé à l'avance par un admin de confiance
> - L'installation sur site ne nécessite que des droits limités
> - La PRP peut être configurée avant même que le RODC soit en ligne

### Gérer un RODC

```powershell
# Vérifier qu'un DC est bien un RODC
Get-ADDomainController -Identity "RODC-AGE-01" | Select-Object Name, IsReadOnly

# Voir les partenaires de réplication d'un RODC
Get-ADReplicationPartnerMetadata -Target "RODC-AGE-01"

# Forcer une réplication vers le RODC
repadmin /replicate RODC-AGE-01 DC-PAR-01 "DC=contoso,DC=com"

# Vérifier l'état de santé d'un RODC
dcdiag /s:RODC-AGE-01 /test:replications
dcdiag /s:RODC-AGE-01 /test:advertising
```

### Gérer les secrets sur un RODC

```powershell
# Voir tous les mots de passe actuellement en cache
Get-ADDomainControllerPasswordReplicationPolicyUsage -Identity "RODC-AGE-01" | 
    Select-Object AccountName, LastLogonDate

# Effacer le cache de mot de passe d'un compte spécifique
Reset-ADDomainControllerPasswordReplicationPolicy -Identity "RODC-AGE-01" `
    -AccountName "jean.dupont"

# Effacer TOUT le cache de mots de passe (après compromission)
Get-ADDomainControllerPasswordReplicationPolicyUsage -Identity "RODC-AGE-01" | 
    ForEach-Object {
        Reset-ADDomainControllerPasswordReplicationPolicy -Identity "RODC-AGE-01" `
            -AccountName $_.AccountName
    }

# Voir l'historique de réplication des mots de passe (audit)
Get-ADDomainControllerPasswordReplicationPolicy -Identity "RODC-AGE-01" -Allowed
Get-ADDomainControllerPasswordReplicationPolicy -Identity "RODC-AGE-01" -Denied
```

> [!warning] Procédure de compromission Si un RODC est volé ou compromis :
> 
> 1. Réinitialisez les mots de passe de TOUS les comptes mis en cache
> 2. Supprimez le RODC de l'AD
> 3. Analysez les logs pour identifier les comptes à risque
> 4. Considérez une réinitialisation du compte machine du RODC (krbtgt_XXXXX)

### Comptes krbtgt du RODC

Chaque RODC possède son **propre compte krbtgt** distinct :

```powershell
# Voir le compte krbtgt spécifique au RODC
Get-ADUser -Filter {Name -like "krbtgt_*"} -Properties Created, PasswordLastSet

# Format : krbtgt_12345 (où 12345 = nombre aléatoire unique au RODC)
```

> [!info] Pourquoi un krbtgt séparé ? Si un RODC est compromis, seuls les tickets Kerberos émis par CE RODC sont invalidés lors de la réinitialisation. Les autres DC et RODC continuent de fonctionner normalement.

### Limitations des RODC

Les RODC ne peuvent **pas** :

- Héberger de rôles FSMO
- Être serveur de catalogue global complet (GC limité aux partitions locales)
- Accepter des écritures (sauf cache DNS dynamique avec paramètres spécifiques)
- Répliquer vers d'autres DC
- Servir de source de réplication pour un autre RODC

> [!tip] Bonnes pratiques RODC ✅ **À faire** :
> 
> - Utilisez dans les sites distants non sécurisés
> - Configurez la PRP de manière restrictive
> - Auditez régulièrement les mots de passe mis en cache
> - Placez le RODC dans un site AD dédié si possible
> - Maintenez au moins un DC en écriture accessible (même distant)
> 
> ❌ **À éviter** :
> 
> - Utiliser un RODC comme seul DC d'un domaine
> - Mettre en cache les comptes privilégiés (Domain Admins, etc.)
> - Ignorer les alertes de réplication unidirectionnelle
> - Oublier de configurer la PRP (aucune authentification locale !)

### Surveillance d'un RODC

```powershell
# Vérifier les événements de sécurité spécifiques aux RODC
Get-WinEvent -LogName Security -FilterXPath "*[System[EventID=4742]]" -MaxEvents 50
# EventID 4742 : Tentative de modification refusée par RODC

# Surveiller les tentatives d'accès aux mots de passe non cachés
Get-WinEvent -LogName "Directory Service" -FilterXPath "*[System[EventID=2961]]"
# EventID 2961 : Mot de passe non en cache, redirection vers DC en écriture

# Vérifier la latence de réplication RODC
repadmin /showrepl RODC-AGE-01 /csv | ConvertFrom-Csv | 
    Where-Object {$_.'Last Replication Result' -ne 0}
```

### Désinstaller un RODC

```powershell
# Rétrograder le RODC (depuis le RODC lui-même)
Uninstall-ADDSDomainController -LocalAdministratorPassword (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force) `
    -Force

# Ou depuis un DC en écriture (si RODC inaccessible)
Remove-ADDomainController -Identity "RODC-AGE-01" -Credential (Get-Credential) -Force

# Nettoyer les métadonnées (si le RODC ne démarre plus)
# Dans Active Directory Sites and Services :
# Sites > Lyon > Servers > RODC-AGE-01 > Clic droit > Delete
# Cochez "This domain controller is permanently offline"
```

> [!warning] Nettoyage complet Après suppression d'un RODC, vérifiez :
> 
> - Les objets de connexion obsolètes
> - Le compte machine du RODC dans AD
> - Les comptes krbtgt_XXXXX associés (conservez-les au moins 30 jours pour l'audit)

---

## 🎯 Synthèse : Haute disponibilité et maintenance

### Points clés à retenir

**Contrôleurs de domaine multiples** :

- Modèle multi-maître pour la redondance
- Rôles FSMO pour opérations critiques uniques
- Minimum 2 DC par domaine en production

**Réplication** :

- Réplication au niveau attribut avec USN
- Intra-site : rapide, non compressée, notifiée
- Inter-sites : planifiée, compressée, optimisée WAN
- Résolution automatique des conflits

**Topologie** :

- KCC génère automatiquement la topologie optimale
- Anneau bidirectionnel intra-site
- Serveurs têtes de pont pour inter-sites
- Connexions manuelles seulement si nécessaire

**Sites AD** :

- Basés sur les sous-réseaux IP
- Optimisent réplication et authentification
- Liens de sites contrôlent la réplication inter-sites
- Coût et planification pour gérer le WAN

**RODC** :

- Lecture seule, sécurisé pour sites distants
- Réplication unidirectionnelle uniquement
- Cache partiel de mots de passe contrôlé par PRP
- Délégation d'administration possible
- Aucun rôle FSMO

### Commandes essentielles

```powershell
# Vérifier l'état global de réplication
repadmin /replsummary
Get-ADReplicationFailure -Target * -Scope Domain

# Forcer réplication complète
repadmin /syncall /AdeP

# Voir les rôles FSMO
netdom query fsmo

# Gérer les sites
Get-ADReplicationSite -Filter *
Get-ADReplicationSiteLink -Filter *

# Gérer un RODC
Get-ADDomainController -Filter {IsReadOnly -eq $true}
Get-ADDomainControllerPasswordReplicationPolicyUsage -Identity "RODC-01"

# Diagnostic complet
dcdiag /v
dcdiag /test:replications /e
```

---

✅ **Cours terminé !** Vous maîtrisez maintenant la haute disponibilité et la maintenance d'Active Directory Domain Services.