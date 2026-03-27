

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

## 🎯 Introduction

Active Directory Domain Services (AD DS) est le service d'annuaire de Microsoft qui constitue le cœur de l'infrastructure réseau Windows en entreprise. Il s'agit d'une base de données hiérarchique qui centralise la gestion des ressources réseau : utilisateurs, ordinateurs, groupes, imprimantes, et bien plus encore.

> [!info] Pourquoi Active Directory ? Sans Active Directory, chaque serveur gère ses propres utilisateurs localement. Avec AD, un utilisateur peut s'authentifier une fois et accéder à toutes les ressources du réseau pour lesquelles il a des permissions. C'est le principe du **Single Sign-On (SSO)**.

---

## 📚 Qu'est-ce qu'Active Directory

### Définition

Active Directory (AD) est un **service d'annuaire** développé par Microsoft qui stocke des informations sur les objets d'un réseau et les rend facilement accessibles aux utilisateurs et administrateurs.

### Composantes principales

|Composante|Description|
|---|---|
|**Base de données**|Fichier NTDS.DIT contenant tous les objets AD|
|**Service d'annuaire**|Interface permettant d'accéder et gérer la base de données|
|**Protocole LDAP**|Lightweight Directory Access Protocol - protocole de communication avec AD|
|**Kerberos**|Protocole d'authentification sécurisé utilisé par AD|
|**DNS**|Système de résolution de noms essentiel au fonctionnement d'AD|

### Types d'objets dans AD

Active Directory stocke différents types d'objets :

- **Utilisateurs** : Comptes permettant l'authentification des personnes
- **Groupes** : Collections d'utilisateurs ou d'ordinateurs
- **Ordinateurs** : Comptes représentant les machines jointes au domaine
- **Unités d'organisation (OU)** : Conteneurs pour organiser les objets
- **Imprimantes** : Ressources d'impression partagées
- **Contacts** : Informations sur des personnes externes

> [!tip] Astuce Chaque objet dans AD possède un **Distinguished Name (DN)** unique qui l'identifie de manière absolue dans l'arborescence. Par exemple : `CN=Jean Dupont,OU=Utilisateurs,OU=Paris,DC=entreprise,DC=local`

---

## 🌲 Domaines, arborescences et forêts

### Le domaine

Un **domaine** est l'unité de base d'organisation dans Active Directory. Il représente une limite administrative et de sécurité.

**Caractéristiques d'un domaine :**

- Possède un nom DNS unique (exemple : `entreprise.local`)
- Contient des objets (utilisateurs, ordinateurs, etc.)
- A sa propre stratégie de sécurité et de mot de passe
- Dispose d'au moins un contrôleur de domaine (DC)

```
Exemple de structure d'un domaine :

entreprise.local
├── Domain Controllers (OU)
├── Users (conteneur)
├── Computers (conteneur)
├── OU=Départements
    ├── OU=IT
    ├── OU=RH
    └── OU=Ventes
```

> [!warning] Important Le nom de domaine AD n'est pas forcément le même que votre domaine Internet public. Il est courant d'utiliser `.local` ou un sous-domaine distinct pour l'AD interne.

### L'arborescence

Une **arborescence** (tree) est un ensemble de domaines connectés par des relations de confiance hiérarchiques qui partagent un espace de noms DNS contigu.

**Exemple d'arborescence :**

```
entreprise.local (domaine racine)
├── paris.entreprise.local (domaine enfant)
├── lyon.entreprise.local (domaine enfant)
└── marseille.entreprise.local (domaine enfant)
```

**Caractéristiques :**

- Les domaines enfants héritent automatiquement du nom du domaine parent
- Relations de confiance bidirectionnelles transitives automatiques
- Permet la délégation administrative par région/division

### La forêt

Une **forêt** (forest) est le périmètre de sécurité le plus large dans Active Directory. Elle regroupe un ou plusieurs arbres de domaines.

**Caractéristiques d'une forêt :**

- Partage le même schéma Active Directory
- Partage le même catalogue global
- Partage la même configuration
- Premier domaine créé = **domaine racine de forêt**
- Relations de confiance automatiques entre tous les domaines

```
Exemple de forêt multi-arbres :

FORÊT "Groupe International"
│
├── Arbre 1: entreprise.local
│   ├── paris.entreprise.local
│   └── lyon.entreprise.local
│
└── Arbre 2: subsidiary.com
    ├── us.subsidiary.com
    └── uk.subsidiary.com
```

