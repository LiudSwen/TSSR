

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

## 🔐 Comptes locaux et comptes Microsoft

### Compte local

Un **compte local** est un compte utilisateur créé et stocké uniquement sur la machine Windows locale.

**Caractéristiques** :

- Authentification basée sur la SAM (Security Account Manager) locale
- Profil stocké dans `C:\Users\NomUtilisateur`
- Aucune synchronisation entre machines
- Paramètres et données non sauvegardés dans le cloud
- Fonctionne sans connexion Internet

> [!tip] Quand utiliser un compte local ?
> 
> - Environnements isolés ou sécurisés sans accès Internet
> - Machines dédiées à une tâche spécifique
> - Tests et développement
> - Préférence pour la vie privée et le contrôle local

**Création d'un compte local** :

- Via Paramètres → Comptes → Famille et autres utilisateurs
- Via la console `lusrmgr.msc`
- Via les commandes `net user` (voir section dédiée)

### Compte Microsoft

Un **compte Microsoft** est un compte en ligne (adresse email) utilisé pour se connecter à Windows et aux services Microsoft.

**Caractéristiques** :

- Authentification via les serveurs Microsoft (Azure AD)
- Synchronisation des paramètres entre appareils
- Accès aux services cloud (OneDrive, Office 365, Store)
- Possibilité de réinitialisation du mot de passe en ligne
- Nécessite une connexion Internet lors de la première connexion

> [!info] Avantages du compte Microsoft
> 
> - Synchronisation automatique des paramètres (thème, favoris, mots de passe)
> - Sauvegarde OneDrive intégrée
> - Accès simplifié aux applications du Microsoft Store
> - Gestion centralisée depuis account.microsoft.com

### Comparaison

|Critère|Compte Local|Compte Microsoft|
|---|---|---|
|**Stockage des données**|Machine locale uniquement|Cloud + Local|
|**Synchronisation**|Aucune|Paramètres, fichiers (OneDrive)|
|**Connexion Internet**|Non requise|Requise (première connexion)|
|**Récupération mot de passe**|Difficile (questions secrètes)|Facile (email/SMS)|
|**Services cloud**|Non intégré|Intégré (OneDrive, Store)|
|**Confidentialité**|Maximum|Données partagées avec Microsoft|

> [!warning] Attention Sur Windows 11, Microsoft pousse fortement l'utilisation de comptes Microsoft. Pour créer un compte local lors de l'installation, des contournements peuvent être nécessaires (pas de connexion réseau, commandes spécifiques).

---

## 🎭 Types de comptes

Windows définit deux types principaux de comptes utilisateurs locaux basés sur leurs privilèges.

### Compte Administrateur

Un compte **Administrateur** possède un contrôle total sur le système.

**Privilèges** :

- Installation/désinstallation de logiciels et pilotes
- Modification des paramètres système
- Création et gestion d'autres comptes utilisateurs
- Accès à tous les fichiers du système
- Modification du registre Windows
- Gestion des services système
- Configuration du pare-feu et de la sécurité

> [!warning] Principe du moindre privilège Ne pas utiliser un compte administrateur pour les tâches quotidiennes. Créer un compte Standard pour l'usage courant et élever les privilèges uniquement quand nécessaire (UAC).

**Compte Administrateur intégré** :

- Windows crée un compte `Administrateur` par défaut (désactivé depuis Windows Vista)
- SID toujours identique : `S-1-5-21-...-500`
- Ne subit pas l'UAC (dangereusement puissant)
- Activation via : `net user Administrateur /active:yes`

```powershell
# Vérifier si un compte est administrateur
net user NomUtilisateur | findstr "Appartenances"
```

### Compte Standard

Un compte **Standard** (ou utilisateur limité) possède des privilèges restreints pour protéger le système.

**Limitations** :

- Ne peut pas installer de logiciels système
- Ne peut pas modifier les paramètres système critiques
- Ne peut pas accéder aux fichiers d'autres utilisateurs
- Ne peut pas créer/supprimer d'autres comptes
- Peut installer des applications utilisateur (Store, certains logiciels)
- Peut modifier ses propres paramètres et fichiers

> [!tip] Bonne pratique de sécurité Créer un compte Standard pour l'utilisation quotidienne, même si vous êtes le seul utilisateur. En cas d'infection par malware, les dégâts seront limités car le malware ne pourra pas facilement s'installer au niveau système.

**Élévation de privilèges** :

- Un compte Standard peut demander une élévation via UAC
- Une fenêtre demande le mot de passe d'un administrateur
- L'élévation est temporaire (durée du processus)

### Compte Invité (désactivé par défaut)

Le compte **Invité** permet un accès temporaire très limité.

**Caractéristiques** :

- Aucun mot de passe requis
- Privilèges minimaux
- Profil temporaire (supprimé à la déconnexion)
- Désactivé par défaut depuis Windows 10
- Rarement utilisé dans un contexte professionnel

```powershell
# Activer le compte Invité (déconseillé)
net user Invité /active:yes
```

> [!warning] Risque de sécurité Le compte Invité représente une faille de sécurité potentielle. Il ne devrait être activé que dans des circonstances très spécifiques et contrôlées.

---

## 🛡️ Contrôle de compte d'utilisateur (UAC)

Le **User Account Control (UAC)** est un mécanisme de sécurité introduit dans Windows Vista pour limiter les dégâts causés par des logiciels malveillants.

### Principe de fonctionnement

L'UAC fonctionne selon le principe du **moindre privilège** :

1. **Par défaut**, tous les comptes (même administrateurs) s'exécutent avec des privilèges limités
2. **Quand nécessaire**, une élévation de privilèges est demandée
3. **Une fenêtre de confirmation** apparaît pour valider l'action
4. **Le processus élevé** s'exécute temporairement avec des privilèges administrateur

> [!info] Différence utilisateur/administrateur
> 
> - **Compte Standard** : UAC demande le mot de passe d'un administrateur
> - **Compte Administrateur** : UAC demande uniquement une confirmation (Oui/Non)

