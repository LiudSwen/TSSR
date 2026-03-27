

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

## <a id="introduction"></a>🎯 Introduction aux comptes utilisateurs

Les **objets utilisateurs** (User objects) sont les éléments fondamentaux d'Active Directory qui représentent des personnes physiques ou des services nécessitant une authentification dans le domaine.

> [!info] Définition
> Un compte utilisateur AD est un objet qui contient toutes les informations nécessaires pour authentifier et autoriser une personne ou un service à accéder aux ressources du réseau.

### Pourquoi c'est important ?

- **Authentification centralisée** : Un seul compte pour accéder à toutes les ressources du domaine
- **Gestion des permissions** : Contrôle précis des droits d'accès
- **Audit et traçabilité** : Suivi de l'activité des utilisateurs
- **Automatisation** : Gestion en masse via scripts PowerShell

---

## <a id="création"></a>➕ Création de comptes utilisateurs

### Méthodes de création

Il existe trois principales méthodes pour créer des comptes utilisateurs :

| Méthode | Avantages | Cas d'usage |
|---------|-----------|-------------|
| **Interface graphique (ADUC)** | Intuitive, visuelle | Création ponctuelle, administration quotidienne |
| **PowerShell** | Automatisation, scripts | Création en masse, tâches répétitives |
| **Importation CSV** | Création massive | Intégration RH, provisioning |

### Création via l'interface graphique (ADUC)

> [!example] Étapes dans Active Directory Users and Computers
> 1. Ouvrir **Active Directory Users and Computers**
> 2. Naviguer vers l'OU cible
> 3. Clic droit → **New** → **User**
> 4. Remplir les informations obligatoires :
>    - **First name** (Prénom)
>    - **Last name** (Nom)
>    - **User logon name** (Identifiant de connexion)
> 5. Définir le mot de passe initial
> 6. Cocher les options appropriées

### Création via PowerShell

```powershell
# Création d'un utilisateur simple
New-ADUser -Name "Jean Dupont" `
           -GivenName "Jean" `
           -Surname "Dupont" `
           -SamAccountName "jdupont" `
           -UserPrincipalName "jdupont@domaine.local" `
           -Path "OU=Utilisateurs,OU=Paris,DC=domaine,DC=local" `
           -AccountPassword (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force) `
           -Enabled $true `
           -ChangePasswordAtLogon $true

# Création avec informations détaillées
New-ADUser -Name "Marie Martin" `
           -GivenName "Marie" `
           -Surname "Martin" `
           -SamAccountName "mmartin" `
           -UserPrincipalName "mmartin@domaine.local" `
           -Path "OU=Utilisateurs,OU=Lyon,DC=domaine,DC=local" `
           -AccountPassword (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force) `
           -Enabled $true `
           -DisplayName "MARTIN Marie" `
           -EmailAddress "marie.martin@domaine.local" `
           -Title "Responsable IT" `
           -Department "Informatique" `
           -Company "MonEntreprise" `
           -Office "Lyon - Bâtiment A" `
           -OfficePhone "+33 4 XX XX XX XX" `
           -MobilePhone "+33 6 XX XX XX XX" `
           -Description "Compte créé le $(Get-Date -Format 'dd/MM/yyyy')"
```

> [!tip] Astuce - Nomenclature des identifiants
> Établissez une convention de nommage cohérente :
> - `prenom.nom` → jean.dupont
> - `premiere_lettre_prenom + nom` → jdupont
> - `nom + premiere_lettre_prenom` → dupontj
> 
> La cohérence facilite la gestion et évite les doublons.

### Création en masse via CSV

```powershell
# Structure du fichier CSV : users.csv
# GivenName,Surname,SamAccountName,UPN,OU,Department
# Jean,Dupont,jdupont,jdupont@domaine.local,"OU=Utilisateurs,DC=domaine,DC=local",IT
# Marie,Martin,mmartin,mmartin@domaine.local,"OU=Utilisateurs,DC=domaine,DC=local",RH

# Script d'importation
$Users = Import-Csv -Path "C:\Scripts\users.csv" -Delimiter ","

foreach ($User in $Users) {
    $Password = ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force
    
    try {
        New-ADUser -Name "$($User.GivenName) $($User.Surname)" `
                   -GivenName $User.GivenName `
                   -Surname $User.Surname `
                   -SamAccountName $User.SamAccountName `
                   -UserPrincipalName $User.UPN `
                   -Path $User.OU `
                   -Department $User.Department `
                   -AccountPassword $Password `
                   -Enabled $true `
                   -ChangePasswordAtLogon $true
        
        Write-Host "✓ Utilisateur $($User.SamAccountName) créé avec succès" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Erreur lors de la création de $($User.SamAccountName): $_" -ForegroundColor Red
    }
}
```

> [!warning] Attention - Sécurité des mots de passe
> Ne jamais stocker les mots de passe en clair dans les scripts ou fichiers CSV. Utilisez des mots de passe temporaires et forcez le changement à la première connexion.

---

## <a id="propriétés"></a>🔧 Propriétés et attributs

### Catégories de propriétés

Les comptes utilisateurs possèdent de nombreux attributs organisés en plusieurs onglets dans ADUC :

#### 1. **Onglet General**

Informations d'identité de base :

```powershell
# Modification des propriétés générales
Set-ADUser -Identity "jdupont" `
           -DisplayName "DUPONT Jean" `
           -Description "Développeur Full Stack" `
           -Office "Paris - Étage 3" `
           -EmailAddress "jean.dupont@domaine.local" `
           -HomePage "https://intranet.domaine.local/profil/jdupont"
```

| Attribut | Description | Importance |
|----------|-------------|------------|
| **Display Name** | Nom affiché dans Outlook/Teams | Haute |
| **Description** | Rôle ou fonction | Moyenne |
| **Office** | Localisation physique | Moyenne |
| **Email** | Adresse électronique | Haute |

