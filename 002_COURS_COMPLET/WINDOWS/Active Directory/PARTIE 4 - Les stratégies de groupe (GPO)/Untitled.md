# 📋 Active Directory - Déploiement de Configurations par GPO

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

## 🎯 Introduction

Le déploiement de configurations via GPO permet d'automatiser et de standardiser l'environnement de travail des utilisateurs. Cette partie couvre les déploiements les plus courants dans un environnement Active Directory.

> [!info] Rappel Les GPO peuvent être liées aux sites, domaines et OUs. L'héritage et la priorité s'appliquent selon les règles de traitement des GPO.

---

## 🗂️ Mappage de lecteurs réseau

### Principe et objectifs

Le mappage de lecteurs réseau via GPO permet de connecter automatiquement des partages réseau en tant que lecteurs lettrés (E:, F:, etc.) sur les postes utilisateurs. C'est une des configurations les plus déployées en entreprise.

**Pourquoi utiliser cette méthode ?**

- Centralisation de la configuration
- Aucun script manuel à maintenir
- Mapping dynamique selon l'appartenance aux groupes
- Suppression automatique des mappings obsolètes

### Configuration via Drive Maps

Le mappage se configure dans les **Préférences de stratégie de groupe** (Group Policy Preferences - GPP), introduites avec Windows Server 2008.

**Chemin de configuration :**

```
Configuration utilisateur
└── Préférences
    └── Paramètres Windows
        └── Mappage de lecteurs
```

> [!example] Création d'un mappage de lecteur

**Étapes de configuration :**

1. **Clic droit** → **Nouveau** → **Lecteur mappé**
    
2. **Paramètres généraux :**
    
    - **Action** : Créer / Remplacer / Mettre à jour / Supprimer
    - **Emplacement** : `\\serveur\partage` (chemin UNC)
    - **Reconnecter** : ☑ (recommandé)
    - **Lettre** : Choisir la lettre du lecteur (ex: P:)
    - **Étiquette** : Nom affiché dans l'explorateur (ex: "Documents Partagés")
3. **Options avancées :**
    
    - **Afficher ce lecteur** : Rendre visible ou masqué
    - **Afficher tous les lecteurs** : Montrer tous les lecteurs réseau

**Exemple de configuration type :**

|Paramètre|Valeur|Description|
|---|---|---|
|Action|Mettre à jour|Crée si absent, modifie si existant|
|Emplacement|`\\SRV-FILES\Commun`|Partage réseau commun|
|Lettre|P:|Lecteur P: pour "Public"|
|Reconnecter|✓|Reconnecte à chaque ouverture de session|
|Étiquette|Documents Partagés|Nom convivial|

### Options avancées

#### Ciblage par groupe (Item-Level Targeting)

Permet de mapper des lecteurs uniquement pour certains utilisateurs ou groupes.

**Configuration du ciblage :**

1. Onglet **Commun** de l'élément de mappage
2. Cocher **Ciblage au niveau de l'élément**
3. Cliquer sur **Ciblage...**
4. Ajouter des conditions :
    - **Groupe de sécurité** : `DOMAIN\GRP_Comptabilite`
    - **OU** : Utilisateurs dans une OU spécifique
    - **Variable d'environnement** : Selon le profil
    - **Requête LDAP** : Filtrage avancé

> [!example] Exemple de ciblage
> 
> ```
> Groupe de sécurité : DOMAIN\GRP_RH
> ET
> Ordinateur du site : Site-Paris
> ```
> 
> Ce mapping ne s'applique qu'aux membres du groupe RH sur le site de Paris.

#### Variables d'environnement

Les variables permettent de personnaliser les chemins par utilisateur :

|Variable|Valeur exemple|Usage|
|---|---|---|
|`%UserName%`|`jdupont`|Dossier personnel utilisateur|
|`%LogonServer%`|`\\DC01`|Serveur de connexion|
|`%HomeDrive%`|`H:`|Lecteur personnel|
|`%DomainName%`|`CONTOSO`|Nom du domaine|

**Exemple de chemin dynamique :**

```
\\SRV-FILES\Users$\%UserName%
```

#### Actions disponibles

|Action|Comportement|Usage recommandé|
|---|---|---|
|**Créer**|Crée uniquement si absent|Mapping initial|
|**Remplacer**|Supprime et recrée|Changement de serveur|
|**Mettre à jour**|Crée ou modifie|**Usage standard** ⭐|
|**Supprimer**|Retire le mapping|Décommissionnement|

> [!tip] Recommandation Utilisez **"Mettre à jour"** par défaut, c'est l'action la plus flexible et la moins problématique.

### Bonnes pratiques

> [!warning] Pièges courants
> 
> - **Lettre de lecteur déjà utilisée** : Peut causer des conflits. Standardisez les lettres dans toute l'organisation.
> - **Permissions NTFS insuffisantes** : Vérifiez que l'utilisateur a les droits sur le partage.
> - **Chemins UNC vs DFS** : Privilégiez DFS pour la résilience : `\\contoso.com\partages\commun`
> - **Mappage au démarrage vs ouverture de session** : Les mappages GPP sont appliqués à l'ouverture de session utilisateur.

**📌 Checklist des bonnes pratiques :**

✅ **Normaliser les lettres de lecteur** (ex: P: pour Public, D: pour Département, H: pour Home) ✅ **Utiliser DFS** plutôt que des noms de serveurs directs ✅ **Activer "Reconnecter"** pour la persistance ✅ **Documenter les mappages** dans la description de la GPO ✅ **Tester le ciblage** avant déploiement en production ✅ **Utiliser "Mettre à jour"** comme action par défaut ✅ **Nettoyer les mappages obsolètes** avec l'action "Supprimer"

> [!tip] Astuce de dépannage Pour forcer l'actualisation des mappages : `gpupdate /force` puis fermer/rouvrir la session ou redémarrer l'explorateur Windows.

**Vérification des mappages appliqués :**

```powershell
# Voir les mappages actifs
net use

# Voir les GPO appliquées (section Préférences)
gpresult /h rapport.html
```

---

## 🖥️ Configuration du bureau et de l'environnement

La configuration du bureau via GPO permet de standardiser l'apparence et le comportement de l'environnement utilisateur. Ces paramètres améliorent l'expérience utilisateur et renforcent l'identité visuelle de l'entreprise.

### Papier peint et arrière-plan

