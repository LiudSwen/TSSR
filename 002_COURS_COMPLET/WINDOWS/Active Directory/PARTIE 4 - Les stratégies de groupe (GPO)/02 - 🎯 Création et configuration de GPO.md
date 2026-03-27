

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

## 🖥️ Console de gestion des stratégies de groupe (GPMC)

### Présentation de la GPMC

La **Group Policy Management Console (GPMC)** est l'interface centralisée pour gérer toutes les stratégies de groupe dans Active Directory. Elle permet de créer, modifier, lier, sauvegarder et analyser les GPO de manière intuitive.

> [!info] Pourquoi utiliser la GPMC ?
> 
> - Interface unifiée pour toutes les opérations GPO
> - Vue d'ensemble de l'héritage et des liens
> - Outils de modélisation et de résultats de stratégie
> - Gestion des sauvegardes et restaurations
> - Rapports détaillés sur les paramètres configurés

### Installation de la GPMC

Sur Windows Server, la GPMC s'installe via le Gestionnaire de serveur :

```powershell
# Installation via PowerShell
Install-WindowsFeature -Name GPMC

# Vérification de l'installation
Get-WindowsFeature -Name GPMC
```

> [!tip] Accès rapide Pour ouvrir la GPMC : `Exécuter` → `gpmc.msc` ou via le menu Outils dans le Gestionnaire de serveur.

### Structure de la GPMC

La console s'organise en plusieurs sections :

|Section|Description|Utilisation|
|---|---|---|
|**Forêt**|Racine de la structure|Contient tous les domaines de la forêt|
|**Domaines**|Liste des domaines AD|Accès aux GPO du domaine|
|**Objets de stratégie de groupe**|Conteneur des GPO|Toutes les GPO créées|
|**Filtres WMI**|Requêtes de ciblage|Filtrage conditionnel des GPO|
|**Sites**|Emplacement réseau|Liaison de GPO au niveau site|

### Création d'une nouvelle GPO

**Méthode 1 : Via l'interface graphique**

1. Cliquer droit sur "Objets de stratégie de groupe"
2. Sélectionner "Nouveau"
3. Nommer la GPO de manière descriptive
4. Cliquer sur "OK"

**Méthode 2 : Via PowerShell**

```powershell
# Création d'une GPO basique
New-GPO -Name "GPO-Securite-Postes" -Comment "Stratégie de sécurité pour les postes de travail"

# Création avec liaison immédiate à une OU
New-GPO -Name "GPO-Config-Serveurs" | New-GPLink -Target "OU=Serveurs,DC=entreprise,DC=local"

# Création à partir d'une GPO modèle
Copy-GPO -SourceName "GPO-Modele" -TargetName "GPO-Production"
```

> [!warning] Convention de nommage Adoptez une convention claire : `GPO-[Type]-[Cible]-[Description]` Exemple : `GPO-SEC-Utilisateurs-MotDePasse` ou `GPO-CONFIG-Serveurs-Firefox`

### Liaison d'une GPO

Une GPO créée doit être liée à un conteneur AD pour s'appliquer :

```powershell
# Lier une GPO à une OU
New-GPLink -Name "GPO-Securite-Postes" -Target "OU=Postes,DC=entreprise,DC=local"

# Lier avec ordre d'application prioritaire
New-GPLink -Name "GPO-Config-VIP" -Target "OU=Direction,DC=entreprise,DC=local" -LinkEnabled Yes -Order 1

# Désactiver un lien sans le supprimer
Set-GPLink -Name "GPO-Test" -Target "OU=Tests,DC=entreprise,DC=local" -LinkEnabled No
```

> [!tip] Ordre de liaison L'ordre 1 est le plus prioritaire. Plus le numéro est bas, plus la GPO est appliquée en dernier (donc prioritaire).

### Édition d'une GPO

Pour modifier les paramètres d'une GPO :

1. **Via la GPMC** : Cliquer droit sur la GPO → "Modifier"
2. **Via PowerShell** : Pas d'édition directe, mais configuration de paramètres spécifiques

```powershell
# Ouvrir l'éditeur de GPO
Invoke-GPUpdate -Computer "PC001" -Force

# Configurer un paramètre de registre via GPO
Set-GPRegistryValue -Name "GPO-Config" -Key "HKCU\Software\Policies\Microsoft\Windows" -ValueName "NoAutoUpdate" -Type DWord -Value 1
```

### Rapports et analyse

La GPMC offre des outils puissants d'analyse :

```powershell
# Générer un rapport HTML d'une GPO
Get-GPOReport -Name "GPO-Securite-Postes" -ReportType HTML -Path "C:\Rapports\GPO-Report.html"

# Rapport XML pour toutes les GPO
Get-GPOReport -All -ReportType XML -Path "C:\Rapports\All-GPOs.xml"

# Résultats de stratégie pour un utilisateur/ordinateur
Get-GPResultantSetOfPolicy -Computer "PC001" -User "ENTREPRISE\jdupont" -ReportType HTML -Path "C:\Rapports\RSoP.html"
```

> [!example] Cas d'usage : Audit de sécurité Exportez régulièrement vos GPO en XML pour garder une trace des modifications et faciliter les audits de conformité.

### Sauvegarde et restauration

**Sauvegarde d'une GPO :**

```powershell
# Sauvegarde d'une GPO spécifique
Backup-GPO -Name "GPO-Critique" -Path "C:\GPO-Backups"

# Sauvegarde de toutes les GPO
Backup-GPO -All -Path "C:\GPO-Backups"

# Sauvegarde avec commentaire
Backup-GPO -Name "GPO-Production" -Path "C:\GPO-Backups" -Comment "Backup avant mise à jour Q4"
```

