

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

## 🚀 Introduction aux GPO

Les **Group Policy Objects (GPO)** constituent l'un des mécanismes les plus puissants d'Active Directory pour administrer et configurer de manière centralisée les ordinateurs et utilisateurs d'un domaine Windows.

> [!info] Qu'est-ce qu'une GPO ? Une GPO est un ensemble de paramètres de configuration qui peuvent être appliqués automatiquement à des utilisateurs et/ou des ordinateurs dans Active Directory. Ces paramètres permettent de contrôler l'environnement de travail, la sécurité, les applications, et bien plus encore.

### 🎯 Pourquoi utiliser les GPO ?

Les stratégies de groupe répondent à plusieurs besoins essentiels en entreprise :

- **Centralisation** : Gérer des milliers d'ordinateurs depuis un point unique
- **Cohérence** : Garantir des configurations identiques sur l'ensemble du parc
- **Sécurité** : Appliquer des politiques de sécurité uniformes
- **Productivité** : Automatiser les déploiements et configurations
- **Conformité** : Assurer le respect des normes et réglementations

> [!example] Exemples d'utilisation courante
> 
> - Définir la complexité des mots de passe pour tous les utilisateurs
> - Installer automatiquement des logiciels sur les postes de travail
> - Configurer les paramètres du pare-feu Windows
> - Mapper des lecteurs réseau selon les départements
> - Restreindre l'accès au panneau de configuration
> - Définir un fond d'écran d'entreprise
> - Configurer les paramètres de proxy internet

---

## 📋 Définition et objectifs

### Définition technique

Une **GPO (Group Policy Object)** est un objet Active Directory qui contient des collections de paramètres de stratégie. Elle se compose de deux parties complémentaires :

1. **Le conteneur GPO** : Objet stocké dans Active Directory (partition de domaine)
2. **Le modèle GPO (GPT)** : Dossier contenant les fichiers de configuration dans SYSVOL

> [!info] GUID unique Chaque GPO possède un identifiant unique (GUID) au format `{XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}` qui permet de lier le conteneur AD et le dossier SYSVOL.

### Structure d'une GPO

Une GPO se divise en deux grandes sections :

|Section|Cible|Moment d'application|
|---|---|---|
|**Configuration ordinateur**|Machines du domaine|Au démarrage de l'ordinateur|
|**Configuration utilisateur**|Comptes utilisateurs|À l'ouverture de session|

```
GPO "Stratégie de sécurité"
├── Configuration ordinateur
│   ├── Stratégies
│   │   ├── Paramètres Windows
│   │   └── Modèles d'administration
│   └── Préférences
│       ├── Paramètres Windows
│       └── Paramètres du Panneau de configuration
└── Configuration utilisateur
    ├── Stratégies
    │   ├── Paramètres Windows
    │   └── Modèles d'administration
    └── Préférences
        ├── Paramètres Windows
        └── Paramètres du Panneau de configuration
```

### Objectifs principaux des GPO

#### 1. 🔒 Sécurité et conformité

Les GPO permettent d'appliquer des politiques de sécurité strictes :

- Complexité et expiration des mots de passe
- Verrouillage de compte après échecs de connexion
- Stratégies d'audit pour tracer les événements
- Restrictions d'accès aux fonctionnalités système
- Configuration du pare-feu et antivirus

#### 2. ⚙️ Standardisation des configurations

Assurer l'homogénéité du parc informatique :

- Paramètres réseau identiques
- Configuration des navigateurs
- Options d'alimentation électrique
- Paramètres d'imprimantes par défaut
- Configurations régionales (langue, fuseau horaire)

#### 3. 📦 Déploiement de logiciels

Automatiser l'installation et la maintenance des applications :

- Déploiement silencieux de logiciels (.msi)
- Mises à jour automatiques
- Désinstallation à distance
- Attribution vs publication d'applications

#### 4. 🎨 Personnalisation de l'environnement

Adapter l'interface utilisateur aux besoins de l'entreprise :

- Fond d'écran et écran de verrouillage
- Menu démarrer personnalisé
- Raccourcis bureau et barre des tâches
- Configuration du profil utilisateur

#### 5. 🛡️ Restriction et contrôle

Limiter les actions des utilisateurs :

- Blocage de l'accès au registre
- Désactivation du panneau de configuration
- Restriction des périphériques USB
- Contrôle des installations de logiciels
- Blocage de l'invite de commandes

> [!warning] Équilibre sécurité/productivité Attention à ne pas trop restreindre l'environnement utilisateur. Des GPO trop restrictives peuvent nuire à la productivité et générer de la frustration. Trouvez le juste équilibre entre sécurité et usabilité.