> [!info] Niveau fonctionnel Chaque domaine et forêt possède un **niveau fonctionnel** qui détermine les fonctionnalités AD disponibles. Il dépend de la version Windows Server la plus ancienne parmi les contrôleurs de domaine.

### Relations de confiance

Les **relations de confiance** (trusts) permettent aux utilisateurs d'un domaine d'accéder aux ressources d'un autre domaine.

|Type de confiance|Description|
|---|---|
|**Bidirectionnelle**|Les deux domaines se font mutuellement confiance|
|**Unidirectionnelle**|Un seul sens de confiance|
|**Transitive**|Si A fait confiance à B et B à C, alors A fait confiance à C|
|**Non-transitive**|Limitée aux deux domaines concernés|
|**Automatique**|Créée automatiquement (parent-enfant, racine de forêt)|
|**Manuelle**|Créée explicitement par l'administrateur|

---

## 🖥️ Contrôleurs de domaine

### Définition

Un **contrôleur de domaine** (Domain Controller - DC) est un serveur Windows Server qui héberge une copie de la base de données Active Directory et qui gère les authentifications et les requêtes d'annuaire.

### Rôles et responsabilités

Un contrôleur de domaine assure les fonctions suivantes :

1. **Authentification** : Vérifie les identifiants des utilisateurs et ordinateurs
2. **Stockage de la base de données AD** : Fichier NTDS.DIT
3. **Réplication** : Synchronise les modifications avec les autres DC
4. **Application des GPO** : Fournit les stratégies de groupe aux clients
5. **Services DNS** : Généralement, les DC hébergent aussi le DNS

> [!warning] Haute disponibilité Il est **fortement recommandé** d'avoir au minimum **deux contrôleurs de domaine** pour assurer la redondance. Si votre unique DC tombe en panne, plus aucune authentification n'est possible !

### Contrôleur de domaine en lecture seule (RODC)

Un **Read-Only Domain Controller (RODC)** est un type spécial de DC qui contient une copie en lecture seule de la base AD.

**Cas d'usage :**

- Sites distants avec sécurité physique faible
- Succursales sans personnel IT sur place
- Environnements où le risque de vol est élevé

**Caractéristiques :**

- Ne permet pas de modifications directes
- Peut gérer les authentifications en cache
- Réplication unidirectionnelle (reçoit mais ne réplique pas)
- Stratégie de réplication de mots de passe configurables

### Rôles FSMO

Certaines opérations dans AD ne peuvent pas être multi-maîtres et nécessitent un DC unique. Ce sont les **rôles FSMO** (Flexible Single Master Operations).

|Rôle FSMO|Portée|Fonction|
|---|---|---|
|**Schema Master**|Forêt|Gère les modifications du schéma AD|
|**Domain Naming Master**|Forêt|Contrôle l'ajout/suppression de domaines|
|**RID Master**|Domaine|Attribue les pools de RID aux DC|
|**PDC Emulator**|Domaine|Synchronisation temps, mots de passe, GPO|
|**Infrastructure Master**|Domaine|Met à jour les références inter-domaines|

> [!tip] Commande PowerShell Pour voir qui détient les rôles FSMO :
> 
> ```powershell
> netdom query fsmo
> # OU
> Get-ADForest | Select-Object SchemaMaster, DomainNamingMaster
> Get-ADDomain | Select-Object RIDMaster, PDCEmulator, InfrastructureMaster
> ```

---

## 🌐 Sites et réplication

### Concept de site

Un **site** dans Active Directory représente un emplacement physique du réseau disposant d'une connectivité rapide et fiable (typiquement un LAN).

**Pourquoi définir des sites ?**

- Optimiser la réplication entre contrôleurs de domaine
- Permettre aux clients de s'authentifier auprès du DC le plus proche
- Contrôler le trafic réseau WAN

### Composants des sites

|Composant|Description|
|---|---|
|**Site**|Représentation d'un emplacement physique|
|**Sous-réseau**|Plages IP associées à un site|
|**Lien de sites**|Connexion entre deux sites avec coût et fréquence|
|**Pont entre liens de sites**|Permet la transitivité entre liens|