### Niveaux de l'UAC

Windows propose 4 niveaux de notification UAC (configurables via `UserAccountControlSettings.exe`) :

|Niveau|Description|Recommandation|
|---|---|---|
|**Toujours notifier**|Notification pour toutes modifications (système + applications)|Sécurité maximale|
|**Notifier seulement les modifications**|Notification uniquement pour les modifications système (défaut)|**Recommandé**|
|**Notifier sans assombrir le bureau**|Comme niveau 2 mais sans Secure Desktop|Moins sécurisé|
|**Ne jamais notifier**|Aucune notification UAC|**Très dangereux**|

> [!warning] Ne jamais désactiver l'UAC Désactiver l'UAC expose le système à des risques majeurs. Les malwares peuvent s'installer silencieusement avec des privilèges élevés. C'est l'une des premières choses qu'un malware tente de faire.

### Secure Desktop

Le **Secure Desktop** est une fonctionnalité de sécurité de l'UAC :

- Assombrit l'écran lors d'une élévation
- Bascule vers un bureau sécurisé isolé
- Les applications normales ne peuvent pas interagir avec ce bureau
- Empêche les attaques par injection de code ou de frappes clavier

```powershell
# Vérifier l'état de l'UAC (registre)
Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableLUA
```

### Comportement visuel de l'UAC

L'UAC utilise un **code couleur** dans sa fenêtre de confirmation :

- 🔵 **Bleu** : Application signée par Microsoft
- 🟡 **Jaune/Orange** : Application d'éditeur vérifié (certificat valide)
- 🔴 **Rouge** : Application non signée ou bloquée (risque élevé)

> [!tip] Toujours lire la fenêtre UAC Prenez l'habitude de lire le nom du programme qui demande l'élévation. Si c'est inattendu ou suspect, refusez !

### Contournements et limitations

L'UAC n'est **pas une barrière de sécurité infranchissable** :

- Un malware peut parfois contourner l'UAC (exploits)
- L'UAC protège contre les modifications non autorisées, pas contre l'ingénierie sociale
- Un utilisateur qui clique toujours "Oui" rend l'UAC inefficace

> [!info] UAC et scripts Les scripts PowerShell ou batch peuvent demander une élévation automatique avec `RunAs` ou en vérifiant les privilèges au démarrage.

```powershell
# Exécuter PowerShell en tant qu'administrateur
Start-Process powershell -Verb RunAs

# Vérifier si le script s'exécute avec des privilèges élevés
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Ce script nécessite des privilèges administrateur" -ForegroundColor Red
    exit
}
```

---

## 🖥️ Console Utilisateurs et groupes locaux

La console **Utilisateurs et groupes locaux** (`lusrmgr.msc`) est l'outil graphique principal pour gérer les comptes et groupes locaux sous Windows.

### Accès à la console

**Méthodes d'ouverture** :

```powershell
# Méthode 1 : Boîte de dialogue Exécuter (Win + R)
lusrmgr.msc

# Méthode 2 : Depuis Gestion de l'ordinateur
compmgmt.msc
# Puis naviguer vers : Outils système > Utilisateurs et groupes locaux

# Méthode 3 : Depuis PowerShell/CMD
lusrmgr.msc
```

> [!warning] Disponibilité limitée La console `lusrmgr.msc` n'est **pas disponible** sur les éditions Windows Home. Elle est présente uniquement sur les éditions Pro, Enterprise et Education.

### Interface de la console

La console se divise en deux sections principales :

1. **👤 Utilisateurs** : Gestion des comptes utilisateurs locaux
2. **👥 Groupes** : Gestion des groupes locaux

### Gestion des utilisateurs

#### Créer un nouvel utilisateur

1. Clic droit sur **Utilisateurs** → **Nouvel utilisateur**
2. Remplir les champs obligatoires :
    - **Nom d'utilisateur** : identifiant de connexion (pas d'espaces recommandés)
    - **Nom complet** : nom affiché (facultatif)
    - **Description** : informations additionnelles (facultatif)
    - **Mot de passe** : respecter la politique de complexité
    - **Confirmer le mot de passe**

**Options de mot de passe** :

- ☐ L'utilisateur doit changer de mot de passe à la prochaine ouverture de session
- ☐ L'utilisateur ne peut pas changer de mot de passe
- ☐ Le mot de passe n'expire jamais
- ☐ Le compte est désactivé

> [!tip] Bonnes pratiques
> 
> - Cocher "L'utilisateur doit changer de mot de passe..." pour les nouveaux comptes
> - Utiliser "Le mot de passe n'expire jamais" uniquement pour les comptes de service
> - Toujours renseigner une description claire du rôle de l'utilisateur

#### Propriétés d'un utilisateur

Double-clic sur un utilisateur pour accéder aux onglets :

**📌 Onglet Général** :

- Nom complet et description
- Options de mot de passe
- État du compte (activé/désactivé)

**📌 Onglet Membre de** :

- Liste des groupes auxquels appartient l'utilisateur
- Ajouter/Retirer des appartenances

**📌 Onglet Profil** :

- Chemin du profil utilisateur
- Script d'ouverture de session
- Répertoire de base

> [!info] Profils utilisateurs Les profils sont stockés par défaut dans `C:\Users\NomUtilisateur`. Ils contiennent les paramètres personnels, documents, bureau, etc.

#### Actions courantes

**Réinitialiser un mot de passe** :

- Clic droit sur l'utilisateur → **Définir le mot de passe**
- ⚠️ L'utilisateur perdra l'accès aux fichiers chiffrés (EFS) et certificats stockés

**Désactiver un compte** :

- Clic droit → **Propriétés** → Cocher "Le compte est désactivé"
- Ou clic droit → **Désactiver le compte** (Windows 10+)

**Renommer un compte** :

- Clic droit → **Renommer**
- Change le nom d'utilisateur mais conserve le SID et le profil

**Supprimer un compte** :

- Clic droit → **Supprimer**
- ⚠️ Action irréversible : le profil reste mais le SID est perdu

