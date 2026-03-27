

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

## 🔍 Get-ADUser - Récupération d'utilisateurs {#get-aduser}

La cmdlet `Get-ADUser` est l'outil fondamental pour interroger et récupérer des informations sur les comptes utilisateurs dans Active Directory. Elle permet de rechercher des utilisateurs selon divers critères et d'extraire leurs propriétés pour l'administration, les audits ou les rapports.

> [!info] Pourquoi Get-ADUser ?
> 
> - Consultation rapide des informations utilisateurs
> - Génération de rapports d'audit
> - Vérification de l'état des comptes
> - Base pour des scripts d'automatisation
> - Export de données pour migration ou analyse

### 📌 Paramètres de recherche {#paramètres-de-recherche}

#### Identity - Recherche d'un utilisateur spécifique

Le paramètre `-Identity` permet de cibler un utilisateur unique en utilisant différents identifiants :

```powershell
# Par SamAccountName (nom de connexion)
Get-ADUser -Identity "jdupont"

# Par Distinguished Name (DN)
Get-ADUser -Identity "CN=Jean Dupont,OU=Utilisateurs,DC=entreprise,DC=local"

# Par GUID (identifiant unique)
Get-ADUser -Identity "a8f3c2d1-4b5e-6f7a-8b9c-0d1e2f3a4b5c"

# Par SID (Security Identifier)
Get-ADUser -Identity "S-1-5-21-123456789-987654321-111111111-1234"
```

> [!tip] Conseil pratique Le SamAccountName est généralement le plus simple et le plus lisible pour les scripts quotidiens. Le GUID et le SID sont utiles pour garantir l'unicité absolue, même après un renommage.

#### Filter - Critères de recherche avancés

Le paramètre `-Filter` est **obligatoire** lorsque vous n'utilisez pas `-Identity`. Il permet de définir des critères de recherche :

```powershell
# Syntaxe de base
Get-ADUser -Filter "PropertyName -Operator 'Value'"

# Tous les utilisateurs (attention aux performances !)
Get-ADUser -Filter *

# Utilisateurs actifs uniquement
Get-ADUser -Filter "Enabled -eq $true"

# Combinaison de critères avec AND/OR
Get-ADUser -Filter "Enabled -eq $true -and Department -eq 'IT'"
Get-ADUser -Filter "(Department -eq 'IT') -or (Department -eq 'Support')"
```

**Opérateurs de comparaison disponibles :**

|Opérateur|Description|Exemple|
|---|---|---|
|`-eq`|Égal à|`"Enabled -eq $true"`|
|`-ne`|Différent de|`"Department -ne 'RH'"`|
|`-lt`|Inférieur à|`"EmployeeNumber -lt 1000"`|
|`-le`|Inférieur ou égal|`"EmployeeNumber -le 999"`|
|`-gt`|Supérieur à|`"EmployeeNumber -gt 5000"`|
|`-ge`|Supérieur ou égal|`"EmployeeNumber -ge 5001"`|
|`-like`|Correspondance avec wildcards|`"Name -like 'Dupon*'"`|
|`-notlike`|Non correspondance|`"Name -notlike '*test*'"`|

> [!warning] Attention aux performances Le filtre `Get-ADUser -Filter *` récupère TOUS les utilisateurs du domaine. Sur de grands annuaires, cela peut être très lent et consommer beaucoup de ressources. Préférez toujours des filtres spécifiques.

#### LDAPFilter - Filtres LDAP avancés

Pour des requêtes complexes, le paramètre `-LDAPFilter` utilise la syntaxe LDAP native :

```powershell
# Syntaxe LDAP (plus technique mais plus puissante)
Get-ADUser -LDAPFilter "(department=IT)"

# Filtres composés
Get-ADUser -LDAPFilter "(&(enabled=TRUE)(department=IT))"

# Négation
Get-ADUser -LDAPFilter "(!(department=RH))"

# Wildcards
Get-ADUser -LDAPFilter "(mail=*@entreprise.com)"
```

> [!info] Filter vs LDAPFilter
> 
> - `-Filter` : syntaxe PowerShell, plus lisible, recommandé
> - `-LDAPFilter` : syntaxe LDAP native, plus puissant pour certaines requêtes complexes Les deux ne peuvent pas être utilisés simultanément.

#### SearchBase - Cibler une OU spécifique

Le paramètre `-SearchBase` limite la recherche à une Organizational Unit (OU) particulière :

```powershell
# Recherche dans une OU spécifique
Get-ADUser -Filter * -SearchBase "OU=Informatique,OU=Utilisateurs,DC=entreprise,DC=local"

# Combine avec d'autres filtres
Get-ADUser -Filter "Enabled -eq $true" `
           -SearchBase "OU=Direction,DC=entreprise,DC=local"
```

> [!tip] Optimisation des performances Utiliser `-SearchBase` réduit considérablement le périmètre de recherche et améliore les performances, surtout dans de grandes infrastructures AD.

#### SearchScope - Profondeur de recherche

Le paramètre `-SearchScope` définit la profondeur de recherche dans l'arborescence :

```powershell
# Base : uniquement l'objet spécifié dans SearchBase
Get-ADUser -Filter * -SearchBase "OU=IT,DC=entreprise,DC=local" -SearchScope Base

# OneLevel : uniquement les enfants directs (1 niveau)
Get-ADUser -Filter * -SearchBase "OU=IT,DC=entreprise,DC=local" -SearchScope OneLevel

# Subtree : tous les niveaux descendants (par défaut)
Get-ADUser -Filter * -SearchBase "OU=IT,DC=entreprise,DC=local" -SearchScope Subtree
```

**Comparaison visuelle :**

```
OU=IT
├── User1          ← OneLevel trouve cet utilisateur
├── User2          ← OneLevel trouve cet utilisateur
└── OU=Dev
    ├── User3      ← Subtree trouve cet utilisateur (OneLevel ne le trouve pas)
    └── User4      ← Subtree trouve cet utilisateur (OneLevel ne le trouve pas)
```

---

### 🏷️ Propriétés et attributs {#propriétés-et-attributs}

Par défaut, `Get-ADUser` ne retourne qu'un **ensemble limité de propriétés**. Pour obtenir plus d'informations, utilisez le paramètre `-Properties`.

#### Propriétés par défaut

Sans spécifier `-Properties`, vous obtenez uniquement :

```powershell
Get-ADUser -Identity "jdupont"

# Retourne :
# DistinguishedName
# Enabled
# GivenName
# Name
# ObjectClass
# ObjectGUID
# SamAccountName
# SID
# Surname
# UserPrincipalName
```

#### Properties - Demander des propriétés supplémentaires

```powershell
# Une propriété spécifique
Get-ADUser -Identity "jdupont" -Properties EmailAddress

# Plusieurs propriétés
Get-ADUser -Identity "jdupont" -Properties EmailAddress, Department, Title, Manager

# TOUTES les propriétés (attention aux performances !)
Get-ADUser -Identity "jdupont" -Properties *
```

> [!warning] Performance avec -Properties * Demander toutes les propriétés avec `-Properties *` peut être très lent et consommer beaucoup de bande passante réseau. Ne l'utilisez que pour l'exploration ponctuelle, jamais en production sur de nombreux utilisateurs.

#### Propriétés courantes et leur usage

**Identité et authentification :**

```powershell
# SamAccountName : nom de connexion (pré-Windows 2000)
Get-ADUser -Filter * -Properties SamAccountName

# UserPrincipalName (UPN) : format email pour connexion
Get-ADUser -Filter * -Properties UserPrincipalName

# DistinguishedName (DN) : chemin complet dans AD
Get-ADUser -Filter * -Properties DistinguishedName
```

**Informations personnelles :**

```powershell
# Nom et prénom
Get-ADUser -Filter * -Properties GivenName, Surname, DisplayName

# Coordonnées
Get-ADUser -Filter * -Properties EmailAddress, OfficePhone, MobilePhone

# Fonction et département
Get-ADUser -Filter * -Properties Title, Department, Company, Office
```

**État du compte :**

```powershell
# Statut et sécurité
Get-ADUser -Filter * -Properties Enabled, LockedOut, PasswordExpired

# Dates importantes
Get-ADUser -Filter * -Properties LastLogonDate, WhenCreated, WhenChanged

# Expiration du compte
Get-ADUser -Filter * -Properties AccountExpirationDate
```

**Relations hiérarchiques :**

```powershell
# Manager (supérieur hiérarchique)
Get-ADUser -Identity "jdupont" -Properties Manager