#### 2. **Onglet Account**

Paramètres de connexion et de sécurité :

```powershell
# Configuration du compte
Set-ADUser -Identity "jdupont" `
           -ChangePasswordAtLogon $false `
           -PasswordNeverExpires $false `
           -CannotChangePassword $false `
           -AccountExpirationDate "31/12/2025"

# Heures de connexion (exemple : lundi-vendredi 8h-18h)
$LogonHours = New-Object byte[] 21
# Configuration binaire des heures autorisées
0..20 | ForEach-Object { $LogonHours[$_] = 0xFF }
Set-ADUser -Identity "jdupont" -Replace @{logonHours = $LogonHours}

# Restriction des postes de travail
Set-ADUser -Identity "jdupont" -LogonWorkstations "PC-001,PC-002,LAPTOP-JD"
```

> [!info] Options du compte importantes
> - **User must change password at next logon** : Force le changement de mot de passe
> - **User cannot change password** : Utilisé pour les comptes de service
> - **Password never expires** : Dangereux pour les comptes normaux, acceptable pour les services
> - **Account is disabled** : Désactive temporairement l'accès

#### 3. **Onglet Profile**

Chemins réseau et scripts :

```powershell
# Configuration du profil utilisateur
Set-ADUser -Identity "jdupont" `
           -ProfilePath "\\serveur\profils\jdupont" `
           -ScriptPath "logon.vbs" `
           -HomeDirectory "\\serveur\home\jdupont" `
           -HomeDrive "H:"
```

| Propriété | Usage | Exemple |
|-----------|-------|---------|
| **Profile Path** | Profil itinérant | `\\serveur\profils\%username%` |
| **Logon Script** | Script d'ouverture de session | `logon.bat` ou `logon.ps1` |
| **Home Folder** | Dossier personnel | Lecteur réseau `H:` |

#### 4. **Onglet Organization**

Informations hiérarchiques :

```powershell
# Informations organisationnelles
Set-ADUser -Identity "jdupont" `
           -Title "Développeur Senior" `
           -Department "DSI" `
           -Company "MonEntreprise SAS" `
           -Manager "CN=Pierre Martin,OU=Managers,DC=domaine,DC=local"

# Récupérer le manager d'un utilisateur
$Manager = Get-ADUser -Identity "jdupont" -Properties Manager | Select-Object -ExpandProperty Manager
Get-ADUser -Identity $Manager | Select-Object Name, Title
```

#### 5. **Attributs personnalisés (Extension Attributes)**

Active Directory propose 15 attributs d'extension personnalisables :

```powershell
# Utilisation des attributs d'extension
Set-ADUser -Identity "jdupont" `
           -Replace @{
               extensionAttribute1 = "Matricule: EMP-12345"
               extensionAttribute2 = "Badge: B-67890"
               extensionAttribute3 = "Site: Paris"
           }

# Recherche par attribut personnalisé
Get-ADUser -Filter {extensionAttribute3 -eq "Paris"} -Properties extensionAttribute3
```

### Consultation des propriétés

```powershell
# Voir toutes les propriétés d'un utilisateur
Get-ADUser -Identity "jdupont" -Properties *

# Voir uniquement certaines propriétés
Get-ADUser -Identity "jdupont" -Properties DisplayName, EmailAddress, Department, Title | 
    Select-Object Name, DisplayName, EmailAddress, Department, Title

# Exporter les propriétés vers CSV
Get-ADUser -Identity "jdupont" -Properties * | 
    Select-Object Name, SamAccountName, EmailAddress, Department, Title, Enabled |
    Export-Csv -Path "C:\Export\UserInfo.csv" -NoTypeInformation
```

> [!tip] Astuce - Performance
> N'utilisez `-Properties *` que pour le débogage. En production, spécifiez toujours les propriétés exactes dont vous avez besoin pour optimiser les performances.

---

## <a id="comptes-spéciaux"></a>⚙️ Comptes de service et comptes système

### Comptes de service (Service Accounts)

Les comptes de service sont des comptes utilisés par les applications et services pour s'authentifier et accéder aux ressources.

#### Types de comptes de service

| Type | Description | Cas d'usage |
|------|-------------|-------------|
| **Compte utilisateur standard** | Compte AD classique dédié | Applications legacy |
| **MSA** (Managed Service Account) | Géré automatiquement par AD | Service sur un seul serveur |
| **gMSA** (Group Managed Service Account) | MSA multi-serveurs | Fermes de serveurs, clustering |

#### Création d'un compte de service standard

```powershell
# Compte de service pour une application
New-ADUser -Name "SVC_AppWeb" `
           -SamAccountName "svc_appweb" `
           -UserPrincipalName "svc_appweb@domaine.local" `
           -Path "OU=ServiceAccounts,DC=domaine,DC=local" `
           -AccountPassword (ConvertTo-SecureString "P@ssw0rd_C0mplex3!" -AsPlainText -Force) `
           -Enabled $true `
           -PasswordNeverExpires $true `
           -CannotChangePassword $true `
           -Description "Compte de service pour l'application Web interne"

# Définir le SPN (Service Principal Name) si nécessaire
SetSPN -A HTTP/appweb.domaine.local svc_appweb
```

> [!warning] Bonnes pratiques - Comptes de service
> - Préfixez toujours les comptes de service (ex: `SVC_`, `SA_`)
> - Utilisez des mots de passe très complexes (25+ caractères)
> - Stockez-les dans une OU dédiée
> - Documentez leur usage dans le champ Description
> - Ne leur donnez jamais de droits d'administration inutiles
> - Auditez régulièrement leur utilisation
> - Privilégiez les gMSA quand c'est possible

#### Création d'un gMSA (Groupe Managed Service Account)

```powershell
# Prérequis : Vérifier que le KDS Root Key existe (pour la rotation automatique)
Get-KdsRootKey