> [!warning] Suppression de compte La suppression d'un compte est définitive. Même si vous recréez un compte avec le même nom, il aura un SID différent et ne pourra pas accéder aux anciennes ressources. Privilégiez la désactivation pour les comptes temporairement inutilisés.

### Informations affichées

La console affiche pour chaque utilisateur :

|Colonne|Description|
|---|---|
|**Nom**|Nom d'utilisateur (login)|
|**Nom complet**|Nom d'affichage|
|**Description**|Rôle ou informations additionnelles|

> [!tip] Filtrage et recherche Utilisez la fonction de recherche (Ctrl+F) pour trouver rapidement un utilisateur dans une liste longue.

### Limitations de la console

- Interface graphique simple mais limitée
- Pas de gestion en masse (multi-sélection limitée)
- Pas de fonctionnalités avancées d'audit
- Pour des tâches complexes ou automatisées, privilégier PowerShell ou les commandes `net`

---

## 🔧 Gestion des groupes locaux

Les **groupes locaux** permettent de gérer collectivement les permissions et droits d'accès pour plusieurs utilisateurs.

### Concept de groupe

Un **groupe** est un conteneur logique qui regroupe des comptes utilisateurs partageant les mêmes besoins d'accès.

**Avantages** :

- Simplification de la gestion des permissions
- Attribution de droits à un groupe plutôt qu'individuellement
- Facilite l'ajout/retrait d'utilisateurs
- Cohérence des accès pour un rôle donné

> [!example] Exemple pratique Au lieu de donner à 10 utilisateurs l'accès individuel à un dossier partagé, on les ajoute au groupe "Comptabilité" et on donne l'accès au groupe. Si un 11ème comptable arrive, on l'ajoute simplement au groupe.

### Types d'appartenances

Un utilisateur peut appartenir à plusieurs groupes simultanément. Ses **permissions effectives** sont la combinaison de toutes les permissions de ses groupes.

**Règle importante** :

- Les permissions **Refuser** sont prioritaires sur **Autoriser**
- Si un groupe refuse un accès, l'utilisateur ne l'aura pas même si un autre groupe l'autorise

### Création d'un groupe local

Via la console `lusrmgr.msc` :

1. Clic droit sur **Groupes** → **Nouveau groupe**
2. Renseigner :
    - **Nom du groupe** : identifiant unique
    - **Description** : rôle et objectif du groupe
3. Cliquer sur **Ajouter** pour insérer des membres
4. Saisir les noms d'utilisateurs séparés par des points-virgules
5. Cliquer sur **Vérifier les noms** pour valider
6. Cliquer sur **Créer**

> [!tip] Convention de nommage Adoptez une convention claire pour nommer vos groupes :
> 
> - Préfixe par fonction : `GRP_Compta`, `GRP_IT`, `GRP_Direction`
> - Ou par accès : `Acces_Serveur_Fichiers`, `Acces_Imprimante_RH`

### Propriétés d'un groupe

Double-clic sur un groupe pour afficher :

**📌 Onglet Général** :

- Nom et description du groupe
- Liste des membres actuels
- Boutons **Ajouter** et **Supprimer** pour gérer les membres

**Actions sur les membres** :

- **Ajouter** : Intégrer des utilisateurs ou autres groupes
- **Supprimer** : Retirer des membres (l'utilisateur n'est pas supprimé)

> [!info] Groupes imbriqués Un groupe peut contenir d'autres groupes (notion de groupe imbriqué). Cela permet une hiérarchie de permissions, mais peut compliquer la compréhension des droits effectifs.

### Gestion des appartenances

**Ajouter un utilisateur à un groupe** :

Méthode 1 - Depuis le groupe :

1. Ouvrir les propriétés du groupe
2. Cliquer sur **Ajouter**
3. Saisir le nom d'utilisateur
4. **Vérifier les noms** → OK

Méthode 2 - Depuis l'utilisateur :

1. Ouvrir les propriétés de l'utilisateur
2. Onglet **Membre de**
3. Cliquer sur **Ajouter**
4. Saisir le nom du groupe

**Retirer un utilisateur d'un groupe** :

1. Ouvrir les propriétés du groupe ou de l'utilisateur
2. Sélectionner l'appartenance à supprimer
3. Cliquer sur **Supprimer**

> [!warning] Groupe principal Chaque utilisateur a un groupe principal (généralement "Utilisateurs"). Ce groupe ne peut pas être retiré tant que l'utilisateur existe. C'est une exigence du système de sécurité Windows.

### Suppression d'un groupe

**Clic droit → Supprimer**

⚠️ **Conséquences** :