# Groupes d'appartenance
Get-ADUser -Identity "jdupont" -Properties MemberOf
```

> [!example] Exemple complet - Audit utilisateur
> 
> ```powershell
> # Récupérer un profil utilisateur complet
> Get-ADUser -Identity "jdupont" -Properties `
>     DisplayName, EmailAddress, Title, Department, `
>     Manager, OfficePhone, Office, `
>     Enabled, LastLogonDate, PasswordLastSet, `
>     MemberOf | Select-Object `
>     Name, DisplayName, EmailAddress, Title, Department, `
>     @{Name='Manager';Expression={(Get-ADUser $_.Manager).Name}}, `
>     Enabled, LastLogonDate, PasswordLastSet, `
>     @{Name='Groups';Expression={$_.MemberOf.Count}}
> ```

#### Accès aux propriétés dans les résultats

```powershell
# Stocker le résultat dans une variable
$user = Get-ADUser -Identity "jdupont" -Properties EmailAddress, Department

# Accéder aux propriétés
$user.EmailAddress
$user.Department
$user.DistinguishedName

# Vérifier si une propriété existe
if ($user.EmailAddress) {
    Write-Host "Email : $($user.EmailAddress)"
}
```

---

### 🎯 Filtres courants {#filtres-courants}

Voici des exemples de filtres fréquemment utilisés dans l'administration quotidienne.

#### Filtres sur l'état du compte

```powershell
# Tous les comptes actifs
Get-ADUser -Filter "Enabled -eq $true"

# Tous les comptes désactivés
Get-ADUser -Filter "Enabled -eq $false"

# Comptes verrouillés
Get-ADUser -Filter * -Properties LockedOut | Where-Object {$_.LockedOut -eq $true}

# Comptes avec mot de passe expiré
Get-ADUser -Filter * -Properties PasswordExpired | Where-Object {$_.PasswordExpired -eq $true}
```

> [!info] Différence Filter vs Where-Object
> 
> - `-Filter` : filtrage côté serveur AD (plus rapide, recommandé)
> - `Where-Object` : filtrage côté client PowerShell (plus lent mais nécessaire pour certaines propriétés)

#### Filtres sur le département et l'organisation

```powershell
# Utilisateurs d'un département spécifique
Get-ADUser -Filter "Department -eq 'IT'" -Properties Department

# Plusieurs départements
Get-ADUser -Filter "Department -eq 'IT' -or Department -eq 'Support'" -Properties Department

# Exclure un département
Get-ADUser -Filter "Department -ne 'RH'" -Properties Department

# Utilisateurs sans département
Get-ADUser -Filter "Department -notlike '*'" -Properties Department
```

#### Filtres sur les emails et contacts

```powershell
# Utilisateurs d'un domaine email spécifique
Get-ADUser -Filter "EmailAddress -like '*@entreprise.com'" -Properties EmailAddress

# Utilisateurs SANS email
Get-ADUser -Filter "EmailAddress -notlike '*'" -Properties EmailAddress

# Utilisateurs avec un numéro de téléphone
Get-ADUser -Filter "OfficePhone -like '*'" -Properties OfficePhone
```

#### Filtres sur les dates

```powershell
# Utilisateurs créés après une date
$date = Get-Date "2024-01-01"
Get-ADUser -Filter "WhenCreated -gt $date" -Properties WhenCreated

# Dernière connexion récente (moins de 30 jours)
$date = (Get-Date).AddDays(-30)
Get-ADUser -Filter "LastLogonDate -gt $date" -Properties LastLogonDate

# Comptes inactifs (pas de connexion depuis 90 jours)
$date = (Get-Date).AddDays(-90)
Get-ADUser -Filter * -Properties LastLogonDate | 
    Where-Object {$_.LastLogonDate -lt $date}
```

> [!warning] LastLogonDate vs LastLogon
> 
> - `LastLogonDate` : répliqué, précision ~14 jours, plus pratique
> - `LastLogon` : non répliqué, précis, nécessite interrogation de tous les DC Pour les audits, `LastLogonDate` est généralement suffisant.

#### Filtres avec wildcards

```powershell
# Nom commençant par...
Get-ADUser -Filter "Name -like 'Dupon*'"

# Nom se terminant par...
Get-ADUser -Filter "Name -like '*user'"

# Nom contenant...
Get-ADUser -Filter "Name -like '*test*'"

# Description spécifique
Get-ADUser -Filter "Description -like '*stagiaire*'" -Properties Description
```

#### Filtres composés complexes

```powershell
# Utilisateurs IT actifs avec email
Get-ADUser -Filter "Enabled -eq $true -and Department -eq 'IT' -and EmailAddress -like '*'" `
           -Properties Department, EmailAddress

# Comptes de service (exemple avec convention de nommage)
Get-ADUser -Filter "Name -like 'svc_*' -or Name -like 'service_*'"

# Utilisateurs sans manager dans un département spécifique
Get-ADUser -Filter "Department -eq 'IT'" -Properties Manager, Department | 
    Where-Object {-not $_.Manager}
```

> [!tip] Bonnes pratiques de filtrage
> 
> 1. Utilisez `-Filter` plutôt que `Where-Object` quand possible (filtrage côté serveur)
> 2. Limitez le nombre de propriétés demandées avec `-Properties`
> 3. Utilisez `-SearchBase` pour réduire le périmètre
> 4. Testez vos filtres sur un petit échantillon avant de les appliquer en masse

---

### 📊 Export et rapports {#export-et-rapports}

L'export de données utilisateurs est essentiel pour les audits, la documentation et les migrations.

#### Export CSV basique

```powershell
# Export simple
Get-ADUser -Filter * -Properties EmailAddress, Department | 
    Select-Object Name, SamAccountName, EmailAddress, Department, Enabled | 
    Export-Csv -Path "C:\Exports\utilisateurs.csv" -NoTypeInformation -Encoding UTF8

# Export avec propriétés calculées
Get-ADUser -Filter * -Properties EmailAddress, Department, Manager | 
    Select-Object Name, EmailAddress, Department, Enabled,
        @{Name='ManagerName';Expression={(Get-ADUser $_.Manager -ErrorAction SilentlyContinue).Name}} | 
    Export-Csv -Path "C:\Exports\utilisateurs_complet.csv" -NoTypeInformation -Encoding UTF8
```

#### Rapport d'audit des comptes inactifs

```powershell
# Comptes inactifs depuis 90 jours
$inactifDepuis = (Get-Date).AddDays(-90)

Get-ADUser -Filter * -Properties LastLogonDate, EmailAddress, Department | 
    Where-Object {$_.LastLogonDate -lt $inactifDepuis -or $_.LastLogonDate -eq $null} | 
    Select-Object Name, SamAccountName, EmailAddress, Department, LastLogonDate, Enabled | 
    Sort-Object LastLogonDate | 
    Export-Csv -Path "C:\Exports\comptes_inactifs.csv" -NoTypeInformation -Encoding UTF8
```

#### Rapport des comptes sans email

```powershell
# Utilisateurs actifs sans adresse email
Get-ADUser -Filter "Enabled -eq $true" -Properties EmailAddress, Department, Title | 
    Where-Object {-not $_.EmailAddress} | 
    Select-Object Name, SamAccountName, Department, Title, Enabled | 
    Export-Csv -Path "C:\Exports\sans_email.csv" -NoTypeInformation -Encoding UTF8
```

#### Rapport de sécurité

```powershell
# Comptes avec problèmes de sécurité
Get-ADUser -Filter * -Properties PasswordNeverExpires, PasswordNotRequired, 
    PasswordExpired, LockedOut, AccountExpirationDate | 
    Where-Object {
        $_.PasswordNeverExpires -eq $true -or 
        $_.PasswordNotRequired -eq $true -or 
        $_.PasswordExpired -eq $true -or 
        $_.LockedOut -eq $true
    } | 
    Select-Object Name, SamAccountName, Enabled, PasswordNeverExpires, 
        PasswordNotRequired, PasswordExpired, LockedOut | 
    Export-Csv -Path "C:\Exports\problemes_securite.csv" -NoTypeInformation -Encoding UTF8
```

#### Rapport HTML formaté

```powershell
# Créer un rapport HTML élégant
$utilisateurs = Get-ADUser -Filter * -Properties EmailAddress, Department, Title, LastLogonDate | 
    Select-Object Name, SamAccountName, EmailAddress, Department, Title, 
        @{Name='LastLogon';Expression={$_.LastLogonDate}}, Enabled

$html = $utilisateurs | ConvertTo-Html -Title "Rapport Utilisateurs AD" `
    -PreContent "<h1>Utilisateurs Active Directory</h1><p>Date: $(Get-Date -Format 'dd/MM/yyyy HH:mm')</p>" `
    -PostContent "<p>Total: $($utilisateurs.Count) utilisateurs</p>"

$html | Out-File -FilePath "C:\Exports\rapport_utilisateurs.html" -Encoding UTF8
```

#### Export pour migration (avec toutes les propriétés)

```powershell
# Sauvegarde complète pour migration
Get-ADUser -Filter * -Properties * | 
    Select-Object Name, SamAccountName, UserPrincipalName, EmailAddress,
        GivenName, Surname, DisplayName, Description,
        Department, Title, Company, Office,
        OfficePhone, MobilePhone, HomePhone,
        StreetAddress, City, State, PostalCode, Country,
        Manager, Enabled, PasswordNeverExpires,
        AccountExpirationDate, WhenCreated, WhenChanged,
        LastLogonDate, DistinguishedName | 
    Export-Csv -Path "C:\Exports\migration_complete.csv" -NoTypeInformation -Encoding UTF8
```

