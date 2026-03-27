

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

## 🔍 Get-LocalUser - Consultation des utilisateurs

### 📖 Concept et utilité

`Get-LocalUser` permet d'interroger et d'analyser les comptes utilisateurs locaux d'un système Windows. Cette cmdlet est essentielle pour l'audit de sécurité, la maintenance système et la vérification des comptes.

> [!info] Pourquoi utiliser Get-LocalUser ?
> 
> - **Audit de sécurité** : Identifier les comptes inactifs ou suspects
> - **Documentation** : Générer un inventaire des utilisateurs
> - **Dépannage** : Vérifier l'état et les propriétés des comptes
> - **Conformité** : Contrôler les politiques de mots de passe

### 🎯 Syntaxe de base

```powershell
# Lister tous les utilisateurs locaux
Get-LocalUser

# Filtrer par nom exact
Get-LocalUser -Name "JohnDoe"

# Filtrer par SID (Security Identifier)
Get-LocalUser -SID "S-1-5-21-xxxxx"
```

### 🔑 Propriétés des objets utilisateur

Chaque utilisateur retourné possède de nombreuses propriétés exploitables :

|Propriété|Description|Type|
|---|---|---|
|**Name**|Nom d'utilisateur|String|
|**Enabled**|Compte activé/désactivé|Boolean|
|**Description**|Description du compte|String|
|**PasswordRequired**|Mot de passe obligatoire|Boolean|
|**PasswordExpires**|Le mot de passe expire|Boolean|
|**LastLogon**|Dernière connexion|DateTime|
|**AccountExpires**|Date d'expiration du compte|DateTime|
|**SID**|Identifiant de sécurité unique|String|
|**UserMayChangePassword**|L'utilisateur peut changer son mot de passe|Boolean|
|**PasswordChangeableDate**|Date à partir de laquelle le mot de passe peut être changé|DateTime|
|**PasswordLastSet**|Dernière modification du mot de passe|DateTime|

> [!example] Exemple d'utilisation des propriétés
> 
> ```powershell
> # Afficher toutes les propriétés d'un utilisateur
> Get-LocalUser -Name "JohnDoe" | Format-List *
> 
> # Sélectionner uniquement certaines propriétés
> Get-LocalUser | Select-Object Name, Enabled, LastLogon, PasswordExpires
> ```

### 🎭 Utilisation des wildcards

Les wildcards permettent de rechercher des utilisateurs par motifs :

```powershell
# Tous les utilisateurs dont le nom commence par "Admin"
Get-LocalUser -Name "Admin*"

# Tous les utilisateurs contenant "test"
Get-LocalUser -Name "*test*"

# Tous les utilisateurs se terminant par "svc"
Get-LocalUser -Name "*svc"
```

> [!tip] Astuce wildcards Les wildcards sont particulièrement utiles pour identifier des comptes suivant une nomenclature (ex: tous les comptes de service, tous les comptes temporaires).

### 🔒 Identification d'utilisateurs désactivés

```powershell
# Lister uniquement les comptes désactivés
Get-LocalUser | Where-Object {$_.Enabled -eq $false}

# Compter les comptes désactivés
(Get-LocalUser | Where-Object {$_.Enabled -eq $false}).Count

# Afficher les comptes désactivés avec leurs dernières connexions
Get-LocalUser | Where-Object {$_.Enabled -eq $false} | 
    Select-Object Name, LastLogon, Description
```

### 👤 Comptes intégrés (Built-in)

Windows crée automatiquement des comptes système essentiels :

> [!info] Comptes intégrés principaux
> 
> - **Administrator** : Compte administrateur principal (SID se termine par -500)
> - **Guest** : Compte invité (généralement désactivé, SID se termine par -501)
> - **DefaultAccount** : Compte système (Windows 10/11)
> - **WDAGUtilityAccount** : Compte Windows Defender Application Guard

```powershell
# Identifier le compte Administrator par son SID
Get-LocalUser | Where-Object {$_.SID -like "*-500"}

# Vérifier l'état du compte Guest
Get-LocalUser -Name "Guest" | Select-Object Name, Enabled

# Lister tous les comptes avec leur SID
Get-LocalUser | Select-Object Name, SID, Description
```