- Le groupe est définitivement supprimé (SID perdu)
- Les utilisateurs membres ne sont pas supprimés
- Les permissions basées sur ce groupe sont perdues
- Les ACL (listes de contrôle d'accès) contiennent un SID orphelin

> [!tip] Vérification avant suppression Avant de supprimer un groupe, vérifiez où il est utilisé (partages réseau, permissions de fichiers, stratégies de groupe locales) pour éviter des pertes d'accès inattendues.

### Bonnes pratiques

- **Utiliser des groupes pour toutes les permissions** : Ne jamais attribuer de droits directement à un utilisateur individuel
- **Documenter les groupes** : Renseigner la description avec le rôle et les accès accordés
- **Audit régulier** : Vérifier périodiquement les appartenances aux groupes, surtout les groupes sensibles (Administrateurs)
- **Principe du moindre privilège** : N'ajouter aux groupes que les utilisateurs qui en ont réellement besoin
- **Nettoyer les groupes obsolètes** : Supprimer les groupes qui ne servent plus

---

## 📚 Groupes locaux prédéfinis

Windows crée automatiquement un ensemble de **groupes locaux prédéfinis** lors de l'installation. Ces groupes ont des droits et privilèges spécifiques définis par le système.

### Groupes prédéfinis principaux

#### 👑 Administrateurs (Administrators)

**Privilèges** :

- Contrôle total sur le système
- Tous les droits d'administration
- Accès complet à tous les fichiers et ressources
- Gestion des stratégies de sécurité

**Membres par défaut** :

- Compte Administrateur intégré
- Premier compte créé lors de l'installation
- (Sur un domaine) : groupe Domain Admins

> [!warning] Groupe le plus sensible L'appartenance à ce groupe doit être strictement contrôlée. Un compte compromis avec ces privilèges donne un contrôle total sur la machine.

**Utilisation** :

- Réserver aux administrateurs système uniquement
- Éviter d'utiliser ces comptes pour les tâches quotidiennes
- Auditer régulièrement les membres

#### 👤 Utilisateurs (Users)

**Privilèges** :

- Exécution d'applications
- Utilisation des ressources système de base
- Lecture de la majorité des fichiers système
- Modification de leurs propres paramètres et fichiers

**Restrictions** :

- Ne peuvent pas installer de logiciels système
- Ne peuvent pas modifier les paramètres système critiques
- Ne peuvent pas accéder aux fichiers d'autres utilisateurs

**Membres par défaut** :

- Tous les nouveaux comptes utilisateurs Standard
- Compte Utilisateur authentifié
- (Sur un domaine) : groupe Domain Users

> [!info] Groupe par défaut C'est le groupe le plus commun. La majorité des utilisateurs doivent appartenir uniquement à ce groupe pour leurs activités quotidiennes.

#### 🔧 Opérateurs de sauvegarde (Backup Operators)

**Privilèges spéciaux** :

- Sauvegarder et restaurer des fichiers (même sans permission de lecture)
- Ouverture de session locale sur un contrôleur de domaine
- Arrêt du système

**Utilisation** :

- Comptes de service pour logiciels de sauvegarde
- Personnel IT responsable des backups
- Privilège élevé mais moins risqué qu'Administrateur

> [!tip] Alternative sécurisée Utiliser ce groupe pour les tâches de sauvegarde plutôt que d'attribuer des privilèges administrateur complets.

#### 🖥️ Opérateurs de configuration réseau (Network Configuration Operators)

**Privilèges** :

- Modification des paramètres réseau (TCP/IP, DNS, WINS)
- Configuration des connexions réseau
- Renouvellement et libération des adresses IP

**Utilisation** :

- Support technique réseau niveau 1
- Personnel autorisé à reconfigurer les connexions réseau

#### 🔍 Utilisateurs du journal de performances (Performance Log Users)

**Privilèges** :

- Gestion des compteurs de performances
- Activation des traces de performance
- Collecte de journaux de performance

**Utilisation** :

- Surveillance des performances système
- Outils de diagnostic et monitoring

#### 🖨️ Opérateurs de configuration du système (Power Users) - Obsolète

**Note historique** :

- Groupe hérité de Windows XP/2000
- Privilèges intermédiaires entre Utilisateurs et Administrateurs
- **Déprécié et non recommandé** depuis Windows Vista
- Maintenu pour compatibilité avec les anciennes applications

> [!warning] Ne plus utiliser Microsoft ne recommande plus l'utilisation de ce groupe. Utilisez plutôt le contrôle d'accès granulaire (ACL) pour attribuer des permissions spécifiques.

#### 📡 Utilisateurs de gestion à distance (Remote Management Users)

**Privilèges** :

- Accès WMI via WinRM (Windows Remote Management)
- Administration à distance via PowerShell Remoting

**Utilisation** :

- Scripts d'administration distants
- Outils de gestion centralisée

#### 🖥️ Utilisateurs du Bureau à distance (Remote Desktop Users)

**Privilèges** :

- Connexion au système via le Bureau à distance (RDP)
- Pas de droits administratifs supplémentaires

**Utilisation** :

- Utilisateurs autorisés à se connecter à distance
- Personnel en télétravail

> [!info] Configuration RDP L'appartenance à ce groupe ne suffit pas : le service Bureau à distance doit être activé et le pare-feu configuré (port 3389).

```powershell
# Vérifier si le Bureau à distance est activé
Get-ItemProperty "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections"
```

#### 🔐 Lecteurs du journal des événements (Event Log Readers)

**Privilèges** :

- Lecture des journaux d'événements (sécurité, système, application)
- Pas de modification ou suppression des logs

**Utilisation** :

- Analystes de sécurité
- Personnel d'audit système

#### 🌐 Utilisateurs de COM distribué (Distributed COM Users)

**Privilèges** :

- Lancement et activation d'objets DCOM sur la machine

**Utilisation** :

- Applications distribuées nécessitant DCOM
- Comptes de service pour logiciels utilisant COM+

### Groupes système spéciaux

Certains groupes ne peuvent pas être modifiés manuellement :

#### 🔹 SYSTÈME (SYSTEM)

- Compte système local
- Privilèges maximum (supérieurs à Administrateur)
- Utilisé par le système d'exploitation et les services Windows

#### 🔹 SERVICE RÉSEAU (NETWORK SERVICE)

- Compte de service prédéfini
- Accès réseau avec l'identité de la machine
- Privilèges minimaux sur le système local

#### 🔹 SERVICE LOCAL (LOCAL SERVICE)

- Compte de service prédéfini
- Aucun accès réseau
- Privilèges minimaux sur le système local

> [!info] Comptes de service Ces comptes sont utilisés par Windows pour exécuter des services système avec des privilèges restreints et spécifiques.

### Tableau récapitulatif des groupes prédéfinis

|Groupe|Niveau de privilège|Usage typique|
|---|---|---|
|**Administrateurs**|🔴 Maximum|Administration système complète|
|**Utilisateurs**|🟢 Standard|Utilisation quotidienne normale|
|**Opérateurs de sauvegarde**|🟡 Élevé|Tâches de backup|
|**Opérateurs config réseau**|🟡 Moyen|Gestion réseau|
|**Utilisateurs Bureau à distance**|🟢 Standard + RDP|Connexion distante|
|**Lecteurs journaux**|🟢 Standard + logs|Audit et surveillance|
|**Invités**|🟢 Minimal|Accès temporaire très limité|

### Vérification des appartenances

```powershell
# Lister les membres d'un groupe
net localgroup "Administrateurs"

# Lister tous les groupes locaux
net localgroup

# Vérifier les groupes d'un utilisateur
net user NomUtilisateur | findstr "Appartenances"
```

> [!tip] Audit de sécurité Examinez régulièrement le groupe Administrateurs pour vous assurer qu'aucun compte indésirable n'y a été ajouté. C'est une vérification de sécurité essentielle.

### Bonnes pratiques avec les groupes prédéfinis

1. **Ne jamais supprimer les groupes prédéfinis** : ils sont essentiels au fonctionnement de Windows
2. **Minimiser le groupe Administrateurs** : seulement les comptes vraiment nécessaires
3. **Utiliser les groupes spécialisés** : préférer "Opérateurs de sauvegarde" à "Administrateurs" pour les backups
4. **Documenter les ajouts** : noter pourquoi un utilisateur est ajouté à un groupe sensible
5. **Révision périodique** : auditer les appartenances aux groupes à privilèges élevés

---

## 💻 Commandes net user et net localgroup

Les commandes **`net user`** et **`net localgroup`** sont des outils en ligne de commande pour gérer les utilisateurs et groupes locaux. Elles sont disponibles sur toutes les versions de Windows, y compris Home Edition (contrairement à `lusrmgr.msc`).

### Commande net user

La commande `net user` permet de créer, modifier, afficher et supprimer des comptes utilisateurs locaux.

#### Syntaxe générale

```cmd
net user [NomUtilisateur [MotDePasse | *] [options]] [/DOMAIN]
```

#### Lister tous les utilisateurs

```cmd
net user
```

**Affichage** :

- Liste tous les comptes utilisateurs locaux
- Affichage en colonnes

> [!tip] Alternative PowerShell `Get-LocalUser` offre une sortie plus structurée et plus de détails.

#### Afficher les détails d'un utilisateur

```cmd
net user NomUtilisateur
```

**Informations affichées** :

- Nom d'utilisateur et nom complet
- Commentaire (description)
- Statut du compte (actif/inactif)
- Date d'expiration du compte
- Dernière connexion
- Appartenances aux groupes locaux
- Options de mot de passe
- Répertoire de base et profil

**Exemple de sortie** :

```
Nom d'utilisateur                     jdupont
Nom complet                           Jean Dupont
Commentaire                           Utilisateur standard
Pays/région (indicatif)               000 (Par défaut du système)
Compte actif                          Oui
Compte expire                         Jamais

Dernière connexion                    27/12/2024 10:30:25
Dernière modification mot de passe    15/12/2024 09:15:42
Mot de passe expire                   Jamais
Mot de passe modifiable               27/12/2024 10:30:25
Mot de passe requis                   Oui
Utilisateur peut changer mot de passe Oui

Stations de travail autorisées        Toutes
Script d'accès
Profil utilisateur
Répertoire de base
Dernière connexion                    27/12/2024 10:30:25

Appartenances au groupe local         *Utilisateurs
Appartenances au groupe global        *Aucune
```

#### Créer un nouvel utilisateur

```cmd
net user NomUtilisateur MotDePasse /ADD
```

**Avec options avancées** :

```cmd
net user jdupont P@ssw0rd123 /ADD /FULLNAME:"Jean Dupont" /COMMENT:"Utilisateur du service comptabilité" /PASSWORDCHG:YES
```

**Options principales** :

|Option|Description|Exemple|
|---|---|---|
|`/ADD`|Crée un nouvel utilisateur|Obligatoire pour création|
|`/FULLNAME:"Nom"`|Définit le nom complet|`/FULLNAME:"Jean Dupont"`|
|`/COMMENT:"Texte"`|Ajoute une description|`/COMMENT:"Service RH"`|
|`/PASSWORDCHG:YES`|Utilisateur peut changer son MDP|`/PASSWORDCHG:NO` pour bloquer|
|`/PASSWORDREQ:YES`|Mot de passe obligatoire|`/PASSWORDREQ:NO` (déconseillé)|
|`/ACTIVE:YES`|Active le compte|`/ACTIVE:NO` pour désactiver|
|`/EXPIRES:date`|Date d'expiration du compte|`/EXPIRES:31/12/2024`|

> [!warning] Mot de passe en ligne de commande Spécifier un mot de passe directement dans la commande est **peu sécurisé** car il apparaît dans l'historique. Utilisez `*` à la place pour une saisie interactive :
> 
> ```cmd
> net user jdupont * /ADD
> Tapez un mot de passe pour l'utilisateur :
> Retapez le mot de passe pour confirmer :
> ```

**Créer un utilisateur sans mot de passe** (fortement déconseillé) :

```cmd
net user invite /ADD /PASSWORDREQ:NO
```

#### Modifier un utilisateur existant

**Changer le mot de passe** :

```cmd
net user NomUtilisateur NouveauMotDePasse
```

Ou de manière sécurisée :

```cmd
net user NomUtilisateur *
```

**Désactiver un compte** :

```cmd
net user NomUtilisateur /ACTIVE:NO
```

**Réactiver un compte** :

```cmd
net user NomUtilisateur /ACTIVE:YES
```

**Forcer le changement de mot de passe à la prochaine connexion** :

```cmd
net user NomUtilisateur /LOGONPASSWORDCHG:YES
```

**Définir une expiration de compte** :

```cmd
net user NomUtilisateur /EXPIRES:31/12/2024
```

**Supprimer l'expiration** :

```cmd
net user NomUtilisateur /EXPIRES:NEVER
```

**Modifier le nom complet et la description** :

```cmd
net user NomUtilisateur /FULLNAME:"Nouveau Nom Complet" /COMMENT:"Nouvelle description"
```

> [!tip] Combinaison d'options Vous pouvez combiner plusieurs options dans une seule commande :
> 
> ```cmd
> net user jdupont /ACTIVE:YES /PASSWORDCHG:YES /EXPIRES:NEVER /COMMENT:"Utilisateur actif service compta"
> ```

#### Supprimer un utilisateur

```cmd
net user NomUtilisateur /DELETE
```

> [!warning] Suppression irréversible Cette action supprime définitivement le compte. Le profil utilisateur reste dans `C:\Users\` mais le SID est perdu. Les permissions basées sur ce compte seront orphelines.

**Vérification avant suppression** :

```cmd
net user NomUtilisateur
# Vérifier les informations avant de confirmer la suppression
net user NomUtilisateur /DELETE
```

#### Options avancées de mot de passe

**Mot de passe n'expire jamais** :

```cmd
net user NomUtilisateur /EXPIRES:NEVER
```

**Empêcher l'utilisateur de changer son mot de passe** :

```cmd
net user NomUtilisateur /PASSWORDCHG:NO
```

**Définir des heures d'accès** :

```cmd
net user NomUtilisateur /TIMES:Monday-Friday,08:00-18:00
```

**Autoriser l'accès à tout moment** :

```cmd
net user NomUtilisateur /TIMES:ALL
```

**Interdire complètement l'accès** :

```cmd
net user NomUtilisateur /TIMES:""
```

> [!example] Exemple pratique : Compte de service
> 
> ```cmd
> net user SvcBackup * /ADD /FULLNAME:"Service Backup" /COMMENT:"Compte service sauvegarde" /PASSWORDCHG:NO /EXPIRES:NEVER /ACTIVE:YES
> ```

---

### Commande net localgroup

La commande `net localgroup` permet de créer, modifier, afficher et supprimer des groupes locaux, ainsi que de gérer leurs membres.

#### Syntaxe générale

```cmd
net localgroup [NomGroupe [/ADD | /DELETE] [/COMMENT:"Texte"]]
net localgroup NomGroupe NomUtilisateur [...] {/ADD | /DELETE}
```

#### Lister tous les groupes locaux

```cmd
net localgroup
```

**Affichage** :

- Liste de tous les groupes locaux
- Inclut les groupes prédéfinis et personnalisés

#### Afficher les membres d'un groupe

```cmd
net localgroup NomGroupe
```

**Exemple** :

```cmd
net localgroup Administrateurs
```

**Sortie** :

```
Nom de groupe     Administrateurs
Commentaire       Les membres du groupe Administrateurs disposent d'un accès complet et illimité à l'ordinateur/au domaine

Membres

-------------------------------------------------------------------------------
Administrateur
DESKTOP-ABC\jmartin
La commande s'est terminée correctement.
```

> [!tip] Groupes sensibles à vérifier
> 
> ```cmd
> net localgroup Administrateurs
> net localgroup "Utilisateurs du Bureau à distance"
> net localgroup "Opérateurs de sauvegarde"
> ```

#### Créer un nouveau groupe

```cmd
net localgroup NomGroupe /ADD
```

**Avec commentaire** :

```cmd
net localgroup "Comptabilite" /ADD /COMMENT:"Groupe pour le service comptabilité"
```

> [!info] Noms avec espaces Si le nom du groupe contient des espaces, utilisez des guillemets :
> 
> ```cmd
> net localgroup "Service RH" /ADD
> ```

#### Supprimer un groupe

```cmd
net localgroup NomGroupe /DELETE
```

**Exemple** :

```cmd
net localgroup "Ancien_Projet" /DELETE
```

> [!warning] Suppression définitive La suppression d'un groupe est irréversible. Le SID du groupe est perdu et toutes les permissions basées sur ce groupe deviennent orphelines.

#### Ajouter un utilisateur à un groupe

```cmd
net localgroup NomGroupe NomUtilisateur /ADD
```

**Exemples** :

```cmd
# Ajouter un utilisateur au groupe Administrateurs
net localgroup Administrateurs jdupont /ADD

# Ajouter un utilisateur à un groupe personnalisé
net localgroup Comptabilite jdupont /ADD

# Ajouter un utilisateur au groupe Bureau à distance
net localgroup "Utilisateurs du Bureau à distance" jdupont /ADD
```

**Ajouter plusieurs utilisateurs en une commande** :

```cmd
net localgroup Comptabilite jdupont mdurand aleblanc /ADD
```

#### Retirer un utilisateur d'un groupe

```cmd
net localgroup NomGroupe NomUtilisateur /DELETE
```

**Exemples** :

```cmd
# Retirer un utilisateur du groupe Administrateurs
net localgroup Administrateurs jdupont /DELETE

# Retirer d'un groupe personnalisé
net localgroup Comptabilite jdupont /DELETE
```

> [!warning] Groupe Utilisateurs Vous ne pouvez pas retirer un utilisateur du groupe "Utilisateurs" car c'est son groupe principal obligatoire.

#### Ajouter un groupe à un autre groupe (imbrication)

```cmd
net localgroup GroupeParent GroupeEnfant /ADD
```

**Exemple** :

```cmd
# Créer une hiérarchie de groupes
net localgroup "IT_Full_Access" "IT_Admins" /ADD
net localgroup "IT_Admins" "IT_Support" /ADD
```

> [!info] Groupes imbriqués Les groupes imbriqués héritent des permissions du groupe parent. Cela permet une gestion hiérarchique mais peut compliquer l'audit des permissions.

---

### Exemples pratiques et cas d'usage

#### Scénario 1 : Créer un nouvel employé

```cmd
# 1. Créer l'utilisateur
net user mleblanc * /ADD /FULLNAME:"Marie Leblanc" /COMMENT:"Service Marketing" /PASSWORDCHG:YES

# 2. Ajouter aux groupes appropriés
net localgroup "Utilisateurs du Bureau à distance" mleblanc /ADD
net localgroup "Marketing" mleblanc /ADD

# 3. Vérifier la création
net user mleblanc
```

#### Scénario 2 : Gestion d'un départ d'employé

```cmd
# 1. Désactiver le compte immédiatement
net user ancien_employe /ACTIVE:NO

# 2. Vérifier les appartenances aux groupes
net user ancien_employe | findstr "Appartenances"

# 3. Retirer des groupes sensibles
net localgroup Administrateurs ancien_employe /DELETE
net localgroup "Utilisateurs du Bureau à distance" ancien_employe /DELETE

# 4. Après archivage des données, supprimer le compte
net user ancien_employe /DELETE
```

#### Scénario 3 : Audit de sécurité

```cmd
# Vérifier qui sont les administrateurs
net localgroup Administrateurs

# Vérifier qui peut se connecter à distance
net localgroup "Utilisateurs du Bureau à distance"

# Vérifier les comptes actifs
net user | findstr /V "Compte désactivé"

# Lister les détails de tous les utilisateurs (PowerShell)
Get-LocalUser | Format-Table Name, Enabled, LastLogon
```

#### Scénario 4 : Création d'un compte de service

```cmd
# Créer un compte de service avec options spécifiques
net user SvcMonitoring * /ADD /FULLNAME:"Service Monitoring" /COMMENT:"Compte service pour monitoring système" /PASSWORDCHG:NO /EXPIRES:NEVER /ACTIVE:YES

# Ajouter aux groupes nécessaires
net localgroup "Utilisateurs du journal de performances" SvcMonitoring /ADD
net localgroup "Lecteurs du journal des événements" SvcMonitoring /ADD

# Vérifier
net user SvcMonitoring
```

#### Scénario 5 : Gestion de projet temporaire

```cmd
# Créer un groupe projet
net localgroup "Projet_X" /ADD /COMMENT:"Équipe projet X - expire 31/12/2024"

# Ajouter les membres
net localgroup "Projet_X" user1 user2 user3 /ADD

# À la fin du projet, supprimer le groupe
net localgroup "Projet_X" /DELETE
```

---

### Comparaison net user vs PowerShell

|Tâche|net user|PowerShell|
|---|---|---|
|Créer utilisateur|`net user nom * /ADD`|`New-LocalUser -Name "nom"`|
|Lister utilisateurs|`net user`|`Get-LocalUser`|
|Modifier MDP|`net user nom *`|`Set-LocalUser -Name "nom" -Password (Read-Host -AsSecureString)`|
|Désactiver compte|`net user nom /ACTIVE:NO`|`Disable-LocalUser -Name "nom"`|
|Supprimer utilisateur|`net user nom /DELETE`|`Remove-LocalUser -Name "nom"`|
|Lister groupes|`net localgroup`|`Get-LocalGroup`|
|Membres d'un groupe|`net localgroup nom`|`Get-LocalGroupMember -Group "nom"`|
|Ajouter à un groupe|`net localgroup grp user /ADD`|`Add-LocalGroupMember -Group "grp" -Member "user"`|

> [!tip] Quand utiliser quoi ?
> 
> - **net user/localgroup** : Scripts batch (.bat), compatibilité maximale, syntaxe simple
> - **PowerShell** : Automatisation avancée, meilleure gestion d'erreurs, sortie structurée, pipelines

---

### Scripts d'automatisation

#### Script Batch : Création d'utilisateurs en masse

```batch
@echo off
REM Script de création d'utilisateurs en masse

echo Création des utilisateurs...

net user user1 * /ADD /FULLNAME:"Utilisateur 1" /COMMENT:"Service IT" /PASSWORDCHG:YES
net user user2 * /ADD /FULLNAME:"Utilisateur 2" /COMMENT:"Service IT" /PASSWORDCHG:YES
net user user3 * /ADD /FULLNAME:"Utilisateur 3" /COMMENT:"Service IT" /PASSWORDCHG:YES

echo Ajout aux groupes...
net localgroup "Utilisateurs du Bureau à distance" user1 /ADD
net localgroup "Utilisateurs du Bureau à distance" user2 /ADD
net localgroup "Utilisateurs du Bureau à distance" user3 /ADD

echo Terminé !
pause
```

#### Script PowerShell : Audit des comptes administrateurs

```powershell
# Script d'audit des administrateurs locaux
Write-Host "=== Audit des Administrateurs Locaux ===" -ForegroundColor Cyan
Write-Host ""

# Récupérer les membres du groupe Administrateurs
$admins = net localgroup Administrateurs | Select-Object -Skip 6 | Select-Object -SkipLast 2

Write-Host "Membres du groupe Administrateurs :" -ForegroundColor Yellow
foreach ($admin in $admins) {
    if ($admin -ne "") {
        Write-Host "  - $admin"
    }
}

Write-Host ""
Write-Host "Vérifiez que tous ces comptes sont légitimes." -ForegroundColor Green
```

#### Script PowerShell : Rapport des dernières connexions

```powershell
# Rapport des dernières connexions utilisateurs
$users = Get-LocalUser | Where-Object {$_.Enabled -eq $true}

Write-Host "=== Rapport des dernières connexions ===" -ForegroundColor Cyan
Write-Host ""

foreach ($user in $users) {
    $lastLogon = $user.LastLogon
    if ($null -eq $lastLogon) {
        $lastLogon = "Jamais connecté"
    }
    
    Write-Host "$($user.Name) - Dernière connexion : $lastLogon"
}
```

---

### Codes de retour et gestion d'erreurs

Les commandes `net user` et `net localgroup` retournent des codes d'erreur :

|Code|Signification|
|---|---|
|`0`|Succès|
|`2`|Utilisateur/groupe non trouvé|
|`3`|Erreur de syntaxe|
|`5`|Accès refusé (privilèges insuffisants)|
|`8`|Mémoire insuffisante|
|`2224`|L'utilisateur existe déjà|
|`2245`|Mot de passe ne respecte pas la politique|

**Vérification du code de retour (Batch)** :

```batch
net user testuser * /ADD
if %errorlevel% equ 0 (
    echo Utilisateur créé avec succès
) else (
    echo Erreur lors de la création : %errorlevel%
)
```

**Vérification (PowerShell)** :

```powershell
$result = net user testuser * /ADD 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "Succès" -ForegroundColor Green
} else {
    Write-Host "Échec : $LASTEXITCODE" -ForegroundColor Red
}
```

---

### Pièges courants et solutions

#### Piège 1 : Mot de passe dans l'historique

**❌ Mauvaise pratique** :

```cmd
net user jdupont MonMotDePasse123 /ADD
```

**✅ Bonne pratique** :

```cmd
net user jdupont * /ADD
```

#### Piège 2 : Noms avec espaces sans guillemets

**❌ Erreur** :

```cmd
net localgroup Utilisateurs du Bureau à distance jdupont /ADD
# Erreur de syntaxe
```

**✅ Correct** :

```cmd
net localgroup "Utilisateurs du Bureau à distance" jdupont /ADD
```

#### Piège 3 : Suppression accidentelle sans vérification

**❌ Dangereux** :

```cmd
net user important_user /DELETE
```

**✅ Sécurisé** :

```cmd
# Vérifier d'abord
net user important_user
# Demander confirmation
echo Êtes-vous sûr de vouloir supprimer cet utilisateur ? (Ctrl+C pour annuler)
pause
net user important_user /DELETE
```

#### Piège 4 : Oublier les privilèges administrateur

Les commandes `net user` et `net localgroup` nécessitent des **privilèges administrateur**.

**Solution** :

- Ouvrir CMD ou PowerShell en tant qu'administrateur
- Clic droit sur l'icône → "Exécuter en tant qu'administrateur"
- Ou via UAC avec `runas`

```cmd
runas /user:Administrateur "cmd.exe"
```

#### Piège 5 : Modifier le mauvais utilisateur

**✅ Toujours vérifier avant modification** :

```cmd
# Afficher les détails avant modification
net user nom_utilisateur
# Confirmer que c'est le bon utilisateur
pause
# Puis effectuer la modification
net user nom_utilisateur /ACTIVE:NO
```

---

### Astuces avancées

#### Astuce 1 : Filtrer les sorties avec findstr

```cmd
# Trouver un utilisateur spécifique
net user | findstr "jdupont"