**Restauration d'une GPO :**

```powershell
# Restauration d'une GPO par nom
Restore-GPO -Name "GPO-Critique" -Path "C:\GPO-Backups"

# Restauration avec ID de sauvegarde spécifique
Restore-GPO -BackupId "{12345678-1234-1234-1234-123456789012}" -Path "C:\GPO-Backups"

# Restauration de toutes les GPO
Restore-GPO -All -Path "C:\GPO-Backups"
```

> [!warning] Bonnes pratiques de sauvegarde
> 
> - Sauvegardez avant toute modification importante
> - Planifiez des sauvegardes automatiques hebdomadaires
> - Stockez les sauvegardes sur un emplacement distinct
> - Documentez chaque sauvegarde avec un commentaire explicite

---

## ⚖️ Configuration ordinateur vs Configuration utilisateur

### Concepts fondamentaux

Chaque GPO contient deux grandes sections indépendantes :

- **Configuration ordinateur** : S'applique aux machines, indépendamment de l'utilisateur connecté
- **Configuration utilisateur** : S'applique aux utilisateurs, quel que soit l'ordinateur utilisé

> [!info] Moment d'application
> 
> - **Configuration ordinateur** : Au démarrage de la machine
> - **Configuration utilisateur** : À l'ouverture de session utilisateur

### Configuration ordinateur

Cette section configure des paramètres qui persistent sur la machine :

**Cas d'usage typiques :**

- Configuration réseau et sécurité système
- Installation de logiciels à l'échelle de la machine
- Paramètres de pare-feu et antivirus
- Configuration du registre système
- Scripts de démarrage/arrêt
- Stratégies de sécurité locale

```powershell
# Exemple : Désactiver IPv6 sur tous les postes
Set-GPRegistryValue -Name "GPO-Config-Reseau" `
    -Key "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" `
    -ValueName "DisabledComponents" `
    -Type DWord `
    -Value 0xff

# Exemple : Configurer un proxy système
Set-GPRegistryValue -Name "GPO-Proxy-Entreprise" `
    -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings" `
    -ValueName "ProxyEnable" `
    -Type DWord `
    -Value 1
```

**Structure de la Configuration ordinateur :**

|Sous-section|Description|
|---|---|
|**Stratégies / Paramètres logiciels**|Déploiement MSI, installation de logiciels|
|**Stratégies / Paramètres Windows**|Scripts, sécurité, QoS, pare-feu|
|**Stratégies / Modèles d'administration**|Registre système, stratégies Windows|
|**Préférences**|Configuration fine et ciblée (lecteurs, services, tâches)|

> [!tip] Priorité d'application La Configuration ordinateur s'applique AVANT la Configuration utilisateur. En cas de conflit, l'ordinateur gagne si le paramètre existe des deux côtés.

### Configuration utilisateur

Cette section suit l'utilisateur d'une machine à l'autre :

**Cas d'usage typiques :**

- Configuration du Bureau et de l'interface
- Mappage de lecteurs réseau personnalisés
- Installation d'applications par utilisateur
- Configuration d'Outlook, Internet Explorer
- Scripts d'ouverture/fermeture de session
- Redirections de dossiers utilisateur

```powershell
# Exemple : Désactiver l'accès au Panneau de configuration
Set-GPRegistryValue -Name "GPO-Restrictions-Utilisateurs" `
    -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -ValueName "NoControlPanel" `
    -Type DWord `
    -Value 1

# Exemple : Définir une page d'accueil Internet Explorer
Set-GPRegistryValue -Name "GPO-Config-IE" `
    -Key "HKCU\Software\Microsoft\Internet Explorer\Main" `
    -ValueName "Start Page" `
    -Type String `
    -Value "https://intranet.entreprise.local"
```

**Structure de la Configuration utilisateur :**

|Sous-section|Description|
|---|---|
|**Stratégies / Paramètres logiciels**|Déploiement d'applications par utilisateur|
|**Stratégies / Paramètres Windows**|Scripts, redirection de dossiers, IE|
|**Stratégies / Modèles d'administration**|Configuration Bureau, Menu Démarrer, applications|
|**Préférences**|Configuration personnalisée (raccourcis, imprimantes)|

### Tableau comparatif

|Critère|Configuration ordinateur|Configuration utilisateur|
|---|---|---|
|**Moment**|Démarrage de la machine|Ouverture de session|
|**Cible**|La machine|L'utilisateur|
|**Ruche registre**|HKEY_LOCAL_MACHINE|HKEY_CURRENT_USER|
|**Persistance**|Sur la machine|Suit l'utilisateur|
|**Exemples**|Proxy, Pare-feu, Antivirus|Fond d'écran, Lecteurs réseau|
|**Priorité**|Plus élevée|Plus faible|
|**Nécessite redémarrage**|Parfois|Rarement|

### Traitement de bouclage

Le traitement de bouclage modifie le comportement standard :

> [!info] Qu'est-ce que le bouclage ? Le bouclage permet d'appliquer la Configuration utilisateur d'une GPO basée sur l'ordinateur plutôt que sur l'utilisateur. Utile pour des machines partagées (kiosques, salles de formation).

**Modes de bouclage :**

1. **Fusion** : Combine les GPO utilisateur + GPO ordinateur (ordinateur prioritaire)
2. **Remplacement** : Ignore complètement les GPO utilisateur, applique uniquement celles de l'ordinateur