> [!tip] Conseils pour les exports
> 
> - Utilisez `-NoTypeInformation` pour éviter la première ligne de métadonnées
> - Utilisez `-Encoding UTF8` pour les caractères accentués
> - Ajoutez la date dans le nom du fichier : `"rapport_$(Get-Date -Format 'yyyyMMdd').csv"`
> - Testez sur un échantillon avant un export complet

---

## ➕ New-ADUser - Création d'utilisateurs {#new-aduser}

La cmdlet `New-ADUser` permet de créer de nouveaux comptes utilisateurs dans Active Directory. Elle offre une grande flexibilité pour définir toutes les propriétés d'un utilisateur dès sa création.

> [!info] Cas d'usage de New-ADUser
> 
> - Provisioning manuel de nouveaux employés
> - Création en masse depuis un fichier CSV
> - Scripts d'automatisation RH
> - Création de comptes de test ou de service
> - Duplication de profils utilisateurs (templates)

### ✅ Paramètres obligatoires {#paramètres-obligatoires}

Seuls deux paramètres sont **absolument obligatoires** pour créer un utilisateur :

#### Name - Nom commun (CN)

```powershell
# -Name définit le CN (Common Name) dans Active Directory
New-ADUser -Name "Jean Dupont"

# Ce sera visible comme : CN=Jean Dupont,OU=...,DC=...
```

> [!info] Nom vs DisplayName
> 
> - `-Name` : identifiant technique dans AD (CN), ne peut pas être changé facilement
> - `-DisplayName` : nom d'affichage pour les utilisateurs, modifiable à tout moment

#### SamAccountName - Nom de connexion

```powershell
# -SamAccountName est le nom de connexion (pré-Windows 2000)
# Limité à 20 caractères, doit être unique dans le domaine
New-ADUser -Name "Jean Dupont" -SamAccountName "jdupont"
```

> [!warning] Unicité du SamAccountName Le SamAccountName **DOIT** être unique dans tout le domaine. Si un utilisateur avec ce nom existe déjà, la création échouera.

**Exemple minimal fonctionnel :**

```powershell
# Création minimale (compte créé mais désactivé et sans mot de passe)
New-ADUser -Name "Jean Dupont" -SamAccountName "jdupont"
```

> [!warning] Compte créé mais non utilisable Avec seulement ces deux paramètres, le compte est :
> 
> - Désactivé par défaut (`Enabled = $false`)
> - Sans mot de passe défini
> - Placé dans le conteneur "Users" par défaut
> 
> Pour un compte utilisable, ajoutez au minimum : `-AccountPassword`, `-Enabled $true`, et `-Path`.

---

### 🎯 Propriétés essentielles {#propriétés-essentielles}

Pour créer un compte utilisateur complet et fonctionnel, plusieurs propriétés supplémentaires sont nécessaires.

#### Identité complète

```powershell
# GivenName et Surname : prénom et nom
New-ADUser -Name "Jean Dupont" `
           -SamAccountName "jdupont" `
           -GivenName "Jean" `
           -Surname "Dupont" `
           -DisplayName "Jean DUPONT"
```

> [!tip] Convention DisplayName Une convention courante : "Prénom NOM" (nom en majuscules) pour faciliter le tri et la lisibilité dans les listes.

#### UserPrincipalName (UPN)

```powershell
# UPN : format email pour connexion moderne (user@domain.com)
New-ADUser -Name "Jean Dupont" `
           -SamAccountName "jdupont" `
           -UserPrincipalName "jdupont@entreprise.local"
```

> [!info] UPN vs SamAccountName
> 
> - **SamAccountName** : connexion legacy (ex: `DOMAINE\jdupont`)
> - **UserPrincipalName** : connexion moderne (ex: `jdupont@entreprise.local`)
> - L'UPN peut être différent de l'email, mais par convention ils sont souvent identiques

#### Path - Emplacement dans AD

```powershell
# -Path : OU de destination (Distinguished Name complet)
New-ADUser -Name "Jean Dupont" `
           -SamAccountName "jdupont" `
           -Path "OU=Informatique,OU=Utilisateurs,DC=entreprise,DC=local"
```

> [!warning] Path doit exister L'OU spécifiée dans `-Path` **doit déjà exister**. Si elle n'existe pas, la création échouera. Sans `-Path`, l'utilisateur est créé dans le conteneur "CN=Users" par défaut.

#### Mot de passe et activation

```powershell
# Créer un SecureString pour le mot de passe
$Password = ConvertTo-SecureString "P@ssw0rd2024!" -AsPlainText -Force

# Créer l'utilisateur avec mot de passe et activation
New-ADUser -Name "Jean Dupont" `
           -SamAccountName "jdupont" `
           -AccountPassword $Password `
           -Enabled $true `
           -ChangePasswordAtLogon $true
```

> [!warning] Sécurité des mots de passe
> 
> - Ne JAMAIS coder en dur un mot de passe dans un script
> - Utiliser `Read-Host -AsSecureString` pour une saisie interactive
> - Générer des mots de passe aléatoires pour les créations en masse
> - Forcer le changement à la première connexion avec `-ChangePasswordAtLogon $true`

**Exemple complet minimal pour un compte fonctionnel :**

```powershell
# Création d'un utilisateur complet et utilisable
$Password = ConvertTo-SecureString "TempP@ss2024!" -AsPlainText -Force

New-ADUser -Name "Jean Dupont" `
           -SamAccountName "jdupont" `
           -GivenName "Jean" `
           -Surname "Dupont" `
           -DisplayName "Jean DUPONT" `
           -UserPrincipalName "jdupont@entreprise.local" `
           -Path "OU=Informatique,OU=Utilisateurs,DC=entreprise,DC=local" `
           -AccountPassword $Password `
           -Enabled $true `
           -ChangePasswordAtLogon $true
```

#### Propriétés de contact

```powershell
# Email et téléphones
New-ADUser -Name "Jean Dupont" `
           -SamAccountName "jdupont" `
           -EmailAddress "jean.dupont@entreprise.com" `
           -OfficePhone "+33 1 23 45 67 89" `
           -MobilePhone "+33 6 12 34 56 78"
```

> [!info] EmailAddress vs UserPrincipalName
> 
> - **EmailAddress** : adresse email réelle pour Exchange/messagerie
> - **UserPrincipalName** : identifiant de connexion (peut être identique mais pas obligatoire)

#### Propriétés organisationnelles

```powershell
# Fonction, département, entreprise
New-ADUser -Name "Jean Dupont" `
           -SamAccountName "jdupont" `
           -Title "Administrateur Systèmes" `
           -Department "Informatique" `
           -Company "Entreprise SA" `
           -Office "Bâtiment A - Bureau 205"
```

#### Manager (supérieur hiérarchique)

```powershell
# Manager : DN du supérieur hiérarchique
New-ADUser -Name "Jean Dupont" `
           -SamAccountName "jdupont" `
           -Manager "CN=Pierre Martin,OU=Direction,DC=entreprise,DC=local"

# Ou récupérer le DN du manager dynamiquement
$manager = Get-ADUser -Identity "pmartin"
New-ADUser -Name "Jean Dupont" `
           -SamAccountName "jdupont" `
           -Manager $manager.DistinguishedName
```

#### Description et notes

```powershell
# Description : information libre
New-ADUser -Name "Jean Dupont" `
           -SamAccountName "jdupont" `
           -Description "Administrateur systèmes - Arrivé le 15/01/2024"
```

#### Adresse postale

```powershell
# Adresse complète
New-ADUser -Name "Jean Dupont" `
           -SamAccountName "jdupont" `
           -StreetAddress "123 Rue de la République" `
           -City "Paris" `
           -State "Île-de-France" `
           -PostalCode "75001" `
           -Country "FR"
```

> [!tip] Country - Code pays Le paramètre `-Country` attend le code pays ISO (FR, US, GB, etc.), pas le nom complet.

---

### ⚙️ Options avancées {#options-avancées}

#### Options de mot de passe

```powershell
# Changement obligatoire à la première connexion
New-ADUser -Name "Jean Dupont" `
           -SamAccountName "jdupont" `
           -AccountPassword $Password `
           -ChangePasswordAtLogon $true

# Mot de passe n'expire jamais (comptes de service)
New-ADUser -Name "Service Backup" `
           -SamAccountName "svc_backup" `
           -AccountPassword $Password `
           -PasswordNeverExpires $true

# Utilisateur ne peut pas changer son mot de passe
New-ADUser -Name "Compte Kiosque" `
           -SamAccountName "kiosque01" `
           -AccountPassword $Password `
           -CannotChangePassword $true