# Voir uniquement les groupes d'un utilisateur
net user jdupont | findstr "Appartenances"

# Lister les comptes actifs
net user | findstr /V "désactivé"
```

#### Astuce 2 : Rediriger vers un fichier pour audit

```cmd
# Exporter la liste des administrateurs
net localgroup Administrateurs > C:\Audit\admins.txt

# Exporter tous les utilisateurs avec détails
for /F "tokens=*" %u in ('net user ^| findstr /V "Commande"') do net user %u >> C:\Audit\users_details.txt
```

#### Astuce 3 : Combiner avec d'autres commandes

```cmd
# Créer un utilisateur et l'ajouter immédiatement à un groupe
net user newuser * /ADD && net localgroup "Utilisateurs du Bureau à distance" newuser /ADD

# Désactiver et retirer des groupes sensibles
net user olduser /ACTIVE:NO && net localgroup Administrateurs olduser /DELETE
```

#### Astuce 4 : Vérification rapide de la sécurité

```cmd
# Script de vérification rapide
@echo off
echo === Vérification de sécurité ===
echo.
echo Administrateurs locaux :
net localgroup Administrateurs
echo.
echo Utilisateurs Bureau à distance :
net localgroup "Utilisateurs du Bureau à distance"
echo.
echo Comptes avec mot de passe non requis :
net user | findstr /V "Mot de passe requis  Oui"
```

---

## 🎯 Résumé des commandes essentielles

### Gestion des utilisateurs

```cmd
# Lister
net user