# Si absent, créer la clé (prend effet après 10h ou immédiatement en lab)
Add-KdsRootKey -EffectiveTime ((Get-Date).AddHours(-10))

# Créer le gMSA
New-ADServiceAccount -Name "gMSA_WebFarm" `
                     -DNSHostName "gMSA_WebFarm.domaine.local" `
                     -PrincipalsAllowedToRetrieveManagedPassword "WEB-SRV01$","WEB-SRV02$","WEB-SRV03$" `
                     -ServicePrincipalNames "HTTP/webfarm.domaine.local"

# Installer le gMSA sur un serveur
Install-ADServiceAccount -Identity "gMSA_WebFarm"

# Tester le gMSA
Test-ADServiceAccount -Identity "gMSA_WebFarm"
```

> [!info] Avantages des gMSA
> - Rotation automatique du mot de passe (par défaut tous les 30 jours)
> - Pas de gestion manuelle des mots de passe
> - Sécurité renforcée
> - Support du clustering et load balancing

### Comptes système intégrés

Active Directory contient des comptes système prédéfinis qu'il ne faut **jamais supprimer ou modifier** :

| Compte | Description | Usage |
|--------|-------------|-------|
| **Administrator** | Administrateur par défaut du domaine | Administration d'urgence uniquement |
| **Guest** | Invité (désactivé par défaut) | Doit rester désactivé |
| **krbtgt** | Compte Kerberos | Utilisé par le protocole Kerberos |
| **SYSTEM** | Compte local système | Processus système Windows |

```powershell
# Vérifier l'état des comptes système
Get-ADUser -Filter {SamAccountName -like "kr*" -or SamAccountName -eq "Administrator"} -Properties * |
    Select-Object Name, SamAccountName, Enabled, Description

# Désactiver le compte Guest (bonne pratique)
Disable-ADAccount -Identity "Guest"
```

> [!warning] Sécurité - Compte Administrator
> - Renommez le compte Administrator par défaut
> - Créez des comptes d'administration nominatifs
> - Activez l'audit sur ce compte
> - Utilisez des mots de passe extrêmement complexes (40+ caractères)

---

## <a id="activation-désactivation"></a>🔄 Activation et désactivation de comptes

### Désactivation de comptes

La désactivation d'un compte empêche son utilisation sans supprimer les données associées.

#### Quand désactiver un compte ?

- Employé en congé longue durée
- Départ temporaire (mutation, détachement)
- Compte compromis nécessitant investigation
- Avant suppression définitive (période de rétention)

#### Désactivation via PowerShell

```powershell
# Désactiver un seul utilisateur
Disable-ADAccount -Identity "jdupont"

# Vérifier l'état
Get-ADUser -Identity "jdupont" | Select-Object Name, Enabled

# Désactiver avec log et date
Disable-ADAccount -Identity "jdupont"
Set-ADUser -Identity "jdupont" -Description "Compte désactivé le $(Get-Date -Format 'dd/MM/yyyy') - Départ entreprise"

# Désactiver plusieurs utilisateurs d'un coup
$Users = "jdupont","mmartin","pdurand"
foreach ($User in $Users) {
    Disable-ADAccount -Identity $User
    Write-Host "Compte $User désactivé" -ForegroundColor Yellow
}
```

#### Désactivation de comptes inactifs

```powershell
# Trouver les comptes non utilisés depuis 90 jours
$InactiveDays = 90
$InactiveDate = (Get-Date).AddDays(-$InactiveDays)

$InactiveUsers = Get-ADUser -Filter {LastLogonDate -lt $InactiveDate -and Enabled -eq $true} `
                             -Properties LastLogonDate, Description |
                 Where-Object {$_.SamAccountName -notlike "svc_*"}

# Afficher les comptes inactifs
$InactiveUsers | Select-Object Name, SamAccountName, LastLogonDate, Description |
    Format-Table -AutoSize

# Désactiver après validation
foreach ($User in $InactiveUsers) {
    Disable-ADAccount -Identity $User.SamAccountName
    
    $NewDescription = "Désactivé auto le $(Get-Date -Format 'dd/MM/yyyy') - Inactif depuis $InactiveDays jours"
    Set-ADUser -Identity $User.SamAccountName -Description $NewDescription
    
    Write-Host "✓ $($User.SamAccountName) désactivé" -ForegroundColor Yellow
}
```

> [!tip] Astuce - Processus de désactivation
> Créez un workflow :
> 1. Désactiver le compte
> 2. Révoquer les sessions actives
> 3. Supprimer des groupes sensibles
> 4. Transférer la messagerie (optionnel)
> 5. Documenter dans Description
> 6. Déplacer vers OU "Comptes Désactivés"
> 7. Planifier la suppression après X mois

### Activation de comptes

```powershell
# Activer un compte
Enable-ADAccount -Identity "jdupont"

# Activer et réinitialiser le mot de passe
Enable-ADAccount -Identity "jdupont"
Set-ADAccountPassword -Identity "jdupont" `
                      -Reset `
                      -NewPassword (ConvertTo-SecureString "P@ssw0rd_N0uveau!" -AsPlainText -Force)
Set-ADUser -Identity "jdupont" -ChangePasswordAtLogon $true

# Activer et mettre à jour la description
Enable-ADAccount -Identity "jdupont"
Set-ADUser -Identity "jdupont" -Description "Compte réactivé le $(Get-Date -Format 'dd/MM/yyyy') - Retour de congé"
```

### Déplacement vers OU dédiée

```powershell
# Déplacer vers OU des comptes désactivés
$DisabledOU = "OU=DisabledAccounts,DC=domaine,DC=local"

