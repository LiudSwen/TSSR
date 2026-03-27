

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

## 🎯 Introduction aux groupes

Les groupes locaux constituent un mécanisme fondamental d'administration Windows permettant de simplifier la gestion des permissions et des droits d'accès. Plutôt que d'attribuer des autorisations individuellement à chaque utilisateur, on regroupe les utilisateurs ayant des besoins similaires et on attribue les permissions au groupe.

> [!info] Définition Un groupe local est un objet de sécurité qui contient des comptes d'utilisateurs, des comptes d'ordinateurs et d'autres groupes. Il sert principalement à attribuer des permissions et des droits sur les ressources locales du serveur.

### Pourquoi utiliser des groupes ?

**Simplification de l'administration** : Au lieu de gérer les permissions utilisateur par utilisateur, vous gérez les permissions groupe par groupe. Si un utilisateur change de fonction, il suffit de modifier son appartenance aux groupes.

**Cohérence des droits** : Tous les membres d'un groupe héritent automatiquement des mêmes permissions, garantissant une uniformité dans la gestion des accès.

**Scalabilité** : L'ajout de nouveaux utilisateurs devient trivial - il suffit de les ajouter aux groupes appropriés.

---

## 🔍 Concept et utilité des groupes

### Principe de fonctionnement

Les groupes locaux fonctionnent selon un principe simple : lorsque vous attribuez une permission à un groupe (par exemple, l'accès en lecture à un dossier), tous les membres de ce groupe héritent automatiquement de cette permission.

```
Groupe "Comptabilité"
    ├── Marie (membre)
    ├── Pierre (membre)
    └── Sophie (membre)
    
Permission : Lecture sur \\Server\Finances
    └── Attribuée au groupe "Comptabilité"
    
Résultat : Marie, Pierre et Sophie peuvent lire \\Server\Finances
```

> [!tip] Astuce Pensez aux groupes comme des "étiquettes" que vous collez sur des utilisateurs. Une permission accordée à l'étiquette s'applique à tous ceux qui la portent.

### Portée des groupes locaux

Les groupes locaux ont une portée **limitée au serveur** sur lequel ils sont créés. Ils ne peuvent contenir que des comptes du serveur local et ne sont reconnus que sur ce serveur.

> [!warning] Limitation importante Les groupes locaux ne sont pas répliqués et n'existent que sur un seul ordinateur. Pour une gestion centralisée dans un environnement Active Directory, on utilise des groupes de domaine (sujet de la Partie 4).

### Types de groupes

Windows distingue deux types de groupes selon leur utilisation :

|Type|Description|Usage typique|
|---|---|---|
|**Groupes de sécurité**|Utilisés pour attribuer des permissions aux ressources|Gestion des accès fichiers, imprimantes, etc.|
|**Groupes de distribution**|Utilisés uniquement pour les listes de diffusion email|Non utilisés pour les permissions (contexte Exchange)|

> [!info] Note Sur un serveur autonome (non membre d'un domaine), seuls les groupes de sécurité sont pertinents. Les groupes de distribution sont principalement utilisés avec Exchange Server.

---

## 🏛️ Groupes intégrés

Windows Server crée automatiquement plusieurs groupes locaux lors de l'installation. Ces groupes intégrés possèdent des droits et privilèges prédéfinis.

### Principaux groupes intégrés

#### 👑 Administrateurs

Le groupe le plus puissant du système local.

**Droits et capacités** :

- Contrôle total sur le serveur
- Installation de logiciels et pilotes
- Modification des paramètres système
- Gestion de tous les comptes utilisateurs
- Accès à toutes les ressources
- Modification des stratégies de sécurité

**Membres par défaut** :

- Le compte Administrateur intégré
- Le compte utilisé lors de l'installation

> [!warning] Sécurité critique L'appartenance au groupe Administrateurs doit être strictement contrôlée. Chaque membre dispose d'un pouvoir absolu sur le système. Principe du moindre privilège : ne donnez ce niveau d'accès qu'en cas de nécessité absolue.

#### 👤 Utilisateurs

Groupe pour les utilisateurs standards du système.

**Droits et capacités** :

- Exécution d'applications
- Utilisation d'imprimantes
- Arrêt et verrouillage du poste
- Modification de leur propre mot de passe
- **Restrictions** : Pas d'installation de logiciels, pas de modification des paramètres système

**Usage typique** : Comptes utilisateurs standards qui n'ont pas besoin de privilèges administratifs.

> [!tip] Bonne pratique La majorité des utilisateurs devraient appartenir uniquement à ce groupe. C'est le principe de sécurité du moindre privilège.

#### 🔧 Utilisateurs avec pouvoir

Groupe intermédiaire entre Utilisateurs et Administrateurs.

**Droits et capacités** :

- Modification de l'heure système
- Modification des paramètres d'affichage
- Ajout d'imprimantes
- Gestion de certains paramètres système
- **Restrictions** : Pas de gestion des utilisateurs, pas d'accès à tous les fichiers système

**Usage** : Utilisateurs nécessitant plus de libertés que les utilisateurs standards, mais sans accès administrateur complet.

> [!info] Note Ce groupe est moins utilisé dans les environnements modernes, où on préfère gérer finement les permissions via d'autres mécanismes.

#### 🔙 Opérateurs de sauvegarde

Groupe spécialisé pour les tâches de sauvegarde.

**Droits et capacités** :

- Sauvegarde et restauration de fichiers (même sans permission en lecture)
- Connexion locale au serveur
- Arrêt du système
- **Particularité** : Contourne les permissions NTFS pour la sauvegarde

**Usage** : Comptes dédiés aux logiciels de sauvegarde ou administrateurs responsables des backups.

> [!example] Cas d'usage Vous avez un logiciel de sauvegarde qui s'exécute sous un compte de service. Ajoutez ce compte au groupe Opérateurs de sauvegarde pour qu'il puisse sauvegarder tous les fichiers sans avoir besoin d'être administrateur.

#### 🖥️ Utilisateurs du Bureau à distance

Groupe pour autoriser les connexions RDP.

**Droits et capacités** :

- Connexion à distance via Remote Desktop Protocol (RDP)
- **Note** : Les membres du groupe Administrateurs ont déjà ce droit par défaut

**Usage** : Utilisateurs devant se connecter au serveur à distance sans être administrateurs.

```powershell
# Ajouter un utilisateur au groupe Utilisateurs du Bureau à distance
Add-LocalGroupMember -Group "Utilisateurs du Bureau à distance" -Member "PrenomNom"
```

#### 📂 Autres groupes intégrés importants

|Groupe|Description|Usage|
|---|---|---|
|**Invités**|Accès temporaire minimal|Comptes invités occasionnels|
|**Opérateurs de configuration réseau**|Modification des paramètres TCP/IP|Gestion réseau sans être admin|
|**Lecteurs des journaux d'événements**|Lecture des journaux d'événements|Monitoring et audit|
|**Utilisateurs de gestion à distance**|Administration à distance via WinRM|Gestion PowerShell distante|
|**Utilisateurs de l'Analyseur de performances**|Consultation des compteurs de performance|Monitoring système|

---

## ⚙️ Création et gestion des groupes

### Méthodes de gestion

Il existe trois façons principales de gérer les groupes locaux :

1. **Interface graphique** : Via Gestion de l'ordinateur
2. **Ligne de commande** : Avec `net localgroup`
3. **PowerShell** : Cmdlets `*-LocalGroup*`

### Gestion via interface graphique

**Accès à la gestion des groupes** :

1. Clic droit sur "Ce PC" → Gérer
2. Ou : `compmgmt.msc` dans Exécuter (Win + R)
3. Naviguer vers : Outils système → Utilisateurs et groupes locaux → Groupes

> [!info] Navigation rapide Vous pouvez aussi taper directement `lusrmgr.msc` pour ouvrir directement la console Utilisateurs et groupes locaux.

#### Créer un nouveau groupe

**Étapes** :

1. Dans la console Utilisateurs et groupes locaux, clic droit sur "Groupes"
2. Sélectionner "Nouveau groupe..."
3. Remplir les informations :
    - **Nom du groupe** : Nom unique et descriptif
    - **Description** : Explication du rôle du groupe
4. Cliquer sur "Créer"

```
Exemple :
Nom du groupe : Comptables_Lyon
Description : Groupe pour les utilisateurs du service comptabilité du site de Lyon
```

> [!tip] Conventions de nommage Adoptez une convention claire : `Service_Site`, `Role_Departement`, etc. Cela facilite la compréhension et la maintenance.

#### Ajouter des membres à un groupe

**Méthode 1 - Depuis le groupe** :

1. Double-clic sur le groupe
2. Cliquer sur "Ajouter..."
3. Entrer les noms d'utilisateurs (séparés par des points-virgules)
4. Cliquer sur "Vérifier les noms"
5. Cliquer sur "OK"

**Méthode 2 - Depuis l'utilisateur** :

1. Double-clic sur l'utilisateur
2. Onglet "Membre de"
3. Cliquer sur "Ajouter..."
4. Sélectionner le groupe
5. Cliquer sur "OK"

> [!tip] Raccourci Pour vérifier rapidement l'appartenance d'un utilisateur : double-clic sur l'utilisateur → onglet "Membre de".

#### Supprimer un membre d'un groupe

1. Double-clic sur le groupe
2. Sélectionner le membre à retirer
3. Cliquer sur "Supprimer"
4. Confirmer

> [!warning] Attention Supprimer un utilisateur d'un groupe lui retire immédiatement tous les droits associés à ce groupe. L'utilisateur devra se reconnecter pour que le changement soit effectif.

#### Supprimer un groupe

1. Clic droit sur le groupe
2. Sélectionner "Supprimer"
3. Confirmer la suppression

> [!warning] Suppression irréversible La suppression d'un groupe est définitive. Les permissions attribuées au groupe seront perdues, même si vous recréez un groupe avec le même nom (car l'identifiant de sécurité SID sera différent).

### Gestion en ligne de commande

La commande `net localgroup` permet de gérer les groupes via l'invite de commandes.

#### Lister tous les groupes

```cmd
net localgroup
```

**Sortie exemple** :

```
Alias pour \\SERVEUR01

-------------------------------------------------------------------------------
*Administrateurs
*Invités
*Opérateurs de sauvegarde
*Utilisateurs
*Utilisateurs du Bureau à distance
Comptables_Lyon
```

#### Afficher les membres d'un groupe

```cmd
net localgroup "Administrateurs"
```

**Sortie exemple** :

```
Nom alias     Administrateurs
Commentaire   Les membres du groupe Administrateurs disposent d'un accès complet

Membres

-------------------------------------------------------------------------------
Administrateur
JeanDupont
```

> [!info] Guillemets Les guillemets sont nécessaires si le nom du groupe contient des espaces.

#### Créer un groupe

```cmd
net localgroup "Support_IT" /add /comment:"Groupe pour l'équipe support informatique"
```

**Explication** :

- `"Support_IT"` : Nom du groupe
- `/add` : Commande de création
- `/comment:"..."` : Description du groupe

#### Ajouter un utilisateur à un groupe

```cmd
net localgroup "Support_IT" "Marie.Martin" /add
```

#### Retirer un utilisateur d'un groupe

```cmd
net localgroup "Support_IT" "Marie.Martin" /delete
```

#### Supprimer un groupe

```cmd
net localgroup "Support_IT" /delete
```

> [!warning] Prudence La suppression d'un groupe via ligne de commande ne demande aucune confirmation. Double-vérifiez avant d'exécuter la commande.

### Gestion via PowerShell

PowerShell offre des cmdlets modernes et puissantes pour gérer les groupes locaux.

#### Lister tous les groupes

```powershell
Get-LocalGroup
```

**Sortie exemple** :

```
Name                           Description
----                           -----------
Administrateurs                Les membres du groupe Administrateurs...
Invités                        Les membres du groupe Invités...
Utilisateurs                   Les membres du groupe Utilisateurs...
```

#### Afficher les membres d'un groupe

```powershell
Get-LocalGroupMember -Group "Administrateurs"
```

**Sortie exemple** :

```
ObjectClass Name                    PrincipalSource
----------- ----                    ---------------
User        SERVEUR01\Administrateur Local
User        SERVEUR01\JeanDupont    Local
```

#### Créer un nouveau groupe

```powershell
New-LocalGroup -Name "DevOps_Team" -Description "Équipe DevOps - Accès aux serveurs de développement"
```

**Paramètres** :

- `-Name` : Nom du groupe (obligatoire)
- `-Description` : Description du groupe (optionnel)

#### Ajouter un utilisateur à un groupe

```powershell
Add-LocalGroupMember -Group "DevOps_Team" -Member "Pierre.Durand"
```

**Ajouter plusieurs utilisateurs simultanément** :

```powershell
Add-LocalGroupMember -Group "DevOps_Team" -Member "Pierre.Durand", "Sophie.Legrand", "Marc.Petit"
```

> [!tip] Efficacité PowerShell permet d'ajouter plusieurs membres en une seule commande, ce qui est impossible avec `net localgroup`.

#### Retirer un utilisateur d'un groupe

```powershell
Remove-LocalGroupMember -Group "DevOps_Team" -Member "Pierre.Durand"
```

#### Vérifier si un utilisateur est membre d'un groupe

```powershell
Get-LocalGroupMember -Group "Administrateurs" | Where-Object {$_.Name -eq "SERVEUR01\JeanDupont"}
```

#### Supprimer un groupe

```powershell
Remove-LocalGroup -Name "DevOps_Team"
```

> [!warning] Confirmation Par défaut, PowerShell demandera confirmation. Utilisez `-Confirm:$false` pour forcer la suppression sans confirmation (à utiliser avec précaution).

#### Script d'exemple : Création d'une structure de groupes

```powershell
# Créer plusieurs groupes pour différents services
$groupes = @(
    @{Name="RH_Lyon"; Description="Service RH du site de Lyon"},
    @{Name="Compta_Lyon"; Description="Service Comptabilité du site de Lyon"},
    @{Name="IT_Support"; Description="Support informatique niveau 1"}
)

foreach ($groupe in $groupes) {
    New-LocalGroup -Name $groupe.Name -Description $groupe.Description
    Write-Host "Groupe $($groupe.Name) créé avec succès" -ForegroundColor Green
}
```

---

## 🔗 Appartenance et imbrication

### Appartenance multiple

Un utilisateur peut appartenir à plusieurs groupes simultanément. Ses permissions effectives sont l'**addition** de toutes les permissions accordées à tous ses groupes.

```
Utilisateur : Sophie.Martin
    ├── Membre de : Utilisateurs (permissions de base)
    ├── Membre de : Comptables_Lyon (accès \\Server\Finances)
    └── Membre de : Auditeurs (accès en lecture \\Server\Audit)

Résultat : Sophie a toutes ces permissions cumulées
```

> [!example] Cas pratique Marie est membre des groupes "Utilisateurs", "Support_IT" et "Utilisateurs du Bureau à distance". Elle peut se connecter à distance (grâce au 3ème groupe) et accéder aux outils de support (grâce au 2ème groupe), en plus des droits utilisateurs de base.

### Imbrication de groupes

L'imbrication (ou "nesting") consiste à ajouter un groupe comme membre d'un autre groupe.

**Structure exemple** :

```
Groupe : Accès_Serveurs_Prod
    ├── DevOps_Team (groupe)
    │   ├── Pierre.Durand (utilisateur)
    │   └── Sophie.Legrand (utilisateur)
    └── Admins_Systeme (groupe)
        ├── Marc.Petit (utilisateur)
        └── Julie.Grand (utilisateur)
```

**Avantage** : Vous pouvez attribuer une permission au groupe parent, et tous les membres des groupes enfants héritent de cette permission.

```powershell
# Ajouter un groupe à un autre groupe
Add-LocalGroupMember -Group "Accès_Serveurs_Prod" -Member "DevOps_Team"
```

> [!tip] Simplification L'imbrication permet de créer des hiérarchies logiques. Plutôt que d'ajouter 20 utilisateurs individuellement, ajoutez leurs groupes respectifs.

### Limitations de l'imbrication locale

> [!warning] Limite importante Les groupes locaux peuvent contenir :
> 
> - Des utilisateurs locaux
> - D'autres groupes locaux
> - Des utilisateurs et groupes de domaine (si le serveur est membre d'un domaine)
> 
> **Mais** l'imbrication reste limitée à un niveau dans un contexte purement local.

### Vérification de l'appartenance effective

Pour connaître tous les groupes (directs et indirects) auxquels appartient un utilisateur :

```powershell
# Voir tous les groupes d'un utilisateur
Get-LocalUser -Name "Sophie.Martin" | Select-Object -ExpandProperty MemberOf
```

**Via ligne de commande (depuis la session de l'utilisateur)** :

```cmd
whoami /groups
```

Cette commande affiche tous les groupes de l'utilisateur actuellement connecté, avec leurs SID et attributs.

---

## ✅ Bonnes pratiques

### Principe du moindre privilège

Accordez uniquement les droits nécessaires à l'accomplissement des tâches.

> [!tip] Règle d'or Par défaut, tout utilisateur devrait être simple membre du groupe "Utilisateurs". N'ajoutez aux groupes privilégiés que ceux qui en ont réellement besoin.

**Exemple** : Un comptable n'a pas besoin d'être administrateur pour faire son travail. Créez un groupe "Comptables" avec accès au dossier finances, et ajoutez-le uniquement à ce groupe.

### Utilisation de groupes plutôt que d'utilisateurs individuels

> [!warning] À éviter Attribuer des permissions directement aux utilisateurs individuels.

> [!tip] À privilégier Créer des groupes basés sur les rôles et attribuer les permissions aux groupes.

**Pourquoi ?**

- Facilite la maintenance (ajout/retrait d'utilisateurs)
- Améliore la traçabilité (qui a accès à quoi)
- Réduit les erreurs (uniformité des droits)

### Convention de nommage cohérente

Adoptez une convention claire et documentée pour nommer vos groupes.

**Exemples de conventions** :

```
Format : [Type]_[Service]_[Site]_[Niveau]

Exemples :
- GRP_Compta_Lyon_Lecture
- GRP_IT_Support_Admin
- GRP_RH_Paris_Modification
```

**Préfixes utiles** :

- `GRP_` : Indique qu'il s'agit d'un groupe
- `LOC_` : Groupe local
- `ADM_` : Groupe administratif

> [!info] Pourquoi ? Une convention cohérente facilite la recherche, la compréhension et la maintenance, surtout dans les grandes organisations.

### Documentation des groupes

Utilisez systématiquement le champ "Description" lors de la création de groupes.

```powershell
New-LocalGroup -Name "Support_Niveau2" -Description "Support IT niveau 2 - Accès privilégiés pour dépannage avancé. Contact: it-support@entreprise.com"
```

**Informations à inclure** :

- Rôle du groupe
- Ressources accessibles
- Contact du responsable
- Date de création/révision

### Audit régulier des appartenances

Planifiez des revues périodiques des appartenances aux groupes, particulièrement les groupes privilégiés.

```powershell
# Script pour auditer les membres du groupe Administrateurs
Get-LocalGroupMember -Group "Administrateurs" | 
    Select-Object Name, ObjectClass, PrincipalSource |
    Export-Csv -Path "C:\Audit\Admins_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation
```

> [!tip] Fréquence recommandée
> 
> - Groupes administratifs : Mensuel
> - Groupes sensibles : Trimestriel
> - Autres groupes : Semestriel ou annuel

### Séparation des comptes administrateurs

Les administrateurs devraient avoir deux comptes :

1. **Compte utilisateur standard** : Pour les tâches quotidiennes (email, navigation, bureautique)
2. **Compte administrateur** : Utilisé uniquement pour les tâches administratives

```
Jean Dupont possède :
- jdupont (membre de : Utilisateurs) → Usage quotidien
- admin_jdupont (membre de : Administrateurs) → Administration uniquement
```

> [!warning] Sécurité Ne pas utiliser un compte administrateur pour la navigation Internet ou la lecture d'emails réduit considérablement le risque d'infection ou de compromission.

### Limitation des membres du groupe Administrateurs

Le groupe Administrateurs devrait contenir le strict minimum de comptes.

> [!tip] Recommandation Idéalement, maximum 2-3 comptes dans le groupe Administrateurs sur un serveur en production.

**Alternative** : Utilisez des groupes spécialisés avec des droits spécifiques plutôt que de multiplier les administrateurs complets.

### Suppression des groupes inutilisés

Les groupes obsolètes doivent être supprimés pour maintenir un environnement propre.

**Processus recommandé** :

1. Identifier les groupes sans membres
2. Vérifier qu'aucune permission n'y est attachée
3. Les supprimer ou les documenter comme "obsolètes"

```powershell
# Lister les groupes vides
Get-LocalGroup | Where-Object {
    (Get-LocalGroupMember -Group $_.Name -ErrorAction SilentlyContinue).Count -eq 0
}
```

### Éviter les imbrications complexes

> [!warning] Piège courant Des imbrications de groupes trop profondes ou circulaires rendent la gestion difficile et peuvent causer des problèmes de permissions.

**Recommandation** : Limitez l'imbrication à 1-2 niveaux maximum dans un contexte de groupes locaux.

---

## 🎓 Points clés à retenir

> [!info] Résumé
> 
> - Les groupes simplifient la gestion des permissions en regroupant des utilisateurs ayant des besoins similaires
> - Les groupes locaux existent uniquement sur le serveur où ils sont créés
> - Windows fournit des groupes intégrés avec des droits prédéfinis (Administrateurs, Utilisateurs, etc.)
> - Trois méthodes de gestion : Interface graphique, ligne de commande (`net localgroup`), PowerShell
> - Un utilisateur peut appartenir à plusieurs groupes (cumul des permissions)
> - L'imbrication permet d'ajouter des groupes dans d'autres groupes
> - Toujours appliquer le principe du moindre privilège
> - Utiliser des conventions de nommage cohérentes et documenter les groupes

---

_Ce cours couvre la gestion des groupes locaux sur Windows Server. Pour la gestion centralisée des groupes dans Active Directory, référez-vous à la Partie 4 du programme._