```

> [!warning] PasswordNeverExpires pour comptes de service uniquement N'utilisez `-PasswordNeverExpires $true` que pour les comptes de service (svc__, service__). Pour les utilisateurs humains, laissez l'expiration active pour la sécurité.

#### Options de compte

```powershell
# Date d'expiration du compte (stagiaires, consultants)
$expiration = (Get-Date).AddMonths(6)
New-ADUser -Name "Marie Stagiaire" `
           -SamAccountName "mstagiaire" `
           -AccountPassword $Password `
           -Enabled $true `
           -AccountExpirationDate $expiration

# Cryptage réversible (déconseillé, sauf contrainte legacy)
New-ADUser -Name "Legacy App Account" `
           -SamAccountName "legacyapp" `
           -AccountPassword $Password `
           -AllowReversiblePasswordEncryption $true
```

> [!warning] AllowReversiblePasswordEncryption - Risque sécurité Cette option stocke les mots de passe de manière réversible (quasi-texte clair). À éviter absolument sauf contrainte technique absolue (anciennes applications).

#### Création avec copie de modèle (template)

```powershell
# Récupérer un utilisateur existant comme modèle
$template = Get-ADUser -Identity "modele_it" -Properties Department, Company, Office, Manager

# Créer le nouvel utilisateur en copiant certaines propriétés
New-ADUser -Name "Nouveau Collaborateur" `
           -SamAccountName "ncollab" `
           -GivenName "Nouveau" `
           -Surname "Collaborateur" `
           -Department $template.Department `
           -Company $template.Company `
           -Office $template.Office `
           -Manager $template.Manager `
           -Path "OU=Informatique,OU=Utilisateurs,DC=entreprise,DC=local" `
           -AccountPassword $Password `
           -Enabled $true
```

> [!tip] Templates d'utilisateurs Créez des comptes "modèles" (désactivés) par département avec les propriétés standards. Utilisez-les comme base pour les nouveaux utilisateurs pour garantir la cohérence.

---

### 📦 Provisioning en masse {#provisioning-en-masse}

La création en masse d'utilisateurs depuis un fichier CSV est un besoin courant lors d'arrivées groupées ou de migrations.

#### Préparation du fichier CSV

**Structure du fichier utilisateurs.csv :**

```csv
GivenName,Surname,SamAccountName,UserPrincipalName,EmailAddress,Department,Title,Office,OfficePhone,Manager,OU
Jean,Dupont,jdupont,jdupont@entreprise.local,jean.dupont@entreprise.com,Informatique,Admin Systèmes,A205,0123456789,pmartin,OU=Informatique
Marie,Martin,mmartin,mmartin@entreprise.local,marie.martin@entreprise.com,RH,Responsable RH,B101,0198765432,dleroy,OU=RH
Pierre,Durand,pdurand,pdurand@entreprise.local,pierre.durand@entreprise.com,Commercial,Commercial Senior,C305,0145678901,aleroux,OU=Commercial
```

#### Script d'import CSV basique

```powershell
# Import du CSV
$users = Import-Csv -Path "C:\Scripts\utilisateurs.csv" -Encoding UTF8

# Mot de passe temporaire (identique pour tous, à changer à la première connexion)
$defaultPassword = ConvertTo-SecureString "TempP@ss2024!" -AsPlainText -Force

# Boucle de création
foreach ($user in $users) {
    try {
        # Construction du Distinguished Name complet
        $ouPath = "$($user.OU),DC=entreprise,DC=local"
        
        # Création de l'utilisateur
        New-ADUser -Name "$($user.GivenName) $($user.Surname)" `
                   -GivenName $user.GivenName `
                   -Surname $user.Surname `
                   -SamAccountName $user.SamAccountName `
                   -UserPrincipalName $user.UserPrincipalName `
                   -DisplayName "$($user.GivenName) $($user.Surname.ToUpper())" `
                   -EmailAddress $user.EmailAddress `
                   -Department $user.Department `
                   -Title $user.Title `
                   -Office $user.Office `
                   -OfficePhone $user.OfficePhone `
                   -Path $ouPath `
                   -AccountPassword $defaultPassword `
                   -Enabled $true `
                   -ChangePasswordAtLogon $true
        
        Write-Host "✓ Utilisateur créé : $($user.SamAccountName)" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Erreur pour $($user.SamAccountName) : $($_.Exception.Message)" -ForegroundColor Red
    }
}
```

#### Script avancé avec gestion des managers

```powershell
# Import du CSV
$users = Import-Csv -Path "C:\Scripts\utilisateurs.csv" -Encoding UTF8
$defaultPassword = ConvertTo-SecureString "TempP@ss2024!" -AsPlainText -Force

# Boucle de création
foreach ($user in $users) {
    try {
        $ouPath = "$($user.OU),DC=entreprise,DC=local"
        
        # Récupération du DN du manager si spécifié
        $managerDN = $null
        if ($user.Manager) {
            $manager = Get-ADUser -Identity $user.Manager -ErrorAction SilentlyContinue
            if ($manager) {
                $managerDN = $manager.DistinguishedName
            } else {
                Write-Warning "Manager '$($user.Manager)' introuvable pour $($user.SamAccountName)"
            }
        }
        
        # Paramètres de création
        $params = @{
            Name                  = "$($user.GivenName) $($user.Surname)"
            GivenName             = $user.GivenName
            Surname               = $user.Surname
            SamAccountName        = $user.SamAccountName
            UserPrincipalName     = $user.UserPrincipalName
            DisplayName           = "$($user.GivenName) $($user.Surname.ToUpper())"
            EmailAddress          = $user.EmailAddress
            Department            = $user.Department
            Title                 = $user.Title
            Office                = $user.Office
            OfficePhone           = $user.OfficePhone
            Path                  = $ouPath
            AccountPassword       = $defaultPassword
            Enabled               = $true
            ChangePasswordAtLogon = $true
        }
        
        # Ajouter le manager si trouvé
        if ($managerDN) {
            $params.Add('Manager', $managerDN)
        }
        
        # Création
        New-ADUser @params
        
        Write-Host "✓ $($user.SamAccountName) créé avec succès" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Erreur $($user.SamAccountName) : $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n--- Résumé ---"
Write-Host "Total dans CSV : $($users.Count)"
Write-Host "Créés avec succès : $(($users | ForEach-Object { Get-ADUser -Identity $_.SamAccountName -ErrorAction SilentlyContinue }).Count)"
```

#### Script avec journalisation et rapport