```powershell
# Activer le bouclage en mode Fusion
Set-GPRegistryValue -Name "GPO-Kiosque" `
    -Key "HKLM\Software\Policies\Microsoft\Windows\System" `
    -ValueName "UserPolicyMode" `
    -Type DWord `
    -Value 1

# Activer le bouclage en mode Remplacement
Set-GPRegistryValue -Name "GPO-Kiosque" `
    -Key "HKLM\Software\Policies\Microsoft\Windows\System" `
    -ValueName "UserPolicyMode" `
    -Type DWord `
    -Value 2
```

> [!example] Cas d'usage : Salle de formation Sur les PC de formation, activez le bouclage en mode Remplacement pour garantir que tous les utilisateurs aient exactement la même configuration, indépendamment de leurs GPO personnelles.

### Désactivation de sections

Pour optimiser les performances, désactivez les sections inutilisées :

```powershell
# Désactiver la Configuration utilisateur
(Get-GPO -Name "GPO-Config-Serveurs").GpoStatus = "UserSettingsDisabled"

# Désactiver la Configuration ordinateur
(Get-GPO -Name "GPO-Profils-Utilisateurs").GpoStatus = "ComputerSettingsDisabled"

# Désactiver complètement une GPO
(Get-GPO -Name "GPO-Test").GpoStatus = "AllSettingsDisabled"
```

> [!tip] Optimisation Désactiver les sections non utilisées accélère l'application des GPO de 30 à 50% lors du démarrage et de l'ouverture de session.

### Pièges courants

> [!warning] Erreurs fréquentes
> 
> **1. Confusion de cible**
> 
> - ❌ Mettre un proxy dans Configuration utilisateur (ne marchera pas toujours)
> - ✅ Mettre un proxy dans Configuration ordinateur
> 
> **2. Ordre d'application**
> 
> - ❌ Compter sur Configuration utilisateur pour écraser Configuration ordinateur
> - ✅ Comprendre que l'ordinateur a priorité sur les paramètres communs
> 
> **3. Bouclage mal configuré**
> 
> - ❌ Activer le bouclage sans comprendre les implications
> - ✅ Tester en mode Fusion avant de passer en Remplacement

---

## 🔧 Paramètres de stratégie disponibles

### Vue d'ensemble des catégories

Les GPO offrent des milliers de paramètres organisés en grandes catégories :

```
GPO
├── Configuration ordinateur
│   ├── Stratégies
│   │   ├── Paramètres logiciels
│   │   ├── Paramètres Windows
│   │   └── Modèles d'administration
│   └── Préférences
│       ├── Paramètres Windows
│       └── Paramètres du Panneau de configuration
└── Configuration utilisateur
    ├── Stratégies
    │   ├── Paramètres logiciels
    │   ├── Paramètres Windows
    │   └── Modèles d'administration
    └── Préférences
        ├── Paramètres Windows
        └── Paramètres du Panneau de configuration
```

### 1. Paramètres logiciels

**Installation de logiciels** : Déploiement d'applications MSI automatiquement.

|Type|Description|Usage|
|---|---|---|
|**Publié**|L'utilisateur peut installer à la demande|Applications optionnelles|
|**Affecté**|Installation automatique obligatoire|Applications critiques|

```powershell
# Aucune cmdlet native pour déploiement MSI via GPO
# Doit être configuré manuellement via GPMC :
# Stratégies → Paramètres logiciels → Installation de logiciel → Nouveau → Package
```

> [!tip] Format MSI requis Seuls les packages .MSI peuvent être déployés via GPO. Les .EXE nécessitent un re-packaging ou l'utilisation de scripts.

### 2. Paramètres Windows

#### Scripts

Exécution de scripts PowerShell, VBScript ou Batch à différents moments :

**Configuration ordinateur :**

- Scripts de démarrage (au boot)
- Scripts d'arrêt (au shutdown)

**Configuration utilisateur :**

- Scripts d'ouverture de session
- Scripts de fermeture de session

```powershell
# Les scripts doivent être placés dans le dossier de la GPO
# Chemin : \\domaine\SYSVOL\domaine\Policies\{GUID-GPO}\Machine\Scripts\Startup

# Exemple de script de mappage de lecteur (à placer dans Scripts d'ouverture de session)
# MapLecteurs.ps1
New-PSDrive -Name "P" -PSProvider FileSystem -Root "\\serveur\partage" -Persist
New-PSDrive -Name "H" -PSProvider FileSystem -Root "\\serveur\home\$env:USERNAME" -Persist
```

> [!warning] Exécution différée Les scripts de démarrage/ouverture peuvent ralentir le boot. Utilisez le mode asynchrone si possible et limitez leur durée d'exécution.

#### Paramètres de sécurité

**Stratégies de compte :**

- Stratégie de mot de passe (complexité, durée, historique)
- Stratégie de verrouillage de compte
- Stratégie Kerberos

```powershell
# Configuration via GPMC ou commande secedit
# Exemple : Export des paramètres de sécurité
secedit /export /cfg C:\security-config.inf /areas USER_POLICY

# Import de paramètres de sécurité
secedit /configure /db C:\secedit.sdb /cfg C:\security-config.inf
```

**Stratégies locales :**

|Catégorie|Exemples de paramètres|
|---|---|
|**Stratégie d'audit**|Audit d'ouverture de session, accès objets, modifications de stratégie|
|**Attribution des droits**|Qui peut ouvrir une session localement, accéder depuis le réseau|
|**Options de sécurité**|Renommer le compte Administrateur, message d'accueil|