### 📊 Exemples pratiques avancés

```powershell
# Utilisateurs n'ayant jamais changé leur mot de passe
Get-LocalUser | Where-Object {$_.PasswordLastSet -eq $null}

# Utilisateurs dont le mot de passe n'expire jamais
Get-LocalUser | Where-Object {$_.PasswordExpires -eq $false}

# Utilisateurs non connectés depuis plus de 90 jours
Get-LocalUser | Where-Object {
    $_.LastLogon -lt (Get-Date).AddDays(-90) -and $_.LastLogon -ne $null
}

# Comptes qui expirent dans les 30 prochains jours
Get-LocalUser | Where-Object {
    $_.AccountExpires -ne $null -and 
    $_.AccountExpires -lt (Get-Date).AddDays(30) -and
    $_.AccountExpires -gt (Get-Date)
}

# Exporter la liste complète en CSV
Get-LocalUser | 
    Select-Object Name, Enabled, Description, LastLogon, PasswordLastSet | 
    Export-Csv -Path "C:\Users_Audit.csv" -NoTypeInformation
```

> [!warning] Attention aux propriétés null Certaines propriétés peuvent être `$null` (LastLogon pour un compte jamais utilisé, AccountExpires pour un compte permanent). Toujours tester la valeur null dans vos filtres.

### 🛡️ Pièges courants

1. **LastLogon peut être null** : Un compte jamais utilisé n'aura pas de LastLogon
2. **SID vs Name** : Privilégier le SID pour identifier de manière unique un compte (le nom peut être changé)
3. **Comptes système** : Certains comptes intégrés ne doivent jamais être supprimés
4. **Permissions** : Certaines propriétés peuvent nécessiter des droits administrateur

---

## ➕ New-LocalUser - Création d'utilisateurs

### 📖 Concept et utilité

`New-LocalUser` permet de créer programmatiquement de nouveaux comptes utilisateurs locaux. Cette cmdlet est indispensable pour l'automatisation du provisioning et le déploiement standardisé.

> [!info] Pourquoi utiliser New-LocalUser ?
> 
> - **Automatisation** : Créer des comptes en masse via scripts
> - **Standardisation** : Appliquer des configurations uniformes
> - **Provisioning** : Intégrer dans des workflows d'onboarding
> - **Reproductibilité** : Déploiements identiques sur plusieurs machines

### 🎯 Paramètres obligatoires

```powershell
# Syntaxe minimale (deux paramètres obligatoires)
New-LocalUser -Name "NomUtilisateur" -Password $SecurePassword
```

|Paramètre|Description|Type|
|---|---|---|
|**-Name**|Nom du compte utilisateur|String|
|**-Password**|Mot de passe du compte|SecureString|

> [!warning] Droits administrateur requis La création d'utilisateurs locaux nécessite **impérativement** des privilèges d'administrateur. Sans cela, vous obtiendrez une erreur d'accès refusé.

### 🔐 Création de SecureString pour mot de passe

PowerShell utilise le type `SecureString` pour protéger les mots de passe en mémoire :

#### Méthode 1 : Read-Host (interactive)

```powershell
# Demander le mot de passe de manière sécurisée (masqué à l'écran)
$Password = Read-Host -Prompt "Entrez le mot de passe" -AsSecureString

# Créer l'utilisateur
New-LocalUser -Name "JohnDoe" -Password $Password
```