# Détails
net user NomUtilisateur

# Créer
net user NomUtilisateur * /ADD /FULLNAME:"Nom Complet" /COMMENT:"Description"

# Modifier mot de passe
net user NomUtilisateur *

# Désactiver
net user NomUtilisateur /ACTIVE:NO

# Activer
net user NomUtilisateur /ACTIVE:YES

# Supprimer
net user NomUtilisateur /DELETE
```

### Gestion des groupes

```cmd
# Lister
net localgroup

# Membres d'un groupe
net localgroup NomGroupe

# Créer un groupe
net localgroup NomGroupe /ADD /COMMENT:"Description"

# Ajouter un membre
net localgroup NomGroupe NomUtilisateur /ADD

# Retirer un membre
net localgroup NomGroupe NomUtilisateur /DELETE

# Supprimer un groupe
net localgroup NomGroupe /DELETE
```

### Vérifications de sécurité

```cmd
# Qui sont les administrateurs ?
net localgroup Administrateurs

# Qui peut se connecter à distance ?
net localgroup "Utilisateurs du Bureau à distance"

# Détails d'un utilisateur spécifique
net user NomUtilisateur
```

---

## ✅ Points clés à retenir

> [!important] Concepts fondamentaux
> 
> - **Comptes locaux** : stockés sur la machine, aucune synchronisation
> - **Comptes Microsoft** : synchronisation cloud, nécessitent Internet
> - **Types de comptes** : Administrateur (contrôle total) vs Standard (limité)
> - **UAC** : protection essentielle contre les modifications non autorisées
> - **Groupes** : gestion collective des permissions, simplifie l'administration

> [!warning] Sécurité critique
> 
> - Ne jamais utiliser un compte administrateur pour les tâches quotidiennes
> - Ne jamais désactiver l'UAC
> - Auditer régulièrement le groupe Administrateurs
> - Appliquer le principe du moindre privilège
> - Utiliser des mots de passe complexes et uniques

> [!tip] Bonnes pratiques
> 
> - Utiliser la console `lusrmgr.msc` pour la gestion graphique (Pro+)
> - Utiliser `net user`/`net localgroup` pour l'automatisation
> - Documenter les appartenances aux groupes
> - Privilégier les groupes prédéfinis quand possible
> - Désactiver plutôt que supprimer les comptes utilisateurs

---

_Cours d'administration Windows - Gestion des utilisateurs et groupes locaux_