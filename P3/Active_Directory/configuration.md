# Configuration Active Directory – billu.lan

# Sommaire

1. [Structure organisationnelle (OU)](#1-structure-organisationnelle-ou)
   - [1.1 Arborescence des OU](#11-arborescence-des-ou)
      - [1.1.1 Sous-OU de BilluComputers](#111-sous-ou-de-billucomputers)
      - [1.1.2 Sous-OU de BilluUsers](#112-sous-ou-de-billuusers)
   - [1.2 Création des OU](#12-création-des-ou)
   - [1.3 Création des sous-OU](#13-création-des-sous-ou)
      - [1.3.1 Sous-OU de BilluComputers](#131-sous-ou-de-billucomputers)
      - [1.3.2 Sous-OU de BilluUsers](#132-sous-ou-de-billuusers)

2. [Création des utilisateurs](#2-création-des-utilisateurs)
   - [2.1 Préparation du fichier CSV](#21-préparation-du-fichier-csv)
   - [2.2 Configuration du script](#22-configuration-du-script)
   - [2.3 Exécution du script](#23-exécution-du-script)
   - [2.4 Vérification](#24-vérification)
   - [2.5 Synchronisation et modification des utilisateurs](#25-synchronisation-et-modification-des-utilisateurs)
      - [2.5.1 Préparation du fichier CSV](#251-préparation-du-fichier-csv)
      - [2.5.2 Configuration du script](#252-configuration-du-script)
      - [2.5.3 Exécution du script](#253-exécution-du-script)
      - [2.5.4 Vérification](#254-vérification)
   - [2.6 Féminisation des postes](#26-féminisation-des-postes)
      - [2.6.1 Configuration du script](#261-configuration-du-script)
      - [2.6.2 Exécution du script](#262-exécution-du-script)
      - [2.6.3 Vérification](#263-vérification)

3. [Déplacement automatique des objets AD](#3.déplacement-automatique-des-objets-ad)
    - [3.1 Explication du script](#31-explication-du-script)
    - [3.2 Automatisation par AT](#32-automatisation-par-at)

4. [Création des groupes](#4-création-des-groupes)
   - [4.1 Arborescence des groupes de sécurité](#41-arborescence-des-groupes-de-sécurité)
   - [4.2 Création d'un groupe](#42-création-dun-groupe)
   - [4.3 Liste des groupes à créer](#43-liste-des-groupes-à-créer)

5. [Stratégies de groupe (GPO)](#5-stratégies-de-groupe-gpo)
   - [5.1 Création de GPO](#51-création-de-gpo)
   - [5.2 GPO de sécurité](#52-gpo-de-sécurité)
   - [5.3 GPO standard](#53-gpo-standard)

6. [Tâche planifiée – Restriction des horaires de connexion](#6-tâche-planifiée--restriction-des-horaires-de-connexion)

7. [Jonction au domaine](#7-jonction-au-domaine)

8. [Transfert des rôles FSMO (PDC et RID)](#8-transfert-des-rôles-fsmo-pdc-et-rid)
   - [8.1 Prérequis et ajout du serveur](#81-prérequis-et-ajout-du-serveur)
   - [8.2 Installation d'Active Directory sur le serveur Core](#82-installation-dactive-directory-sur-le-serveur-core)
   - [8.3 Promotion en contrôleur de domaine](#83-promotion-en-contrôleur-de-domaine)
   - [8.4 Attribution des rôles FSMO](#84-attribution-des-rôles-fsmo)
   - [8.5 Configuration NTP sur le PDC Emulator](#85-configuration-ntp-sur-le-pdc-emulator)
   - [8.6 Vérification](#86-vérification)

9. [Relation de confiance avec Ecotech](#9-relation-de-confiance-avec-ecotech)

---

## 1. Structure organisationnelle (OU)

L'arborescence des Unités d'Organisation (OU) du domaine billu.lan a été conçue selon une approche fonctionnelle. La structure repose sur trois **OU** principales permettant une séparation claire des objets Active Directory par type et fonction.

### 1.1 Arborescence des OU

| OU                 | Chemin DN                         | Objets contenus                                                  |
| ------------------ | --------------------------------- | ---------------------------------------------------------------- |
| **BilluComputers** | OU=BilluComputers,DC=billu,DC=lan | Comptes ordinateurs (workstations, laptops, serveurs membres)    |
| **BilluUsers**     | OU=BilluUsers,DC=billu,DC=lan     | Comptes utilisateurs (tous services confondus)                   |
| **BilluSecurity**  | OU=BilluSecurity,DC=billu,DC=lan  | Groupes de sécurité, groupes de distribution, comptes de service |

#### 1.1.1 Sous-OU de BilluComputers

| Sous-OU           | Chemin DN                                          | Service                                |
| ----------------- | -------------------------------------------------- | -------------------------------------- |
| **DEV**           | OU=DEV,OU=BilluComputers,DC=billu,DC=lan           | Développement                          |
| **COMMERCIAL**    | OU=COMMERCIAL,OU=BilluComputers,DC=billu,DC=lan    | Commercial                             |
| **COMMUNICATION** | OU=COMMUNICATION,OU=BilluComputers,DC=billu,DC=lan | Communication                          |
| **JURIDIQUE**     | OU=JURIDIQUE,OU=BilluComputers,DC=billu,DC=lan     | Juridique                              |
| **DIRECTION**     | OU=DIRECTION,OU=BilluComputers,DC=billu,DC=lan     | Direction                              |
| **COMPTABILITE**  | OU=COMPTABILITE,OU=BilluComputers,DC=billu,DC=lan  | Comptabilité                           |
| **QHSE**          | OU=QHSE,OU=BilluComputers,DC=billu,DC=lan          | Qualité Hygiène Sécurité Environnement |
| **RH**            | OU=RH,OU=BilluComputers,DC=billu,DC=lan            | Ressources Humaines                    |
| **DSI**           | OU=DSI,OU=BilluComputers,DC=billu,DC=lan           | Direction des Systèmes d'Information   |

#### 1.1.2 Sous-OU de BilluUsers

| Sous-OU           | Chemin DN                                      | Service                                |
| ----------------- | ---------------------------------------------- | -------------------------------------- |
| **DEV**           | OU=DEV,OU=BilluUsers,DC=billu,DC=lan           | Développement                          |
| **COMMERCIAL**    | OU=COMMERCIAL,OU=BilluUsers,DC=billu,DC=lan    | Commercial                             |
| **COMMUNICATION** | OU=COMMUNICATION,OU=BilluUsers,DC=billu,DC=lan | Communication                          |
| **JURIDIQUE**     | OU=JURIDIQUE,OU=BilluUsers,DC=billu,DC=lan     | Juridique                              |
| **DIRECTION**     | OU=DIRECTION,OU=BilluUsers,DC=billu,DC=lan     | Direction                              |
| **COMPTABILITE**  | OU=COMPTABILITE,OU=BilluUsers,DC=billu,DC=lan  | Comptabilité                           |
| **QHSE**          | OU=QHSE,OU=BilluUsers,DC=billu,DC=lan          | Qualité Hygiène Sécurité Environnement |
| **RH**            | OU=RH,OU=BilluUsers,DC=billu,DC=lan            | Ressources Humaines                    |
| **DSI**           | OU=DSI,OU=BilluUsers,DC=billu,DC=lan           | Direction des Systèmes d'Information   |

### 1.2 Création des OU

Dans le Server Manager ==> Dashboard :
- Cliquer sur **"Tools"** et **"Active Directory Users and Computers"**

![image01](Ressources/Screenshots-Installation/01_creation_ou.png)

- Dans le volet de gauche, clic droit sur **"billu.lan"**
- Sélectionner **"New"** ==> **"Organizational Unit"**

![image02](Ressources/Screenshots-Installation/02_creation_ou.png)

Dans la fenêtre qui s'ouvre :
- Case **"Name"** : **"BilluComputers"**
- Cocher **"Protect container from accidental deletion"**
- Cliquer sur **"OK"**

![image03](Ressources/Screenshots-Installation/03_creation_ou.png)

**"OU"** BilluComputers a été créé.

Même procédure pour les autres **"OU"** :
- Case **"Name"** : **"BilluUsers"**
- Case **"Name"** : **"BilluSecurity"**

![image04](Ressources/Screenshots-Installation/04_creation_ou.png)

Voilà nos **"OU"** créées dans la forêt de **"billu.lan"**.

### 1.3 Création des sous-OU

#### 1.3.1 Sous-OU de BilluComputers

- Dans le volet de gauche, clic droit sur **"BilluComputers"**
- Sélectionner **"New"** ==> **"Organizational Unit"**

![image01](Ressources/Screenshots-Installation/01-sous_ou_billucomputers.png)

Dans la fenêtre qui s'ouvre :
- Case **"Name"** : **"DEV"**
- Cocher **"Protect container from accidental deletion"**
- Cliquer sur **"OK"**

![image02](Ressources/Screenshots-Installation/2-sous_ou_billucomputers.png)

La **"SOUS-OU"** **"DEV"** a été créée dans l'**"OU"** BilluComputers.

Même procédure pour les autres **"SOUS-OU"** :
- Case **"Name"** : **"COMMERCIAL"**
- Case **"Name"** : **"COMMUNICATION"**
- Case **"Name"** : **"JURIDIQUE"**
- Case **"Name"** : **"DIRECTION"**
- Case **"Name"** : **"COMPTABILITE"**
- Case **"Name"** : **"QHSE"**
- Case **"Name"** : **"RH"**
- Case **"Name"** : **"DSI"**

![image03](Ressources/Screenshots-Installation/03-sous_ou_billucomputers.png)

Voilà nos **"SOUS-OU"** créées dans l'**"OU"** **"BilluComputers"**.

#### 1.3.2 Sous-OU de BilluUsers

- Dans le volet de gauche, clic droit sur **"BilluUsers"**
- Sélectionner **"New"** ==> **"Organizational Unit"**

![image01](Ressources/Screenshots-Installation/01-sous_ou_billuUsers.png)

Dans la fenêtre qui s'ouvre :
- Case **"Name"** : **"COMMERCIAL"**
- Cocher **"Protect container from accidental deletion"**
- Cliquer sur **"OK"**

![image02](Ressources/Screenshots-Installation/02-sous_ou_billuUsers.png)

La **"SOUS-OU"** **"COMMERCIAL"** a été créée dans l'**"OU"** BilluUsers.

Même procédure pour les autres **"SOUS-OU"** :
- Case **"Name"** : **"COMMUNICATION"**
- Case **"Name"** : **"COMPTABILITE"**
- Case **"Name"** : **"DEV"**
- Case **"Name"** : **"DIRECTION"**
- Case **"Name"** : **"DSI"**
- Case **"Name"** : **"JURIDIQUE"**
- Case **"Name"** : **"QHSE"**
- Case **"Name"** : **"RH"**

![image03](Ressources/Screenshots-Installation/03-sous_ou_billuUsers.png)

Voilà nos **"SOUS-OU"** créées dans l'**"OU"** **"BilluUsers"**.

---

## 2. Création des utilisateurs

La création des utilisateurs est automatisée via un script PowerShell qui importe les données depuis un fichier CSV.

### 2.1 Préparation du fichier CSV

Le fichier CSV doit respecter le format suivant :
- **Délimiteur** : point-virgule ( ; )
- **Encodage** : UTF-8

**Exemple de structure :**

```csv
Prenom;Nom;Departement;Service;fonction;Societe;Telephone fixe;Telephone portable;Manager-Prenom;Manager-Nom
Jean;Dupont;Service Commercial;ADV;Responsable ADV;BillU;01 23 45 67 89;06 12 34 56 78;Marie;Martin
Sophie;Lefebvre;DSI;Support;Technicien Support;BillU;01 23 45 67 90;;Jean;Dupont
```

**Colonnes du fichier CSV :**

| Colonne | Description | Obligatoire |
|---------|-------------|-------------|
| Prenom | Prénom de l'utilisateur | Oui |
| Nom | Nom de famille | Oui |
| Departement | Département (doit correspondre au mapping) | Oui |
| Service | Service dans le département | Oui |
| fonction | Poste/fonction | Oui |
| Societe | Nom de la société | Oui |
| Telephone fixe | Numéro de téléphone fixe | Non |
| Telephone portable | Numéro de téléphone portable | Non |
| Manager-Prenom | Prénom du manager | Non |
| Manager-Nom | Nom du manager | Non |

### 2.2 Configuration du script

Modifier les variables suivantes au début du script selon votre environnement :

```powershell
$SourceCSV = "\\DOM-FS-01\departements\DSI\scripts\s01_BillU.csv"    # Chemin du fichier CSV
$DomainDN = "DC=billU,DC=lan"              # DN du domaine
$DomainName = "@billU.lan"                  # Suffixe email
$DefaultPassword = "Azerty1*"               # Mot de passe par défaut
```

**Mapping des départements et services :**

Le script utilise des tables de correspondance pour mapper les noms vers les OU. Si un nouveau département ou service est ajouté, il doit être référencé dans les hashtables `$DepartementMapping` et `$ServiceMapping` du script.

### 2.3 Exécution du script

1. Ouvrir **PowerShell en tant qu'administrateur**
2. Se placer dans le répertoire du script :

```powershell
cd C:\
```

3. Exécuter le script :

```powershell
.\Create-ADUsers.ps1
```

**Fonctionnement du script :**

Le script effectue automatiquement les actions suivantes :
- Génération du **SamAccountName** : `prenom.nom` (minuscules, sans accents, max 20 caractères)
- Génération de l'**UPN** : `prenom.nom@billU.lan`
- Placement de l'utilisateur dans la **bonne OU** selon son département et service
- Attribution du **mot de passe par défaut** (changement obligatoire à la première connexion)
- Attribution du **manager** si renseigné dans le CSV (en 2e passe)

### 2.4 Vérification

**Via l'interface graphique :**
1. Ouvrir **Active Directory Users and Computers**
2. Naviguer vers `billu.lan > BilluUsers`
3. Vérifier que les utilisateurs sont placés dans les bonnes OU

---

## 2.5 Synchronisation et modification des utilisateurs

Lors d'une mise à jour du fichier RH (arrivées, départs, changements de service), la synchronisation des comptes Active Directory est automatisée via le script `modifUsersAD.ps1`. Ce script compare le fichier CSV fourni par les RH avec les comptes existants dans l'AD et applique les modifications nécessaires.

**Le script gère trois cas :**

| Cas | Action |
|-----|--------|
| Utilisateur présent dans le CSV et dans l'AD | Mise à jour des attributs (département, service, fonction, téléphones) et déplacement dans la bonne OU si nécessaire |
| Utilisateur présent dans le CSV mais absent de l'AD | Création du compte avec placement dans la bonne OU |
| Utilisateur présent dans l'AD mais absent du CSV | Désactivation du compte et déplacement vers `OU=UsersDeactived` |

### 2.5.1 Préparation du fichier CSV

Le fichier CSV de synchronisation doit respecter le format suivant :
- **Délimiteur** : virgule ( , )
- **Encodage** : UTF-8

**Colonnes du fichier CSV :**

| Colonne | Description | Obligatoire |
|---------|-------------|-------------|
| Civilité | Civilité de l'utilisateur (M. ou Mme) | Oui |
| Prenom | Prénom de l'utilisateur | Oui |
| Nom | Nom de famille | Oui |
| Departement | Département (doit correspondre au mapping) | Oui |
| Service | Service dans le département | Oui |
| fonction | Poste/fonction | Oui |
| Societe | Nom de la société | Oui |
| Telephone fixe | Numéro de téléphone fixe (peut être vide ou `-`) | Non |
| Telephone portable | Numéro de téléphone portable | Non |
| Manager-Prenom | Prénom du manager | Non |
| Manager-Nom | Nom du manager | Non |

> **Note :** Les champs téléphone peuvent contenir un tiret `-` pour indiquer l'absence de numéro. Le script gère ce cas automatiquement.

### 2.5.2 Configuration du script

Modifier les variables suivantes au début du script selon votre environnement :

```powershell
$SourceCSV       = "C:\Users\Administrator\Documents\s04-a02-BillU-ListeRHCollaborateurs.csv"
$DomainDN        = "DC=billu,DC=lan"
$DomainName      = "@billu.lan"
$DefaultPassword = "Azerty1*"
```

**Points importants :**

- Le script utilise deux méthodes de recherche AD pour gérer les noms avec caractères spéciaux (apostrophes, tirets) : `LDAPFilter` en priorité, puis `Where-Object`.
- Si un nouveau département ou service apparaît dans le CSV, il doit être ajouté dans les hashtables `$DepartementMapping` et `$ServiceMapping` du script.
- Les comptes désactivés sont déplacés vers `OU=UsersDeactived,DC=billu,DC=lan`.

### 2.5.3 Exécution du script

1. Ouvrir **PowerShell en tant qu'administrateur**
2. Exécuter le script :

```powershell
.\modifUsersAD.ps1
```

**Le script affiche en temps réel :**

| Indicateur | Couleur | Signification |
|------------|---------|---------------|
| `[MAJ]` | Cyan | Compte mis à jour |
| `[CRÉÉ]` | Vert | Nouveau compte créé |
| `[DÉPLACÉ]` | Magenta | Compte déplacé vers une nouvelle OU |
| `[DÉSACTIVÉ]` | Jaune | Compte désactivé et déplacé vers UsersDeactived |
| `[DOUBLON]` | Magenta | Plusieurs comptes trouvés, utilisation du compte actif |
| `[ERREUR]` | Rouge | Erreur lors du traitement |

**À la fin de l'exécution, un résumé est affiché :**

```
Utilisateurs traités       : 220
Utilisateurs créés         : 8
Utilisateurs mis à jour    : 207
Utilisateurs désactivés    : 10
Utilisateurs ignorés       : 0
Erreurs manager            : 0
```

### 2.5.4 Vérification

**Via l'interface graphique :**
1. Ouvrir **Active Directory Users and Computers**
2. Naviguer vers `billu.lan > BilluUsers`
3. Vérifier que les utilisateurs sont placés dans les bonnes OU
4. Naviguer vers `billu.lan > UsersDeactived` pour vérifier les comptes désactivés

---

## 2.6 Féminisation des postes

Suite à une demande RH, les intitulés de poste des collaboratrices (Mme) doivent être mis à jour avec leur forme féminine dans l'Active Directory. Cette opération est automatisée via le script `feminisationPosteAD.ps1`.

Le script lit le fichier CSV RH, filtre les utilisatrices identifiées par la civilité `Mme`, et met à jour l'attribut `Title` de leur compte AD avec la forme féminine correspondante définie dans une table de mapping.

**Le script gère trois cas :**

| Cas | Indicateur | Action |
|-----|------------|--------|
| Titre à féminiser | `[MAJ]` | Mise à jour du Title dans l'AD |
| Titre déjà féminisé | `[DÉJÀ OK]` | Aucune modification |
| Fonction absente du mapping | `[MAPPING MANQUANT]` | Signalement dans le résumé |

### 2.6.1 Configuration du script

Modifier les variables suivantes au début du script :

```powershell
$SourceCSV = "C:\Users\Administrator\Documents\s04-a02-BillU-ListeRHCollaborateurs.csv"
$DomainDN  = "DC=billu,DC=lan"
```

**Extrait de la table de féminisation :**

```powershell
$FeminisationMapping = @{
    "Développeur"                       = "Développeuse"
    "Technicien HSE"                    = "Technicienne HSE"
    "Directeur des ressources humaines" = "Directrice des ressources humaines"
    "Auditeur"                          = "Auditrice"
    "Rédacteur"                         = "Rédactrice"
    "Testeur"                           = "Testeuse"
    # ...
}
```

> Si une nouvelle fonction apparaît dans le CSV, elle doit être ajoutée à la hashtable `$FeminisationMapping` du script avec sa forme féminine correspondante.

### 2.6.2 Exécution du script

1. Ouvrir **PowerShell en tant qu'administrateur**
2. Exécuter le script :

```powershell
.\feminisationPosteAD.ps1
```

**À la fin de l'exécution, un résumé est affiché :**

```
Femmes traitées            : 85
Postes féminisés           : 72
Déjà féminisés             : 13
Ignorés / Erreurs          : 0
```

### 2.6.3 Vérification

**Via l'interface graphique :**
1. Ouvrir **Active Directory Users and Computers**
2. Double-cliquer sur le compte d'une collaboratrice
3. Onglet **"General"** → vérifier le champ **"Job Title"**

---

## 3. Déplacement automatique des objets AD

### 3.1 Explication du script
Vous pouvez allez consulter la doc sur le script ici : [Documentation du script](../Active_Directory/Script_Move_Object_AD_Configuration.md)
### 3.2 Automatisation par AT

Afin d'automatiser le déplacement des objets ordinateurs dans les bonnes unités d'organisation de l'Active Directory, le script PowerShell est exécuté automatiquement via le Planificateur de tâches Windows (Task Scheduler).

Cette automatisation permet d'exécuter régulièrement le script afin de vérifier si de nouveaux ordinateurs ont été ajoutés dans l'Active Directory et de les déplacer automatiquement dans l'OU correspondant à leur service.

---

#### Création de la tâche planifiée

Le planificateur de tâches Windows est utilisé pour exécuter automatiquement le script.

Pour ouvrir le planificateur :

```
taskschd.msc
```

Puis naviguer vers :

```
Task Scheduler Library → Create Task
```

---

#### Onglet General

Cet onglet permet de définir les informations principales de la tâche et les paramètres de sécurité.

##### Name

Nom de la tâche :

```
Automatisation déplacement ordinateurs AD
```

Ce nom permet d'identifier facilement la tâche dans le planificateur.

##### Security options

Compte utilisé pour exécuter la tâche :

```
BILLU\Administrator
```

> Le compte doit disposer des droits nécessaires pour modifier les objets Active Directory.

 **Options configurées**

| Option | Description |
|---|---|
| **Run whether user is logged on or not** | Permet d'exécuter la tâche même si aucun utilisateur n'est connecté sur le serveur. |
| **Run with highest privileges** | Permet d'exécuter la tâche avec les privilèges administrateur nécessaires pour accéder à Active Directory et déplacer les objets ordinateurs. |

---

#### Onglet Triggers

Cet onglet permet de définir quand la tâche doit être exécutée. Un déclencheur est ajouté avec la configuration suivante.

##### Begin the task

```
On a schedule
```

La tâche est déclenchée selon un planning.

##### Settings

La tâche est configurée pour s'exécuter quotidiennement :

```
Daily — 02:00
```

> Cette heure correspond généralement à une période de faible activité sur le réseau.

##### Advanced settings

Pour faciliter les tests, la tâche est répétée automatiquement :

```
Repeat task every : 15 minutes
For a duration of  : Indefinitely
```

> **Note :** En production, cette répétition peut être supprimée afin de limiter l'exécution à une fois par jour.

---

#### Onglet Actions

Cet onglet définit le programme qui sera exécuté par la tâche. Une nouvelle action est configurée.

##### Action

```
Start a program
```

##### Program/script

```
powershell.exe
```

Le planificateur lance PowerShell afin d'exécuter le script.

##### Add arguments

```
-ExecutionPolicy Bypass -File "\\DOM-FS-01\departements\DSI\scripts\Move_Object_AD.ps1"
```

| Paramètre | Description |
|---|---|
| `ExecutionPolicy Bypass` | Permet d'exécuter le script même si la politique d'exécution PowerShell est restrictive. |
| `-File` | Indique le script PowerShell à exécuter. |

---

#### Onglet Conditions

Cet onglet permet de définir les conditions nécessaires à l'exécution de la tâche.

Pour un serveur, certaines options ne sont pas nécessaires. Les options liées à l'alimentation électrique peuvent être laissées désactivées.

---

#### Onglet Settings

Cet onglet définit le comportement de la tâche. Les options suivantes sont activées.

| Option | Description |
|---|---|
| **Allow task to be run on demand** | Permet d'exécuter la tâche manuellement depuis le planificateur pour effectuer des tests. |
| **Run task as soon as possible after a scheduled start is missed** | Si le serveur était arrêté au moment de l'exécution prévue, la tâche sera exécutée dès que possible. |
| **If the task is already running** | Valeur : `Do not start a new instance` — évite que plusieurs instances du script s'exécutent en même temps. |


---

## 4. Création des groupes

### 4.1 Arborescence des groupes de sécurité

Tous les groupes doivent être créés dans l'arborescence suivante :

```
OU=BilluSecurity
      └── Groupes GRP_DEP_*
      └── Groupes GRP_SVC_*
```

### 4.2 Création d'un groupe

**Nomenclature :**

| Préfixe | Description |
|---------|-------------|
| `GRP_DEP_` | Groupe de département (contient les groupes de services) |
| `GRP_SVC_` | Groupe de service (contient les utilisateurs) |

**Procédure de création :**

Dans Active Directory Users and Computers :

- Faire un clic droit sur l'OU **BilluSecurity**
- Sélectionner **New > Group**
- Remplir les paramètres suivants :

| Paramètre | Valeur |
|-----------|--------|
| **Nom du groupe** | Selon la nomenclature (voir tableau ci-dessus) |
| **Type de groupe** | **Sécurité** |
| **Étendue du groupe** | **Globale** |

- Cliquer sur **OK**
- Répéter l'opération pour chaque groupe à créer (voir liste ci-dessous)
- Une fois les groupes créés, ajouter les membres de chaque service dans le groupe correspondant

### 4.3 Liste des groupes à créer

**Groupes de départements :**

```
GRP_DEP_COMMERCIAL_USERS
GRP_DEP_COMMUNICATION_USERS
GRP_DEP_COMPTABILITE_USERS
GRP_DEP_DEV_USERS
GRP_DEP_DIRECTION_USERS
GRP_DEP_DSI_USERS
GRP_DEP_DSI_COMPUTERS
GRP_DEP_JURIDIQUE_USERS
GRP_DEP_QHSE_USERS
GRP_DEP_RH_USERS
GRP_SEC_ADMIN_USERS
```

**Services COMMERCIAL :**

```
GRP_SVC_ADMINISTRATION_DES_VENTES_USERS
GRP_SVC_B2B_USERS
GRP_SVC_SERVICE_ACHAT_USERS
GRP_SVC_SERVICE_CLIENT_USERS
```

**Services COMMUNICATION :**

```
GRP_SVC_COMMUNICATION_INTERNE_USERS
GRP_SVC_GESTION_DES_MARQUES_USERS
GRP_SVC_RELATIONS_MEDIA_USERS
```

**Services COMPTABILITÉ :**

```
GRP_SVC_FINANCE_USERS
GRP_SVC_FISCALITE_USERS
GRP_SVC_SERVICE_COMPTABILITE_USERS
```

**Services DÉVELOPPEMENT :**

```
GRP_SVC_ANALYSE_CONCEPTION_USERS
GRP_SVC_DEVELOPPEMENT_USERS
GRP_SVC_RECHERCHE_PROTOTYPAGE_USERS
GRP_SVC_TESTS_QUALITE_USERS
```

**Services DIRECTION :**

```
GRP_SVC_DIRECTION_USERS
```

**Services DSI :**

```
GRP_SVC_ADMIN_USERS
GRP_SVC_ANALYSE_CONCEPTION_USERS
GRP_SVC_DEVELOPPEMENT_INTEGRATION_USERS
GRP_SVC_EXPLOITATION_USERS
GRP_SVC_SUPPORT_USERS
```

**Services JURIDIQUE :**

```
GRP_SVC_DROITS_DES_SOCIETES_USERS
GRP_SVC_PROPRIETES_INTELLECTUELLES_USERS
GRP_SVC_PROTECTION_DONNEES_CONFORMITES_USERS
```

**Services QHSE :**

```
GRP_SVC_CERTIFICATION_USERS
GRP_SVC_CONTROLE_QUALITE_USERS
GRP_SVC_GESTION_ENVIRONNEMENTALE_USERS
```

**Services RESSOURCES HUMAINES :**

```
GRP_SVC_RH_USERS
```

---

## 5. Stratégies de groupe (GPO)

### 5.1 Création de GPO

**Cette partie est à titre d'exemple. Suivre cette procédure pour créer chaque GPO des chapitres 5.2 et 5.3.**

#### 5.1.1 Accès au menu des GPO

- Dans `Server Manager`, cliquer sur `Tools` puis `Group Policy Management`

![img](Ressources/06_gpo/01_GPO.png)

#### 5.1.2 Création d'une GPO

1. Faire `Clic droit` sur `Group Policy Objects`
2. Sélectionner `New`

![img](Ressources/06_gpo/02_GPO.png)

#### 5.1.3 Nommage de la GPO

- Entrer le nom de la GPO en suivant la convention de nommage

![img](Ressources/06_gpo/03_GPO.png)

#### 5.1.4 Accès à l'éditeur de GPO

1. Faire `Clic droit` sur la GPO créée
2. Sélectionner `Edit...` pour faire apparaître la console `Group Policy Management Editor`

![img](Ressources/06_gpo/04_GPO.png)

#### 5.1.5 Navigation dans les paramètres de la GPO

1. Naviguer dans le menu pour trouver l'emplacement du paramètre
2. Double-cliquer pour ouvrir un paramètre et l'éditer

![img](Ressources/06_gpo/05_GPO.png)

#### 5.1.6 Portée de la GPO

1. Sélectionner l'onglet **Scope**
2. Choisir l'OU de **Liaison** (Links)
3. Choisir le ou les groupes/Utilisateurs/Ordinateurs pour le filtrage de la GPO

> La GPO sera appliquée à l'OU de liaison en tenant compte du filtrage ajouté.

![img](Ressources/06_gpo/06_GPO.png)

#### 5.1.7 Statut de la GPO

1. Sélectionner l'onglet **Détails**
2. Ajuster le statut de la GPO

![img](Ressources/06_gpo/07_GPO.png)

#### 5.1.8 Vérification de l'application des GPO

**Forcer la mise à jour des GPO sur un ordinateur :**
```cmd
gpupdate /force
```

**Vérifier les GPO appliquées à l'ordinateur :**
```cmd
gpresult /r
```

**Générer un rapport HTML détaillé des GPO appliquées :**
```cmd
gpresult /h rapport_gpo.html
```

---

### 5.2 GPO de sécurité

#### 5.2.1 Politique de mot de passe

**Nom :** `Default Domain Policy`

**Chemin de configuration :**
> Computer Configuration > Policies > Windows Settings > Security Settings > Account Policies > Password Policy

**Paramètres :**

| Paramètre | Valeur | Note |
|-----------|--------|------|
| Enforce password history | `24 passwords` | Empêche la réutilisation des 24 derniers mots de passe |
| Maximum password age | `90 days` | Renouvellement obligatoire tous les 90 jours |
| Minimum password age | `1 day` | Empêche le changement immédiat du mot de passe |
| Minimum password length | `12 characters` | Longueur minimale requise |
| Minimum password length audit | `12 characters` | Audit de longueur minimale des mots de passe |
| Password must meet complexity requirements | `Enabled` | Doit contenir : majuscules, minuscules, chiffres et caractères spéciaux |
| Store passwords using reversible encryption | `Disabled` | Stockage sécurisé des mots de passe |

**Portée :**

| Propriété | Valeur |
|-----------|--------|
| Liaison | Racine du domaine `billu.lan` |
| Filtrage | Authenticated Users |
| Cible | Domain Controllers et tous les comptes du domaine |
| Statut | User configuration settings disabled |

> **Note :** Les Account Policies (Password Policy, Account Lockout Policy, Kerberos Policy) ne fonctionnent qu'au niveau du domaine. Elles doivent obligatoirement être configurées dans la Default Domain Policy ou une GPO liée à la racine du domaine pour affecter les comptes de domaine.

---

#### 5.2.2 Verrouillage de compte

**Nom :** `Default Domain Policy`

**Chemin de configuration :**
> Computer Configuration > Policies > Windows Settings > Security Settings > Account Policies > Account Lockout Policy

**Paramètres :**

| Paramètre | Valeur | Note |
|-----------|--------|------|
| Account lockout duration | `15 minutes` | Durée de verrouillage du compte |
| Account lockout threshold | `3 invalid attempts` | Nombre de tentatives avant verrouillage |
| Reset account lockout counter after | `15 minutes` | Réinitialisation du compteur d'échecs |

**Portée :**

| Propriété | Valeur |
|-----------|--------|
| Liaison | Racine du domaine `billu.lan` |
| Filtrage | Authenticated Users |
| Cible | Domain Controllers et tous les comptes du domaine |
| Statut | User configuration settings disabled |

> **Note :** Cette politique est configurée dans la même GPO que la Password Policy (Default Domain Policy) car les Account Policies ne s'appliquent qu'au niveau du domaine.

---

#### 5.2.3 Restriction d'installation de logiciels

**Nom :** `PROD_COMPUTERS_RestrictionSoftwareInstall`

**Chemin de configuration :**
> Computer Configuration > Policies > Administrative Templates > Windows Components > Windows Installer

**Paramètres :**

| Paramètre | Valeur | Note |
|-----------|--------|------|
| Turn off Windows Installer | `Enabled` > `For non-managed applications only` | Autorise seulement les programmes approuvés |
| Prohibit User Installs | `Enabled` > `Hide User Installs` | Empêche les installations per-user |

**Portée :**

| Propriété | Valeur |
|-----------|--------|
| Liaison | `billu.lan > BilluComputers > Tous les départements` |
| Filtrage | Tous les groupes de départements (sauf la DSI) |
| Cible | Computers |
| Statut | User configuration settings disabled |

---

#### 5.2.4 Blocage de l'accès à la base de registre

**Nom :** `PROD_USERS_BlockBaseRegistry`

**Chemin de configuration :**
> User Configuration > Policies > Administrative Templates > System

**Paramètres :**

| Paramètre | Valeur | Note |
|-----------|--------|------|
| Prevent access to registry editing tools | `Enabled` > `Yes` | Bloque l'accès à regedit.exe et reg.exe sans message d'avertissement |

**Portée :**

| Propriété | Valeur |
|-----------|--------|
| Liaison | `billu.lan > BilluUsers > Tous les départements` |
| Filtrage | Tous les groupes de départements sauf la DSI |
| Cible | Users |
| Statut | Computer configuration settings disabled |

---

#### 5.2.5 Blocage du panneau de configuration

**Nom :** `PROD_USERS_RestrictionControlPanel`

**Chemin de configuration :**
> User Configuration > Policies > Administrative Templates > Control Panel

**Paramètres :**

| Paramètre | Valeur | Note |
|-----------|--------|------|
| Prohibit access to Control Panel and PC settings | `Enabled` | Bloque complètement l'accès au panneau de configuration |

**Portée :**

| Propriété | Valeur |
|-----------|--------|
| Liaison | `billu.lan > BilluUsers > Tous les départements sauf la DSI` |
| Filtrage | Tous les groupes de départements sauf la DSI |
| Cible | Users |
| Statut | Computer configuration settings disabled |

---

#### 5.2.6 Restriction des périphériques amovibles

**Nom :** `PROD_USERS_RestrictionRemoveDevices`

**Chemin de configuration :**
> User Configuration > Policies > Administrative Templates > System > Removable Storage Access

**Paramètres :**

| Paramètre | Valeur | Note |
|-----------|--------|------|
| All Removable Storage classes: Deny all access | `Enabled` | Bloque tous les périphériques amovibles |

**Portée :**

| Propriété | Valeur |
|-----------|--------|
| Liaison | `billu.lan > BilluComputers > Tous les départements sauf la DSI` |
| Filtrage | Tous les groupes de départements sauf la DSI |
| Cible | Users |
| Statut | Computer configuration settings disabled |

---

#### 5.2.7 Gestion du pare-feu

**Nom :** `PROD_COMPUTERS_Firewall`

**Chemin de configuration :**
> Computer Configuration > Policies > Windows Settings > Security Settings > Windows Defender Firewall with Advanced Security > Windows Defender Firewall with Advanced Security

Clic droit > **Properties**

**Domain Profile :**

| Paramètre | Valeur | Note |
|-----------|--------|------|
| Firewall state | `On` | Active le pare-feu |
| Inbound connections | `Block (default)` | Bloque par défaut |
| Outbound connections | `Allow (default)` | Autorise par défaut |

**Private Profile :**

| Paramètre | Valeur | Note |
|-----------|--------|------|
| Firewall state | `On` | Active le pare-feu |
| Inbound connections | `Block (default)` | Bloque par défaut |
| Outbound connections | `Allow (default)` | Autorise par défaut |

**Public Profile :**

| Paramètre | Valeur | Note |
|-----------|--------|------|
| Firewall state | `On` | Active le pare-feu |
| Inbound connections | `Block (default)` | Bloque par défaut |
| Outbound connections | `Allow (default)` | Autorise par défaut |

**Portée :**

| Propriété | Valeur |
|-----------|--------|
| Liaison | `billu.lan > BilluComputers > Tous les départements sauf la DSI` |
| Filtrage | Tous les groupes de départements sauf la DSI |
| Cible | Computers |
| Statut | User configuration settings disabled |

---

#### 5.2.8 Écran de veille avec mot de passe

**Nom :** `PROD_USERS_ScreenSaver`

**Chemin de configuration :**
> User Configuration > Policies > Administrative Templates > Control Panel > Personalization

**Paramètres :**

| Paramètre | Valeur | Note |
|-----------|--------|------|
| Enable screen saver | `Enabled` | Active l'écran de veille |
| Password protect the screen saver | `Enabled` | Demande le mot de passe à la sortie |
| Screen saver timeout | `Enabled` > `900` | Définit le délai d'activation (15 minutes) |
| Prevent changing screen saver | `Enabled` | Empêche la modification des paramètres |

**Portée :**

| Propriété | Valeur |
|-----------|--------|
| Liaison | `billu.lan > BilluUsers > Tous les départements` |
| Filtrage | Tous les groupes de départements |
| Cible | Users |
| Statut | Computer configuration settings disabled |

---

#### 5.2.9 Bureau à distance sécurisé

**Nom :** `PROD_USERS_RDP`

**Chemin de configuration :**
> User Configuration > Policies > Administrative Templates > Windows Components > Remote Desktop Services > Remote Desktop Session Host > Connections

**Paramètres :**

| Paramètre | Valeur | Note |
|-----------|--------|------|
| Set rules for remote control of Remote Desktop Services user sessions | `Enabled` > `Full Control with user's permission` | Autorise l'accès au bureau à distance |

**Portée :**

| Propriété | Valeur |
|-----------|--------|
| Liaison | `billu.lan > BilluUsers > Tous les départements sauf la DSI` |
| Filtrage | Tous les groupes de départements |
| Cible | Users |
| Statut | Computer configuration settings disabled |

---

#### 5.2.10 Accès aux postes d'administration – utilisateurs autorisés

**Nom :** `PROD_USERS_ConnectPCAdministration`

**Objectif :** Restreindre l'accès local aux postes d'administration afin que seuls les administrateurs autorisés puissent s'y connecter.

**Chemin de configuration :**
> Computer Configuration > Policies > Windows Settings > Security Settings > Local Policies > User Rights Assignment

**Paramètres :**

| Paramètre | Valeur | Note |
|-----------|--------|------|
| Allow log on locally | `BILLU\GRP_SEC_ADMIN`, `BUILTIN\Administrators` | Autorise uniquement les administrateurs à ouvrir une session locale |

**Portée :**

| Propriété | Valeur |
|-----------|--------|
| Liaison | OU `BilluComputers` |
| Filtrage de sécurité | Groupes administrateurs uniquement |
| Cible | Ordinateurs |
| Statut | User configuration settings disabled |

---

#### 5.2.11 Accès local au VLAN DSI – utilisateurs autorisés

**Nom :** `PROD_USERS_ConnectVLANDSI`

**Objectif :** Autoriser l'accès local aux postes du VLAN DSI uniquement aux équipes habilitées et aux administrateurs.

**Chemin de configuration :**
> Computer Configuration > Policies > Windows Settings > Security Settings > Local Policies > User Rights Assignment

**Paramètres :**

| Paramètre | Valeur | Note |
|-----------|--------|------|
| Allow log on locally | `BILLU\GRP_DEP_DSI`, `BILLU\GRP_SEC_ADMIN`, `BUILTIN\Administrators` | Accès limité aux équipes DSI et administrateurs |

**Portée :**

| Propriété | Valeur |
|-----------|--------|
| Liaison | OU `DSI` |
| Filtrage de sécurité | Groupes DSI et sécurité |
| Cible | Ordinateurs |
| Statut | User configuration settings disabled |

---

#### 5.2.12 Restriction des horaires de connexion
**Nom :** `PROD_COMPUTER_LogonRestriction`
**Chemin de configuration :**
> Computer Configuration > Policies > Windows Settings > Security Settings > Local Policies > Security Options

**Paramètres :**
| Paramètre | Valeur | Note |
|-----------|--------|------|
| Network Security : Force logoff when logon hours expire | `Define this policy Setting` > `Enabled` | Déconnecte les sessions hors horaires autorisés |

**Portée :**
| Propriété | Valeur |
|-----------|--------|
| Liaison | `billu.lan > BilluComputers` |
| Filtrage | Domain Computers |
| Cible | Computer |
| Statut | User configuration settings disabled |

**Tâche planifiée :** Voir section 5

---

### 5.3 GPO standard

#### 5.3.1 Fond d'écran

**Nom :** `PROD_USERS_Wallpaper`

**Chemin de configuration :**
> User Configuration > Policies > Administrative Templates > Desktop > Desktop

**Paramètres :**

| Paramètre | Valeur | Note |
|-----------|--------|------|
| Desktop Wallpaper | `\\DOM-AD-01\share\wallpaper.jpg` | Chemin du fichier image |
| Wallpaper Style | `Fill` | |

**Portée :**

| Propriété | Valeur |
|-----------|--------|
| Liaison | `billu.lan > BilluUsers > Tous les départements` |
| Filtrage | Tous les groupes de départements |
| Cible | Users |
| Statut | Computer configuration settings disabled |

---

#### 5.3.2 Mappage de lecteurs réseau

**Nom :** `PROD_USERS_Drives`

**Chemin de configuration :**
> User Configuration > Preferences > Windows Settings > Drive Maps

Clic droit > **New** > **Mapped Drive**

**Paramètres :**

| Paramètre | Valeur | Note |
|-----------|--------|------|
| Action | `Create` | |
| Location | `\\DOM-AD-01\share` | Chemin du partage réseau |
| Reconnect | `Enabled` | Reconnecte le lecteur à chaque ouverture de session |
| Label as | `Documents` | Nom d'affichage du lecteur |
| Drive Letter | `H:` | Lettre de lecteur à utiliser |
| Hide/Show this drive | `No change` | Visibilité du lecteur |
| Hide/Show all drives | `No change` | Visibilité de tous les lecteurs |

**Portée :**

| Propriété | Valeur |
|-----------|--------|
| Liaison | `billu.lan > BilluUsers > Tous les départements` |
| Filtrage | Tous les groupes de départements |
| Cible | Users |
| Statut | Computer configuration settings disabled |

---

#### 5.3.3 Gestion de l'alimentation

**Nom :** `PROD_COMPUTERS_PowerSaving`

**Chemin de configuration :**
> Computer Configuration > Policies > Administrative Templates > System > Power Management > Video and Display Settings

**Paramètres :**

| Paramètre | Valeur | Note |
|-----------|--------|------|
| Turn off the display (on battery) | `Enabled` > `300` | Éteint l'écran après 5 minutes sur batterie |

> Computer Configuration > Policies > Administrative Templates > System > Power Management > Sleep Settings

| Paramètre | Valeur | Note |
|-----------|--------|------|
| Specify the system sleep timeout (plugged in) | `Enabled` > `900` | Mise en veille sur secteur après 15 minutes |
| Require a password when a computer wakes (plugged in) | `Enabled` | Demande le mot de passe au réveil |
| Specify the system sleep timeout (on battery) | `Enabled` > `900` | Mise en veille sur batterie après 15 minutes |
| Require a password when a computer wakes (on battery) | `Enabled` | Demande le mot de passe au réveil |

**Portée :**

| Propriété | Valeur |
|-----------|--------|
| Liaison | `billu.lan > BilluComputers > Tous les départements` |
| Filtrage | Tous les groupes de départements |
| Cible | Computers |
| Statut | User configuration settings disabled |

---

#### 5.3.4 Déploiement de logiciels

**Nom :** `PROD_USERS_Software_7zip`

**Chemin de configuration :**
> User Configuration > Policies > Software Settings > Software installation

Clic droit > **New** > **Package**

**Paramètres :**

| Paramètre | Valeur | Note |
|-----------|--------|------|
| Package path | `\\DOM-AD-01\share\software\7z2501-x64.msi` | Chemin du fichier MSI 7zip |
| Deployment method | `Published` | L'application apparaît dans "Programmes et fonctionnalités" > "Installer un programme à partir du réseau" – installation manuelle par l'utilisateur |
| Installation user interface options | `Basic` | |

**Portée :**

| Propriété | Valeur |
|-----------|--------|
| Liaison | `billu.lan > BilluUsers > Tous les départements` |
| Filtrage | Tous les groupes de départements |
| Cible | Users |
| Statut | Computer configuration settings disabled |

---

#### 5.3.5 Redirection de dossiers

**Nom :** `PROD_USERS_FolderRedirection`

**Chemin de configuration – Documents :**
> User Configuration > Policies > Windows Settings > Folder Redirection > Documents

Clic droit > **Properties**

| Paramètre | Valeur | Note |
|-----------|--------|------|
| Setting | `Basic - Redirect everyone's folder to the same location` | Type de redirection |
| Target folder location | `Create a folder for each user under the root path` | Organisation des dossiers |
| Root Path | `\\DOM-AD-01\share\users$\` | Chemin de redirection |
| Grant the user exclusive rights to Documents | `Enabled` | Droits NTFS exclusifs |
| Move the contents of Documents to the new location | `Enabled` | Déplace les fichiers existants |

**Chemin de configuration – Desktop :**
> User Configuration > Policies > Windows Settings > Folder Redirection > Desktop

| Paramètre | Valeur | Note |
|-----------|--------|------|
| Setting | `Basic - Redirect everyone's folder to the same location` | Type de redirection |
| Root Path | `\\DOM-AD-01\share\users$\` | Chemin de redirection |
| Grant the user exclusive rights to Desktop | `Enabled` | Droits NTFS exclusifs |
| Move the contents of Desktop to the new location | `Enabled` | Déplace les fichiers existants |

**Portée :**

| Propriété | Valeur |
|-----------|--------|
| Liaison | `billu.lan > BilluUsers > Tous les départements` |
| Filtrage | Tous les groupes de départements |
| Cible | Users |
| Statut | Computer configuration settings disabled |

---

#### 5.3.6 Configuration du navigateur Firefox

**Fichiers requis pour la configuration de la GPO :**

1. Aller sur le lien GitHub : https://github.com/mozilla/policy-templates/releases
2. Télécharger la dernière version des `policy_templates`
3. Copier les fichiers `firefox.admx` et `mozilla.admx` dans `C:\Windows\PolicyDefinitions`
4. Copier les fichiers `firefox.adml` et `mozilla.adml` (dossier `en-US`) dans `C:\Windows\PolicyDefinitions\en-US`

**Nom :** `PROD_USERS_Firefox`

**Chemin de configuration :**
> User Configuration > Policies > Administrative Templates > Mozilla > Firefox > Homepage

| Paramètre | Valeur | Note |
|-----------|--------|------|
| Homepage | `Enabled` | Configure la page d'accueil |
| Homepage URL | `https://youtube.com` | URL de la page d'accueil |
| Lock Homepage | `Enabled` | Empêche la modification de la page d'accueil |

> User Configuration > Policies > Administrative Templates > Mozilla > Firefox

| Paramètre | Valeur | Note |
|-----------|--------|------|
| Disable Private Browsing | `Enabled` > `Disable Private Browsing Mode` | Désactive la navigation privée |
| Password Manager | `Disabled` | Désactive le gestionnaire de mots de passe |

**Portée :**

| Propriété | Valeur |
|-----------|--------|
| Liaison | `billu.lan > BilluUsers > Tous les départements sauf la DSI` |
| Filtrage | Tous les groupes de départements sauf la DSI |
| Cible | Users |
| Statut | Computer configuration settings disabled |

---

#### 5.3.7 Déploiement de GLPI Agent

**Nom :** `PROD_COMPUTERS_GLPI_Agent`

**Chemin de configuration :**
> Computer Configuration > Policies > Windows Settings > Scripts > Startup

Onglet **PowerShell Scripts** > **Add...**

**Paramètres :**

| Paramètre | Valeur | Note |
|-----------|--------|------|
| Script Name | `\\DOM-AD-01\share\software\Install-GLPIAgent.ps1` | Chemin du script PowerShell d'installation |

---

#### 5.3.8 Création automatique du dossier HOME

**Nom :** `GPO-FS-HOME-CREATE`

**Chemin de configuration :**
> User Configuration > Preferences > Windows Settings > Folders

Clic droit > **New** > **Folder**

**Paramètres :**

| Paramètre | Valeur | Note |
|-----------|--------|------|
| Action | `Create` | Crée le dossier s'il n'existe pas |
| Path | `\\DOM-FS-01\HOME\%USERNAME%` | Chemin du dossier personnel de l'utilisateur |

**Portée :**

| Propriété | Valeur |
|-----------|--------|
| Liaison | `billu.lan > BilluUsers` |
| Filtrage | Authenticated Users |
| Cible | Users |
| Statut | Computer configuration settings disabled |

---

#### 5.3.9 Mappage du lecteur HOME

**Nom :** `GPO-FS-HOME-I`

**Chemin de configuration :**
> User Configuration > Preferences > Windows Settings > Drive Maps

Clic droit > **New** > **Mapped Drive**

**Paramètres :**

| Paramètre | Valeur | Note |
|-----------|--------|------|
| Action | `Create` | Crée le mappage du lecteur |
| Location | `\\DOM-FS-01\HOME\%USERNAME%` | Chemin du dossier personnel de l'utilisateur |
| Reconnect | `Enabled` | Reconnecte le lecteur à chaque ouverture de session |
| Label as | `HOME` | Nom d'affichage du lecteur |
| Drive Letter | `I:` | Lettre de lecteur à utiliser |

**Portée :**

| Propriété | Valeur |
|-----------|--------|
| Liaison | `billu.lan > BilluUsers` |
| Filtrage | Authenticated Users |
| Cible | Users |
| Statut | Computer configuration settings disabled |

---

## 6. Tâche planifiée – Restriction des horaires de connexion

1) Ouvrir le menu **Démarrer**
2) Écrire `task scheduler`

![img](Ressources/09_configuration_task_scheduler/01_logonhours_taskmanager.png)

1) Faire `Clic Droit` sur **Task Scheduler Library**
2) Cliquer sur `Create Task...`

![img](Ressources/09_configuration_task_scheduler/02_logonhours_taskmanager.png)

1) Entrer le nom de la tâche planifiée : `AD_LogonHoursRestriction`
2) Sélectionner `Run Whether user is logged on or not`
3) Cocher `Run with highest privileges`
4) Sélectionner **Windows Server 2022**

![img](Ressources/09_configuration_task_scheduler/03_logonhours_taskmanager.png)

1) Sélectionner l'onglet **Triggers**
2) Cliquer sur `New`

![img](Ressources/09_configuration_task_scheduler/04_logonhours_taskmanager.png)

1) Choisir **On a schedule**
2) Sélectionner la date de commencement ainsi que l'heure
3) Choisir `Daily` et entrer la valeur `1`
4) Cocher `Enabled`

![img](Ressources/09_configuration_task_scheduler/06_logonhours_taskmanager.png)

1) Sélectionner l'onglet `Actions`
2) Cliquer sur `New`

![img](Ressources/09_configuration_task_scheduler/06_logonhours_taskmanager.png)

1) Choisir l'action `Start a program`
2) Entrer le chemin de PowerShell dans `Program/script` :
```
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
```
3) Ajouter les paramètres et chemin du script dans `Add arguments` :
```
-NonInteractive -ExecutionPolicy Bypass -File "\\DOM-FS-01\departements\DSI\scripts\AD_LogonHoursRestriction.ps1"
```

![img](Ressources/09_configuration_task_scheduler/07_logonhours_taskmanager.png)

1) Sélectionner l'onglet `Settings`
2) Cocher `If the task fails, restart every` et choisir `1 minute`
3) Pour `Stop the task if it run longer than:`, choisir `1 hour`
4) Sélectionner `Do not start a new instance`

![img](Ressources/09_configuration_task_scheduler/08_logonhours_taskmanager.png)

1) Entrer un utilisateur ayant les permissions d'effectuer cette tâche (Administrator)
2) Entrer le mot de passe

![img](Ressources/09_configuration_task_scheduler/09_logonhours_taskmanager.png)

- Vérifier que la tâche planifiée apparaît dans la liste.

![img](Ressources/09_configuration_task_scheduler/10_logonhours_taskmanager.png)

---

## 7. Jonction au domaine

### 7.1 Joindre Ubuntu/Debian à un domaine Active Directory

#### Prérequis

- Le DNS du serveur doit pointer vers le contrôleur de domaine (DC)
- L'heure du serveur doit être synchronisée avec le DC (Kerberos est sensible au décalage horaire)
- Un compte AD avec les droits de jonction au domaine

#### 7.1.1 Installation des paquets

```bash
sudo apt update
sudo apt install -y realmd sssd sssd-tools adcli krb5-user \
    packagekit samba-common-bin oddjob oddjob-mkhomedir
```

> ⚠️ Lors de l'installation de `krb5-user`, entrez le royaume Kerberos en **MAJUSCULES** (ex: `BILLU.LAN`)

Ou éditer manuellement le fichier `/etc/krb5.conf` :

```ini
[libdefaults]
    default_realm = BILLU.LAN

[realms]
    BILLU.LAN = {
        kdc = DOM-AD-01
        admin_server = administrator
    }

[domain_realm]
    .billu.lan = BILLU.LAN
    billu.lan = BILLU.LAN
```

#### 7.1.2 Découverte du domaine

Voir le DNS actuellement configuré :
```bash
cat /etc/resolv.conf
```

Le DNS doit pointer vers votre **contrôleur de domaine AD**. Si ce n'est pas le cas, corrigez-le :

```bash
sudo nano /etc/resolv.conf
```

```
nameserver 172.16.12.1   # IP de votre DC
search billu.lan
```

```bash
realm discover billu.lan
```

La commande doit retourner les informations du domaine. Si rien n'apparaît, vérifiez votre configuration DNS.

#### 7.1.3 Jonction au domaine

```bash
sudo realm join --user=Administrator billu.lan
```

Entrez le mot de passe du compte AD quand il est demandé.

#### 7.1.4 Vérification

```bash
# Vérifier que la jonction est réussie
realm list

# Tester avec un compte AD existant
id moncompte@billu.lan
```

---

## 8. Transfert des rôles FSMO (PDC et RID)

Cette section décrit la procédure de déploiement d'un second contrôleur de domaine (Server Core) et le transfert des rôles FSMO PDC Emulator et RID Master vers ce nouveau serveur.

### 8.1 Prérequis et ajout du serveur

#### 8.1.1 Configuration du clavier en AZERTY

Par défaut, Windows Server Core démarre avec un clavier en QWERTY. Avant toute autre opération, passer le clavier en AZERTY de façon permanente dans une console PowerShell :

```powershell
# Passer le clavier en AZERTY (français)
Set-WinUserLanguageList -LanguageList fr-FR -Force

# Appliquer le changement au niveau système (pour tous les utilisateurs)
Set-WinSystemLocale fr-FR
```

Redémarrer le serveur pour que la configuration soit définitive :

```powershell
Restart-Computer
```

> Une fois redémarré, ouvrir une nouvelle session PowerShell : le clavier est désormais en AZERTY.

---

#### 8.1.2 Configuration IP du serveur Core

Dans une console PowerShell, entrer les commandes suivantes :

1. Vérifier l'index de l'adaptateur :
```powershell
Get-NetAdapter
```

> Adapter la valeur de `InterfaceIndex` selon le résultat obtenu.

2. Supprimer l'ancienne IP et route :
```powershell
Remove-NetIPAddress -InterfaceIndex 1 -Confirm:$false
Remove-NetRoute -InterfaceIndex 1 -Confirm:$false
```

3. Appliquer la nouvelle configuration :
```powershell
New-NetIPAddress -InterfaceIndex 1 -IPAddress "172.16.12.6" -PrefixLength 28 -DefaultGateway "172.16.12.14"
```

4. Configuration du DNS :
```powershell
Set-DnsClientServerAddress -InterfaceIndex 1 -ServerAddresses "172.16.12.1"
```

#### 8.1.3 Jonction du serveur Core au domaine

1. Choisir l'option **1** dans sconfig

![img](Ressources/08_configuration_fsmo_img/01_fsmo_configuration.png)

2. Ajouter le serveur dans le domaine :
    - Entrer `D` pour sélectionner Domain
    - Entrer `billu.lan`
    - Entrer le nom d'un utilisateur autorisé : `Administrator`
    - Entrer son mot de passe
    - Changer le nom de la machine par : `DOM-AD-PDC-01`
    - Entrer le mot de passe du serveur Core
    - Redémarrer en appuyant sur `Y`

![img](Ressources/08_configuration_fsmo_img/02_fsmo_configuration.png)

#### 8.1.4 Ajout du serveur dans le Server Manager

Depuis le serveur graphique :

1. Cliquer sur `Manage` puis `Add Servers`

![img](Ressources/08_configuration_fsmo_img/03_fsmo_configuration.png)

2. Cliquer sur `Find Now`
3. Sélectionner le serveur à ajouter
4. Vérifier qu'il apparaît dans la liste **Selected**

![img](Ressources/08_configuration_fsmo_img/04_fsmo_configuration.png)

Le serveur doit apparaître dans la liste `All Servers`.

![img](Ressources/08_configuration_fsmo_img/05_fsmo_configuration.png)

---

### 8.2 Installation d'Active Directory sur le serveur Core

- Faire `clic droit` sur le serveur **PDC** dans la liste `All Servers`

![img](Ressources/08_configuration_fsmo_img/06_fsmo_configuration.png)

1. Cliquer sur `Next` jusqu'à la sélection des serveurs
2. Sélectionner le serveur PDC

![img](Ressources/08_configuration_fsmo_img/07_fsmo_configuration.png)

3. Cocher **Active Directory Domain Services**

![img](Ressources/08_configuration_fsmo_img/08_fsmo_configuration.png)

4. Cliquer sur `Add Features`

![img](Ressources/08_configuration_fsmo_img/09_fsmo_configuration.png)

5. Faire `Next` jusqu'à l'étape `Confirmation`
6. Vérifier les informations et cliquer sur `Install`

![img](Ressources/08_configuration_fsmo_img/10_fsmo_configuration.png)

7. Attendre la confirmation de l'installation

![img](Ressources/08_configuration_fsmo_img/11_fsmo_configuration.png)

---

### 8.3 Promotion en contrôleur de domaine

1. Cliquer sur le drapeau
2. Cliquer sur `Promote this server to a domain controller`

![img](Ressources/08_configuration_fsmo_img/12_fsmo_configuration.png)

3. Sélectionner `Add a domain controller to an existing domain`
4. Cliquer sur `Change` et entrer les credentials Administrator

![img](Ressources/08_configuration_fsmo_img/13_fsmo_configuration.png)

5. Cocher `Domain Name System (DNS) server` et `Global Catalog (GC)`
6. Définir un mot de passe DSRM

![img](Ressources/08_configuration_fsmo_img/14_fsmo_configuration.png)

7. Cliquer sur `Next` jusqu'à `Prerequisites Check` puis sur `Install`

![img](Ressources/08_configuration_fsmo_img/17_fsmo_configuration.png)

8. Attendre la confirmation de la configuration

![img](Ressources/08_configuration_fsmo_img/18_fsmo_configuration.png)

9. **Redémarrer le serveur Core**

---

### 8.4 Attribution des rôles FSMO

1. Dans le **Server Manager**, sélectionner `AD DS`
2. Faire `Clic droit` sur le serveur **PDC**
3. Sélectionner `Active Directory Users and Computers`

![img](Ressources/08_configuration_fsmo_img/19_fsmo_configuration.png)

Dans la console `Active Directory Users and Computers` :

1. Faire `Clic droit` sur le domaine
2. Cliquer sur `Operations Masters`

![img](Ressources/08_configuration_fsmo_img/19_fsmo_configuration1.png)

3. Sélectionner l'onglet `PDC`
4. Cliquer sur `Changer`

![img](Ressources/08_configuration_fsmo_img/20_fsmo_configuration.png)

5. Sélectionner `Yes` pour transférer le rôle PDC Emulator sur le serveur Core

![img](Ressources/08_configuration_fsmo_img/21_fsmo_configuration.png)

#### Transfert du rôle RID Master

Le rôle RID Master est transféré sur un second serveur Core dédié (`DOM-AD-RID-01`). La procédure de déploiement de ce serveur (config IP, jonction au domaine, installation AD DS, promotion DC) est identique à celle décrite aux étapes 7.1 à 7.3 en adaptant le nom de machine à `DOM-AD-RID-01`.

Une fois le serveur prêt, procéder au transfert du rôle :

1. Dans le **Server Manager**, faire `Clic droit` sur le serveur **DOM-AD-RID-01**
2. Sélectionner `Active Directory Users and Computers`

![img](Ressources/08_configuration_fsmo_img/24_fsmo_configuration.png)

3. Dans la console `Active Directory Users and Computers`, faire `Clic droit` sur le domaine
4. Cliquer sur `Operations Masters`
5. Sélectionner l'onglet `RID`
6. Cliquer sur `Change...` pour transférer le rôle vers `dom-ad-rid-01.billu.lan`

![img](Ressources/08_configuration_fsmo_img/25_fsmo_configuration.png)

---

### 8.5 Configuration NTP sur le PDC Emulator

Le PDC Emulator étant la source de temps autoritaire du domaine Active Directory, il doit être configuré pour se synchroniser sur des serveurs NTP externes. Les autres contrôleurs de domaine et les machines membres se synchroniseront automatiquement sur lui.

#### 8.5.1 Configurer la source de temps externe

Dans une console PowerShell sur `DOM-AD-PDC-01`, exécuter :

```cmd
w32tm /config /manualpeerlist:"0.fr.pool.ntp.org,0x8 1.fr.pool.ntp.org,0x8 2.fr.pool.ntp.org,0x8" /syncfromflags:manual /reliable:YES /update
```

> Le paramètre `/reliable:YES` est indispensable : il désigne ce serveur comme source de temps fiable pour l'ensemble du domaine.

#### 8.5.2 Redémarrer le service W32Time

```cmd
net stop w32time && net start w32time
```

#### 8.5.3 Forcer une synchronisation immédiate

```cmd
w32tm /resync /force
```

#### 8.5.4 Vérifier la configuration

```cmd
w32tm /query /status
```

Contrôler les éléments suivants dans la sortie :

- **Source** → doit afficher l'un des serveurs du pool NTP (ex: `1.fr.pool.ntp.org,0x8`)
- **Stratum** → doit afficher `2`
- **Leap Indicator** → doit afficher `0 (no warning)`
- **Last Successful Sync Time** → doit afficher une heure récente

---

### 8.6 Vérification

Exécuter la commande suivante dans PowerShell pour confirmer le transfert des deux rôles :

```powershell
Get-ADDomain | Select-Object PDCEmulator, RIDMaster, InfrastructureMaster
```

Le résultat doit afficher :
- **PDCEmulator** → `DOM-AD-PDC-01.billu.lan`
- **RIDMaster** → `DOM-AD-RID-01.billu.lan`

![img](Ressources/08_configuration_fsmo_img/26_fsmo_configuration.png)

---

## 9. Relation de confiance avec Ecotech

Un partenariat entre les sociétés **BillU** et **EcoTechSolutions** vient d'être signé.

Depuis le `Server Manager`

- Cliquer sur `Tools`
- Cliquer sur `DNS`
- Cliquer sur `DOM-AD-01`
- Clique droit sur `New zone`
- Cliquer sur `Next`
- Cocher `Stub zone`
- Cocher `To all DNS servers running on domain controllers in this forest: billu.lan`
- Cliquer sur `Next` X2
- Entrer le nom de domaine : `ecotech.local`
- Cliquer sur `Next`
- Entrer IP du DNS Ecotech : `10.20.20.20.6`
- Cliquer sur `Next`

![image_01](Ressources/Configuration/01_config_adds.png)

---

Depuis le `Server Manager`

- Cliquer sur `Tools`
- Cliquer sur `Active Directory Domains and Trusts`
- Clique droit sur `billu.lan`
- Cliquer sur `Properties`
- Cliquer sur `Trusts`
- Cliquer sur `New Trust`
- Cliquer sur `Next`
- Dans Name : `ecotech.local`

![image](Ressources/configuration/02_config_adds.png)


![image](Ressources/configuration/03_config_adds.png)


![image](Ressources/configuration/04_config_adds.png)


![image](Ressources/configuration/06_config_adds.png)


![image](Ressources/configuration/07_config_adds.png)


![image](Ressources/configuration/08_config_adds.png)


![image](Ressources/configuration/09_config_adds.png)

- Connexion en RDP autoriser sur notre Serveur de fichiers 'DOM-FS-01'

- Se mettre en Powershell depuis le serveur de fichiers "DOM-FS-01"

On doit activer le `rdp`

```powershell
cscript C:\Windows\System32\Scregedit.wsf /ar 0
```

On ajoute le Groupe Admin `ECOTECH`

```powershell
net localgroup "Remote Desktop Users" "ECOTECH\eco-bdx-gx-gxc" /add
```