```
Exemple de configuration :

Site Paris (192.168.1.0/24)
    ├── DC-PARIS-01
    └── DC-PARIS-02
           ↕ Lien "Paris-Lyon" (Coût: 100, Fréquence: 180 min)
Site Lyon (192.168.2.0/24)
    └── DC-LYON-01
```

### Réplication Active Directory

La **réplication** est le processus de synchronisation des modifications de la base AD entre les contrôleurs de domaine.

**Types de réplication :**

1. **Réplication intra-site** :
    
    - Entre DC du même site
    - Rapide et fréquente (notification de changement)
    - Non compressée
    - Utilise RPC (Remote Procedure Call)
2. **Réplication inter-site** :
    
    - Entre DC de sites différents
    - Planifiée selon le lien de sites
    - Compressée pour économiser la bande passante
    - Peut utiliser RPC ou SMTP

> [!info] Réplication multi-maître Active Directory utilise la réplication **multi-maître** : tous les DC peuvent accepter des modifications. Un mécanisme de résolution de conflits (numéros de versions) gère les modifications concurrentes.

### Topologie de réplication

Active Directory génère automatiquement une **topologie de réplication** optimale grâce au service **KCC** (Knowledge Consistency Checker).

**Principes :**

- Création automatique d'objets de connexion entre DC
- Maximum de 3 sauts (hops) entre deux DC
- Création d'un anneau bidirectionnel dans chaque site

> [!tip] Forcer la réplication Pour forcer une réplication immédiate :
> 
> ```powershell
> repadmin /syncall /AdeP
> # OU depuis un DC spécifique
> repadmin /replicate DC-CIBLE DC-SOURCE "DC=entreprise,DC=local"
> ```

---

## 📖 Catalogue global

### Définition

Le **Catalogue global** (Global Catalog - GC) est un contrôleur de domaine spécial qui contient une copie partielle de tous les objets de tous les domaines de la forêt.

### Rôle du catalogue global

**Fonctions principales :**

1. **Recherche dans toute la forêt** : Permet de trouver des objets sans connaître leur domaine
2. **Authentification UPN** : Permet la connexion avec `utilisateur@entreprise.local`
3. **Appartenance aux groupes universels** : Nécessaire pour l'ouverture de session
4. **Recherche dans Outlook** : Carnet d'adresses global (GAL)

> [!warning] Importance critique Sans accès à un serveur de catalogue global, les utilisateurs ne peuvent **pas ouvrir de session** (sauf s'ils sont membres du groupe Admins du domaine ou si la mise en cache d'appartenance de groupe universel est activée).

### Contenu du catalogue global

Le GC contient :

- **Tous les objets** de la forêt
- **Tous les attributs** des objets du domaine local
- **Attributs partiels** des objets des autres domaines (ceux marqués dans le schéma)

**Attributs typiquement répliqués :**

- Nom d'utilisateur
- Prénom, nom
- Adresse email
- Numéro de téléphone
- Informations de département

### Configuration du catalogue global

**Par défaut :**

- Le premier DC de la forêt est automatiquement un GC
- Dans un environnement mono-domaine, tous les DC sont généralement des GC

**Activer le catalogue global sur un DC :**

1. Ouvrir **Sites et services Active Directory**
2. Développer le site → Servers → nom du DC
3. Clic droit sur **NTDS Settings** → Propriétés
4. Cocher **Catalogue global**

```powershell
# Vérifier quels DC sont des serveurs de catalogue global
Get-ADDomainController -Filter * | Select-Object Name, IsGlobalCatalog

# Activer le catalogue global via PowerShell
$dc = Get-ADDomainController -Identity "DC-PARIS-01"
Set-ADObject -Identity $dc.NTDSSettingsObjectDN -Replace @{options='1'}
```

> [!tip] Bonnes pratiques
> 
> - Avoir au moins **2 serveurs GC** par site pour la redondance
> - Dans les sites distants, évaluer si un GC local est nécessaire (impact sur authentification vs bande passante réplication)
> - Activer la **mise en cache d'appartenance de groupe universel** sur les sites sans GC

---

## 🔧 Schéma Active Directory

### Qu'est-ce que le schéma ?

Le **schéma Active Directory** est l'ensemble des définitions qui décrivent :

- Les types d'objets pouvant être créés dans AD (classes)
- Les attributs que peuvent avoir ces objets
- Les règles de création et de modification