> [!example] Sécurité renforcée Activez l'audit des échecs d'ouverture de session pour détecter les tentatives d'intrusion.

#### Pare-feu Windows avec fonctions avancées de sécurité

Configuration centralisée du pare-feu Windows :

```powershell
# Configuration via GPO ou directement avec netsh/PowerShell
# Exemple : Bloquer le port 445 en entrée
New-NetFirewallRule -DisplayName "Bloquer SMB" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 445 `
    -Action Block

# Autoriser RDP depuis un sous-réseau spécifique
New-NetFirewallRule -DisplayName "RDP Admin" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 3389 `
    -Action Allow `
    -RemoteAddress "192.168.1.0/24"
```

**Profils de pare-feu :**

- **Domaine** : Quand l'ordinateur est connecté au domaine AD
- **Privé** : Réseau privé (maison)
- **Public** : Réseau non fiable (café, hôtel)

> [!tip] Stratégie par profil Configurez des règles différentes selon le profil. Exemple : RDP autorisé en Domaine, bloqué en Public.

#### Redirection de dossiers

Redirection automatique des dossiers utilisateur vers un serveur :

**Dossiers redirectables :**

- Bureau
- Documents
- Images
- Musique
- Vidéos
- Favoris
- AppData (Roaming)

```powershell
# Configuration via GPMC :
# Configuration utilisateur → Stratégies → Paramètres Windows → Redirection de dossiers

# Chemin typique : \\serveur\users$\%USERNAME%\Documents
```

> [!warning] Permissions NTFS requises L'utilisateur doit avoir Contrôle total sur son dossier de redirection. Configurez les permissions avec :
> 
> - Créateur Propriétaire : Contrôle total
> - Utilisateur : Contrôle total (ce dossier uniquement)
> - Administrateurs : Contrôle total

### 3. Modèles d'administration

Les modèles d'administration représentent la plus vaste catégorie de paramètres. Ils modifient le registre Windows.

#### Modèles d'administration - Ordinateur

**Système :**

|Paramètre|Emplacement|Usage|
|---|---|---|
|**Scripts d'arrêt visible**|Système / Scripts|Afficher progression des scripts|
|**Désactiver redémarrage automatique**|Système / Windows Update|Empêcher redémarrage forcé|
|**Exécution des scripts PowerShell**|Système / Scripts PowerShell|Définir politique d'exécution|

```powershell
# Exemple : Autoriser scripts PowerShell signés
Set-GPRegistryValue -Name "GPO-PowerShell" `
    -Key "HKLM\Software\Policies\Microsoft\Windows\PowerShell" `
    -ValueName "EnableScripts" `
    -Type DWord `
    -Value 1

Set-GPRegistryValue -Name "GPO-PowerShell" `
    -Key "HKLM\Software\Policies\Microsoft\Windows\PowerShell" `
    -ValueName "ExecutionPolicy" `
    -Type String `
    -Value "RemoteSigned"
```

**Réseau :**

- Configuration du client DNS
- Paramètres Wi-Fi
- Fournisseurs de localisation
- Client/Serveur SMB

**Composants Windows :**

|Composant|Paramètres typiques|
|---|---|
|**Windows Update**|Configuration WSUS, calendrier de mise à jour|
|**Bureau à distance**|Autorisation RDP, niveau d'authentification|
|**Windows Defender**|Exclusions, analyses planifiées|
|**Internet Explorer**|Proxy, zones de sécurité, page d'accueil|

```powershell
# Exemple : Configurer WSUS
Set-GPRegistryValue -Name "GPO-WSUS" `
    -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" `
    -ValueName "WUServer" `
    -Type String `
    -Value "http://wsus.entreprise.local:8530"

Set-GPRegistryValue -Name "GPO-WSUS" `
    -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" `
    -ValueName "UseWUServer" `
    -Type DWord `
    -Value 1
```

#### Modèles d'administration - Utilisateur

**Bureau :**

- Configuration du fond d'écran
- Désactivation des éléments du Bureau
- Masquage des icônes système

**Menu Démarrer et Barre des tâches :**

```powershell
# Exemple : Supprimer "Exécuter" du menu Démarrer
Set-GPRegistryValue -Name "GPO-Restrictions-UI" `
    -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -ValueName "NoRun" `
    -Type DWord `
    -Value 1

# Exemple : Masquer les paramètres dans le menu Démarrer
Set-GPRegistryValue -Name "GPO-Restrictions-UI" `
    -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -ValueName "NoSetFolders" `
    -Type DWord `
    -Value 1