### Types de paramètres dans une GPO

Les GPO contiennent deux types de paramètres :

#### Stratégies (Policies)

- **Nature** : Paramètres natifs Windows
- **Persistance** : Disparaissent si la GPO est supprimée ou ne s'applique plus
- **Gestion** : Via les fichiers de registre (Registry.pol)
- **Priorité** : Gérée par l'ordre d'application des GPO

#### Préférences (Preferences)

- **Nature** : Paramètres étendus ajoutés depuis Windows Server 2008
- **Persistance** : Restent en place même si la GPO est supprimée
- **Gestion** : Fichiers XML dans SYSVOL
- **Flexibilité** : Ciblage avancé (targeting) selon des critères

> [!tip] Quand utiliser les préférences ? Utilisez les préférences pour des paramètres que l'utilisateur peut modifier (lecteurs réseau, raccourcis, imprimantes) et les stratégies pour des paramètres de sécurité que l'utilisateur ne doit pas pouvoir changer.

---

## 🏗️ Architecture des GPO

### Composants architecturaux

L'architecture des GPO repose sur plusieurs composants interconnectés :

#### 1. Le conteneur GPO dans Active Directory

Stocké dans la partition de domaine AD :

```
CN={GUID},CN=Policies,CN=System,DC=domaine,DC=local
```

**Contenu du conteneur** :

- GUID de la GPO
- Nom d'affichage (Display Name)
- Numéro de version
- État (activé/désactivé)
- Informations de sécurité (ACL)
- Liens WMI (filtres)

#### 2. Le modèle GPO (GPT) dans SYSVOL

Dossier physique sur les contrôleurs de domaine :

```
\\domaine.local\SYSVOL\domaine.local\Policies\{GUID}\
```

**Structure du dossier GPT** :

```
{GUID}/
├── GPT.INI                    # Fichier de version et informations
├── Machine/                   # Configuration ordinateur
│   ├── Registry.pol           # Paramètres de registre
│   ├── Microsoft/
│   │   └── Windows NT/
│   │       └── SecEdit/
│   │           └── GptTmpl.inf  # Modèles de sécurité
│   ├── Scripts/               # Scripts de démarrage/arrêt
│   │   ├── Startup/
│   │   └── Shutdown/
│   └── Preferences/           # Préférences ordinateur
└── User/                      # Configuration utilisateur
    ├── Registry.pol
    ├── Scripts/               # Scripts ouverture/fermeture session
    │   ├── Logon/
    │   └── Logoff/
    └── Preferences/           # Préférences utilisateur
```

> [!info] Fichier GPT.INI Ce fichier contient le numéro de version de la GPO. Il est utilisé pour déterminer si une GPO a été modifiée et doit être réappliquée sur les clients.

### Processus de réplication

Les GPO sont répliquées entre contrôleurs de domaine via deux mécanismes :

|Composant|Mécanisme de réplication|Protocole|
|---|---|---|
|Conteneur AD|Réplication Active Directory|LDAP/RPC|
|GPT (SYSVOL)|Réplication de fichiers|FRS ou DFSR|

> [!warning] Synchronisation GPO Le conteneur AD et le GPT doivent avoir le même numéro de version. Une désynchronisation peut entraîner des problèmes d'application des stratégies.

### Hiérarchie et héritage des GPO

Les GPO peuvent être liées à différents niveaux de l'architecture AD :

```
Forêt
└── Domaine (Site Local)
    ├── Site (GPO Site)
    ├── Domaine (GPO Domaine par défaut)
    └── Unités d'Organisation (OU)
        ├── OU Utilisateurs (GPO OU Utilisateurs)
        ├── OU Ordinateurs (GPO OU Ordinateurs)
        └── Sous-OU (GPO Sous-OU)
```

**Ordre d'application (LSDOU)** :

1. **L**ocal (GPO locale de la machine)
2. **S**ite (GPO liée au site AD)
3. **D**omain (GPO liée au domaine)
4. **O**U (GPO liées aux OU, de la plus haute vers la plus basse)

> [!example] Exemple d'héritage Un utilisateur dans `OU=Comptabilité,OU=Finance,DC=entreprise,DC=local` recevra les GPO dans cet ordre :
> 
> 1. GPO locale de son poste
> 2. GPO du site AD (ex: Site-Paris)
> 3. GPO du domaine entreprise.local
> 4. GPO de l'OU Finance
> 5. GPO de l'OU Comptabilité (dernière appliquée = prioritaire)