> [!info] Métaphore Le schéma est comme un "plan de construction" ou un "moule" qui définit ce qui peut exister dans Active Directory et comment cela doit être structuré.

### Composants du schéma

**1. Classes d'objets** Définissent les types d'objets (utilisateur, ordinateur, groupe, etc.)

**2. Attributs** Propriétés que peuvent avoir les objets (nom, email, téléphone, etc.)

**3. Relations**

- Classes parentes (héritage)
- Attributs obligatoires vs optionnels
- Attributs indexés

### Extension du schéma

Le schéma peut être étendu pour ajouter de nouvelles classes ou attributs, mais cela doit être fait avec **grande prudence**.

**Cas d'extension courants :**

- Installation d'Exchange Server
- Installation de Configuration Manager (SCCM)
- Ajout d'attributs métier personnalisés

> [!warning] Attention !
> 
> - Les modifications du schéma sont **irréversibles** (on ne peut pas supprimer, seulement désactiver)
> - Elles se répliquent dans toute la forêt
> - Nécessitent le rôle FSMO **Schema Master**
> - Nécessitent appartenance au groupe **Schema Admins**

**Accéder au schéma :**

```powershell
# Enregistrer le snap-in MMC du schéma
regsvr32 schmmgmt.dll

# Puis : mmc.exe → Fichier → Ajouter un composant logiciel → Schéma Active Directory
```

---

## ✅ Bonnes pratiques

### Conception de la forêt et des domaines

> [!tip] Recommandations
> 
> - **Privilégier le modèle mono-domaine** quand c'est possible (plus simple à gérer)
> - Créer plusieurs domaines uniquement si nécessaire (politiques de mots de passe différentes, contraintes légales, délégation complète)
> - Éviter les structures trop complexes qui compliquent la maintenance

### Contrôleurs de domaine

- ✅ Déployer **minimum 2 DC** par domaine (redondance)
- ✅ Au moins **2 serveurs de catalogue global** dans l'entreprise
- ✅ Placer les DC sur du matériel dédié et fiable
- ✅ Isoler les DC sur des VLANs sécurisés si possible
- ✅ Sauvegarder régulièrement l'état du système des DC

### Sites et réplication

- ✅ Définir les sites selon la topologie réseau réelle
- ✅ Associer correctement les sous-réseaux aux sites
- ✅ Configurer les liens de sites avec des coûts appropriés
- ✅ Planifier la réplication inter-sites aux heures creuses si la bande passante est limitée

### Nommage

- ✅ Utiliser des noms DNS cohérents et standards
- ✅ Prévoir l'évolution (fusions, acquisitions)
- ✅ Documenter les choix de nommage

> [!example] Exemple de convention de nommage pour DC
> 
> ```
> DC-<SITE>-<NUMERO>
> DC-PARIS-01
> DC-PARIS-02
> DC-LYON-01
> ```

### Sécurité

- ✅ Protéger physiquement les DC (salles serveurs sécurisées)
- ✅ Limiter l'appartenance aux groupes privilégiés (Domain Admins, Enterprise Admins)
- ✅ Utiliser des comptes à privilèges séparés pour l'administration
- ✅ Activer l'audit des modifications critiques
- ✅ Maintenir les DC à jour (patches de sécurité)

### Documentation

- ✅ Documenter la topologie de la forêt et des domaines
- ✅ Cartographier les sites et liens de sites
- ✅ Identifier les détenteurs des rôles FSMO
- ✅ Maintenir un inventaire des DC (nom, IP, site, rôles)

---

## 🎓 Points clés à retenir

|Concept|À retenir|
|---|---|
|**Domaine**|Limite administrative de base, au moins 1 DC requis|
|**Forêt**|Périmètre de sécurité maximal, schéma et catalogue global partagés|
|**DC**|Serveur hébergeant AD, gère authentification et réplication|
|**Sites**|Emplacements réseau physiques, optimisent réplication et authentification|
|**Catalogue Global**|Index de tous les objets de la forêt, essentiel pour l'authentification|
|**Schéma**|Définition des objets et attributs possibles dans AD|
|**FSMO**|Rôles uniques pour certaines opérations critiques (5 au total)|

---

_Ce document couvre les concepts fondamentaux d'Active Directory. La compréhension de ces principes est essentielle avant de passer à l'installation et la configuration pratique d'AD DS._