**Chemin de configuration :**

```
Configuration utilisateur
└── Stratégies
    └── Modèles d'administration
        └── Bureau
            └── Bureau
```

#### Configuration du papier peint

**Paramètre principal :** `Papier peint du Bureau`

|Option|Valeur|Description|
|---|---|---|
|État|Activé|Force l'application|
|Nom du papier peint|`\\srv\netlogon\wallpaper.jpg`|Chemin UNC ou local|
|Style du papier peint|Remplir / Ajuster / Étirer / Mosaïque / Centrer|Mode d'affichage|

> [!example] Configuration recommandée
> 
> ```
> Nom : \\contoso.com\SYSVOL\contoso.com\Policies\Wallpapers\corporate_1920x1080.jpg
> Style : Remplir
> ```

**Paramètres complémentaires :**

- **Empêcher la modification du papier peint** : Bloque les changements utilisateur
- **Couleur d'arrière-plan du Bureau** : Définir une couleur unie (format RGB)
- **Écran de verrouillage** (Windows 10/11) : Personnaliser l'écran de connexion

> [!tip] Formats et résolutions
> 
> - **Format recommandé** : JPG (taille réduite) ou PNG (qualité)
> - **Résolutions courantes** : 1920x1080 (Full HD), 2560x1440 (2K), 3840x2160 (4K)
> - **Poids maximal recommandé** : < 2 Mo pour un chargement rapide
> - **Stockage** : SYSVOL ou partage réseau avec droits de lecture pour tous

### Menu Démarrer et barre des tâches

#### Configuration du Menu Démarrer

**Windows 10/11 - Chemin :**

```
Configuration utilisateur
└── Stratégies
    └── Modèles d'administration
        └── Menu Démarrer et barre des tâches
```

**Paramètres clés :**

|Paramètre|Usage|Valeur|
|---|---|---|
|Supprimer et empêcher l'accès à la commande Arrêter|Empêcher l'arrêt|Activé/Désactivé|
|Supprimer le lien Exécuter du menu Démarrer|Masquer "Exécuter"|Activé|
|Supprimer la liste des programmes récents|Confidentialité|Activé|
|Épingler des applications au Menu Démarrer|Standardisation|Activé + XML|
|Désactiver et supprimer le lien Documents|Simplification|Activé|

#### Épinglage d'applications

Pour épingler des applications de manière standardisée (Windows 10/11), il faut exporter une configuration de référence.

**Méthode d'épinglage :**

1. **Configurer un poste de référence** avec les applications épinglées souhaitées
2. **Exporter la configuration :**

```powershell
Export-StartLayout -Path "C:\StartLayout.xml"
```

3. **Copier le XML** dans SYSVOL : `\\domain\SYSVOL\domain\Policies\StartLayout.xml`
4. **Configurer la GPO :**

```
Menu Démarrer et barre des tâches
└── Fichier de présentation de l'écran d'accueil
    État : Activé
    Fichier : \\contoso.com\SYSVOL\contoso.com\Policies\StartLayout.xml
```

> [!warning] Limitation L'épinglage forcé via GPO empêche les utilisateurs de personnaliser leur Menu Démarrer. Considérez si c'est nécessaire pour votre environnement.

#### Configuration de la barre des tâches

**Paramètres courants :**

|Paramètre|Description|Recommandation|
|---|---|---|
|Supprimer la zone de recherche de la barre des tâches|Masque la recherche Windows|Selon besoin|
|Masquer la zone de notification|Cache les icônes système|Non recommandé|
|Verrouiller la barre des tâches|Empêche le déplacement|Activé en entreprise|
|Ne pas conserver l'historique des documents récemment ouverts|Confidentialité|Selon politique|

### Explorateur de fichiers

**Chemin de configuration :**

```
Configuration utilisateur
└── Stratégies
    └── Modèles d'administration
        └── Composants Windows
            └── Explorateur de fichiers
```

#### Paramètres de l'Explorateur

**Configurations recommandées :**

|Paramètre|Objectif|Valeur suggérée|
|---|---|---|
|Masquer ces lecteurs spécifiés|Cacher des partitions système|Activé (ex: C:)|
|Empêcher l'accès aux lecteurs|Blocage complet|Selon sécurité|
|Afficher les extensions de fichiers|Sécurité (détection malware)|Activé ✅|
|Masquer les fichiers protégés du système d'exploitation|Protection système|Activé|
|Supprimer l'onglet Sécurité|Limiter la visibilité NTFS|Désactivé (transparence)|

> [!example] Configuration type pour utilisateurs standard
> 
> ```
> ✓ Afficher les extensions de fichiers : Activé
> ✓ Masquer les fichiers protégés : Activé
> ✓ Ne pas afficher les éléments masqués : Activé
> ✓ Ouvrir l'Explorateur sur : Ce PC (au lieu de Accès rapide)
> ```

#### Masquage de lecteurs

Le masquage de lecteurs utilise une valeur bitmask :

|Lecteur|Valeur|Lecteur|Valeur|
|---|---|---|---|
|A:|1|N:|8192|
|B:|2|O:|16384|
|C:|4|P:|32768|
|D:|8|Q:|65536|
|...|...|...|...|

**Pour masquer C: et D: :** `4 + 8 = 12`

> [!tip] Astuce Utilisez un calculateur en ligne de bitmask GPO pour faciliter le calcul des combinaisons.

### Options d'alimentation

**Chemin de configuration :**

```
Configuration ordinateur
└── Stratégies
    └── Modèles d'administration
        └── Système
            └── Gestion de l'alimentation
```

#### Paramètres d'économie d'énergie

**Configurations par profil (Secteur / Batterie) :**

|Paramètre|Usage|Valeur recommandée|
|---|---|---|
|Délai d'extinction de l'écran|Économie d'énergie|10 min (secteur) / 5 min (batterie)|
|Délai de mise en veille|Protection + économie|30 min (secteur) / 15 min (batterie)|
|Exiger un mot de passe lors de la sortie de veille|Sécurité|✅ Activé|
|Autoriser les états de veille en veille|Mode veille moderne|Activé pour portables|

> [!example] Profil entreprise type - Postes fixes
> 
> ```
> Extinction écran (secteur) : 15 minutes
> Mise en veille (secteur) : 1 heure
> Mise en veille prolongée : Désactivée
> Mot de passe au réveil : Obligatoire
> ```