```

**Composants Windows - Utilisateur :**

|Application|Paramètres configurables|
|---|---|
|**Explorateur de fichiers**|Masquer lecteurs, désactiver options|
|**Microsoft Edge**|Page d'accueil, extensions, synchronisation|
|**OneDrive**|Empêcher utilisation, limiter bande passante|
|**Outlook**|Configuration Exchange, archivage, cache|

> [!example] Personnalisation standardisée Forcez un fond d'écran d'entreprise et masquez les paramètres de personnalisation pour maintenir une identité visuelle cohérente.

### 4. Préférences

Les **Préférences** diffèrent des **Stratégies** :

|Caractéristique|Stratégies|Préférences|
|---|---|---|
|**Modification utilisateur**|❌ Interdite|✅ Autorisée|
|**Persistance**|Tant que GPO appliquée|Même après retrait GPO|
|**Action**|Impose|Suggère|
|**Suppression**|Automatique|Nécessite configuration|

#### Préférences Windows

**Lecteurs mappés :**

Configuration GUI via GPMC :

- Créer / Remplacer / Mettre à jour / Supprimer
- Lettre de lecteur
- Chemin UNC
- Reconnexion à l'ouverture de session
- Étiquette

```powershell
# Les préférences GPO ne sont pas facilement scriptables
# Alternative : Script dans GPO
net use P: \\serveur\partage /persistent:yes
```

**Raccourcis :**

- Création de raccourcis Bureau, Menu Démarrer
- Personnalisation des icônes et emplacements

**Imprimantes :**

- Connexion automatique à des imprimantes réseau
- Définition d'imprimante par défaut

**Variables d'environnement :**

```powershell
# Exemple : Définir une variable TEMP custom
Set-GPRegistryValue -Name "GPO-Config-Env" `
    -Key "HKCU\Environment" `
    -ValueName "TEMP_PROJECT" `
    -Type String `
    -Value "\\serveur\temp\%USERNAME%"
```

#### Préférences Panneau de configuration

**Services :**

- Démarrage / Arrêt de services
- Configuration du type de démarrage

**Tâches planifiées :**

- Création de tâches planifiées
- Définition des déclencheurs et actions

**Options d'alimentation :**

- Configuration des plans d'alimentation
- Définition des délais de veille

> [!tip] Ciblage au niveau élément Les Préférences permettent un ciblage fin avec des conditions (appartenance groupe, système d'exploitation, type de connexion réseau, etc.). Plus flexible que les filtres de sécurité GPO.

### Paramètres avancés

#### Fichiers ADMX et ADML

Les modèles d'administration modernes utilisent le format XML :

- **ADMX** : Définition des paramètres (neutre)
- **ADML** : Traductions et descriptions (langue spécifique)

**Emplacement central (recommandé) :**

```
\\domaine\SYSVOL\domaine\Policies\PolicyDefinitions\
    ├── ADMX files (fichiers .admx)
    └── fr-FR\ (ou en-US\, etc.)
        └── ADML files (fichiers .adml)
```

> [!info] Avantage du magasin central Un magasin central ADMX garantit que tous les administrateurs voient les mêmes paramètres, évitant les incohérences dues à différentes versions de Windows.

#### Paramètres personnalisés via registre

Pour configurer des paramètres non disponibles dans les modèles :

```powershell
# Créer un paramètre personnalisé
Set-GPRegistryValue -Name "GPO-Custom" `
    -Key "HKLM\Software\Entreprise\Config" `
    -ValueName "ParametreMetier" `
    -Type String `
    -Value "ValeurPersonnalisee"

# Supprimer un paramètre personnalisé
Remove-GPRegistryValue -Name "GPO-Custom" `
    -Key "HKLM\Software\Entreprise\Config" `
    -ValueName "ParametreMetier"
```

> [!warning] Documentation essentielle Les paramètres personnalisés via registre doivent être méticuleusement documentés, car ils n'apparaissent pas dans les rapports GPO standards.

### Pièges courants et bonnes pratiques

> [!warning] Erreurs fréquentes
> 
> **1. Surcharge de paramètres**
> 
> - ❌ 200 paramètres dans une seule GPO
> - ✅ GPO thématiques avec 20-50 paramètres max
> 
> **2. Configuration contradictoire**
> 
> - ❌ Paramètres opposés dans Configuration ordinateur et utilisateur
> - ✅ Vérifier la cohérence et documenter les priorités
> 
> **3. Préférences sans ciblage**
> 
> - ❌ Appliquer à tous sans distinction
> - ✅ Utiliser le ciblage au niveau élément pour affiner

> [!tip] Bonnes pratiques
> 
> **Organisation :**
> 
> - Nommez vos GPO de manière descriptive et cohérente
> - Créez des GPO par fonction (sécurité, config réseau, applications)
> - Désactivez les sections inutilisées
> 
> **Test :**
> 
> - Testez toujours sur une OU de test avant production
> - Utilisez `gpresult /h rapport.html` pour valider l'application
> - Surveillez les journaux d'événements
> 
> **Documentation :**
> 
> - Commentez chaque GPO avec son objectif
> - Exportez régulièrement les rapports HTML
> - Maintenez un registre des modifications avec dates et raisons

**Performance :**

> - Évitez trop de GPO sur une même OU (max 10-15)
> - Utilisez les filtres WMI avec parcimonie (impact performance)
> - Privilégiez les filtres de sécurité aux filtres WMI quand possible

**Sécurité :**

> - Limitez qui peut modifier les GPO (Admins du domaine uniquement)
> - Activez l'audit des modifications de GPO
> - Ne stockez jamais de mots de passe en clair dans les scripts GPO

---

## 🎯 Synthèse et points clés

### Récapitulatif GPMC

La **Group Policy Management Console** est l'outil central pour :

- ✅ Créer et organiser les GPO
- ✅ Lier les GPO aux conteneurs AD
- ✅ Analyser l'application et les conflits
- ✅ Sauvegarder et restaurer les configurations
- ✅ Générer des rapports détaillés

**Commandes PowerShell essentielles :**

```powershell
# Création
New-GPO -Name "Nom-GPO"

# Liaison
New-GPLink -Name "Nom-GPO" -Target "OU=Cible,DC=domaine,DC=local"

# Sauvegarde
Backup-GPO -All -Path "C:\Backups"

# Rapport
Get-GPOReport -Name "Nom-GPO" -ReportType HTML -Path "rapport.html"