```powershell
# Configuration
$csvPath = "C:\Scripts\utilisateurs.csv"
$logPath = "C:\Scripts\Logs\creation_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$reportPath = "C:\Scripts\Rapports\rapport_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"

# Fonction de journalisation
function Write-Log {
    param($Message, $Type = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Type] $Message"
    Add-Content -Path $logPath -Value $logMessage
    
    switch ($Type) {
        "SUCCESS" { Write-Host $Message -ForegroundColor Green }
        "ERROR"   { Write-Host $Message -ForegroundColor Red }
        "WARNING" { Write-Host $Message -ForegroundColor Yellow }
        default   { Write-Host $Message }
    }
}

# Import
$users = Import-Csv -Path $csvPath -Encoding UTF8
$defaultPassword = ConvertTo-SecureString "TempP@ss2024!" -AsPlainText -Force
$results = @()

Write-Log "=== Début de la création en masse ==="
Write-Log "Nombre d'utilisateurs à créer : $($users.Count)"

# Création
foreach ($user in $users) {
    $result = [PSCustomObject]@{
        SamAccountName = $user.SamAccountName
        Name           = "$($user.GivenName) $($user.Surname)"
        Status         = ""
        Message        = ""
    }
    
    try {
        # Vérifier si l'utilisateur existe déjà
        $existing = Get-ADUser -Identity $user.SamAccountName -ErrorAction SilentlyContinue
        if ($existing) {
            $result.Status = "SKIP"
            $result.Message = "Utilisateur déjà existant"
            Write-Log "⊗ $($user.SamAccountName) existe déjà" "WARNING"
            $results += $result
            continue
        }
        
        $ouPath = "$($user.OU),DC=entreprise,DC=local"
        
        # Paramètres
        $params = @{
            Name                  = "$($user.GivenName) $($user.Surname)"
            GivenName             = $user.GivenName
            Surname               = $user.Surname
            SamAccountAccount     = $user.SamAccountName
            UserPrincipalName     = $user.UserPrincipalName
            DisplayName           = "$($user.GivenName) $($user.Surname.ToUpper())"
            EmailAddress          = $user.EmailAddress
            Department            = $user.Department
            Title                 = $user.Title
            Office                = $user.Office
            OfficePhone           = $user.OfficePhone
            Path                  = $ouPath
            AccountPassword       = $defaultPassword
            Enabled               = $true
            ChangePasswordAtLogon = $true
        }
        
        # Manager
        if ($user.Manager) {
            $manager = Get-ADUser -Identity $user.Manager -ErrorAction SilentlyContinue
            if ($manager) {
                $params.Add('Manager', $manager.DistinguishedName)
            }
        }
        
        # Création
        New-ADUser @params
        
        $result.Status = "SUCCESS"
        $result.Message = "Créé avec succès"
        Write-Log "✓ $($user.SamAccountName) créé avec succès" "SUCCESS"
    }
    catch {
        $result.Status = "ERROR"
        $result.Message = $_.Exception.Message
        Write-Log "✗ Erreur $($user.SamAccountName) : $($_.Exception.Message)" "ERROR"
    }
    
    $results += $result
}

# Rapport final
$results | Export-Csv -Path $reportPath -NoTypeInformation -Encoding UTF8

$successCount = ($results | Where-Object { $_.Status -eq "SUCCESS" }).Count
$errorCount = ($results | Where-Object { $_.Status -eq "ERROR" }).Count
$skipCount = ($results | Where-Object { $_.Status -eq "SKIP" }).Count

Write-Log "`n=== Résumé ==="
Write-Log "Total traité : $($users.Count)"
Write-Log "Succès : $successCount" "SUCCESS"
Write-Log "Erreurs : $errorCount" $(if($errorCount -gt 0){"ERROR"}else{"INFO"})
Write-Log "Ignorés : $skipCount" $(if($skipCount -gt 0){"WARNING"}else{"INFO"})
Write-Log "Log : $logPath"
Write-Log "Rapport : $reportPath"
```

> [!tip] Bonnes pratiques pour l'import en masse
> 
> 1. **Testez d'abord** sur un échantillon (1-3 utilisateurs)
> 2. **Vérifiez les OUs** : elles doivent exister avant la création
> 3. **Validez les SamAccountName** : format cohérent, unicité
> 4. **Journalisez tout** : succès, erreurs, avertissements
> 5. **Générez un rapport** : CSV pour traçabilité
> 6. **Sauvegardez le CSV** original pour référence
> 7. **Utilisez des transactions** si possible (tout ou rien)

#### Génération de mots de passe aléatoires

```powershell
# Fonction de génération de mot de passe sécurisé
function New-RandomPassword {
    param(
        [int]$Length = 12,
        [switch]$IncludeSpecialChars
    )
    
    $lowercase = 'abcdefghijklmnopqrstuvwxyz'
    $uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    $numbers = '0123456789'
    $special = '!@#$%^&*()_+-=[]{}|;:,.<>?'
    
    $chars = $lowercase + $uppercase + $numbers
    if ($IncludeSpecialChars) {
        $chars += $special
    }
    
    # Générer le mot de passe
    $password = -join (1..$Length | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
    
    # S'assurer qu'il contient au moins : 1 majuscule, 1 minuscule, 1 chiffre
    if ($password -notmatch '[a-z]' -or $password -notmatch '[A-Z]' -or $password -notmatch '[0-9]') {
        return New-RandomPassword -Length $Length -IncludeSpecialChars:$IncludeSpecialChars
    }
    
    return $password
}

# Utilisation dans une création avec mot de passe unique par utilisateur
foreach ($user in $users) {
    $randomPassword = New-RandomPassword -Length 14 -IncludeSpecialChars
    $securePassword = ConvertTo-SecureString $randomPassword -AsPlainText -Force
    
    # Créer l'utilisateur avec le mot de passe unique
    New-ADUser -Name "$($user.GivenName) $($user.Surname)" `
               -SamAccountName $user.SamAccountName `
               -AccountPassword $securePassword `
               -Enabled $true `
               -ChangePasswordAtLogon $true
    
    # Enregistrer le mot de passe de manière sécurisée (à envoyer à l'utilisateur)
    Add-Content -Path "C:\Scripts\Passwords\$($user.SamAccountName)_password.txt" -Value $randomPassword
}
```

> [!warning] Gestion sécurisée des mots de passe
> 
> - Ne jamais afficher les mots de passe à l'écran
> - Ne jamais les inclure dans les logs
> - Les stocker temporairement dans des fichiers séparés chiffrés
> - Les transmettre de manière sécurisée (jamais par email en clair)
> - Supprimer les fichiers de mots de passe après transmission

---

### 🔑 Droits requis

Pour créer des utilisateurs dans Active Directory, vous devez disposer des permissions appropriées :

> [!info] Permissions nécessaires
> 
> - **Droits de création** sur l'OU cible
> - **Membre du groupe "Account Operators"** (minimum)
> - **Membre du groupe "Domain Admins"** (droits complets)
> - Ou **délégation spécifique** sur l'OU concernée

#### Vérifier ses droits

```powershell
# Vérifier l'appartenance aux groupes
whoami /groups

# Vérifier les droits sur une OU spécifique
Get-Acl "AD:\OU=Informatique,OU=Utilisateurs,DC=entreprise,DC=local" | Format-List
```

#### Délégation de droits (pour les admins)

```powershell
# Exemple : déléguer la création d'utilisateurs à un groupe spécifique
# (nécessite des droits Domain Admins)

$ou = "OU=Informatique,OU=Utilisateurs,DC=entreprise,DC=local"
$group = "GRP_IT_UserAdmins"

# Cette opération se fait généralement via l'interface graphique AD
# ou avec des commandes ADSI plus complexes
```

---

### 📋 Récapitulatif et exemples complets

#### Exemple 1 : Création basique manuelle

```powershell
# Définir le mot de passe
$password = Read-Host "Entrez le mot de passe" -AsSecureString

# Créer l'utilisateur
New-ADUser -Name "Sophie Bernard" `
           -GivenName "Sophie" `
           -Surname "Bernard" `
           -SamAccountName "sbernard" `
           -UserPrincipalName "sbernard@entreprise.local" `
           -DisplayName "Sophie BERNARD" `
           -EmailAddress "sophie.bernard@entreprise.com" `
           -Department "Marketing" `
           -Title "Chef de projet" `
           -Office "B302" `
           -Path "OU=Marketing,OU=Utilisateurs,DC=entreprise,DC=local" `
           -AccountPassword $password `
           -Enabled $true `
           -ChangePasswordAtLogon $true

Write-Host "Utilisateur sbernard créé avec succès" -ForegroundColor Green
```

#### Exemple 2 : Compte de service

```powershell
# Mot de passe complexe pour compte de service
$svcPassword = ConvertTo-SecureString "Tr3s_C0mpl3x3_P@ssw0rd!" -AsPlainText -Force

# Créer le compte de service
New-ADUser -Name "Service Monitoring" `
           -SamAccountName "svc_monitoring" `
           -UserPrincipalName "svc_monitoring@entreprise.local" `
           -Description "Compte de service pour Nagios - Créé le $(Get-Date -Format 'dd/MM/yyyy')" `
           -Path "OU=ServiceAccounts,DC=entreprise,DC=local" `
           -AccountPassword $svcPassword `
           -PasswordNeverExpires $true `
           -CannotChangePassword $true `
           -Enabled $true

Write-Host "Compte de service créé avec succès" -ForegroundColor Green
```

#### Exemple 3 : Stagiaire avec date d'expiration

```powershell
# Date d'expiration dans 3 mois
$expirationDate = (Get-Date).AddMonths(3)

$password = ConvertTo-SecureString "Stage2024!" -AsPlainText -Force

New-ADUser -Name "Thomas Stagiaire" `
           -GivenName "Thomas" `
           -Surname "Leroy" `
           -SamAccountName "tleroy.stage" `
           -UserPrincipalName "tleroy.stage@entreprise.local" `
           -DisplayName "Thomas LEROY (Stagiaire)" `
           -EmailAddress "thomas.leroy@entreprise.com" `
           -Department "Informatique" `
           -Title "Stagiaire Développeur" `
           -Description "Stage de 3 mois - Expire le $($expirationDate.ToString('dd/MM/yyyy'))" `
           -Path "OU=Stagiaires,OU=Utilisateurs,DC=entreprise,DC=local" `
           -AccountPassword $password `
           -AccountExpirationDate $expirationDate `
           -Enabled $true `
           -ChangePasswordAtLogon $true

Write-Host "Stagiaire créé - Expiration : $($expirationDate.ToString('dd/MM/yyyy'))" -ForegroundColor Yellow
```

---

### ⚠️ Pièges courants et solutions

#### Piège 1 : SamAccountName déjà utilisé

```powershell
# Problème : New-ADUser échoue si le SamAccountName existe

# Solution : Vérifier avant de créer
if (Get-ADUser -Filter "SamAccountName -eq 'jdupont'" -ErrorAction SilentlyContinue) {
    Write-Host "L'utilisateur jdupont existe déjà !" -ForegroundColor Red
} else {
    New-ADUser -Name "Jean Dupont" -SamAccountName "jdupont" # ...
}
```

#### Piège 2 : OU inexistante

```powershell
# Problème : Path pointant vers une OU qui n'existe pas

# Solution : Vérifier l'existence de l'OU
$ouPath = "OU=NouveauService,OU=Utilisateurs,DC=entreprise,DC=local"

if (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouPath'" -ErrorAction SilentlyContinue) {
    New-ADUser -Name "Jean Dupont" -Path $ouPath # ...
} else {
    Write-Host "L'OU $ouPath n'existe pas !" -ForegroundColor Red
}
```

#### Piège 3 : Mot de passe ne respectant pas la politique

```powershell
# Problème : Mot de passe trop simple, création échoue

# Solution : Générer des mots de passe conformes
function Test-PasswordComplexity {
    param([string]$Password)
    
    $hasUppercase = $Password -cmatch '[A-Z]'
    $hasLowercase = $Password -cmatch '[a-z]'
    $hasNumber = $Password -cmatch '[0-9]'
    $hasSpecial = $Password -match '[^a-zA-Z0-9]'
    $isLongEnough = $Password.Length -ge 8
    
    return ($hasUppercase -and $hasLowercase -and $hasNumber -and $hasSpecial -and $isLongEnough)
}

# Utilisation
$plainPassword = "P@ssw0rd2024!"
if (Test-PasswordComplexity -Password $plainPassword) {
    $securePassword = ConvertTo-SecureString $plainPassword -AsPlainText -Force
    New-ADUser # ... -AccountPassword $securePassword
} else {
    Write-Host "Le mot de passe ne respecte pas la politique de complexité" -ForegroundColor Red
}
```

#### Piège 4 : Manager inexistant ou DN invalide

```powershell
# Problème : DN du manager incorrect ou utilisateur inexistant

# Solution : Valider le manager avant attribution
$managerSam = "pmartin"
$manager = Get-ADUser -Identity $managerSam -ErrorAction SilentlyContinue

if ($manager) {
    New-ADUser -Name "Jean Dupont" `
               -SamAccountName "jdupont" `
               -Manager $manager.DistinguishedName # ...
} else {
    Write-Host "Manager $managerSam introuvable" -ForegroundColor Yellow
    # Créer sans manager ou demander un autre manager
}
```

---

### 💡 Astuces avancées

#### Astuce 1 : Fonction réutilisable de création

```powershell
function New-CompanyUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$GivenName,
        
        [Parameter(Mandatory)]
        [string]$Surname,
        
        [Parameter(Mandatory)]
        [string]$Department,
        
        [string]$Title,
        [string]$Manager,
        [SecureString]$Password
    )
    
    # Générer SamAccountName automatiquement
    $samAccount = ($GivenName.Substring(0,1) + $Surname).ToLower() -replace '[^a-z0-9]', ''
    
    # Vérifier unicité
    $counter = 1
    $originalSam = $samAccount
    while (Get-ADUser -Filter "SamAccountName -eq '$samAccount'" -ErrorAction SilentlyContinue) {
        $samAccount = "$originalSam$counter"
        $counter++
    }
    
    # Déterminer l'OU selon le département
    $ouMap = @{
        'Informatique' = 'OU=IT,OU=Utilisateurs,DC=entreprise,DC=local'
        'RH'           = 'OU=RH,OU=Utilisateurs,DC=entreprise,DC=local'
        'Commercial'   = 'OU=Commercial,OU=Utilisateurs,DC=entreprise,DC=local'
    }
    $ouPath = $ouMap[$Department]
    
    if (-not $Password) {
        $Password = ConvertTo-SecureString (New-RandomPassword -Length 14) -AsPlainText -Force
    }
    
    # Créer l'utilisateur
    $params = @{
        Name                  = "$GivenName $Surname"
        GivenName             = $GivenName
        Surname               = $Surname
        SamAccountName        = $samAccount
        UserPrincipalName     = "$samAccount@entreprise.local"
        DisplayName           = "$GivenName $($Surname.ToUpper())"
        EmailAddress          = "$samAccount@entreprise.com"
        Department            = $Department
        Path                  = $ouPath
        AccountPassword       = $Password
        Enabled               = $true
        ChangePasswordAtLogon = $true
    }
    
    if ($Title) { $params.Add('Title', $Title) }
    if ($Manager) {
        $mgr = Get-ADUser -Identity $Manager -ErrorAction SilentlyContinue
        if ($mgr) { $params.Add('Manager', $mgr.DistinguishedName) }
    }
    
    New-ADUser @params
    
    return [PSCustomObject]@{
        SamAccountName    = $samAccount
        UserPrincipalName = "$samAccount@entreprise.local"
        Email             = "$samAccount@entreprise.com"
    }
}

# Utilisation simplifiée
$newUser = New-CompanyUser -GivenName "Alice" -Surname "Dupont" `
                           -Department "Informatique" -Title "Développeuse" `
                           -Manager "pmartin"
```

#### Astuce 2 : Duplication d'utilisateur existant

```powershell
function Copy-ADUserProfile {
    param(
        [string]$SourceUser,
        [string]$NewGivenName,
        [string]$NewSurname
    )
    
    # Récupérer l'utilisateur source
    $source = Get-ADUser -Identity $SourceUser -Properties *
    
    # Générer le nouveau SamAccountName
    $newSam = ($NewGivenName.Substring(0,1) + $NewSurname).ToLower()
    
    # Créer avec les mêmes propriétés
    $password = Read-Host "Mot de passe pour $newSam" -AsSecureString
    
    New-ADUser -Name "$NewGivenName $NewSurname" `
               -GivenName $NewGivenName `
               -Surname $NewSurname `
               -SamAccountName $newSam `
               -UserPrincipalName "$newSam@entreprise.local" `
               -DisplayName "$NewGivenName $($NewSurname.ToUpper())" `
               -Department $source.Department `
               -Title $source.Title `
               -Company $source.Company `
               -Office $source.Office `
               -Manager $source.Manager `
               -Path $source.DistinguishedName.Substring($source.DistinguishedName.IndexOf(',') + 1) `
               -AccountPassword $password `
               -Enabled $true `
               -ChangePasswordAtLogon $true
    
    # Copier l'appartenance aux groupes
    $groups = Get-ADUser -Identity $SourceUser -Properties MemberOf | Select-Object -ExpandProperty MemberOf
    foreach ($group in $groups) {
        Add-ADGroupMember -Identity $group -Members $newSam
    }
    
    Write-Host "Utilisateur $newSam créé sur le modèle de $SourceUser" -ForegroundColor Green
}

# Utilisation
Copy-ADUserProfile -SourceUser "jdupont" -NewGivenName "Marie" -NewSurname "Leroy"
```

#### Astuce 3 : Création avec validation complète

```powershell
function New-ValidatedADUser {
    param(
        [Parameter(Mandatory)]
        [hashtable]$UserData
    )
    
    $errors = @()
    
    # Validations
    if (-not $UserData.SamAccountName) {
        $errors += "SamAccountName manquant"
    } elseif (Get-ADUser -Filter "SamAccountName -eq '$($UserData.SamAccountName)'" -ErrorAction SilentlyContinue) {
        $errors += "SamAccountName '$($UserData.SamAccountName)' déjà utilisé"
    }
    
    if ($UserData.EmailAddress -and $UserData.EmailAddress -notmatch '^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}) {
        $errors += "Format email invalide"
    }
    
    if ($UserData.Path) {
        if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$($UserData.Path)'" -ErrorAction SilentlyContinue)) {
            $errors += "OU '$($UserData.Path)' n'existe pas"
        }
    }
    
    # Si erreurs, afficher et arrêter
    if ($errors.Count -gt 0) {
        Write-Host "❌ Erreurs de validation :" -ForegroundColor Red
        $errors | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
        return $false
    }
    
    # Création
    try {
        New-ADUser @UserData
        Write-Host "✓ Utilisateur $($UserData.SamAccountName) créé" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ Erreur création : $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Utilisation
$userData = @{
    Name              = "Test User"
    SamAccountName    = "tuser"
    GivenName         = "Test"
    Surname           = "User"
    AccountPassword   = (ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force)
    Enabled           = $true
    EmailAddress      = "tuser@entreprise.com"
    Path              = "OU=IT,OU=Utilisateurs,DC=entreprise,DC=local"
}

New-ValidatedADUser -UserData $userData
```

---

## 🔄 Combinaison Get-ADUser et New-ADUser

L'utilisation conjointe de `Get-ADUser` et `New-ADUser` permet des scénarios puissants d'automatisation.

### Scénario 1 : Audit avant création en masse

```powershell
# Vérifier les doublons avant import CSV
$csvUsers = Import-Csv -Path "C:\Scripts\nouveaux_utilisateurs.csv"
$existingUsers = Get-ADUser -Filter * -Properties SamAccountName

$doublons = @()
$nouveaux = @()

foreach ($user in $csvUsers) {
    if ($existingUsers.SamAccountName -contains $user.SamAccountName) {
        $doublons += $user
    } else {
        $nouveaux += $user
    }
}

Write-Host "Utilisateurs à créer : $($nouveaux.Count)" -ForegroundColor Green
Write-Host "Doublons détectés : $($doublons.Count)" -ForegroundColor Yellow

if ($doublons.Count -gt 0) {
    Write-Host "`nDoublons :" -ForegroundColor Yellow
    $doublons | Format-Table SamAccountName, Name
}