> [!example] Profil entreprise type - Portables
> 
> ```
> Extinction écran (batterie) : 5 minutes
> Mise en veille (batterie) : 15 minutes
> Fermeture du capot : Mise en veille
> Batterie faible : Mise en veille prolongée à 10%
> ```

#### Paramètres avancés

**Options de veille :**

- **Autoriser la mise en veille hybride** : Combine veille et hibernation (postes fixes)
- **Autoriser les états de veille en veille** : Veille connectée (S0 Low Power Idle)
- **Spécifier l'action du bouton d'alimentation** : Arrêt / Veille / Aucune action

**Paramètres de batterie (portables) :**

- **Action batterie critique** : Mise en veille prolongée
- **Niveau de batterie critique** : 5-10%
- **Notification batterie faible** : 20-25%

> [!warning] Pièges courants
> 
> - **Veille vs veille prolongée** : La veille consomme (RAM alimentée), la veille prolongée sauvegarde sur disque.
> - **Écran vs ordinateur** : L'extinction de l'écran n'est pas la mise en veille du système.
> - **BitLocker** : La mise en veille prolongée peut nécessiter le PIN BitLocker au réveil.
> - **Serveurs RDS** : Désactivez la mise en veille sur les serveurs d'accès à distance.

> [!tip] Recommandations sectorielles
> 
> - **Bureautique standard** : Veille après 30 min, écran après 10 min
> - **CAO/Graphisme** : Extinction écran uniquement (pas de veille)
> - **Salles de réunion** : Veille rapide (5 min) pour économie
> - **Serveurs** : Pas de veille, haute performance uniquement

---

## 🔒 Restrictions et sécurité

Les restrictions de sécurité via GPO permettent de limiter l'accès aux fonctionnalités du système et de renforcer la posture de sécurité. Ces configurations sont essentielles dans un environnement d'entreprise.

### Restrictions d'accès aux fonctionnalités

Ces restrictions limitent l'accès à certaines fonctionnalités Windows pour les utilisateurs standard.

#### Restrictions système courantes

**Chemin de configuration :**

```
Configuration utilisateur
└── Stratégies
    └── Modèles d'administration
        └── Système
```

**Paramètres clés :**

|Paramètre|Impact|Usage recommandé|
|---|---|---|
|Désactiver l'invite de commandes|Bloque CMD|⚠️ Utilisateurs non-techniques|
|Désactiver les outils de modification du Registre|Bloque regedit|✅ Utilisateurs standard|
|Empêcher l'accès au Panneau de configuration|Bloque accès paramètres|⚠️ Selon profil|
|Désactiver le Gestionnaire des tâches|Empêche Ctrl+Alt+Suppr|⚠️ Peut gêner support|
|Empêcher l'installation de périphériques|Limite USB, etc.|✅ Postes sensibles|