# Déplacer un utilisateur
Get-ADUser -Identity "jdupont" | Move-ADObject -TargetPath $DisabledOU

# Déplacer tous les comptes désactivés d'une OU
Get-ADUser -Filter {Enabled -eq $false} -SearchBase "OU=Utilisateurs,DC=domaine,DC=local" |
    Move-ADObject -TargetPath $DisabledOU
```

---

## <a id="mots-de-passe"></a>🔐 Réinitialisation de mots de passe

### Politique de mots de passe

Avant de réinitialiser, il est important de comprendre les politiques appliquées (définies au niveau du domaine ou des PSO - Password Settings Objects).

```powershell
# Voir la politique par défaut du domaine
Get-ADDefaultDomainPasswordPolicy

# Voir les PSO (Fine-Grained Password Policy)
Get-ADFineGrainedPasswordPolicy -Filter * | 
    Select-Object Name, Precedence, MinPasswordLength, PasswordHistoryCount

# Voir quelle politique s'applique à un utilisateur
Get-ADUserResultantPasswordPolicy -Identity "jdupont"
```

### Réinitialisation simple

```powershell
# Méthode 1 : Réinitialisation avec nouveau mot de passe
Set-ADAccountPassword -Identity "jdupont" `
                      -Reset `
                      -NewPassword (ConvertTo-SecureString "P@ssw0rd_Temp123!" -AsPlainText -Force)

# Forcer le changement à la prochaine connexion
Set-ADUser -Identity "jdupont" -ChangePasswordAtLogon $true

# Méthode 2 : Tout en une commande
$NewPassword = ConvertTo-SecureString "P@ssw0rd_Temp123!" -AsPlainText -Force
Set-ADAccountPassword -Identity "jdupont" -Reset -NewPassword $NewPassword
Set-ADUser -Identity "jdupont" -ChangePasswordAtLogon $true
Write-Host "✓ Mot de passe réinitialisé pour jdupont" -ForegroundColor Green
```

### Réinitialisation interactive

```powershell
# Demander le mot de passe de manière sécurisée (non visible)
$NewPassword = Read-Host "Entrez le nouveau mot de passe" -AsSecureString
Set-ADAccountPassword -Identity "jdupont" -Reset -NewPassword $NewPassword
Set-ADUser -Identity "jdupont" -ChangePasswordAtLogon $true

# Script interactif complet
$Username = Read-Host "Nom d'utilisateur"
$NewPassword = Read-Host "Nouveau mot de passe" -AsSecureString

try {
    Set-ADAccountPassword -Identity $Username -Reset -NewPassword $NewPassword -ErrorAction Stop
    Set-ADUser -Identity $Username -ChangePasswordAtLogon $true -ErrorAction Stop
    Write-Host "✓ Mot de passe réinitialisé avec succès pour $Username" -ForegroundColor Green
}
catch {
    Write-Host "✗ Erreur : $_" -ForegroundColor Red
}
```

### Génération automatique de mots de passe

```powershell
# Fonction pour générer un mot de passe complexe
function New-RandomPassword {
    param(
        [int]$Length = 16
    )
    
    $CharSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
    $Password = -join ((1..$Length) | ForEach-Object { $CharSet[(Get-Random -Maximum $CharSet.Length)] })
    
    return $Password
}

# Utilisation
$GeneratedPassword = New-RandomPassword -Length 20
$SecurePassword = ConvertTo-SecureString $GeneratedPassword -AsPlainText -Force

Set-ADAccountPassword -Identity "jdupont" -Reset -NewPassword $SecurePassword
Set-ADUser -Identity "jdupont" -ChangePasswordAtLogon $true

Write-Host "Mot de passe temporaire : $GeneratedPassword" -ForegroundColor Cyan
Write-Host "À communiquer à l'utilisateur de manière sécurisée !" -ForegroundColor Yellow
```

> [!warning] Sécurité - Communication des mots de passe
> - Ne jamais envoyer de mot de passe par email
> - Utiliser un canal sécurisé (téléphone, en personne, outil de partage sécurisé)
> - Toujours forcer le changement à la première connexion
> - Documenter la réinitialisation dans les logs

### Déblocage de compte

Les comptes se bloquent après X tentatives incorrectes (défini dans la politique).

```powershell
# Vérifier si un compte est bloqué
Get-ADUser -Identity "jdupont" -Properties LockedOut | Select-Object Name, LockedOut

# Débloquer un compte
Unlock-ADAccount -Identity "jdupont"

# Débloquer et réinitialiser en même temps
Unlock-ADAccount -Identity "jdupont"
$NewPassword = ConvertTo-SecureString "P@ssw0rd_Reset123!" -AsPlainText -Force
Set-ADAccountPassword -Identity "jdupont" -Reset -NewPassword $NewPassword
Set-ADUser -Identity "jdupont" -ChangePasswordAtLogon $true

Write-Host "✓ Compte débloqué et mot de passe réinitialisé" -ForegroundColor Green
```

### Recherche des comptes bloqués

```powershell
# Trouver tous les comptes bloqués dans le domaine
Search-ADAccount -LockedOut | 
    Select-Object Name, SamAccountName, LockedOut, LastLogonDate |
    Format-Table -AutoSize

# Débloquer tous les comptes (avec confirmation)
$LockedAccounts = Search-ADAccount -LockedOut

foreach ($Account in $LockedAccounts) {
    $Confirm = Read-Host "Débloquer $($Account.SamAccountName)? (O/N)"
    if ($Confirm -eq "O") {
        Unlock-ADAccount -Identity $Account.SamAccountName
        Write-Host "✓ $($Account.SamAccountName) débloqué" -ForegroundColor Green
    }
}
```

### Historique des changements de mot de passe

```powershell
# Voir la dernière modification du mot de passe
Get-ADUser -Identity "jdupont" -Properties PasswordLastSet, PasswordExpired, PasswordNeverExpires |
    Select-Object Name, PasswordLastSet, PasswordExpired, PasswordNeverExpires