# Créer uniquement les nouveaux
if ($nouveaux.Count -gt 0) {
    $confirmation = Read-Host "`nCréer $($nouveaux.Count) utilisateurs ? (O/N)"
    if ($confirmation -eq 'O') {
        foreach ($user in $nouveaux) {
            # Création...
        }
    }
}
```

### Scénario 2 : Clonage de structure d'équipe

```powershell
# Dupliquer une équipe entière (nouveau projet)
function Copy-ADTeam {
    param(
        [string]$SourceOU,
        [string]$DestinationOU,
        [string]$Suffix = "2"
    )
    
    # Récupérer tous les utilisateurs de l'OU source
    $sourceUsers = Get-ADUser -Filter * -SearchBase $SourceOU `
                              -Properties Department, Title, Manager, MemberOf
    
    Write-Host "Clonage de $($sourceUsers.Count) utilisateurs..." -ForegroundColor Cyan
    
    foreach ($user in $sourceUsers) {
        # Nouveau SamAccountName avec suffixe
        $newSam = "$($user.SamAccountName)$Suffix"
        
        # Vérifier si existe déjà
        if (Get-ADUser -Filter "SamAccountName -eq '$newSam'" -ErrorAction SilentlyContinue) {
            Write-Host "⊗ $newSam existe déjà, ignoré" -ForegroundColor Yellow
            continue
        }
        
        # Créer le clone
        $password = ConvertTo-SecureString "Projet2024!" -AsPlainText -Force
        
        New-ADUser -Name "$($user.Name) ($Suffix)" `
                   -GivenName $user.GivenName `
                   -Surname $user.Surname `
                   -SamAccountName $newSam `
                   -UserPrincipalName "$newSam@entreprise.local" `
                   -DisplayName "$($user.DisplayName) ($Suffix)" `
                   -Department $user.Department `
                   -Title $user.Title `
                   -Path $DestinationOU `
                   -AccountPassword $password `
                   -Enabled $true `
                   -ChangePasswordAtLogon $true
        
        # Copier l'appartenance aux groupes
        foreach ($group in $user.MemberOf) {
            Add-ADGroupMember -Identity $group -Members $newSam -ErrorAction SilentlyContinue
        }
        
        Write-Host "✓ $newSam créé" -ForegroundColor Green
    }
}