> [!warning] Attention à l'équilibre Des restrictions trop strictes peuvent :
> 
> - Gêner la productivité des utilisateurs
> - Complexifier le support informatique
> - Créer des contournements (utilisation d'outils tiers)

#### Restrictions du Panneau de configuration

**Chemin :**

```
Configuration utilisateur
└── Stratégies
    └── Modèles d'administration
        └── Panneau de configuration
```

**Restrictions par composant :**

|Composant|Paramètre|Raison de bloquer|
|---|---|---|
|Ajout/Suppression de programmes|Masquer "Programmes et fonctionnalités"|Empêcher désinstallation logiciels|
|Système|Masquer l'onglet "Nom de l'ordinateur"|Éviter renommage poste|
|Souris|Désactiver l'accès|Empêcher modification vitesse, etc.|
|Date et heure|Empêcher la modification|Éviter désynchronisation|
|Comptes d'utilisateurs|Masquer le lien|Empêcher élévation de privilèges|

> [!example] Configuration type - Utilisateur standard
> 
> ```
> ✓ Désactiver regedit
> ✓ Masquer "Programmes et fonctionnalités"
> ✓ Empêcher modification nom ordinateur
> ✓ Empêcher modification date/heure
> ✗ Ne PAS bloquer Gestionnaire des tâches (utile pour support)
> ✗ Ne PAS bloquer CMD (ou autoriser pour groupe support)
> ```

#### Restrictions des périphériques amovibles

**Chemin :**

```
Configuration ordinateur
└── Stratégies
    └── Modèles d'administration
        └── Système
            └── Accès au stockage amovible
```

**Types de restrictions :**

|Classe de périphérique|Paramètre|Impact sécurité|
|---|---|---|
|Lecteurs de CD et DVD|Refuser l'accès en lecture|Empêche exfiltration|
|Disques amovibles|Refuser l'accès en écriture|Empêche infection malware|
|Clés USB|Refuser l'accès en lecture/écriture|Bloque totalement USB|
|Lecteurs de bandes|Refuser l'accès|Limite sauvegardes locales|
|Appareils WPD|Refuser l'accès|Bloque smartphones, appareils photos|

> [!tip] Approche granulaire recommandée Au lieu de tout bloquer :
> 
> - **Lecture seule** sur USB pour les utilisateurs standard
> - **Liste blanche** d'appareils autorisés par ID matériel
> - **Exceptions** pour groupes IT via GPO dédiée avec priorité plus élevée

### Politiques de sécurité locale

Les politiques de sécurité locale définissent les règles de sécurité du système d'exploitation.

**Chemin de configuration :**

```
Configuration ordinateur
└── Stratégies
    └── Paramètres Windows
        └── Paramètres de sécurité
            └── Stratégies locales
```

#### Stratégies de comptes

**Stratégie de mot de passe :**

|Paramètre|Valeur recommandée|Justification|
|---|---|---|
|Longueur minimale|12 caractères|ANSSI 2024|
|Complexité requise|Activé|3/4 catégories (maj, min, chiffre, spécial)|
|Durée de vie maximale|90 jours|Rotation régulière|
|Historique|24 mots de passe|Éviter réutilisation|
|Durée de vie minimale|1 jour|Empêcher changements rapides|

**Stratégie de verrouillage de compte :**

|Paramètre|Valeur recommandée|Justification|
|---|---|---|
|Seuil de verrouillage|5 tentatives|Équilibre sécurité/usabilité|
|Durée de verrouillage|30 minutes|Auto-déverrouillage|
|Réinitialiser le compteur après|30 minutes|Fenêtre d'observation|

> [!info] Évolutions NIST 2024 Les recommandations NIST récentes préconisent :
> 
> - Pas d'expiration obligatoire (sauf compromission)
> - Longueur minimale 12-15 caractères
> - Pas de complexité forcée si longueur > 15
> - Vérification contre listes de mots de passe compromis

#### Options de sécurité

**Paramètres cruciaux :**

|Catégorie|Paramètre|Valeur|
|---|---|---|
|**Comptes**|Renommer le compte Administrateur|`SysAdmin` (différent du défaut)|
|**Comptes**|Limiter l'utilisation de comptes locaux avec des mots de passe vides|Activé|
|**Accès réseau**|Ne pas autoriser l'énumération anonyme des comptes SAM|Activé|
|**Connexion interactive**|Ne pas afficher le dernier nom d'utilisateur|Activé (confidentialité)|
|**Connexion interactive**|Message pour les utilisateurs essayant de se connecter|Texte légal|
|**Console de récupération**|Autoriser la connexion automatique|Désactivé|
|**Arrêt**|Autoriser l'arrêt du système sans connexion|Désactivé (serveurs)|

**Configuration de l'UAC (User Account Control) :**

```
Contrôle de compte d'utilisateur
├── Mode d'approbation Administrateur pour le compte Administrateur intégré : Activé
├── Élever uniquement les exécutables signés et validés : Désactivé (trop strict)
├── Comportement de l'invite d'élévation : Demander les informations d'identification
└── Détecter les installations d'applications et demander une élévation : Activé
```

> [!warning] Désactivation de l'UAC **Ne jamais désactiver l'UAC en production !** C'est une couche de sécurité essentielle contre les malwares et les élévations de privilèges non autorisées.

### AppLocker

AppLocker est une fonctionnalité de contrôle d'application qui permet de définir quelles applications peuvent s'exécuter sur les postes clients (Windows 7 Enterprise/Ultimate et supérieur).

**Chemin de configuration :**

```
Configuration ordinateur
└── Stratégies
    └── Paramètres Windows
        └── Paramètres de sécurité
            └── Stratégies de contrôle d'application
                └── AppLocker
```

#### Types de règles AppLocker

AppLocker gère 5 types de fichiers :

|Type|Extension|Usage|
|---|---|---|
|**Exécutables**|.exe, .com|Applications standard|
|**Scripts**|.ps1, .bat, .cmd, .vbs, .js|Scripts automatisés|
|**Windows Installer**|.msi, .msp, .mst|Packages d'installation|
|**DLL**|.dll, .ocx|Bibliothèques (⚠️ impact performance)|
|**Applications empaquetées**|.appx|Applications Windows Store|

> [!warning] Règles DLL Les règles DLL peuvent impacter significativement les performances. Ne les activez que si nécessaire et testez en profondeur.

#### Conditions de règle

AppLocker offre 3 types de conditions pour créer des règles :

**1. Règle d'éditeur (Publisher)**

- Basée sur la signature numérique
- La plus sécurisée et flexible
- Survit aux mises à jour

**Exemple :**

```
Éditeur : O=MICROSOFT CORPORATION, L=REDMOND, S=WASHINGTON, C=US
Nom du produit : MICROSOFT® WINDOWS® OPERATING SYSTEM
Nom du fichier : *
Version du fichier : * et supérieure
```

**2. Règle de chemin d'accès (Path)**

- Basée sur l'emplacement du fichier
- Simple mais contournable si utilisateur a droits d'écriture

**Exemple :**

```
%PROGRAMFILES%\*
%WINDIR%\*
```

**3. Règle de hachage (Hash)**

- Basée sur l'empreinte SHA256
- Très sécurisée mais rigide
- Doit être mise à jour à chaque version de fichier

> [!tip] Ordre de préférence recommandé
> 
> 1. **Éditeur** (meilleur compromis sécurité/gestion)
> 2. **Chemin** (simplicité, mais attention aux permissions)
> 3. **Hachage** (cas spécifiques uniquement)

#### Configuration d'AppLocker

**Étapes de mise en œuvre :**

1. **Activer le service Application Identity**

```
Services → Application Identity → Type de démarrage : Automatique
```

2. **Créer des règles par défaut**

- Clic droit sur "Règles exécutables" → **Créer des règles par défaut**
- Répéter pour Scripts, Windows Installer, etc.

**Règles par défaut créées :**

```
✓ Autoriser les administrateurs locaux à exécuter tout
✓ Autoriser tout le monde à exécuter depuis Windows et Program Files
```

3. **Créer des règles personnalisées**

> [!example] Bloquer l'exécution depuis les dossiers temporaires
> 
> ```
> Type : Règle exécutable
> Autorisation : Refuser
> Utilisateurs : Tout le monde
> Conditions : Chemin
> Chemins :
>   - %TEMP%\*
>   - %USERPROFILE%\AppData\Local\Temp\*
>   - %USERPROFILE%\Downloads\*
> ```

> [!example] Autoriser uniquement les logiciels signés Microsoft
> 
> ```
> Type : Règle exécutable
> Autorisation : Autoriser
> Utilisateurs : Tout le monde
> Conditions : Éditeur
> Éditeur : O=MICROSOFT CORPORATION*
> Produit : *
> Nom du fichier : *
> Version : * et supérieure
> ```

4. **Configurer la mise en œuvre**

```
Propriétés d'AppLocker
├── Règles exécutables : Activé (ou Audit uniquement)
├── Règles Windows Installer : Activé
├── Règles Script : Activé
└── Règles DLL : Désactivé (sauf besoin spécifique)
```

> [!tip] Mode Audit Déployez d'abord en **mode Audit** pour observer les blocages potentiels sans impact :
> 
> ```powershell
> # Consulter les événements AppLocker en mode Audit
> Get-WinEvent -LogName "Microsoft-Windows-AppLocker/EXE and DLL" | Where-Object {$_.Id -eq 8004}
> ```

#### Déploiement progressif recommandé

|Phase|Configuration|Durée|Objectif|
|---|---|---|---|
|**Phase 1**|Mode Audit uniquement|2-4 semaines|Collecter les données|
|**Phase 2**|Activation sur groupe pilote|2 semaines|Valider les règles|
|**Phase 3**|Déploiement progressif|4-8 semaines|Étendre à tous|
|**Phase 4**|Monitoring continu|Permanent|Ajuster les règles|

> [!warning] Pièges courants AppLocker
> 
> - **Oublier d'activer le service Application Identity** : AppLocker ne fonctionne pas
> - **Pas de règles par défaut** : Tout est bloqué, y compris Windows
> - **Règles trop restrictives** : Blocage de logiciels métier critiques
> - **DLL activées sans test** : Dégradation majeure des performances
> - **Pas de mode Audit** : Déploiement brutal avec incidents

### Restrictions logicielles

Les Stratégies de restriction logicielle (SRP - Software Restriction Policies) sont l'ancêtre d'AppLocker, disponibles sur toutes les versions de Windows.

**Chemin de configuration :**

```
Configuration ordinateur
└── Stratégies
    └── Paramètres Windows
        └── Paramètres de sécurité
            └── Stratégies de restriction logicielle
```

> [!info] SRP vs AppLocker
> 
> - **SRP** : Compatible toutes versions Windows, moins granulaire
> - **AppLocker** : Windows Enterprise/Education uniquement, plus puissant
> - **Recommandation** : Utilisez AppLocker si disponible

#### Niveaux de sécurité

SRP offre 2 niveaux de sécurité par défaut :

|Niveau|Comportement|Usage|
|---|---|---|
|**Non autorisé**|Bloque l'exécution|Mode liste blanche (restrictif)|
|**Non restreint**|Autorise l'exécution|Mode liste noire (permissif)|

**Configuration du niveau par défaut :**

```
Clic droit sur "Stratégies de restriction logicielle"
→ Créer une stratégie de restriction logicielle
→ Propriétés de "Niveaux de sécurité"
→ Double-clic sur le niveau souhaité → Définir par défaut
```

#### Types de règles SRP

**1. Règle de chemin d'accès**

```
%PROGRAMFILES%\Application\*
C:\Apps\Autorisés\*
%APPDATA%\* (à bloquer)
```

**2. Règle de hachage**

- Hash MD5 ou SHA-256 du fichier
- Mise à jour manuelle requise

**3. Règle de certificat**

- Basée sur le certificat de signature
- Similaire aux règles d'éditeur AppLocker

**4. Règle de zone Internet**

- Internet, Intranet local, Sites de confiance, Sites sensibles

> [!example] Configuration SRP type - Mode liste blanche
> 
> ```
> Niveau par défaut : Non autorisé
> 
> Règles d'exception (Autorisées) :
> ✓ %WINDIR%\*
> ✓ %PROGRAMFILES%\*
> ✓ %PROGRAMFILES(X86)%\*
> ✓ Certificat : Éditeur Microsoft
> ✓ Certificat : Éditeur Adobe Systems
> ```

#### Utilisateurs affectés

Par défaut, SRP s'applique à tous les utilisateurs. Pour exclure les administrateurs :

```
Stratégies de restriction logicielle
→ Clic droit → Propriétés
→ Onglet "Mise en œuvre"
→ Appliquer les stratégies de restriction logicielle à : Tous les utilisateurs sauf les administrateurs locaux
```

> [!tip] Recommandations SRP
> 
> - **N'utilisez SRP que si AppLocker n'est pas disponible**
> - **Testez en profondeur** avant déploiement
> - **Documentez toutes les règles** créées
> - **Privilégiez les chemins avec variables d'environnement** pour la flexibilité

---

## 📦 Installation de logiciels

Le déploiement de logiciels via GPO permet d'installer automatiquement des applications sur les postes clients sans intervention manuelle. Cette méthode centralise et standardise le parc logiciel.

### Déploiement via MSI

Les GPO ne supportent nativement que les packages **Windows Installer (.msi)**. Les fichiers .exe ne peuvent pas être déployés directement (nécessitent un wrapper ou des scripts).

**Chemin de configuration :**

```
Configuration ordinateur (ou utilisateur)
└── Stratégies
    └── Paramètres du logiciel
        └── Installation de logiciel
```

#### Prérequis pour le déploiement

**1. Point de distribution**

Les packages MSI doivent être stockés sur un partage réseau accessible :

```
\\srv-files\Applications$\
├── 7-Zip\
│   └── 7z2301-x64.msi
├── VLC\
│   └── vlc-3.0.20-win64.msi
└── AdobeReader\
    └── AcroRdrDC.msi
```

**Permissions requises :**

- `Ordinateurs du domaine` : Lecture
- `Utilisateurs authentifiés` : Lecture
- `Administrateurs` : Contrôle total

> [!warning] Chemin UNC obligatoire Utilisez toujours un chemin UNC (`\\serveur\partage`), jamais une lettre mappée (F:) qui peut ne pas être disponible lors de l'installation.

**2. Fichiers de transformation (.mst)**

Les fichiers MST personnalisent l'installation sans modifier le MSI source :

```
7z2301-x64.msi          (fichier original)
7z-custom.mst           (transformations)
```

**Utilisations courantes des MST :**

- Désactiver les raccourcis bureau
- Préconfigurations (paramètres, licences)
- Installation silencieuse personnalisée
- Désactivation de fonctionnalités

#### Création d'un déploiement

**Étapes de configuration :**

1. **Clic droit** sur "Installation de logiciel" → **Nouveau** → **Package**
    
2. **Sélectionner le fichier MSI**
    
    - Naviguer vers `\\srv-files\Applications$\7-Zip\7z2301-x64.msi`
    - ⚠️ Le chemin doit rester en UNC (ne pas convertir en lettre)
3. **Choisir la méthode de déploiement**
    

|Méthode|Quand ?|Impact|
|---|---|---|
|**Publié**|Applications optionnelles utilisateur|Disponible dans "Ajout/Suppression"|
|**Attribué**|Applications obligatoires|Installation automatique|
|**Avancé**|Configuration personnalisée|Options détaillées|

4. **Configurer les options avancées**

### Publication vs Attribution

Les deux modes de déploiement ont des comportements différents selon qu'ils sont appliqués à l'ordinateur ou à l'utilisateur.

#### Attribution (Assigned)

|Cible|Comportement|Moment d'installation|
|---|---|---|
|**Ordinateur**|Installation automatique forcée|Au démarrage (avant ouverture session)|
|**Utilisateur**|Annoncé, s'installe à la première utilisation|À l'ouverture du fichier associé|

**Attribué à l'ordinateur :**

```
✓ Installation au démarrage du PC
✓ Disponible pour tous les utilisateurs
✓ Ne dépend pas de l'utilisateur connecté
✓ Idéal pour logiciels système
```

**Attribué à l'utilisateur :**

```
✓ Raccourcis créés au démarrage
✓ Installation réelle au premier lancement
✓ Suit l'utilisateur sur tous les PC
✓ Idéal pour logiciels métier personnels
```

#### Publication (Published)

> [!warning] Disponible uniquement pour Configuration utilisateur La publication n'existe pas pour Configuration ordinateur.

**Publié à l'utilisateur :**

```
✓ Apparaît dans "Programmes et fonctionnalités"
✓ L'utilisateur choisit d'installer ou non
✓ Installation via extension de fichier possible
✓ Idéal pour logiciels optionnels
```

> [!example] Cas d'usage par méthode
> 
> **Attribué ordinateur :**
> 
> - Antivirus, agents de supervision
> - Logiciels de sécurité obligatoires
> - Pilotes, outils système
> 
> **Attribué utilisateur :**
> 
> - Suite Office
> - Logiciels métier standards
> - Applications de productivité
> 
> **Publié utilisateur :**
> 
> - Outils optionnels (7-Zip, Notepad++)
> - Logiciels de niche
> - Versions alternatives

### Configuration avancée

Lors de la sélection de la méthode "Avancé", plusieurs onglets permettent de personnaliser le déploiement.

#### Onglet "Déploiement"

**Options de déploiement :**

|Option|Description|Recommandation|
|---|---|---|
|**Type de déploiement**|Publié / Attribué|Selon besoin|
|**Installer cette application lors de l'ouverture de session**|Force l'installation complète|✅ Pour apps critiques|
|**Installer cette application à l'activation d'une extension de fichier**|Install on demand|✅ Pratique|
|**Désinstaller cette application si elle n'est plus dans l'étendue de la gestion**|Auto-suppression|✅ Recommandé|
|**Ne pas afficher ce package dans Ajout/Suppression de programmes**|Masque de la liste|⚠️ Pour apps système uniquement|
|**Installer lors du démarrage**|Installation machine|✅ Pour Configuration ordinateur|

**Options d'installation :**

```
☑ De base
    Installation standard avec interface utilisateur basique
    
☑ Maximale
    Installation complète sans intervention
    
☐ Définir comme package 32 bits sur clients 64 bits
    Force l'installation en 32 bits
```

> [!tip] Configuration recommandée standard
> 
> ```
> ✓ Attribué
> ✓ Installer lors de l'ouverture de session
> ✓ Désinstaller si hors étendue
> ✓ Interface utilisateur : De base
> ```

#### Onglet "Mises à niveau"

Permet de gérer les mises à jour des applications déjà déployées.

**Ajouter une mise à niveau :**

1. Cliquer sur **Ajouter...**
2. Sélectionner le package à remplacer (ancienne version)
3. Choisir le type de mise à niveau :

|Type|Comportement|Usage|
|---|---|---|
|**Obligatoire**|Désinstalle l'ancienne, installe la nouvelle|Mises à jour majeures|
|**Facultative**|L'utilisateur peut choisir|Proposer nouvelle version|

**Options :**

```
☑ Désinstaller le package existant, puis installer le package de mise à niveau
    Suppression propre de l'ancienne version
    
☐ Le package peut mettre à niveau le package existant
    Mise à jour en place (si le MSI le supporte)
```

> [!example] Mise à niveau VLC 3.0.18 → 3.0.20
> 
> ```
> Package actuel : vlc-3.0.18-win64.msi
> Nouveau package : vlc-3.0.20-win64.msi
> 
> Configuration :
> - Type : Obligatoire
> - ✓ Désinstaller le package existant
> - Résultat : Mise à jour automatique sur tous les postes
> ```

#### Onglet "Catégories"

Les catégories organisent les applications dans "Ajout/Suppression de programmes".

**Créer des catégories :**

1. Configuration ordinateur → Installation de logiciel → Propriétés
2. Onglet "Catégories" → Ajouter des catégories

**Exemples de catégories :**

```
📁 Bureautique
📁 Développement
📁 Graphisme
📁 Communication
📁 Utilitaires
📁 Sécurité
```

**Assigner une catégorie à un package :**

- Propriétés du package → Onglet Catégories → Sélectionner

> [!tip] Avantage des catégories Les utilisateurs peuvent filtrer les applications disponibles par catégorie, facilitant la découverte des logiciels mis à disposition.

#### Onglet "Modifications"

Permet d'ajouter des fichiers de transformation (.mst) pour personnaliser l'installation.

**Ajout de transformations :**

1. Cliquer sur **Ajouter...**
2. Sélectionner le fichier .mst
3. Ordre des transformations : de haut en bas

```
Package : AcroRdrDC.msi
Modifications :
  1. AcroRdr-NoUpdates.mst     (désactive les mises à jour)
  2. AcroRdr-HideToolbar.mst   (masque des éléments)
```

> [!warning] Ordre important Les transformations sont appliquées dans l'ordre de la liste. L'ordre peut impacter le résultat final.

#### Onglet "Sécurité"

Définit quels utilisateurs/groupes peuvent installer le logiciel.

**Permissions par défaut :**

```
Utilisateurs authentifiés : Lecture
Ordinateurs du domaine : Lecture
Administrateurs : Contrôle total
```

**Pour restreindre à un groupe :**

1. Supprimer "Utilisateurs authentifiés"
2. Ajouter le groupe spécifique (ex: GRP_Comptabilite)
3. Donner "Lecture" et "Lecture & exécution"

### Gestion des mises à jour

#### Méthode 1 : Mise à niveau via GPO

Créer un nouveau déploiement de la version supérieure et configurer la mise à niveau (voir section "Onglet Mises à niveau").

**Avantages :**

- ✅ Automatique
- ✅ Centralisé
- ✅ Planifiable

**Inconvénients :**

- ⚠️ Nécessite redémarrage ou nouvelle session
- ⚠️ Consomme bande passante réseau

#### Méthode 2 : Redéploiement

Supprimer l'ancien package, déployer le nouveau.

**⚠️ Attention :** Peut causer une fenêtre sans logiciel si mal planifié.

#### Méthode 3 : Mise à jour en place

Remplacer le fichier MSI dans le point de distribution par la nouvelle version (même nom).

**Conditions :**

- Le ProductCode MSI doit rester identique
- Fonctionnalité de réparation/réinstallation

**Forcer la réinstallation :**

```powershell
# Via GPO ou script
msiexec /fa \\srv\apps\application.msi /qn
```

> [!tip] Stratégie de mise à jour recommandée
> 
> **Applications critiques (antivirus, agents) :**
> 
> - Déploiement ordinateur
> - Mise à niveau obligatoire automatique
> - Tests préalables sur groupe pilote
> 
> **Applications bureautiques :**
> 
> - Déploiement utilisateur
> - Mise à niveau facultative ou planifiée
> - Communication aux utilisateurs
> 
> **Applications optionnelles :**
> 
> - Publication
> - Notification de disponibilité
> - Mise à jour à la demande

> [!warning] Pièges courants - Déploiement logiciels
> 
> **Permissions insuffisantes :**
> 
> - Les ordinateurs n'ont pas accès au partage réseau
> - Solution : Vérifier les permissions NTFS et partage
> 
> **Chemin avec lettre mappée :**
> 
> - Le lecteur n'est pas disponible lors de l'installation
> - Solution : Toujours utiliser des chemins UNC
> 
> **MSI corrompu ou inaccessible :**
> 
> - Installation échoue silencieusement
> - Solution : Tester le MSI manuellement, vérifier les logs
> 
> **Déploiement utilisateur sur ordinateur partagé :**
> 
> - Installe pour chaque utilisateur
> - Solution : Préférer déploiement ordinateur
> 
> **Pas de désinstallation à la sortie de l'étendue :**
> 
> - Les logiciels restent après changement d'OU
> - Solution : Activer "Désinstaller si hors étendue"
> 
> **Conflit de versions :**
> 
> - Ancienne et nouvelle version coexistent
> - Solution : Configurer correctement les mises à niveau

**Dépannage - Logs Windows Installer :**

```powershell
# Activer les logs détaillés
reg add "HKLM\Software\Policies\Microsoft\Windows\Installer" /v Logging /t REG_SZ /d "voicewarmup" /f

# Logs situés dans :
C:\Windows\Temp\MSI*.log
```

---

## ⚙️ Scripts de démarrage/arrêt et ouverture/fermeture

Les scripts GPO permettent d'exécuter automatiquement des commandes lors d'événements système spécifiques. C'est un outil puissant pour l'automatisation et la configuration avancée.

### Types de scripts

Les GPO supportent 4 types de scripts, divisés en deux catégories :

#### Scripts ordinateur

**Chemin de configuration :**

```
Configuration ordinateur
└── Stratégies
    └── Paramètres Windows
        └── Scripts (démarrage/arrêt)
```

|Type|Moment d'exécution|Contexte|Usage|
|---|---|---|---|
|**Démarrage**|Au boot, avant l'écran de connexion|SYSTEM|Configuration machine, montage réseau|
|**Arrêt**|Lors de l'extinction|SYSTEM|Nettoyage, sauvegardes|

#### Scripts utilisateur

**Chemin de configuration :**

```
Configuration utilisateur
└── Stratégies
    └── Paramètres Windows
        └── Scripts (ouverture/fermeture de session)
```

|Type|Moment d'exécution|Contexte|Usage|
|---|---|---|---|
|**Ouverture de session**|Après authentification|Utilisateur|Configuration profil, mappages personnalisés|
|**Fermeture de session**|Lors de la déconnexion|Utilisateur|Sauvegarde documents, nettoyage temporaire|

> [!info] Contexte d'exécution
> 
> - **Scripts ordinateur** s'exécutent avec les privilèges **SYSTEM** (administrateur)
> - **Scripts utilisateur** s'exécutent avec les droits de **l'utilisateur connecté**

### Configuration des scripts

#### Ajouter un script

**Méthode standard :**

1. **Ouvrir les propriétés de scripts**
    
    - Double-clic sur "Démarrage" (ou Arrêt, Ouverture, Fermeture)
2. **Ajouter un script**
    
    - Cliquer sur **Ajouter...**
    - **Nom du script** : Naviguer vers le script ou entrer le chemin
    - **Paramètres du script** : Arguments éventuels
3. **Bouton "Afficher les fichiers..."**
    
    - Copie automatiquement vers : `\\domain\SYSVOL\domain\Policies\{GUID}\Machine\Scripts\Startup\`
    - Ou : `\User\Scripts\Logon\`

> [!tip] Stockage des scripts Les scripts sont automatiquement répliqués via SYSVOL sur tous les contrôleurs de domaine, garantissant leur disponibilité.

**Structure SYSVOL :**

```
\\contoso.com\SYSVOL\contoso.com\Policies\{GUID-GPO}\
├── Machine\
│   └── Scripts\
│       ├── Startup\
│       │   ├── config-network.ps1
│       │   └── mount-shares.bat
│       └── Shutdown\
│           └── cleanup.ps1
└── User\
    └── Scripts\
        ├── Logon\
        │   ├── map-drives.ps1
        │   └── sync-time.vbs
        └── Logoff\
            └── backup-docs.ps1
```

#### Paramètres des scripts

**Onglet "Scripts" :**

|Option|Description|Recommandation|
|---|---|---|
|**Ordre d'exécution**|Ordre de traitement (haut → bas)|Scripts critiques en premier|
|**Vers le haut / Bas**|Modifier la priorité|Ajuster selon dépendances|

**Onglet "Options PowerShell" :**

|Paramètre|Effet|Usage|
|---|---|---|
|**Pour cette GPO, exécuter les scripts dans l'ordre suivant**|Ordre scripts|Choisir l'ordre|
|- Scripts Windows PowerShell en premier|PS puis Batch|✅ Recommandé (moderne)|
|- Scripts Windows PowerShell en dernier|Batch puis PS|Compatibilité ancienne|
|**Ne pas exécuter**|Désactive un type|Selon besoin|

> [!example] Configuration recommandée
> 
> ```
> Ordre d'exécution : PowerShell en premier
> Raison : Scripts PowerShell plus puissants et modernes
> ```

### Scripts PowerShell vs Batch

#### Comparaison

|Critère|PowerShell (.ps1)|Batch (.bat, .cmd)|VBScript (.vbs)|
|---|---|---|---|
|**Puissance**|⭐⭐⭐⭐⭐|⭐⭐|⭐⭐⭐|
|**Simplicité**|⭐⭐⭐|⭐⭐⭐⭐⭐|⭐⭐|
|**Gestion erreurs**|⭐⭐⭐⭐⭐|⭐|⭐⭐⭐|
|**Compatibilité**|Windows 7+|Toutes versions|Toutes versions|
|**Maintenance**|⭐⭐⭐⭐⭐|⭐⭐⭐|⭐⭐|
|**Sécurité**|⭐⭐⭐⭐ (signing)|⭐⭐|⭐⭐|

> [!tip] Recommandation 2025 **Utilisez PowerShell** pour tous les nouveaux scripts. Batch et VBScript sont à éviter sauf pour maintenir des scripts existants.

#### PowerShell - Politique d'exécution

Par défaut, PowerShell bloque l'exécution de scripts non signés. Pour les scripts GPO :

**Configurer la politique d'exécution via GPO :**

```
Configuration ordinateur (ou utilisateur)
└── Stratégies
    └── Modèles d'administration
        └── Composants Windows
            └── Windows PowerShell
                └── Activer l'exécution des scripts
```

**Options disponibles :**

|Politique|Description|Recommandation|
|---|---|---|
|**RemoteSigned**|Scripts locaux OK, scripts téléchargés signés requis|✅ Environnement standard|
|**AllSigned**|Tous les scripts doivent être signés|Environnement haute sécurité|
|**Unrestricted**|Aucune restriction|⚠️ Non recommandé|
|**Bypass**|Aucun blocage ni avertissement|⚠️ Tests uniquement|

> [!example] Configuration recommandée
> 
> ```
> Configuration ordinateur :
> ├── Activer l'exécution des scripts : Activé
> └── Politique d'exécution des scripts : RemoteSigned
> ```

#### Exemples de scripts

> [!example] Script PowerShell - Mappage de lecteur réseau avec log
> 
> ```powershell
> # Script : Map-SharedDrive.ps1
> # Description : Mappe le lecteur P: sur le partage commun avec logging
> 
> $LogFile = "$env:TEMP\MapDrive.log"
> $SharePath = "\\srv-files\Commun"
> $DriveLetter = "P:"
> 
> try {
>     # Supprimer le mapping s'il existe déjà
>     if (Test-Path $DriveLetter) {
>         Remove-PSDrive -Name ($DriveLetter -replace ":","") -ErrorAction SilentlyContinue
>     }
>     
>     # Créer le nouveau mapping
>     New-PSDrive -Name ($DriveLetter -replace ":","") -PSProvider FileSystem -Root $SharePath -Persist -ErrorAction Stop
>     
>     # Log succès
>     $Message = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - SUCCESS: Lecteur $DriveLetter mappé sur $SharePath"
>     Add-Content -Path $LogFile -Value $Message
>     
> } catch {
>     # Log erreur
>     $Message = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ERROR: $($_.Exception.Message)"
>     Add-Content -Path $LogFile -Value $Message
>     exit 1
> }
> ```

> [!example] Script Batch - Synchronisation horaire
> 
> ```batch
> @echo off
> REM Script : sync-time.bat
> REM Description : Force la synchronisation avec le serveur de temps
> 
> echo [%date% %time%] Synchronisation horaire en cours... >> C:\Temp\timesync.log
> 
> w32tm /resync /force
> 
> if %errorlevel% equ 0 (
>     echo [%date% %time%] Synchronisation reussie >> C:\Temp\timesync.log
> ) else (
>     echo [%date% %time%] Echec de la synchronisation >> C:\Temp\timesync.log
> )
> ```

> [!example] Script PowerShell - Nettoyage profil temporaire (Fermeture session)
> 
> ```powershell
> # Script : Cleanup-UserTemp.ps1
> # Description : Nettoie les fichiers temporaires de l'utilisateur
> 
> $TempFolders = @(
>     "$env:TEMP",
>     "$env:USERPROFILE\AppData\Local\Temp",
>     "$env:USERPROFILE\Downloads"
> )
> 
> $DaysOld = 7
> $DateLimit = (Get-Date).AddDays(-$DaysOld)
> 
> foreach ($Folder in $TempFolders) {
>     if (Test-Path $Folder) {
>         Get-ChildItem -Path $Folder -Recurse -File -ErrorAction SilentlyContinue |
>             Where-Object { $_.LastWriteTime -lt $DateLimit } |
>             Remove-Item -Force -ErrorAction SilentlyContinue
>     }
> }
> ```

### Ordre d'exécution

L'ordre d'exécution des scripts et GPO est crucial pour comprendre le comportement du système.

#### Séquence de démarrage

```
1. ⚡ Démarrage du système
2. 🔧 Scripts de démarrage (Configuration ordinateur)
   └── Contexte : SYSTEM
   └── Ordre : GPO avec priorité la plus élevée en premier
3. 🖥️ Écran de connexion Windows
4. 🔐 Authentification utilisateur
5. 👤 Scripts d'ouverture de session (Configuration utilisateur)
   └── Contexte : Utilisateur
   └── Ordre : GPO avec priorité la plus élevée en premier
6. 🏠 Bureau utilisateur affiché
```

#### Séquence d'arrêt

```
1. 🔌 Demande d'arrêt du système
2. 👤 Scripts de fermeture de session (Configuration utilisateur)
   └── Tous les utilisateurs connectés
3. 🔧 Scripts d'arrêt (Configuration ordinateur)
   └── Contexte : SYSTEM
4. ⚡ Extinction du système
```

#### Ordre entre GPO multiples

Si plusieurs GPO contiennent des scripts, l'ordre suit la hiérarchie GPO standard :

```
1. GPO au niveau Local (ordinateur lui-même)
2. GPO au niveau Site
3. GPO au niveau Domaine
4. GPO au niveau OU (de la plus haute à la plus basse)
```

**À chaque niveau, les GPO sont traitées selon leur ordre de liaison (Link Order).**

> [!warning] Ordre de liaison Un Link Order de **1** est traité en DERNIER (priorité la plus haute). Un Link Order de **5** est traité en PREMIER (priorité la plus basse).

#### Ordre des scripts dans une même GPO

Au sein d'une même GPO, les scripts s'exécutent **de haut en bas** dans la liste.

**Exemple :**

```
Scripts d'ouverture de session :
1. 01-init-environment.ps1    ← Exécuté en 1er
2. 02-map-drives.ps1           ← Exécuté en 2ème
3. 03-start-applications.ps1   ← Exécu
```