### Mécanismes de contrôle de l'héritage

#### Blocage de l'héritage (Block Inheritance)

Empêche les GPO des niveaux supérieurs de s'appliquer à une OU :

```
OU Marketing (Block Inheritance activé)
└── Les GPO du domaine ne s'appliquent PAS ici
```

> [!warning] Utilisation prudente Le blocage d'héritage peut créer des incohérences de sécurité. À utiliser uniquement si nécessaire (ex: filiales autonomes).

#### Application forcée (Enforced/No Override)

Force l'application d'une GPO même si un niveau inférieur bloque l'héritage :

```
Domaine (GPO Sécurité - Enforced)
└── OU Marketing (Block Inheritance)
    └── La GPO Sécurité s'applique QUAND MÊME
```

**Ordre de priorité en cas de conflit** :

1. GPO locale
2. GPO site/domaine/OU normales
3. GPO avec Enforced (la plus haute dans l'arborescence gagne)

### Filtrage de sécurité

Les GPO utilisent les permissions NTFS et les ACL pour contrôler leur application :

**Permissions requises pour appliquer une GPO** :

- **Lecture** : Lire le contenu de la GPO
- **Appliquer la stratégie de groupe** : Permission spéciale nécessaire

```
Groupe de sécurité      | Lecture | Appliquer GPO
-----------------------|---------|---------------
Utilisateurs du domaine | ✓       | ✓
Admins du domaine       | ✓       | ✗ (par défaut)
Groupe-IT               | ✓       | ✓
Groupe-Finance          | ✓       | ✗
```

> [!tip] Filtrage par groupe Plutôt que de créer de nombreuses OU, utilisez le filtrage de sécurité pour appliquer une GPO uniquement à certains groupes d'utilisateurs ou d'ordinateurs.

### Filtres WMI

Les filtres WMI permettent d'appliquer une GPO selon des critères système :

**Exemples de critères** :

- Version du système d'exploitation
- Quantité de RAM
- Espace disque disponible
- Présence d'un logiciel spécifique
- Type de matériel (portable vs fixe)

```sql
-- Exemple : Appliquer seulement aux Windows 11
SELECT * FROM Win32_OperatingSystem 
WHERE Version LIKE "10.0.22%" AND ProductType="1"
```

> [!warning] Impact sur les performances Les filtres WMI ralentissent l'application des GPO car ils nécessitent l'exécution de requêtes WMI sur chaque client. Utilisez-les avec parcimonie.

### Traitement des GPO côté client

#### Cycle de rafraîchissement

Les GPO sont actualisées régulièrement sur les clients :

|Contexte|Intervalle|Aléatoire|
|---|---|---|
|Configuration ordinateur|90 minutes|± 30 min|
|Configuration utilisateur|90 minutes|± 30 min|
|Contrôleurs de domaine|5 minutes|Aucun|

**Forcer le rafraîchissement manuellement** :

```powershell
# Forcer la mise à jour de toutes les GPO
gpupdate /force

# Forcer et redémarrer si nécessaire
gpupdate /force /boot

# Forcer et fermer la session si nécessaire
gpupdate /force /logoff
```

#### Mode de traitement

Deux modes de traitement existent :

**Traitement synchrone** (par défaut au démarrage/ouverture session) :

- Les GPO sont traitées séquentiellement
- L'utilisateur attend que tout soit appliqué
- Plus lent mais garanti que tout est configuré

**Traitement asynchrone** (par défaut en arrière-plan) :

- Les GPO sont traitées en parallèle
- L'utilisateur peut travailler pendant le traitement
- Plus rapide mais peut créer des états temporaires incohérents

> [!info] Traitement en boucle de rappel (Loopback) Le mode Loopback permet d'appliquer des GPO utilisateur en fonction de l'ordinateur utilisé, plutôt que du compte utilisateur. Utile pour les postes partagés (salles de formation, bornes d'accueil).

---

## 💾 Stockage SYSVOL

### Qu'est-ce que SYSVOL ?

**SYSVOL** (System Volume) est un dossier partagé présent sur tous les contrôleurs de domaine qui stocke les fichiers essentiels du domaine :

- **GPO** : Modèles de stratégies de groupe (GPT)
- **Scripts** : Scripts de connexion et de démarrage
- **Fichiers publics** : Autres fichiers de stratégie partagés

> [!info] Chemin SYSVOL Le chemin par défaut est `C:\Windows\SYSVOL\` sur chaque contrôleur de domaine, mais le partage réseau utilisé est `\\domaine.local\SYSVOL\`.

### Structure détaillée de SYSVOL

```
C:\Windows\SYSVOL\
├── domain/                          # Lien symbolique vers sysvol
└── sysvol/
    └── domaine.local/
        ├── Policies/                # Dossier des GPO
        │   ├── {31B2F340-016D-11D2-945F-00C04FB984F9}/  # Default Domain Policy
        │   │   ├── GPT.INI
        │   │   ├── Machine/
        │   │   └── User/
        │   ├── {6AC1786C-016F-11D2-945F-00C04fB984F9}/  # Default Domain Controllers Policy
        │   └── {GUID-custom-GPO}/   # Vos GPO personnalisées
        └── scripts/                 # Scripts de connexion classiques
            ├── startup.bat
            └── logon.vbs
```

### Accès au partage SYSVOL

Le partage SYSVOL est accessible via plusieurs chemins UNC :

```
# Accès par nom de domaine (recommandé)
\\domaine.local\SYSVOL\domaine.local\

# Accès par nom de contrôleur de domaine
\\DC01.domaine.local\SYSVOL\domaine.local\

# Chemin local sur le DC
C:\Windows\SYSVOL\sysvol\domaine.local\
```

> [!tip] Diagnostic SYSVOL Utilisez `\\domaine.local\SYSVOL\` plutôt que le nom d'un DC spécifique. Cela garantit que vous accédez toujours à un DC disponible et évite les problèmes si un DC est hors ligne.

### Réplication de SYSVOL

SYSVOL doit être identique sur tous les contrôleurs de domaine. Deux technologies de réplication existent :

#### FRS (File Replication Service)

- **Ancienne technologie** (Windows 2000/2003)
- **Obsolète** depuis Windows Server 2008 R2
- Réplication basée sur le journal USN
- Problèmes de performances et de fiabilité

#### DFSR (Distributed File System Replication)

- **Technologie moderne** (Windows Server 2008+)
- **Recommandée** et utilisée par défaut
- Réplication multi-maître efficace
- Compression des données répliquées
- Gestion intelligente des conflits

> [!warning] Migration FRS vers DFSR Si vous avez un domaine créé avant Windows Server 2008 R2, vérifiez que SYSVOL utilise DFSR. La migration se fait avec l'outil `dfsrmig.exe`.

**Vérifier le mode de réplication actuel** :

```powershell
# Vérifier l'état de la migration DFSR
dfsrmig /getglobalstate

# États possibles :
# 0 = Start (FRS utilisé)
# 1 = Prepared
# 2 = Redirected
# 3 = Eliminated (DFSR utilisé)
```

### Permissions sur SYSVOL

Les permissions NTFS et de partage sont critiques pour la sécurité :

**Permissions de partage** :

|Groupe|Permission|
|---|---|
|Tout le monde|Lecture|
|Administrateurs|Contrôle total|

**Permissions NTFS sur le dossier Policies** :

|Groupe|Permission|Héritage|
|---|---|---|
|Admins du domaine|Contrôle total|Oui|
|Système|Contrôle total|Oui|
|Utilisateurs authentifiés|Lecture et exécution|Oui|
|Propriétaires créateurs|Contrôle total|Sous-dossiers uniquement|

> [!warning] Sécurité SYSVOL Ne modifiez jamais les permissions par défaut de SYSVOL sans raison valide. Des permissions incorrectes peuvent empêcher l'application des GPO ou créer des failles de sécurité.

### Dépannage SYSVOL

#### Problèmes courants

**Symptôme** : Les GPO ne s'appliquent pas ou de façon incohérente

**Causes possibles** :

1. SYSVOL non répliqué entre les DC
2. Service de réplication arrêté
3. Problèmes de connectivité réseau
4. Permissions SYSVOL incorrectes
5. Corruption de la base DFSR

**Commandes de diagnostic** :

```powershell
# Vérifier l'état de la réplication DFSR
Get-DfsrBacklog -GroupName "Domain System Volume" -FolderName "SYSVOL Share" -SourceComputerName DC01 -DestinationComputerName DC02

# Vérifier l'état du service DFSR
Get-Service DFSR | Select-Object Status, StartType

# Forcer une synchronisation
dfsrdiag syncnow /rgname:"Domain System Volume" /partner:DC02 /time:1

# Vérifier les événements de réplication
Get-EventLog -LogName "DFS Replication" -Newest 50 | Where-Object {$_.EntryType -eq "Error"}
```

#### Reconstruction de SYSVOL

En cas de corruption sévère, une reconstruction peut être nécessaire :

> [!warning] Procédure avancée La reconstruction de SYSVOL est une opération critique. Testez toujours sur un DC non-production d'abord et assurez-vous d'avoir des sauvegardes.

**Faire une sauvegarde autoritaire d'un DC** :

```powershell
# Sur le DC source (celui qui a le bon SYSVOL)
dfsrdiag pollad

# Marquer comme autoritaire
Stop-Service DFSR
Set-DfsrMembership ... -Force

# Relancer le service
Start-Service DFSR
```

### Bonnes pratiques SYSVOL

> [!tip] Recommandations essentielles
> 
> - **Surveillez** la réplication SYSVOL avec des outils de monitoring
> - **Limitez** la taille des GPO (évitez les gros fichiers dans SYSVOL)
> - **Nettoyez** régulièrement les anciennes GPO non utilisées
> - **Documentez** toute modification manuelle dans SYSVOL
> - **Testez** les GPO dans une OU de test avant déploiement
> - **Sauvegardez** régulièrement avec des snapshots de l'état système

### Taille et performances de SYSVOL

La taille de SYSVOL impacte directement les performances :

**Impact d'un SYSVOL volumineux** :

- Réplication plus lente entre DC
- Temps de démarrage des DC augmenté
- Bande passante réseau consommée
- Stockage disque sur tous les DC

**Limiter la taille de SYSVOL** :

```powershell
# Identifier les GPO volumineuses
Get-ChildItem "\\domaine.local\SYSVOL\domaine.local\Policies" -Recurse | 
    Group-Object Directory | 
    Select-Object Name, @{Name="SizeMB";Expression={($_.Group | Measure-Object Length -Sum).Sum / 1MB}} | 
    Sort-Object SizeMB -Descending

# Nettoyer les anciennes GPO
Remove-GPO -Name "Ancienne-GPO-2019" -Domain domaine.local
```

> [!tip] Optimisation Si vous devez déployer de gros fichiers (installateurs, wallpapers haute résolution), utilisez plutôt un partage DFS ou un serveur de fichiers dédié et référencez-le dans les GPO au lieu de stocker les fichiers dans SYSVOL.

### Fichiers sensibles dans SYSVOL

Certains fichiers de SYSVOL contiennent des informations sensibles :

**Groups.xml** (obsolète mais parfois présent) :

- Contenait des mots de passe chiffrés avec une clé connue
- **Vulnérabilité de sécurité majeure**
- Microsoft a publié un correctif en 2014

> [!warning] Audit de sécurité Recherchez et supprimez tout fichier Groups.xml ou autres fichiers de préférences contenant des mots de passe :
> 
> ```powershell
> Get-ChildItem -Path "\\domaine.local\SYSVOL\" -Recurse -Filter "Groups.xml"
> Get-ChildItem -Path "\\domaine.local\SYSVOL\" -Recurse -Filter "*.xml" | Select-String "cpassword"
> ```

---

## 🎓 Pièges courants et bonnes pratiques

### ⚠️ Pièges à éviter

1. **Trop de GPO** : Multiplier les GPO ralentit l'ouverture de session
2. **GPO mal nommées** : Utilisez des noms descriptifs (ex: "SEC-Mot de passe-V2")
3. **Pas de documentation** : Documentez toujours la raison d'être d'une GPO
4. **Modifications directes dans SYSVOL** : Utilisez toujours la console GPMC
5. **Oublier de tester** : Testez dans une OU de test avant production
6. **Conflits de paramètres** : Le dernier paramètre appliqué gagne
7. **Filtres WMI complexes** : Impactent les performances

### ✅ Bonnes pratiques essentielles

> [!tip] Conventions de nommage Adoptez une convention claire :
> 
> - **Préfixe** : Type de GPO (SEC, CFG, APP, USR, CMP)
> - **Description** : Fonction de la GPO
> - **Version** : Numéro de version (V1, V2...)
> 
> Exemple : `SEC-MotDePasse-Complexite-V3`

> [!tip] Organisation par OU Structurez votre AD avec des OU logiques :
> 
> ```
> domaine.local
> ├── OU=Postes
> │   ├── OU=Serveurs
> │   ├── OU=Postes-Fixes
> │   └── OU=Portables
> └── OU=Utilisateurs
>     ├── OU=Administratifs
>     ├── OU=Techniques
>     └── OU=Direction
> ```

> [!tip] Principe du moindre privilège N'appliquez que les paramètres nécessaires. Une GPO trop restrictive nuit à la productivité.

---

_Cours rédigé pour une utilisation avec Obsidian - Active Directory Domain Services_