# Utilisation
Copy-ADTeam -SourceOU "OU=ProjetAlpha,OU=Projets,DC=entreprise,DC=local" `
            -DestinationOU "OU=ProjetBeta,OU=Projets,DC=entreprise,DC=local" `
            -Suffix "_beta"
```

### Scénario 3 : Rapport de conformité et correction

```powershell
# Vérifier la conformité et corriger automatiquement
$users = Get-ADUser -Filter * -Properties EmailAddress, Department, Title, Manager

$problemes = @()

foreach ($user in $users) {
    $issues = @()
    
    # Vérifications
    if (-not $user.EmailAddress) {
        $issues += "Pas d'email"
    }
    
    if (-not $user.Department) {
        $issues += "Pas de département"
    }
    
    if (-not $user.Title) {
        $issues += "Pas de fonction"
    }
    
    if ($user.Enabled -eq $true -and -not $user.Manager) {
        $issues += "Pas de manager"
    }
    
    if ($issues.Count -gt 0) {
        $problemes += [PSCustomObject]@{
            SamAccountName = $user.SamAccountName
            Name           = $user.Name
            Issues         = $issues -join ", "
        }
    }
}

# Afficher le rapport
Write-Host "`n=== Rapport de conformité ===" -ForegroundColor Cyan
Write-Host "Utilisateurs avec problèmes : $($problemes.Count)`n"
$problemes | Format-Table -AutoSize

# Proposition de correction
if ($problemes.Count -gt 0) {
    $correction = Read-Host "`nVoulez-vous tenter une correction automatique ? (O/N)"
    if ($correction -eq 'O') {
        foreach ($pb in $problemes) {
            $user = Get-ADUser -Identity $pb.SamAccountName -Properties EmailAddress, Department
            
            # Générer email si manquant
            if (-not $user.EmailAddress) {
                $email = "$($user.SamAccountName)@entreprise.com"
                Set-ADUser -Identity $user.SamAccountName -EmailAddress $email
                Write-Host "✓ Email ajouté pour $($user.SamAccountName): $email" -ForegroundColor Green
            }
            
            # Autres corrections possibles...
        }
    }
}
```

### Scénario 4 : Synchronisation avec système externe

```powershell
# Synchroniser AD avec un système RH externe (CSV)
function Sync-ADFromHR {
    param(
        [string]$HRFilePath
    )
    
    # Import du fichier RH
    $hrData = Import-Csv -Path $HRFilePath -Encoding UTF8
    
    # Récupérer tous les utilisateurs AD
    $adUsers = Get-ADUser -Filter * -Properties EmployeeID, Department, Title, EmailAddress
    
    $stats = @{
        ToCreate = @()
        ToUpdate = @()
        ToDisable = @()
    }
    
    # Identifier les actions nécessaires
    foreach ($hrUser in $hrData) {
        $adUser = $adUsers | Where-Object { $_.EmployeeID -eq $hrUser.EmployeeID }
        
        if (-not $adUser) {
            # Utilisateur n'existe pas dans AD -> Créer
            $stats.ToCreate += $hrUser
        } else {
            # Utilisateur existe -> Vérifier si mise à jour nécessaire
            if ($adUser.Department -ne $hrUser.Department -or 
                $adUser.Title -ne $hrUser.Title -or
                $adUser.EmailAddress -ne $hrUser.EmailAddress) {
                $stats.ToUpdate += $hrUser
            }
        }
    }
    
    # Identifier les utilisateurs à désactiver (présents dans AD mais pas dans RH)
    $hrEmployeeIDs = $hrData | Select-Object -ExpandProperty EmployeeID
    $stats.ToDisable = $adUsers | Where-Object { 
        $_.EmployeeID -and $_.EmployeeID -notin $hrEmployeeIDs -and $_.Enabled -eq $true 
    }
    
    # Afficher le résumé
    Write-Host "`n=== Rapport de synchronisation ===" -ForegroundColor Cyan
    Write-Host "À créer : $($stats.ToCreate.Count)" -ForegroundColor Green
    Write-Host "À mettre à jour : $($stats.ToUpdate.Count)" -ForegroundColor Yellow
    Write-Host "À désactiver : $($stats.ToDisable.Count)" -ForegroundColor Red
    
    # Exécuter les actions
    $confirmation = Read-Host "`nExécuter la synchronisation ? (O/N)"
    if ($confirmation -eq 'O') {
        # Créations
        foreach ($hrUser in $stats.ToCreate) {
            $password = ConvertTo-SecureString (New-RandomPassword -Length 14) -AsPlainText -Force
            
            New-ADUser -Name "$($hrUser.FirstName) $($hrUser.LastName)" `
                       -GivenName $hrUser.FirstName `
                       -Surname $hrUser.LastName `
                       -SamAccountName $hrUser.Username `
                       -UserPrincipalName "$($hrUser.Username)@entreprise.local" `
                       -EmailAddress $hrUser.EmailAddress `
                       -Department $hrUser.Department `
                       -Title $hrUser.Title `
                       -EmployeeID $hrUser.EmployeeID `
                       -AccountPassword $password `
                       -Enabled $true `
                       -ChangePasswordAtLogon $true
            
            Write-Host "✓ Créé: $($hrUser.Username)" -ForegroundColor Green
        }
        
        # Mises à jour
        foreach ($hrUser in $stats.ToUpdate) {
            Set-ADUser -Identity $hrUser.Username `
                       -Department $hrUser.Department `
                       -Title $hrUser.Title `
                       -EmailAddress $hrUser.EmailAddress
            
            Write-Host "✓ Mis à jour: $($hrUser.Username)" -ForegroundColor Yellow
        }
        
        # Désactivations
        foreach ($adUser in $stats.ToDisable) {
            Disable-ADAccount -Identity $adUser.SamAccountName
            Write-Host "✓ Désactivé: $($adUser.SamAccountName)" -ForegroundColor Red
        }
    }
}

# Utilisation
Sync-ADFromHR -HRFilePath "C:\RH\export_mensuel.csv"
```

---

## 📚 Résumé des commandes essentielles

### Get-ADUser - Syntaxe rapide

```powershell
# Recherche basique
Get-ADUser -Identity "username"
Get-ADUser -Filter "Enabled -eq $true"
Get-ADUser -Filter * -SearchBase "OU=IT,DC=domain,DC=local"

# Avec propriétés
Get-ADUser -Identity "username" -Properties EmailAddress, Department, Manager
Get-ADUser -Filter * -Properties * # Toutes les propriétés (lent)