# Calculer quand le mot de passe expirera
$User = Get-ADUser -Identity "jdupont" -Properties PasswordLastSet
$Policy = Get-ADDefaultDomainPasswordPolicy
$ExpirationDate = $User.PasswordLastSet.AddDays($Policy.MaxPasswordAge.Days)

Write-Host "Mot de passe défini le : $($User.PasswordLastSet)" -ForegroundColor Cyan
Write-Host "Expiration prévue le : $ExpirationDate" -ForegroundColor Yellow
Write-Host "Jours restants : $(($ExpirationDate - (Get-Date)).Days)" -ForegroundColor Green
```

> [!tip] Automatisation - Script de réinitialisation complet
> Créez un script standardisé qui :
> 1. Vérifie l'existence de l'utilisateur
> 2. Génère un mot de passe aléatoire complexe
> 3. Débloque le compte si nécessaire
> 4. Réinitialise le mot de passe
> 5. Force le changement
> 6. Envoie une notification à l'administrateur
> 7. Log l'action dans un fichier

### Gestion des expéditions de mot de passe

```powershell
# Désactiver l'expiration pour un compte spécifique
Set-ADUser -Identity "jdupont" -PasswordNeverExpires $true

# Forcer l'expiration immédiate (oblige à changer)
Set-ADUser -Identity "jdupont" -ChangePasswordAtLogon $true

# Voir tous les utilisateurs avec mots de passe qui n'expirent jamais
Get-ADUser -Filter {PasswordNeverExpires -eq $true} -Properties PasswordNeverExpires |
    Where-Object {$_.Enabled -eq $true} |
    Select-Object Name, SamAccountName, PasswordNeverExpires |
    Format-Table -AutoSize