# Restauration
Restore-GPO -Name "Nom-GPO" -Path "C:\Backups"
```

### Récapitulatif Configuration ordinateur vs utilisateur

|Aspect|Configuration ordinateur|Configuration utilisateur|
|---|---|---|
|**Quand**|Démarrage machine|Ouverture session|
|**Cible**|Machine (tous utilisateurs)|Utilisateur spécifique|
|**Registre**|HKLM|HKCU|
|**Exemples**|Proxy, Pare-feu, WSUS|Bureau, Lecteurs mappés|
|**Mobilité**|Fixe sur la machine|Suit l'utilisateur|

**Règle d'or :**

- Configuration **système/sécurité** → Configuration ordinateur
- Configuration **interface/personnalisation** → Configuration utilisateur

### Récapitulatif Paramètres disponibles

**Hiérarchie des paramètres :**

```
Stratégies (imposées, non modifiables par l'utilisateur)
├── Paramètres logiciels → Déploiement MSI
├── Paramètres Windows → Scripts, Sécurité, Pare-feu
└── Modèles d'administration → Registre, Applications

Préférences (suggérées, modifiables par l'utilisateur)
├── Paramètres Windows → Lecteurs, Variables, Raccourcis
└── Paramètres Panneau de configuration → Services, Tâches, Alimentation
```

**Paramètres les plus utilisés :**

1. **Sécurité** : Stratégies de mot de passe, verrouillage de compte, pare-feu
2. **Réseau** : Proxy, DNS, lecteurs mappés
3. **Applications** : WSUS, Internet Explorer/Edge, Outlook
4. **Interface** : Fond d'écran, restrictions Menu Démarrer
5. **Scripts** : Automatisation au démarrage/ouverture de session

### Commandes de vérification essentielles

```powershell
# Vérifier l'application des GPO sur une machine
gpresult /r

# Rapport détaillé HTML
gpresult /h C:\rapport-gpo.html /f

# Forcer l'application immédiate
gpupdate /force

# Lister toutes les GPO du domaine
Get-GPO -All | Select-Object DisplayName, GpoStatus

# Voir les liens d'une GPO
Get-GPO -Name "Nom-GPO" | Get-GPLink

# Tester l'application pour un utilisateur/ordinateur
Get-GPResultantSetOfPolicy -Computer "PC001" -User "DOMAINE\user"
```

### Dépannage rapide

|Problème|Cause probable|Solution|
|---|---|---|
|GPO ne s'applique pas|Lien désactivé ou ordre incorrect|Vérifier statut du lien avec `Get-GPLink`|
|Paramètre ne fonctionne pas|Section désactivée|Vérifier GpoStatus de la GPO|
|Application lente|Trop de GPO ou filtres WMI|Réduire nombre de GPO, éviter WMI|
|Conflit entre GPO|Héritage non contrôlé|Utiliser `gpresult` pour voir l'ordre|
|Script ne s'exécute pas|Chemin incorrect ou permissions|Vérifier logs dans Observateur d'événements|

> [!tip] Outil de diagnostic Utilisez toujours `gpresult /h rapport.html` comme premier réflexe de diagnostic. Ce rapport montre exactement quelles GPO sont appliquées, dans quel ordre, et quels paramètres sont configurés.

---

## 📊 Tableau de référence rapide

### Cmdlets PowerShell GPO essentielles

|Cmdlet|Usage|Exemple|
|---|---|---|
|`New-GPO`|Créer une GPO|`New-GPO -Name "GPO-Test"`|
|`Get-GPO`|Obtenir infos GPO|`Get-GPO -Name "GPO-Test"`|
|`Set-GPO`|Modifier propriétés|`Set-GPO -Name "GPO-Test" -Comment "MAJ"`|
|`Remove-GPO`|Supprimer GPO|`Remove-GPO -Name "GPO-Test"`|
|`Copy-GPO`|Dupliquer GPO|`Copy-GPO -SourceName "A" -TargetName "B"`|
|`New-GPLink`|Lier GPO à OU|`New-GPLink -Name "GPO" -Target "OU=..."`|
|`Set-GPLink`|Modifier lien|`Set-GPLink -Name "GPO" -Target "OU=..." -Order 1`|
|`Remove-GPLink`|Supprimer lien|`Remove-GPLink -Name "GPO" -Target "OU=..."`|
|`Backup-GPO`|Sauvegarder|`Backup-GPO -Name "GPO" -Path "C:\Backup"`|
|`Restore-GPO`|Restaurer|`Restore-GPO -Name "GPO" -Path "C:\Backup"`|
|`Get-GPOReport`|Générer rapport|`Get-GPOReport -Name "GPO" -ReportType HTML`|
|`Set-GPRegistryValue`|Configurer registre|`Set-GPRegistryValue -Name "GPO" -Key "..."`|
|`Import-GPO`|Importer GPO|`Import-GPO -BackupId "{GUID}" -Path "..."`|

### Emplacements clés dans l'éditeur GPO

|Paramètre recherché|Chemin|
|---|---|
|**Scripts de démarrage**|Config Ordinateur → Stratégies → Param. Windows → Scripts → Démarrage|
|**Stratégie de mot de passe**|Config Ordinateur → Stratégies → Param. Windows → Param. sécurité → Stratégies de compte|
|**Pare-feu Windows**|Config Ordinateur → Stratégies → Param. Windows → Param. sécurité → Pare-feu...|
|**WSUS**|Config Ordinateur → Stratégies → Modèles admin → Composants Windows → Windows Update|
|**PowerShell ExecutionPolicy**|Config Ordinateur → Stratégies → Modèles admin → Composants Windows → Windows PowerShell|
|**Proxy Internet Explorer**|Config Utilisateur → Stratégies → Param. Windows → Maintenance IE → Connexion|
|**Redirection dossiers**|Config Utilisateur → Stratégies → Param. Windows → Redirection de dossiers|
|**Fond d'écran**|Config Utilisateur → Stratégies → Modèles admin → Bureau → Bureau (Active Desktop)|
|**Lecteurs mappés**|Config Utilisateur → Préférences → Param. Windows → Mappages de lecteurs|
|**Restrictions Menu Démarrer**|Config Utilisateur → Stratégies → Modèles admin → Menu Démarrer et barre des tâches|

### Valeurs de registre communes

|Paramètre|Clé|Valeur|Type|Données|
|---|---|---|---|---|
|Désactiver UAC|HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System|EnableLUA|DWORD|0|
|Désactiver IPv6|HKLM\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters|DisabledComponents|DWORD|0xFF|
|Proxy activé|HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings|ProxyEnable|DWORD|1|
|Proxy serveur|HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings|ProxyServer|STRING|proxy:8080|
|Masquer lecteur C:|HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer|NoDrives|DWORD|4|
|Désactiver Panneau config|HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer|NoControlPanel|DWORD|1|
|Désactiver Cmd.exe|HKCU\Software\Policies\Microsoft\Windows\System|DisableCMD|DWORD|1|
|Exécution PowerShell|HKLM\Software\Policies\Microsoft\Windows\PowerShell|EnableScripts|DWORD|1|

> [!info] Convention DWORD
> 
> - **0** = Désactivé/Non/Faux
> - **1** = Activé/Oui/Vrai
> - **2+** = Valeur spécifique selon le paramètre

---

## 🔍 Cas d'usage pratiques

### Exemple 1 : GPO de sécurité pour postes de travail

**Objectif :** Renforcer la sécurité des postes utilisateurs.

**Configuration ordinateur :**

```powershell
# 1. Créer la GPO
New-GPO -Name "GPO-SEC-Postes-Standard" -Comment "Sécurité de base pour tous les postes"

# 2. Configurer pare-feu (bloquer WinRM sauf depuis admin)
# Via GPMC : Config Ordinateur → Stratégies → Param. Windows → Param. sécurité → Pare-feu

# 3. Forcer Windows Update via WSUS
Set-GPRegistryValue -Name "GPO-SEC-Postes-Standard" `
    -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" `
    -ValueName "NoAutoUpdate" `
    -Type DWord `
    -Value 0

# 4. Désactiver autorun des médias amovibles
Set-GPRegistryValue -Name "GPO-SEC-Postes-Standard" `
    -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -ValueName "NoDriveTypeAutoRun" `
    -Type DWord `
    -Value 255

# 5. Lier à l'OU Postes
New-GPLink -Name "GPO-SEC-Postes-Standard" -Target "OU=Postes,OU=Ordinateurs,DC=entreprise,DC=local"
```

**Configuration utilisateur :**

```powershell
# Désactiver l'invite de commandes
Set-GPRegistryValue -Name "GPO-SEC-Postes-Standard" `
    -Key "HKCU\Software\Policies\Microsoft\Windows\System" `
    -ValueName "DisableCMD" `
    -Type DWord `
    -Value 2
```

### Exemple 2 : GPO de configuration pour Direction

**Objectif :** Configuration VIP avec lecteurs spécifiques et fond d'écran entreprise.

**Configuration utilisateur :**

```powershell
# 1. Créer la GPO
New-GPO -Name "GPO-CONFIG-Direction" -Comment "Configuration spécifique Direction"

# 2. Lecteurs mappés (via Préférences dans GPMC)
# P: → \\serveur\projets-direction
# R: → \\serveur\rapports-confidentiels

# 3. Fond d'écran forcé
Set-GPRegistryValue -Name "GPO-CONFIG-Direction" `
    -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" `
    -ValueName "Wallpaper" `
    -Type String `
    -Value "\\serveur\images\wallpaper-direction.jpg"

Set-GPRegistryValue -Name "GPO-CONFIG-Direction" `
    -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" `
    -ValueName "WallpaperStyle" `
    -Type String `
    -Value "2"

# 4. Lier avec ordre prioritaire
New-GPLink -Name "GPO-CONFIG-Direction" -Target "OU=Direction,OU=Utilisateurs,DC=entreprise,DC=local" -Order 1
```

### Exemple 3 : GPO de déploiement logiciel

**Objectif :** Installer automatiquement 7-Zip sur tous les nouveaux postes.

**Configuration ordinateur :**

```powershell
# 1. Créer la GPO
New-GPO -Name "GPO-SOFT-7Zip" -Comment "Installation automatique de 7-Zip"

# 2. Préparer le package MSI
# Copier 7z.msi vers \\domaine\NETLOGON\Software\7-Zip\7z.msi

# 3. Configuration via GPMC
# Config Ordinateur → Stratégies → Paramètres logiciels → Installation de logiciel
# → Nouveau → Package → Sélectionner \\domaine\NETLOGON\Software\7-Zip\7z.msi
# → Méthode de déploiement : Affecté

# 4. Lier à l'OU
New-GPLink -Name "GPO-SOFT-7Zip" -Target "OU=Postes,OU=Ordinateurs,DC=entreprise,DC=local"
```

> [!warning] Remarque importante Le déploiement de logiciels nécessite des packages MSI. Les fichiers .exe doivent être convertis ou installés via scripts.

### Exemple 4 : GPO pour salle de formation (bouclage)

**Objectif :** Configuration standardisée indépendante de l'utilisateur connecté.

```powershell
# 1. Créer la GPO
New-GPO -Name "GPO-Kiosque-Formation" -Comment "Config figée pour salles de formation"

# 2. Activer le bouclage en mode Remplacement
Set-GPRegistryValue -Name "GPO-Kiosque-Formation" `
    -Key "HKLM\Software\Policies\Microsoft\Windows\System" `
    -ValueName "UserPolicyMode" `
    -Type DWord `
    -Value 2

# 3. Configuration utilisateur (appliquée à tous via bouclage)
Set-GPRegistryValue -Name "GPO-Kiosque-Formation" `
    -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -ValueName "NoControlPanel" `
    -Type DWord `
    -Value 1

Set-GPRegistryValue -Name "GPO-Kiosque-Formation" `
    -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -ValueName "NoRun" `
    -Type DWord `
    -Value 1

# 4. Lier à l'OU des PC de formation
New-GPLink -Name "GPO-Kiosque-Formation" -Target "OU=Salles-Formation,OU=Ordinateurs,DC=entreprise,DC=local"
```

---

## ⚡ Astuces avancées

### 1. Filtres de sécurité

Appliquer une GPO uniquement à certains utilisateurs/groupes :

```powershell
# Retirer "Utilisateurs authentifiés" (appliqué par défaut)
Set-GPPermission -Name "GPO-Direction" -TargetName "Utilisateurs authentifiés" -TargetType Group -PermissionLevel None

# Ajouter le groupe Direction avec droit de lecture/application
Set-GPPermission -Name "GPO-Direction" -TargetName "GRP-Direction" -TargetType Group -PermissionLevel GpoApply
```

> [!tip] Filtres de sécurité vs Ciblage
> 
> - **Filtres de sécurité** : Au niveau de la GPO entière (performance optimale)
> - **Ciblage (Préférences)** : Au niveau de chaque élément (plus flexible mais plus lent)

### 2. Délégation de gestion

Permettre à un groupe de modifier certaines GPO sans être Admin du domaine :

```powershell
# Donner les droits de modification sur une GPO
Set-GPPermission -Name "GPO-Service-RH" -TargetName "GRP-Admins-RH" -TargetType Group -PermissionLevel GpoEdit

# Donner les droits de liaison sur une OU
Set-GPPermission -Name "GPO-Service-RH" -TargetName "GRP-Admins-RH" -TargetType Group -PermissionLevel GpoEditDeleteModifySecurity
```

### 3. Modélisation de stratégie

Tester l'impact d'une GPO avant de l'appliquer :

```powershell
# Simuler l'application pour un utilisateur sur un ordinateur
Invoke-GPUpdate -Computer "PC001" -Target "User" -RandomDelayInMinutes 0 -LogOff -WhatIf
```

Via GPMC : Clic droit sur domaine/OU → "Modélisation de stratégie de groupe"

### 4. Optimisation des performances

```powershell
# Désactiver sections inutilisées
$gpo = Get-GPO -Name "GPO-Optimisee"
$gpo.GpoStatus = "UserSettingsDisabled"  # Si aucun paramètre utilisateur

# Vérifier les GPO vides ou mal configurées
Get-GPO -All | ForEach-Object {
    $report = [xml](Get-GPOReport -Guid $_.Id -ReportType Xml)
    if (-not $report.GPO.Computer.ExtensionData -and -not $report.GPO.User.ExtensionData) {
        Write-Host "$($_.DisplayName) est vide !" -ForegroundColor Yellow
    }
}
```

### 5. Migration de GPO entre domaines

```powershell
# Export depuis domaine source
Backup-GPO -Name "GPO-A-Migrer" -Path "C:\Migration-GPO"

# Import vers domaine cible (avec table de migration pour adapter les SID/noms)
Import-GPO -BackupGpoName "GPO-A-Migrer" -Path "C:\Migration-GPO" -TargetName "GPO-Migree" -CreateIfNeeded -MigrationTable "C:\Migration-GPO\MigTable.migtable"
```

---

## 🎓 Conclusion

La maîtrise de la **création et configuration des GPO** dans Active Directory repose sur trois piliers :

1. **La GPMC** : Votre outil de contrôle centralisé pour créer, lier, analyser et sauvegarder les GPO
2. **La distinction Configuration ordinateur/utilisateur** : Comprendre quand et comment appliquer les paramètres selon la cible
3. **Les paramètres disponibles** : Exploiter la richesse des Stratégies et Préférences pour automatiser et standardiser votre infrastructure

> [!tip] Pour aller plus loin Maintenant que vous maîtrisez la création et la configuration des GPO, les prochaines étapes logiques dans votre apprentissage seront :
> 
> - La liaison et l'application des GPO (héritage, ordre, blocage)
> - Le dépannage et l'analyse des stratégies de groupe
> - Les scénarios avancés (WMI, ciblage, délégation)

**Points essentiels à retenir :**

- ✅ Toujours tester sur une OU de test avant la production
- ✅ Documenter chaque GPO avec des commentaires clairs
- ✅ Sauvegarder régulièrement vos GPO
- ✅ Utiliser `gpresult` pour diagnostiquer les problèmes
- ✅ Privilégier la simplicité : mieux vaut plusieurs GPO ciblées qu'une GPO complexe
- ✅ Désactiver les sections inutilisées pour optimiser les performances