> [!tip] Utilisation interactive `Read-Host -AsSecureString` est parfait pour les scripts interactifs. Le mot de passe sera masqué pendant la saisie (affichage d'astérisques).

#### Méthode 2 : ConvertTo-SecureString (automatisation)

```powershell
# Convertir une chaîne en SecureString (pour scripts automatisés)
$Password = ConvertTo-SecureString "MotD3P@sse!" -AsPlainText -Force

# Créer l'utilisateur
New-LocalUser -Name "JaneDoe" -Password $Password
```

> [!warning] Sécurité des mots de passe en clair Évitez de stocker des mots de passe en clair dans vos scripts. Cette méthode est acceptable pour le développement/test, mais en production, privilégiez :
> 
> - Les variables d'environnement chiffrées
> - Azure Key Vault ou des gestionnaires de secrets
> - La génération aléatoire de mots de passe

### 📝 Paramètres optionnels

```powershell
# Création complète avec tous les paramètres optionnels
$Password = ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force

New-LocalUser -Name "ServiceAccount" `
    -Password $Password `
    -Description "Compte de service pour l'application XYZ" `
    -FullName "Service Account XYZ" `
    -AccountExpires (Get-Date).AddMonths(6) `
    -PasswordNeverExpires $false `
    -UserMayNotChangePassword $false
```

|Paramètre|Description|Valeur par défaut|
|---|---|---|
|**-Description**|Description du compte|Vide|
|**-FullName**|Nom complet de l'utilisateur|Vide|
|**-AccountExpires**|Date d'expiration du compte|Jamais (permanent)|
|**-AccountNeverExpires**|Le compte n'expire jamais|$true|
|**-PasswordNeverExpires**|Le mot de passe n'expire jamais|$false|
|**-UserMayNotChangePassword**|Empêche l'utilisateur de changer son mot de passe|$false|

### 🚫 Création sans mot de passe (-NoPassword)

```powershell
# Créer un compte sans mot de passe
New-LocalUser -Name "GuestUser" -NoPassword -Description "Compte invité temporaire"
```

> [!warning] Risque de sécurité majeur L'utilisation de `-NoPassword` est **fortement déconseillée** sauf dans des contextes très spécifiques :
> 
> - Environnements de test isolés
> - Comptes destinés à être configurés immédiatement après création
> - **JAMAIS en production** : cela représente une faille de sécurité critique

### 🛡️ Bonnes pratiques de sécurité

> [!tip] Recommandations de sécurité
> 
> 1. **Mots de passe forts** : Minimum 12 caractères avec majuscules, minuscules, chiffres et symboles
> 2. **Expiration** : Définir `PasswordNeverExpires $false` pour forcer les changements réguliers
> 3. **Principe du moindre privilège** : Ne créez que des comptes utilisateurs standards (pas d'admin par défaut)
> 4. **Documentation** : Utiliser `-Description` pour tracer la raison d'être du compte
> 5. **Expiration des comptes** : Pour les comptes temporaires, toujours définir `-AccountExpires`

### 📊 Exemples pratiques

```powershell
# Compte utilisateur standard avec expiration
$Password = Read-Host -AsSecureString -Prompt "Mot de passe pour le stagiaire"
New-LocalUser -Name "Stagiaire2024" `
    -Password $Password `
    -FullName "Stagiaire Été 2024" `
    -Description "Compte temporaire - Stage été 2024" `
    -AccountExpires (Get-Date).AddMonths(3)

# Compte de service avec mot de passe permanent
$Password = ConvertTo-SecureString "C0mpl3x!S3rv1c3P@ss" -AsPlainText -Force
New-LocalUser -Name "svc_backup" `
    -Password $Password `
    -Description "Compte de service pour tâches de sauvegarde" `
    -PasswordNeverExpires $true `
    -UserMayNotChangePassword $true

# Création en masse depuis un CSV
$Users = Import-Csv "C:\NewUsers.csv"
foreach ($User in $Users) {
    $Password = ConvertTo-SecureString $User.Password -AsPlainText -Force
    New-LocalUser -Name $User.Name `
        -Password $Password `
        -FullName $User.FullName `
        -Description $User.Description
}

# Génération de mot de passe aléatoire sécurisé
Add-Type -AssemblyName System.Web
$RandomPassword = [System.Web.Security.Membership]::GeneratePassword(16, 4)
$SecurePassword = ConvertTo-SecureString $RandomPassword -AsPlainText -Force
New-LocalUser -Name "TempUser" -Password $SecurePassword
Write-Host "Mot de passe généré : $RandomPassword" -ForegroundColor Green
```

> [!example] Structure CSV pour création en masse
> 
> ```csv
> Name,Password,FullName,Description
> user01,P@ss123!,John Doe,Utilisateur département IT
> user02,P@ss456!,Jane Smith,Utilisateur département RH
> ```

### 🔍 Vérification post-création

```powershell
# Vérifier que l'utilisateur a bien été créé
Get-LocalUser -Name "NouvelUtilisateur"

# Vérifier toutes les propriétés
Get-LocalUser -Name "NouvelUtilisateur" | Format-List *

# Test conditionnel
if (Get-LocalUser -Name "TestUser" -ErrorAction SilentlyContinue) {
    Write-Host "✓ Utilisateur créé avec succès" -ForegroundColor Green
} else {
    Write-Host "✗ Échec de la création" -ForegroundColor Red
}
```

### 🛠️ Pièges courants

1. **Nom déjà existant** : La cmdlet échouera si le nom est déjà utilisé (vérifier d'abord avec `Get-LocalUser`)
2. **Caractères interdits** : Certains caractères sont interdits dans les noms (`" / \ [ ] : ; | = , + * ? < >`)
3. **Longueur maximale** : Le nom d'utilisateur est limité à 20 caractères
4. **Cas sensible** : Windows traite "User" et "user" comme identiques (conflit possible)
5. **SecureString obligatoire** : Même pour des tests, le format SecureString est requis

---

## ✏️ Set-LocalUser - Modification d'utilisateurs

### 📖 Concept et utilité

`Set-LocalUser` permet de modifier les propriétés d'utilisateurs locaux existants. Cette cmdlet est essentielle pour la maintenance continue, l'application de politiques de sécurité et l'adaptation aux besoins changeants.

> [!info] Pourquoi utiliser Set-LocalUser ?
> 
> - **Maintenance** : Mettre à jour les comptes régulièrement
> - **Sécurité** : Réinitialiser mots de passe, forcer expirations
> - **Gestion du cycle de vie** : Prolonger ou réduire la durée des comptes
> - **Conformité** : Appliquer des politiques de sécurité évolutives

### 🎯 Identification de l'utilisateur

```powershell
# Identifier l'utilisateur par son nom
Set-LocalUser -Name "JohnDoe" [paramètres]

# Identifier par l'objet utilisateur
$User = Get-LocalUser -Name "JohnDoe"
Set-LocalUser -InputObject $User [paramètres]

# Identifier par SID (plus robuste)
Set-LocalUser -SID "S-1-5-21-xxxxx" [paramètres]
```

> [!tip] Préférer le SID pour les scripts Le SID est immuable tandis que le nom peut changer. Pour des scripts robustes, stockez et utilisez le SID.

### 🔐 Modification du mot de passe

```powershell
# Méthode interactive (sécurisée)
$NewPassword = Read-Host -AsSecureString -Prompt "Nouveau mot de passe"
Set-LocalUser -Name "JohnDoe" -Password $NewPassword

# Méthode automatisée
$NewPassword = ConvertTo-SecureString "N0uv34uP@ss!" -AsPlainText -Force
Set-LocalUser -Name "JohnDoe" -Password $NewPassword

# Réinitialisation de mot de passe pour tous les comptes temporaires
Get-LocalUser -Name "*temp*" | ForEach-Object {
    $RandomPwd = [System.Web.Security.Membership]::GeneratePassword(16, 4)
    $SecurePwd = ConvertTo-SecureString $RandomPwd -AsPlainText -Force
    Set-LocalUser -Name $_.Name -Password $SecurePwd
    Write-Host "Mot de passe réinitialisé pour : $($_.Name)"
}
```

### 📝 Modification des propriétés descriptives

```powershell
# Mettre à jour la description
Set-LocalUser -Name "JohnDoe" -Description "Administrateur système - Bâtiment A"

# Mettre à jour le nom complet
Set-LocalUser -Name "JohnDoe" -FullName "John Doe - IT Manager"

# Modification multiple
Set-LocalUser -Name "ServiceAccount" `
    -Description "Compte de service mis à jour - Version 2.0" `
    -FullName "Service Account Application XYZ v2"
```

### ⏰ Gestion de l'expiration

```powershell
# Définir une date d'expiration
Set-LocalUser -Name "Stagiaire" -AccountExpires (Get-Date).AddMonths(3)

# Prolonger l'expiration de 30 jours
$User = Get-LocalUser -Name "Stagiaire"
$NewExpiry = $User.AccountExpires.AddDays(30)
Set-LocalUser -Name "Stagiaire" -AccountExpires $NewExpiry

# Rendre le compte permanent (ne jamais expirer)
Set-LocalUser -Name "Permanent" -AccountNeverExpires $true

# Supprimer l'expiration d'un compte existant
Set-LocalUser -Name "JohnDoe" -AccountExpires $null
```

### 🔒 Gestion des politiques de mot de passe

```powershell
# Forcer l'expiration du mot de passe (suivra la politique de domaine/locale)
Set-LocalUser -Name "JohnDoe" -PasswordNeverExpires $false

# Empêcher l'expiration du mot de passe
Set-LocalUser -Name "ServiceAccount" -PasswordNeverExpires $true

# Autoriser l'utilisateur à changer son mot de passe
Set-LocalUser -Name "JohnDoe" -UserMayChangePassword $true

# Empêcher l'utilisateur de changer son mot de passe
Set-LocalUser -Name "Kiosk" -UserMayChangePassword $false
```

> [!warning] Politique de mot de passe Même si `-PasswordNeverExpires $false`, le mot de passe n'expirera que si la politique de sécurité locale le définit. Vérifiez avec `net accounts` ou les stratégies de groupe.

### 📊 Gestion des comptes en masse

```powershell
# Forcer l'expiration de tous les mots de passe utilisateurs
Get-LocalUser | Where-Object {
    $_.Name -notlike "Admin*" -and $_.Enabled -eq $true
} | Set-LocalUser -PasswordNeverExpires $false

# Mettre à jour la description de tous les comptes de service
Get-LocalUser -Name "svc_*" | Set-LocalUser -Description "Compte de service - Mis à jour $(Get-Date -Format 'yyyy-MM-dd')"

# Prolonger l'expiration de tous les comptes temporaires de 30 jours
Get-LocalUser | Where-Object {
    $_.AccountExpires -ne $null -and $_.AccountExpires -lt (Get-Date).AddDays(30)
} | ForEach-Object {
    Set-LocalUser -Name $_.Name -AccountExpires ($_.AccountExpires.AddDays(30))
}

# Désactiver tous les comptes inactifs depuis 90 jours
Get-LocalUser | Where-Object {
    $_.LastLogon -ne $null -and 
    $_.LastLogon -lt (Get-Date).AddDays(-90) -and
    $_.Enabled -eq $true
} | Disable-LocalUser
```

> [!tip] Scripts de maintenance Créez des scripts planifiés pour appliquer automatiquement vos politiques de sécurité (expiration, réinitialisation, désactivation des comptes inactifs).

### 🔄 Scripts de mise à jour depuis CSV

```powershell
# Structure du CSV : Name,NewDescription,PasswordNeverExpires,AccountExpires
$Updates = Import-Csv "C:\UserUpdates.csv"

foreach ($Update in $Updates) {
    # Vérifier que l'utilisateur existe
    if (Get-LocalUser -Name $Update.Name -ErrorAction SilentlyContinue) {
        
        # Construire les paramètres dynamiquement
        $Params = @{
            Name = $Update.Name
        }
        
        if ($Update.NewDescription) {
            $Params.Add('Description', $Update.NewDescription)
        }
        
        if ($Update.PasswordNeverExpires) {
            $Params.Add('PasswordNeverExpires', [bool]$Update.PasswordNeverExpires)
        }
        
        if ($Update.AccountExpires) {
            $Params.Add('AccountExpires', [DateTime]$Update.AccountExpires)
        }
        
        # Appliquer les modifications
        Set-LocalUser @Params
        Write-Host "✓ Utilisateur $($Update.Name) mis à jour" -ForegroundColor Green
        
    } else {
        Write-Host "✗ Utilisateur $($Update.Name) introuvable" -ForegroundColor Red
    }
}
```

> [!example] Exemple de CSV pour mises à jour
> 
> ```csv
> Name,NewDescription,PasswordNeverExpires,AccountExpires
> user01,Utilisateur IT - Mis à jour,False,2024-12-31
> svc_backup,Service de sauvegarde v2,True,
> tempuser,Compte temporaire prolongé,False,2024-06-30
> ```

### 🔍 Vérification des modifications

```powershell
# Vérifier une modification spécifique
$User = Get-LocalUser -Name "JohnDoe"
Write-Host "Description : $($User.Description)"
Write-Host "Password Never Expires : $($User.PasswordNeverExpires)"
Write-Host "Account Expires : $($User.AccountExpires)"

# Comparer avant/après modification
$UserBefore = Get-LocalUser -Name "JohnDoe" | Select-Object Name, Description, PasswordNeverExpires
Set-LocalUser -Name "JohnDoe" -Description "Nouvelle description" -PasswordNeverExpires $true
$UserAfter = Get-LocalUser -Name "JohnDoe" | Select-Object Name, Description, PasswordNeverExpires

Compare-Object $UserBefore $UserAfter -Property Description, PasswordNeverExpires
```

### 📋 Cas d'usage pratiques

```powershell
# Scénario 1 : Onboarding - Configurer un nouveau compte après création
New-LocalUser -Name "NewEmployee" -Password $Password -NoPassword
Set-LocalUser -Name "NewEmployee" `
    -Description "Employé département Marketing" `
    -FullName "Nouvel Employé" `
    -AccountExpires (Get-Date).AddYears(1) `
    -UserMayChangePassword $true

# Scénario 2 : Offboarding - Préparer un compte pour désactivation
$User = Get-LocalUser -Name "LeavingEmployee"
Set-LocalUser -Name $User.Name `
    -Description "COMPTE DÉSACTIVÉ - Départ $(Get-Date -Format 'yyyy-MM-dd')" `
    -AccountExpires (Get-Date).AddDays(30)
Disable-LocalUser -Name $User.Name

# Scénario 3 : Audit de sécurité - Forcer changement de mot de passe
Get-LocalUser | Where-Object {
    $_.PasswordLastSet -lt (Get-Date).AddMonths(-6) -and
    $_.Enabled -eq $true
} | ForEach-Object {
    Set-LocalUser -Name $_.Name -PasswordNeverExpires $false
    Write-Host "⚠️ $($_.Name) devra changer son mot de passe" -ForegroundColor Yellow
}

# Scénario 4 : Renouvellement de comptes temporaires
Get-LocalUser -Name "*temp*" | Where-Object {
    $_.AccountExpires -ne $null -and
    $_.AccountExpires -lt (Get-Date).AddDays(7)
} | ForEach-Object {
    Set-LocalUser -Name $_.Name -AccountExpires ($_.AccountExpires.AddMonths(1))
    Write-Host "✓ Compte $($_.Name) prolongé d'un mois" -ForegroundColor Green
}
```

### 🛠️ Pièges courants

1. **Propriétés non modifiables** : Certaines propriétés comme `Name` et `SID` ne peuvent pas être changées avec Set-LocalUser
2. **Valeurs $null** : Utiliser `$null` pour "supprimer" une valeur (ex: AccountExpires)
3. **Types de données** : Respecter les types (DateTime pour dates, Boolean pour vrais/faux)
4. **Utilisateurs système** : Éviter de modifier les comptes intégrés (Administrator, Guest)
5. **Modification sans vérification** : Toujours vérifier qu'un utilisateur existe avant modification

### 🎯 Bonnes pratiques

> [!tip] Recommandations
> 
> 1. **Logs et traçabilité** : Enregistrer toutes les modifications dans un fichier journal
> 2. **Sauvegarde avant modification** : Exporter l'état avant modifications massives
> 3. **Tests sur compte de test** : Valider vos commandes sur un compte non critique
> 4. **Documentation** : Utiliser `-Description` pour tracer l'historique des modifications
> 5. **Automatisation progressive** : Commencer par des modifications simples avant de scripter en masse

```powershell
# Exemple de logging des modifications
$LogFile = "C:\Logs\UserModifications_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$User = Get-LocalUser -Name "JohnDoe"

# Sauvegarder l'état avant
$Before = $User | Select-Object * | ConvertTo-Json

# Modifier
Set-LocalUser -Name "JohnDoe" -Description "Nouvelle description"

# Sauvegarder l'état après
$After = Get-LocalUser -Name "JohnDoe" | Select-Object * | ConvertTo-Json

# Logger
"=== Modification de $($User.Name) ===" | Out-File $LogFile -Append
"Date : $(Get-Date)" | Out-File $LogFile -Append
"Avant :`n$Before" | Out-File $LogFile -Append
"Après :`n$After" | Out-File $LogFile -Append
"`n" | Out-File $LogFile -Append
```

---