# Filtres courants
Get-ADUser -Filter "Department -eq 'IT' -and Enabled -eq $true"
Get-ADUser -Filter "EmailAddress -like '*@domain.com'"
Get-ADUser -Filter "LastLogonDate -gt $date"

# Export
Get-ADUser -Filter * -Properties EmailAddress | 
    Select-Object Name, SamAccountName, EmailAddress | 
    Export-Csv -Path "users.csv" -NoTypeInformation
```

### New-ADUser - Syntaxe rapide

```powershell
# Minimal
New-ADUser -Name "John Doe" -SamAccountName "jdoe"

# Complet
$pwd = ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force
New-ADUser -Name "John Doe" `
           -GivenName "John" `
           -Surname "Doe" `
           -SamAccountName "jdoe" `
           -UserPrincipalName "jdoe@domain.local" `
           -DisplayName "John DOE" `
           -EmailAddress "john.doe@domain.com" `
           -Department "IT" `
           -Title "Admin" `
           -Path "OU=IT,DC=domain,DC=local" `
           -AccountPassword $pwd `
           -Enabled $true `
           -ChangePasswordAtLogon $true

# Import CSV
$users = Import-Csv "users.csv"
foreach ($user in $users) {
    $pwd = ConvertTo-SecureString "TempPass!" -AsPlainText -Force
    New-ADUser -Name $user.Name `
               -SamAccountName $user.SamAccountName `
               -AccountPassword $pwd `
               -Enabled $true
}
```

---

## 🎓 Points clés à retenir

> [!tip] Get-ADUser - L'essentiel
> 
> 1. **Toujours utiliser `-Filter`** ou `-Identity` (obligatoire)
> 2. **Limiter les propriétés** avec `-Properties` (éviter `*` en production)
> 3. **Utiliser `-SearchBase`** pour optimiser les performances
> 4. **Privilégier `-Filter`** côté serveur plutôt que `Where-Object`
> 5. **Exporter en CSV** avec `-NoTypeInformation` et encodage UTF8

> [!tip] New-ADUser - L'essentiel
> 
> 6. **Minimum requis** : `-Name` et `-SamAccountName`
> 7. **Compte utilisable** : ajouter `-AccountPassword`, `-Enabled $true`, `-Path`
> 8. **Sécurité** : toujours utiliser `ConvertTo-SecureString` pour les mots de passe
> 9. **Validation** : vérifier l'unicité du SamAccountName et l'existence des OUs
> 10. **Création en masse** : gérer les erreurs, journaliser, générer des rapports

> [!warning] Erreurs fréquentes à éviter
> 
> - ❌ Utiliser `Get-ADUser -Filter *` sans nécessité (lent)
> - ❌ Demander toutes les propriétés avec `-Properties *` (lourd)
> - ❌ Oublier de convertir les mots de passe en SecureString
> - ❌ Ne pas vérifier l'unicité du SamAccountName avant création
> - ❌ Ne pas gérer les erreurs dans les scripts de masse
> - ❌ Coder en dur les mots de passe dans les scripts
> - ❌ Oublier `-ChangePasswordAtLogon $true` pour les nouveaux comptes

---

## 🔐 Considérations de sécurité

### Bonnes pratiques de sécurité

1. **Mots de passe**
    
    - Générer des mots de passe complexes aléatoires
    - Ne jamais afficher ou journaliser les mots de passe
    - Forcer le changement à la première connexion
    - Respecter la politique de mot de passe du domaine
2. **Permissions**
    
    - Appliquer le principe du moindre privilège
    - Utiliser des groupes de délégation plutôt que Domain Admins
    - Auditer régulièrement les droits de création d'utilisateurs
    - Documenter qui peut créer des utilisateurs et où
3. **Audit et traçabilité**
    
    - Journaliser toutes les créations d'utilisateurs
    - Conserver les logs pendant une durée réglementaire
    - Identifier clairement qui a créé quel compte et quand
    - Mettre en place des alertes pour les créations inhabituelles
4. **Validation des données**
    
    - Valider les entrées utilisateur (format email, numéros de téléphone)
    - Vérifier l'existence des managers, OUs, groupes
    - Contrôler les conventions de nommage (SamAccountName, UPN)
    - Éviter les injections LDAP dans les filtres

### Exemple de script sécurisé

```powershell
function New-SecureADUser {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$GivenName,
        
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Surname,
        
        [Parameter(Mandatory)]
        [ValidatePattern('^[a-z0-9]{3,20})]
        [string]$SamAccountName,
        
        [Parameter(Mandatory)]
        [ValidatePattern('^[\w-\.]+@([\w-]+\.)+[\w-]{2,4})]
        [string]$EmailAddress,
        
        [Parameter(Mandatory)]
        [ValidateSet('IT', 'RH', 'Commercial', 'Finance')]
        [string]$Department
    )
    
    # Validation de l'unicité
    if (Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'" -ErrorAction SilentlyContinue) {
        throw "L'utilisateur $SamAccountName existe déjà"
    }
    
    # Génération de mot de passe sécurisé
    $password = ConvertTo-SecureString (New-RandomPassword -Length 16 -IncludeSpecialChars) -AsPlainText -Force
    
    # Journalisation
    $logEntry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Création utilisateur $SamAccountName par $($env:USERNAME)"
    Add-Content -Path "C:\Logs\AD_UserCreation.log" -Value $logEntry
    
    # Création avec confirmation
    if ($PSCmdlet.ShouldProcess($SamAccountName, "Créer utilisateur AD")) {
        try {
            New-ADUser -Name "$GivenName $Surname" `
                       -GivenName $GivenName `
                       -Surname $Surname `
                       -SamAccountName $SamAccountName `
                       -UserPrincipalName "$SamAccountName@entreprise.local" `
                       -EmailAddress $EmailAddress `
                       -Department $Department `
                       -AccountPassword $password `
                       -Enabled $true `
                       -ChangePasswordAtLogon $true `
                       -ErrorAction Stop
            
            Write-Host "✓ Utilisateur $SamAccountName créé avec succès" -ForegroundColor Green
            
            # Journalisation succès
            Add-Content -Path "C:\Logs\AD_UserCreation.log" -Value "  → SUCCÈS"
            
            return $true
        }
        catch {
            Write-Error "Erreur lors de la création : $($_.Exception.Message)"
            Add-Content -Path "C:\Logs\AD_UserCreation.log" -Value "  → ÉCHEC: $($_.Exception.Message)"
            return $false
        }
    }
}

# Utilisation avec WhatIf pour tester sans créer
New-SecureADUser -GivenName "Test" -Surname "User" `
                 -SamAccountName "tuser" -EmailAddress "tuser@entreprise.com" `
                 -Department "IT" -WhatIf
```

---

## 📊 Performances et optimisation

### Optimisation des requêtes Get-ADUser

```powershell
# ❌ LENT : Récupérer tous puis filtrer côté client
$users = Get-ADUser -Filter * -Properties Department
$itUsers = $users | Where-Object { $_.Department -eq 'IT' }

# ✅ RAPIDE : Filtrer côté serveur
$itUsers = Get-ADUser -Filter "Department -eq 'IT'" -Properties Department

# ❌ LENT : Demander toutes les propriétés
Get-ADUser -Filter * -Properties *

# ✅ RAPIDE : Demander uniquement les propriétés nécessaires
Get-ADUser -Filter * -Properties EmailAddress, Department, Title

# ✅ OPTIMISÉ : Limiter avec SearchBase
Get-ADUser -Filter * -SearchBase "OU=IT,DC=entreprise,DC=local" `
           -Properties EmailAddress -SearchScope OneLevel
```

### Optimisation des créations en masse

```powershell
# Créations parallèles avec runspaces (pour grands volumes)
$users = Import-Csv "users.csv"

# Définir le nombre de threads parallèles
$throttleLimit = 10

# Utiliser ForEach-Object -Parallel (PowerShell 7+)
$users | ForEach-Object -ThrottleLimit $throttleLimit -Parallel {
    $password = ConvertTo-SecureString "TempPass!" -AsPlainText -Force
    
    New-ADUser -Name $_.Name `
               -SamAccountName $_.SamAccountName `
               -AccountPassword $password `
               -Enabled $true `
               -ErrorAction Continue
}

# Pour PowerShell 5.1, utiliser PoshRSJob ou ThreadJob
```

### Mesure des performances

```powershell
# Mesurer le temps d'exécution
Measure-Command {
    Get-ADUser -Filter * -Properties EmailAddress, Department
}

# Comparer deux approches
$temps1 = Measure-Command {
    Get-ADUser -Filter * | Where-Object { $_.Enabled -eq $true }
}

$temps2 = Measure-Command {
    Get-ADUser -Filter "Enabled -eq $true"
}

Write-Host "Approche 1: $($temps1.TotalSeconds)s"
Write-Host "Approche 2: $($temps2.TotalSeconds)s"
Write-Host "Gain: $(($temps1.TotalSeconds - $temps2.TotalSeconds))s"
```

---

_Fin du cours - Get-ADUser & New-ADUser_