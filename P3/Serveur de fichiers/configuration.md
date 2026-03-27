e## Sommaire

- [Chapitre 1 – Pré-requis](#chapitre-1--pré-requis)
  - [1.1 Environnement Active Directory](#11-environnement-active-directory)
  - [1.2 Comptes et groupes Active Directory](#12-comptes-et-groupes-active-directory)
  - [1.3 Serveur de fichiers](#13-serveur-de-fichiers)
  - [1.4 Partages SMB existants](#14-partages-smb-existants)

- [Chapitre 2 – Ajout du serveur de fichiers dans Server Manager](#chapitre-2--ajout-du-serveur-de-fichiers-dans-server-manager)
  - [2.2 Ajout du serveur](#22-ajout-du-serveur)
  - [2.3 Vérification](#23-vérification)

- [Chapitre 3 – DEPARTEMENTS – Lecteur K](#chapitre-3--departements--lecteur-k)
  - [3.1 Arborescence NTFS](#31-arborescence-ntfs)
  - [3.2 Création du partage SMB](#32-création-du-partage-smb)
  - [3.3 Permissions NTFS – Racine DEPARTEMENTS](#33-permissions-ntfs--racine-departements)
  - [3.4 Permissions NTFS – Dossiers de département](#34-permissions-ntfs--dossiers-de-département)
  - [3.5 Création de la GPO de mappage](#35-création-de-la-gpo-de-mappage)

- [Chapitre 4 – SERVICES – Lecteur J](#chapitre-4--services--lecteur-j)
  - [4.1 Arborescence NTFS](#41-arborescence-ntfs)
  - [4.2 Création du partage SMB](#42-création-du-partage-smb)
  - [4.3 Permissions NTFS – Racine SERVICES](#43-permissions-ntfs--racine-services)
  - [4.4 Permissions NTFS – Dossiers de service](#44-permissions-ntfs--dossiers-de-service)
  - [4.5 Création de la GPO de mappage](#45-création-de-la-gpo-de-mappage)

- [Chapitre 5 – HOME – Lecteur I](#chapitre-5--home--lecteur-i)
  - [5.1 Arborescence NTFS](#51-arborescence-ntfs)
  - [5.2 Création du partage SMB](#52-création-du-partage-smb)
  - [5.3 Permissions NTFS – Racine HOME](#53-permissions-ntfs--racine-home)
  - [5.4 Création de la GPO de création automatique](#54-création-de-la-gpo-de-création-automatique)
  - [5.5 Création de la GPO de mappage](#55-création-de-la-gpo-de-mappage)

# Chapitre 1 – Pré-requis

## 1.1 Environnement Active Directory

- Un domaine Active Directory fonctionnel est en place
- Le serveur `DOM-FS-01` est joint au domaine et synchronisé avec l'AD (DNS fonctionnel)
- Les contrôleurs de domaine sont opérationnels et accessibles depuis `DOM-FS-01`

## 1.2 Comptes et groupes Active Directory

Les groupes suivants existent dans Active Directory :

**Groupes de départements**

- `GRP_DEP_<DEPARTEMENT>_USERS` (un groupe par département)

**Groupes de services**

- `GRP_SVC_<SERVICE>_USERS` (un groupe par service)

**Groupe d'administration**

- `GRP_SEC_ADMIN_USERS` (administration du serveur de fichiers et des données)

## 1.3 Serveur de fichiers

- Système : Windows Server
- Nom : `DOM-FS-01`
- Rôle **File Server** installé
- Volume de données : `E:\DATA` formaté en NTFS

## 1.4 Partages SMB existants

|Partage|Chemin NTFS|
|---|---|
|`HOME`|`E:\DATA\HOME`|
|`DEPARTEMENTS`|`E:\DATA\DEPARTEMENTS`|
|`SERVICES`|`E:\DATA\SERVICES`|

**Configuration commune :**

- Access-Based Enumeration (ABE) activée
- Pas de droits utilisateurs directs sur la racine NTFS
- Accès contrôlé exclusivement par groupes AD

---

# Chapitre 2 – Ajout du serveur de fichiers dans Server Manager

## 2.2 Ajout du serveur

1. Ouvrir **Server Manager**
2. Cliquer sur **Manage** (coin supérieur droit)
3. Sélectionner **Add Servers**
4. Dans la fenêtre "Add Servers" :
    - Onglet **Active Directory**
    - Saisir `DOM-FS-01` dans le champ de recherche
    - Cliquer sur **Find Now**
    - Sélectionner `DOM-FS-01` dans la liste
    - Cliquer sur la flèche pour l'ajouter à la liste "Selected"
5. Cliquer sur **OK**

## 2.3 Vérification

Dans Server Manager :

- Accéder à **All Servers** (volet de gauche)
- Vérifier que `DOM-FS-01` apparaît dans la liste avec :
    - Nom
    - État (Online)
    - Adresse IP
    - Système d'exploitation

Aucune alerte critique ne doit être présente.

---

# Chapitre 3 – DEPARTEMENTS – Lecteur K

## 3.1 Arborescence NTFS

**Emplacement :** `E:\DATA\DEPARTEMENTS`

**Structure :**

```
E:\DATA\DEPARTEMENTS
├── COMPTA
├── DEV
├── DSI
├── RH
└── ...
```

Un dossier par département. Aucun fichier directement à la racine.

## 3.2 Création du partage SMB

1. Ouvrir **Server Manager**
2. Cliquer sur **File and Storage Services** → **Shares**
3. Cliquer sur **TASKS** → **New Share**
4. Sélectionner **SMB Share - Quick**
5. Paramètres :
    - **Share location** : `E:\DATA\DEPARTEMENTS`
    - **Share name** : `DEPARTEMENTS`
    - **Enable access-based enumeration** : Coché
    - **Offline Settings** : Only the files and programs that users specify are available offline

### Permissions de partage

**Share Permissions** :

|Groupe|Droit|
|---|---|
|`GRP_SEC_ADMIN_USERS`|Full Control|
|`Authenticated Users`|Read|


## 3.3 Permissions NTFS – Racine DEPARTEMENTS

1. Dans le finder
2. Clic droit sur `E:\DATA\DEPARTEMENTS` → **Properties**
3. Onglet **Security** → **Advanced**
4. Désactiver l'héritage : **Disable inheritance** → **Convert inherited permissions into explicit permissions**
5. Supprimer toutes les entrées sauf SYSTEM
6. Ajouter les permissions suivantes :

|Principal|Droits|Portée|
|---|---|---|
|`SYSTEM`|Full Control|This folder, subfolders and files|
|`GRP_SEC_ADMIN_USERS`|Full Control|This folder, subfolders and files|
|`Authenticated Users`|Traverse folder / Execute file|This folder only|

**Configuration de "Authenticated Users" :**

- Cliquer sur **Add** → **Select a principal** → `Authenticated Users`
- **Type** : Allow
- **Applies to** : This folder only
- Cliquer sur **Show advanced permissions**
- Cocher uniquement :
    - `Traverse folder / Execute file`
    - `List folder / Read data` (décocher si coché)
    - `Read attributes`
    - `Read extended attributes`
    - `Read permissions`

## 3.4 Permissions NTFS – Dossiers de département

Pour chaque dossier département (exemple : `E:\DATA\DEPARTEMENTS\DEV`) :

1. Clic droit → **Properties** → **Security** → **Advanced**
2. **Disable inheritance** → **Remove all inherited permissions**
3. Ajouter les permissions :

|Principal|Droits|Portée|
|---|---|---|
|`SYSTEM`|Full Control|This folder, subfolders and files|
|`GRP_SEC_ADMIN_USERS`|Full Control|This folder, subfolders and files|
|`GRP_DEP_DEV_USERS`|Modify|This folder, subfolders and files|

Répéter pour chaque département en adaptant le groupe (GRP_DEP_COMPTA_USERS, GRP_DEP_RH_USERS, etc.).

## 3.5 Création de la GPO de mappage

### Création de la GPO

1. Ouvrir **Group Policy Management** (GPMC)
2. Naviguer vers Group Plicy Objects
3. Clic droit → **Create a GPO in this domain, and Link it here**
4. Nom : `GPO-FS-DEPARTEMENTS-K`

### Configuration du mappage

1. Clic droit sur la GPO → **Edit**
2. Naviguer vers :
    
	```
    User Configuration
    └── Preferences    
    └── Windows Settings        
    └── Drive Maps
    ```
    
3. Clic droit → **New** → **Mapped Drive**
4. Paramètres :

|Paramètre|Valeur|
|---|---|
|Action|Create|
|Location|`\\DOM-FS-01\DEPARTEMENTS`|
|Reconnect|Coché|
|Label as|`DEPARTEMENTS`|
|Drive Letter|K:|
|Use|(vide)|

5. Cliquer sur **OK**

### Filtrage de sécurité

1. Fermer l'éditeur de GPO
2. Dans GPMC, sélectionner la GPO `GPO_FS_DEPARTEMENTS_K`
3. Onglet **Scope** → Section **Security Filtering**
4. Supprimer **Authenticated Users**
5. Cliquer sur **Add** et ajouter tous les groupes :
    - `GRP_DEP_COMPTA_USERS`
    - `GRP_DEP_DEV_USERS`
    - `GRP_DEP_DSI_USERS`
    - `GRP_DEP_RH_USERS`
    - etc.

---

# Chapitre 4 – SERVICES – Lecteur J

## 4.1 Arborescence NTFS

**Emplacement :** `E:\DATA\SERVICES`

**Structure :**

```
E:\DATA\SERVICES
├── AD
├── SUPPORT
├── FINANCE
├── QA
└── ...
```

Un dossier par service. Aucun fichier directement à la racine.

## 4.2 Création du partage SMB

1. Ouvrir **Server Manager**
2. **File and Storage Services** → **Shares**
3. **TASKS** → **New Share**
4. Sélectionner **SMB Share - Quick**
5. Paramètres :
    - **Share location** : `E:\DATA\SERVICES`
    - **Share name** : `SERVICES`
    - **Enable access-based enumeration** : Coché
    - **Offline Settings** : Only the files and programs that users specify are available offline

### Permissions de partage

**Share Permissions** :

|Groupe|Droit|
|---|---|
|`GRP_SEC_ADMIN_USERS`|Full Control|
|`Authenticated Users`|Read|

## 4.3 Permissions NTFS – Racine SERVICES

1. Clic droit sur `E:\DATA\SERVICES` → **Properties**
2. **Security** → **Advanced**
3. **Disable inheritance** → **Convert inherited permissions into explicit permissions**
4. Supprimer toutes les entrées sauf SYSTEM
5. Ajouter les permissions :

|Principal|Droits|Portée|
|---|---|---|
|`SYSTEM`|Full Control|This folder, subfolders and files|
|`GRP_SEC_ADMIN_USERS`|Full Control|This folder, subfolders and files|
|`Authenticated Users`|Traverse folder / Execute file|This folder only|

Configuration identique au chapitre 3.3.

## 4.4 Permissions NTFS – Dossiers de service

Pour chaque dossier service (exemple : `E:\DATA\SERVICES\SUPPORT`) :

1. Clic droit → **Properties** → **Security** → **Advanced**
2. **Disable inheritance** → **Remove all inherited permissions**
3. Ajouter les permissions :

|Principal|Droits|Portée|
|---|---|---|
|`SYSTEM`|Full Control|This folder, subfolders and files|
|`GRP_SEC_ADMIN_USERS`|Full Control|This folder, subfolders and files|
|`GRP_SVC_SUPPORT_USERS`|Modify|This folder, subfolders and files|

Répéter pour chaque service en adaptant le groupe.

Un utilisateur peut être membre de plusieurs groupes `GRP_SVC_*_USERS`.

## 4.5 Création de la GPO de mappage

### Création de la GPO

1. Ouvrir **Group Policy Management** (GPMC)
2. Naviguer vers Group Plicy Objects
3. Clic droit → **Create a GPO in this domain, and Link it here**
4. Nom : `GPO-FS-SERVICES-J`

### Configuration du mappage

1. Clic droit sur la GPO → **Edit**
2. Naviguer vers :
    
    ```
    User Configuration
    └── Preferences    
    └── Windows Settings        
    └── Drive Maps
    ```
    
3. Clic droit → **New** → **Mapped Drive**
4. Paramètres :

|Paramètre|Valeur|
|---|---|
|Action|Create|
|Location|`\\DOM-FS-01\SERVICES`|
|Reconnect|Coché|
|Label as|`SERVICES`|
|Drive Letter|J:|

5. Cliquer sur **OK**

### Filtrage de sécurité

1. Fermer l'éditeur de GPO
2. Dans GPMC, sélectionner la GPO `GPO_FS_SERVICES_J`
3. **Scope** → **Security Filtering**
4. Supprimer **Authenticated Users**
5. Ajouter tous les groupes :
    - `GRP_SVC_AD_USERS`
    - `GRP_SVC_SUPPORT_USERS`
    - `GRP_SVC_FINANCE_USERS`
    - `GRP_SVC_QA_USERS`
    - etc.


---

# Chapitre 5 – HOME – Lecteur I

## 5.1 Arborescence NTFS

**Emplacement :** `E:\DATA\HOME`

**Structure :**

```
E:\DATA\HOME
├── alice.dupont
├── bob.martin
└── ...
```

Un dossier par utilisateur. Le nom du dossier correspond strictement à `%USERNAME%`.

## 5.2 Création du partage SMB

1. Ouvrir **Server Manager**
2. **File and Storage Services** → **Shares**
3. **TASKS** → **New Share**
4. Sélectionner **SMB Share - Quick**
5. Paramètres :
    - **Share location** : `E:\DATA\HOME`
    - **Share name** : `HOME`
    - **Enable access-based enumeration** : Coché
    - **Offline Settings** : Only the files and programs that users specify are available offline

### Permissions de partage

**Share Permissions** :

|Groupe|Droit|
|---|---|
|`GRP_SEC_ADMIN_USERS`|Full Control|
|`Authenticated Users`|Read|

## 5.3 Permissions NTFS – Racine HOME

1. Clic droit sur `E:\DATA\HOME` → **Properties**
2. **Security** → **Advanced**
3. **Disable inheritance** → **Convert inherited permissions into explicit permissions**
4. Supprimer toutes les entrées sauf SYSTEM
5. Ajouter les permissions suivantes :

|Principal|Droits|Portée|
|---|---|---|
|`SYSTEM`|Full Control|This folder, subfolders and files|
|`GRP_SEC_ADMIN_USERS`|Full Control|This folder, subfolders and files|
|`CREATOR OWNER`|Full Control|Subfolders and files only|
|`Authenticated Users`|Traverse + Create folders|This folder only|

### Configuration de "Authenticated Users"

1. **Add** → **Select a principal** → `Authenticated Users`
2. **Type** : Allow
3. **Applies to** : This folder only
4. **Show advanced permissions** et cocher :
    - `Traverse folder / Execute file`
    - `Create folders / Append data`
    - `Read attributes`
    - `Read extended attributes`
    - `Read permissions`

### Configuration de "CREATOR OWNER"

1. **Add** → **Select a principal** → `CREATOR OWNER`
2. **Type** : Allow
3. **Applies to** : Subfolders and files only
4. Cocher **Full Control**

**Fonctionnement :**

- **Create folders / Append data** : permet aux utilisateurs de créer leur dossier personnel
- **Traverse folder** : permet d'accéder au sous-dossier sans voir le contenu de la racine
- **CREATOR OWNER** : l'utilisateur qui crée le dossier en devient propriétaire avec droits complets

## 5.4 Création de la GPO de création automatique

### Création de la GPO

1. Ouvrir **Group Policy Management** (GPMC)
2. Naviguer vers Group Plicy Objects
3. Clic droit → **Create a GPO in this domain, and Link it here**
4. Nom : `GPO-FS-HOME-CREATE`

### Configuration de la création du dossier

1. Clic droit sur la GPO → **Edit**
2. Naviguer vers :
    
    ```
    User Configuration
    └── Preferences    
    └── Windows Settings        
    └── Folders
    ```
    
3. Clic droit → **New** → **Folder**
4. Paramètres :

|Paramètre|Valeur|
|---|---|
|Action|Create|
|Path|`\\DOM-FS-01\HOME\%USERNAME%`|

5. Cliquer sur **OK**

### Filtrage de sécurité

1. Fermer l'éditeur de GPO
2. Dans GPMC, sélectionner la GPO `GPO_FS_HOME_CREATE`
3. **Scope** → **Security Filtering**
4. Vérifier que **Authenticated Users**

## 5.5 Création de la GPO de mappage

### Création de la GPO

1. Ouvrir **Group Policy Management** (GPMC)
2. Naviguer vers Group Plicy Objects
3. Clic droit → **Create a GPO in this domain, and Link it here**
4. Nom : `GPO-FS-HOME-I`

### Configuration du mappage

1. Clic droit sur la GPO → **Edit**
2. Naviguer vers :
    
    ```
    User Configuration
    └── Preferences    
    └── Windows Settings        
    └── Drive Maps
    ```
    
3. Clic droit → **New** → **Mapped Drive**
4. Paramètres :

|Paramètre|Valeur|
|---|---|
|Action|Create|
|Location|`\\DOM-FS-01\HOME\%USERNAME%`|
|Reconnect|Coché|
|Label as|`HOME`|
|Drive Letter|I:|

5. Cliquer sur **OK**

### Filtrage de sécurité

1. Fermer l'éditeur de GPO
2. Dans GPMC, sélectionner la GPO `GPO_FS_HOME_I`
3. **Scope** → **Security Filtering**
4. Vérifier que **Authenticated Users**