```

> [!info] Bonnes pratiques - Mots de passe
> - Longueur minimale : 12-14 caractères (16+ pour les admins)
> - Complexité : majuscules, minuscules, chiffres, symboles
> - Historique : conserver les 24 derniers mots de passe
> - Durée de vie : 90 jours max (60 pour les comptes sensibles)
> - Blocage : 5 tentatives max, durée de blocage 30 min
> - Comptes de service : mots de passe très longs (25+) ou gMSA

---

## 🎯 Pièges courants et bonnes pratiques

### ❌ Pièges à éviter

1. **Créer des comptes dans le conteneur Users par défaut**
   - Toujours utiliser des OU organisées logiquement

2. **Ne pas documenter les comptes de service**
   - Le champ Description est votre ami

3. **Oublier de désactiver les comptes au départ des employés**
   - Automatisez avec des scripts basés sur l'inactivité

4. **Donner trop de permissions dès la création**
   - Principe du moindre privilège : ajoutez les droits progressivement

5. **Ne pas sauvegarder les SPN des comptes de service**
   - Documentez-les pour faciliter les migrations

### ✅ Bonnes pratiques

1. **Convention de nommage cohérente**
   ```powershell
   # Bon exemple
   SamAccountName: jdupont
   DisplayName: DUPONT Jean
   UPN: jdupont@domaine.local
   
   # Comptes de service
   SamAccountName: svc_application
   DisplayName: Service - Application Web
   ```

2. **Structure organisationnelle claire**
   ```
   OU=Utilisateurs
   ├── OU=Paris
   │   ├── OU=IT
   │   ├── OU=RH
   │   └── OU=Finance
   ├── OU=Lyon
   └── OU=Marseille
   
   OU=ServiceAccounts
   ├── OU=SQL_Services
   ├── OU=Web_Services
   └── OU=Backup_Services
   ```

3. **Automatisation des tâches répétitives**
   ```powershell
   # Script de création standardisé
   function New-StandardUser {
       param(
           [Parameter(Mandatory=$true)]
           [string]$FirstName,
           
           [Parameter(Mandatory=$true)]
           [string]$LastName,
           
           [Parameter(Mandatory=$true)]
           [string]$Department,
           
           [Parameter(Mandatory=$true)]
           [string]$Location
       )
       
       # Génération automatique des identifiants
       $SamAccountName = ($FirstName.Substring(0,1) + $LastName).ToLower()
       $UPN = "$SamAccountName@domaine.local"
       $DisplayName = "$LastName $FirstName".ToUpper()
       $Email = "$FirstName.$LastName@domaine.local".ToLower()
       
       # OU basée sur le site
       $OU = "OU=$Department,OU=$Location,OU=Utilisateurs,DC=domaine,DC=local"
       
       # Mot de passe temporaire complexe
       $TempPassword = ConvertTo-SecureString "Welcome2024!Change" -AsPlainText -Force
       
       try {
           New-ADUser -Name "$FirstName $LastName" `
                      -GivenName $FirstName `
                      -Surname $LastName `
                      -SamAccountName $SamAccountName `
                      -UserPrincipalName $UPN `
                      -DisplayName $DisplayName `
                      -EmailAddress $Email `
                      -Department $Department `
                      -Office $Location `
                      -Path $OU `
                      -AccountPassword $TempPassword `
                      -Enabled $true `
                      -ChangePasswordAtLogon $true `
                      -Description "Créé le $(Get-Date -Format 'dd/MM/yyyy')"
           
           Write-Host "✓ Utilisateur $SamAccountName créé avec succès" -ForegroundColor Green
           Write-Host "  Email: $Email" -ForegroundColor Cyan
           Write-Host "  Mot de passe temporaire à communiquer de manière sécurisée" -ForegroundColor Yellow
       }
       catch {
           Write-Host "✗ Erreur: $_" -ForegroundColor Red
       }
   }
   
   # Utilisation
   New-StandardUser -FirstName "Sophie" -LastName "Bernard" -Department "IT" -Location "Paris"
   ```

4. **Audit et monitoring réguliers**
   ```powershell
   # Script d'audit mensuel
   $ReportPath = "C:\Reports\AD_Audit_$(Get-Date -Format 'yyyyMMdd').html"
   
   # Comptes jamais connectés
   $NeverLoggedIn = Get-ADUser -Filter {LastLogonDate -notlike "*" -and Enabled -eq $true} |
       Select-Object Name, SamAccountName, Created
   
   # Comptes inactifs > 90 jours
   $InactiveUsers = Get-ADUser -Filter * -Properties LastLogonDate |
       Where-Object {$_.LastLogonDate -lt (Get-Date).AddDays(-90) -and $_.Enabled -eq $true} |
       Select-Object Name, SamAccountName, LastLogonDate
   
   # Comptes avec mot de passe qui n'expire jamais
   $NoExpiry = Get-ADUser -Filter {PasswordNeverExpires -eq $true -and Enabled -eq $true} |
       Where-Object {$_.SamAccountName -notlike "svc_*"} |
       Select-Object Name, SamAccountName
   
   # Génération du rapport HTML
   $HTML = @"
   <html>
   <head>
       <title>Rapport d'audit Active Directory</title>
       <style>
           body { font-family: Arial, sans-serif; }
           table { border-collapse: collapse; width: 100%; margin: 20px 0; }
           th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
           th { background-color: #4CAF50; color: white; }
           .warning { background-color: #fff3cd; }
       </style>
   </head>
   <body>
       <h1>Rapport d'audit AD - $(Get-Date -Format 'dd/MM/yyyy')</h1>
       
       <h2>Comptes jamais connectés ($($NeverLoggedIn.Count))</h2>
       $($NeverLoggedIn | ConvertTo-Html -Fragment)
       
       <h2>Comptes inactifs > 90 jours ($($InactiveUsers.Count))</h2>
       $($InactiveUsers | ConvertTo-Html -Fragment)
       
       <h2>Comptes sans expiration de mot de passe ($($NoExpiry.Count))</h2>
       $($NoExpiry | ConvertTo-Html -Fragment)
   </body>
   </html>
"@
   
   $HTML | Out-File $ReportPath
   Write-Host "✓ Rapport généré : $ReportPath" -ForegroundColor Green
   ```

5. **Sécurisation des comptes sensibles**
   ```powershell
   # Configuration d'un compte administrateur sécurisé
   $AdminAccount = "admin_jdupont"
   
   Set-ADUser -Identity $AdminAccount `
              -PasswordNeverExpires $false `
              -CannotChangePassword $false `
              -SmartcardLogonRequired $true `
              -AccountExpirationDate (Get-Date).AddMonths(6)
   
   # Ajouter à un groupe protégé
   Add-ADGroupMember -Identity "Protected Users" -Members $AdminAccount
   
   # Configurer les heures de connexion restrictives
   # (uniquement pendant les heures de bureau)
   ```

6. **Documentation systématique**
   ```powershell
   # Template de description standardisé
   $Description = @"
   Créé: $(Get-Date -Format 'dd/MM/yyyy')
   Rôle: Développeur Full Stack
   Manager: Pierre Martin
   Projet: Refonte application interne
   Contact: +33 6 XX XX XX XX
"@
   
   Set-ADUser -Identity "jdupont" -Description $Description
   ```

7. **Gestion des départs**
   ```powershell
   # Processus complet de désactivation
   function Disable-DepartingUser {
       param(
           [Parameter(Mandatory=$true)]
           [string]$Username,
           
           [string]$Reason = "Départ entreprise"
       )
       
       $User = Get-ADUser -Identity $Username -Properties MemberOf, Manager
       
       # 1. Désactiver le compte
       Disable-ADAccount -Identity $Username
       
       # 2. Révoquer les sessions actives (nécessite des droits appropriés)
       # Invoke-Command -ComputerName DC01 -ScriptBlock { quser /server:. | Select-String $Using:Username }
       
       # 3. Retirer des groupes (sauf Domain Users)
       $User.MemberOf | ForEach-Object {
           if ($_ -notlike "*Domain Users*") {
               Remove-ADGroupMember -Identity $_ -Members $Username -Confirm:$false
           }
       }
       
       # 4. Mettre à jour la description
       $NewDescription = "Désactivé le $(Get-Date -Format 'dd/MM/yyyy') - $Reason"
       Set-ADUser -Identity $Username -Description $NewDescription
       
       # 5. Déplacer vers OU appropriée
       $DisabledOU = "OU=DisabledAccounts,DC=domaine,DC=local"
       Get-ADUser -Identity $Username | Move-ADObject -TargetPath $DisabledOU
       
       # 6. Log de l'action
       $LogEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Username désactivé - $Reason"
       Add-Content -Path "C:\Logs\UserDepartures.log" -Value $LogEntry
       
       Write-Host "✓ Utilisateur $Username désactivé et déplacé" -ForegroundColor Green
       Write-Host "  Groupes retirés: $($User.MemberOf.Count - 1)" -ForegroundColor Cyan
   }
   
   # Utilisation
   Disable-DepartingUser -Username "jdupont" -Reason "Démission"
   ```

8. **Standardisation des attributs**
   ```powershell
   # Vérifier et corriger les attributs manquants
   $Users = Get-ADUser -Filter * -Properties EmailAddress, Department, Title
   
   foreach ($User in $Users) {
       $Updated = $false
       
       # Email manquant
       if ([string]::IsNullOrEmpty($User.EmailAddress)) {
           $Email = "$($User.SamAccountName)@domaine.local"
           Set-ADUser -Identity $User.SamAccountName -EmailAddress $Email
           Write-Host "Email ajouté pour $($User.SamAccountName)" -ForegroundColor Yellow
           $Updated = $true
       }
       
       # Département manquant
       if ([string]::IsNullOrEmpty($User.Department)) {
           Write-Host "⚠ Département manquant pour $($User.SamAccountName)" -ForegroundColor Red
       }
   }
   ```

> [!tip] Checklist de création d'utilisateur
> - [ ] Vérifier que l'identifiant est unique
> - [ ] Utiliser la bonne OU selon l'organisation
> - [ ] Remplir tous les attributs standards (email, département, titre)
> - [ ] Générer un mot de passe complexe temporaire
> - [ ] Forcer le changement à la première connexion
> - [ ] Documenter dans le champ Description
> - [ ] Ajouter aux groupes appropriés (voir partie sur les groupes)
> - [ ] Tester la connexion
> - [ ] Communiquer les identifiants de manière sécurisée

---

## 📊 Scripts utiles et cas d'usage avancés

### Recherche et filtrage avancés

```powershell
# Utilisateurs d'un département spécifique
Get-ADUser -Filter {Department -eq "IT"} -Properties Department, Title |
    Select-Object Name, SamAccountName, Department, Title

# Utilisateurs créés dans les 7 derniers jours
$LastWeek = (Get-Date).AddDays(-7)
Get-ADUser -Filter {Created -gt $LastWeek} -Properties Created |
    Select-Object Name, SamAccountName, Created |
    Sort-Object Created -Descending

# Utilisateurs avec email d'un domaine spécifique
Get-ADUser -Filter {EmailAddress -like "*@externe.com"} -Properties EmailAddress |
    Select-Object Name, SamAccountName, EmailAddress

# Comptes activés mais jamais utilisés
Get-ADUser -Filter {Enabled -eq $true} -Properties LastLogonDate |
    Where-Object {$_.LastLogonDate -eq $null -or $_.LastLogonDate -eq ""} |
    Select-Object Name, SamAccountName, Created, LastLogonDate

# Recherche par multiple critères
Get-ADUser -Filter {
    (Department -eq "IT") -and 
    (Enabled -eq $true) -and 
    (Title -like "*Manager*")
} -Properties Department, Title |
    Select-Object Name, Department, Title
```

### Modifications en masse

```powershell
# Modifier le département pour plusieurs utilisateurs
$Users = "jdupont","mmartin","pdurand"
foreach ($User in $Users) {
    Set-ADUser -Identity $User -Department "IT" -Title "Développeur"
    Write-Host "✓ $User mis à jour" -ForegroundColor Green
}

# Ajouter un préfixe de téléphone pour un site
Get-ADUser -Filter {Office -eq "Paris"} -Properties OfficePhone |
    Where-Object {$_.OfficePhone -and $_.OfficePhone -notlike "+33*"} |
    ForEach-Object {
        $NewPhone = "+33 1 " + $_.OfficePhone
        Set-ADUser -Identity $_.SamAccountName -OfficePhone $NewPhone
    }

# Mettre à jour la société pour tous les utilisateurs
Get-ADUser -Filter * | Set-ADUser -Company "MonEntreprise SAS"

# Standardiser les DisplayName
Get-ADUser -Filter * -Properties DisplayName |
    ForEach-Object {
        $StandardName = "$($_.Surname) $($_.GivenName)".ToUpper()
        if ($_.DisplayName -ne $StandardName) {
            Set-ADUser -Identity $_.SamAccountName -DisplayName $StandardName
            Write-Host "DisplayName standardisé: $StandardName" -ForegroundColor Cyan
        }
    }
```

### Export et reporting

```powershell
# Export complet des utilisateurs
Get-ADUser -Filter * -Properties * |
    Select-Object Name, SamAccountName, EmailAddress, Department, Title, 
                  Enabled, Created, LastLogonDate, PasswordLastSet |
    Export-Csv -Path "C:\Export\AllUsers.csv" -NoTypeInformation -Encoding UTF8

# Export des comptes désactivés
Get-ADUser -Filter {Enabled -eq $false} -Properties LastLogonDate, Description |
    Select-Object Name, SamAccountName, LastLogonDate, Description |
    Export-Csv -Path "C:\Export\DisabledUsers.csv" -NoTypeInformation

# Statistiques par département
Get-ADUser -Filter * -Properties Department |
    Group-Object Department |
    Select-Object Name, Count |
    Sort-Object Count -Descending |
    Format-Table -AutoSize

# Rapport d'expiration des mots de passe
$Policy = Get-ADDefaultDomainPasswordPolicy
$Users = Get-ADUser -Filter {Enabled -eq $true -and PasswordNeverExpires -eq $false} `
                    -Properties PasswordLastSet

$Report = foreach ($User in $Users) {
    $ExpirationDate = $User.PasswordLastSet.AddDays($Policy.MaxPasswordAge.Days)
    $DaysRemaining = ($ExpirationDate - (Get-Date)).Days
    
    [PSCustomObject]@{
        Nom = $User.Name
        Identifiant = $User.SamAccountName
        DerniereModification = $User.PasswordLastSet
        Expiration = $ExpirationDate
        JoursRestants = $DaysRemaining
    }
}

$Report | Where-Object {$_.JoursRestants -lt 14} |
    Sort-Object JoursRestants |
    Export-Csv -Path "C:\Export\PasswordExpirations.csv" -NoTypeInformation
```

### Comparaison avant/après

```powershell
# Sauvegarder l'état actuel
$BeforeSnapshot = Get-ADUser -Filter * -Properties * |
    Select-Object Name, SamAccountName, EmailAddress, Department, Enabled

# ... effectuer des modifications ...

# Comparer avec l'état précédent
$AfterSnapshot = Get-ADUser -Filter * -Properties * |
    Select-Object Name, SamAccountName, EmailAddress, Department, Enabled

Compare-Object -ReferenceObject $BeforeSnapshot -DifferenceObject $AfterSnapshot -Property SamAccountName |
    Select-Object SamAccountName, @{N='Changement';E={$_.SideIndicator}}
```

---

## 🔍 Dépannage et résolution de problèmes

### Problèmes de connexion

```powershell
# Vérifier l'état complet d'un compte
$User = Get-ADUser -Identity "jdupont" -Properties *

# Points de vérification
Write-Host "=== Diagnostic du compte $($User.SamAccountName) ===" -ForegroundColor Cyan
Write-Host "Activé: $($User.Enabled)" -ForegroundColor $(if($User.Enabled){"Green"}else{"Red"})
Write-Host "Verrouillé: $($User.LockedOut)" -ForegroundColor $(if($User.LockedOut){"Red"}else{"Green"})
Write-Host "Mot de passe expiré: $($User.PasswordExpired)" -ForegroundColor $(if($User.PasswordExpired){"Red"}else{"Green"})
Write-Host "Compte expiré: $(if($User.AccountExpirationDate){if($User.AccountExpirationDate -lt (Get-Date)){'Oui'}else{'Non'}}else{'Non'})"
Write-Host "Dernière connexion: $($User.LastLogonDate)"
Write-Host "Dernier échec: $($User.LastBadPasswordAttempt)"

# Vérifier les restrictions de connexion
if ($User.LogonWorkstations) {
    Write-Host "Restriction de postes: $($User.LogonWorkstations)" -ForegroundColor Yellow
}
```

### Erreurs courantes et solutions

> [!example] Erreur : "The specified account does not exist"
> **Cause** : L'identifiant est incorrect ou l'objet n'existe pas
> 
> **Solution** :
> ```powershell
> # Rechercher l'utilisateur
> Get-ADUser -Filter {Name -like "*dupont*"}
> 
> # Ou par email
> Get-ADUser -Filter {EmailAddress -eq "jean.dupont@domaine.local"} -Properties EmailAddress
> ```

> [!example] Erreur : "The password does not meet the password policy requirements"
> **Cause** : Le mot de passe ne respecte pas la politique
> 
> **Solution** :
> ```powershell
> # Vérifier la politique
> Get-ADDefaultDomainPasswordPolicy
> 
> # Ou la politique fine-grained
> Get-ADUserResultantPasswordPolicy -Identity "jdupont"
> 
> # Utiliser un mot de passe conforme
> $Password = ConvertTo-SecureString "P@ssw0rd_C0mplex3!2024" -AsPlainText -Force
> ```

> [!example] Erreur : "Access is denied"
> **Cause** : Droits insuffisants
> 
> **Solution** :
> ```powershell
> # Vérifier vos droits actuels
> whoami /groups
> 
> # Demander les droits appropriés ou utiliser un compte avec permissions
> # Nécessite généralement : Account Operators, Domain Admins, ou délégation spécifique
> ```

### Nettoyage et maintenance

```powershell
# Supprimer les comptes test/temporaires anciens
$TestAccounts = Get-ADUser -Filter {SamAccountName -like "test*"} -Properties Created |
    Where-Object {$_.Created -lt (Get-Date).AddMonths(-6)}

foreach ($Account in $TestAccounts) {
    Write-Host "Suppression de $($Account.SamAccountName)" -ForegroundColor Yellow
    Remove-ADUser -Identity $Account.SamAccountName -Confirm:$true
}

# Nettoyer les attributs obsolètes
Get-ADUser -Filter * -Properties Info |
    Where-Object {$_.Info -like "*Temporaire*"} |
    ForEach-Object {
        Set-ADUser -Identity $_.SamAccountName -Clear Info
        Write-Host "Attribut Info nettoyé pour $($_.SamAccountName)" -ForegroundColor Green
    }
```

---

## 🎓 Résumé des commandes essentielles

| Action | Commande PowerShell |
|--------|---------------------|
| **Créer un utilisateur** | `New-ADUser -Name "Jean Dupont" -SamAccountName "jdupont" ...` |
| **Modifier un utilisateur** | `Set-ADUser -Identity "jdupont" -Department "IT"` |
| **Désactiver un compte** | `Disable-ADAccount -Identity "jdupont"` |
| **Activer un compte** | `Enable-ADAccount -Identity "jdupont"` |
| **Réinitialiser le mot de passe** | `Set-ADAccountPassword -Identity "jdupont" -Reset -NewPassword $pwd` |
| **Débloquer un compte** | `Unlock-ADAccount -Identity "jdupont"` |
| **Supprimer un utilisateur** | `Remove-ADUser -Identity "jdupont"` |
| **Rechercher des utilisateurs** | `Get-ADUser -Filter {Department -eq "IT"}` |
| **Voir les propriétés** | `Get-ADUser -Identity "jdupont" -Properties *` |
| **Déplacer un utilisateur** | `Move-ADObject -Identity "CN=Jean Dupont,..." -TargetPath "OU=..."` |

---

## 💡 Points clés à retenir

> [!info] Synthèse
> - Les **comptes utilisateurs** sont la base de l'authentification AD
> - Privilégiez **PowerShell** pour l'automatisation et la gestion en masse
> - Les **comptes de service** nécessitent une gestion spécifique (préférez les gMSA)
> - Toujours **documenter** les comptes (Description, attributs personnalisés)
> - **Désactivez** plutôt que supprimer immédiatement
> - Implémentez un **processus standardisé** pour la création/suppression
> - **Auditez régulièrement** les comptes inactifs et les politiques de mots de passe
> - La **sécurité** passe par des mots de passe forts et des révisions périodiques

---

*Cours créé pour Obsidian - Active Directory DS - Gestion des utilisateurs*