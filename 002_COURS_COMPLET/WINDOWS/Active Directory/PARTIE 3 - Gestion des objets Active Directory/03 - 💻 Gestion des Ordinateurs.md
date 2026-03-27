

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

## 🖥️ Comptes ordinateurs dans AD

### Qu'est-ce qu'un compte ordinateur ?

Un **compte ordinateur** (Computer Account) est un objet Active Directory qui représente une machine physique ou virtuelle membre du domaine. Il fonctionne de manière similaire à un compte utilisateur, mais pour les machines.

> [!info] Pourquoi c'est important
> 
> - Authentifie la machine auprès du domaine (pas seulement l'utilisateur)
> - Permet l'application des stratégies de groupe (GPO) à la machine
> - Sécurise les communications entre la machine et le contrôleur de domaine
> - Permet la gestion centralisée du parc informatique

### Caractéristiques techniques d'un compte ordinateur

|Caractéristique|Description|
|---|---|
|**Nom**|Nom NetBIOS de la machine (max 15 caractères) + "$" à la fin|
|**DN**|Distinguished Name complet dans l'AD|
|**Mot de passe**|Changé automatiquement tous les 30 jours par défaut|
|**SID**|Security Identifier unique|
|**Emplacement par défaut**|Container `CN=Computers`|

> [!example] Exemple de nom de compte Pour un ordinateur nommé `PC-COMPTA-01`, le compte dans AD sera :
> 
> - Nom d'affichage : `PC-COMPTA-01`
> - Nom de compte SAM : `PC-COMPTA-01$`
> - DN : `CN=PC-COMPTA-01,CN=Computers,DC=entreprise,DC=local`

### Attributs importants d'un compte ordinateur

```powershell
# Visualiser les attributs principaux d'un compte ordinateur
Get-ADComputer -Identity "PC-COMPTA-01" -Properties *

# Attributs clés à connaître :
# - Name : Nom de l'ordinateur
# - DNSHostName : Nom DNS complet (FQDN)
# - OperatingSystem : Système d'exploitation
# - OperatingSystemVersion : Version de l'OS
# - IPv4Address : Adresse IP
# - LastLogonDate : Dernière connexion au domaine
# - PasswordLastSet : Dernier changement de mot de passe machine
# - Enabled : Compte activé ou désactivé
```

> [!tip] Astuce professionnelle L'attribut `LastLogonDate` est très utile pour identifier les ordinateurs inactifs et faire du nettoyage dans l'AD.

### Sécurité du compte ordinateur

Le compte ordinateur possède un **mot de passe complexe** généré automatiquement qui :

- Fait 120 caractères de long
- Est changé automatiquement tous les 30 jours
- Est géré par le service Netlogon
- Sert à établir un canal sécurisé avec le contrôleur de domaine

> [!warning] Attention aux réinitialisations Si le mot de passe de la machine n'est plus synchronisé avec l'AD (après une restauration système par exemple), la machine ne pourra plus s'authentifier. Il faudra réinitialiser le compte ou rejoindre à nouveau le domaine.

---

## 🔗 Jonction d'un poste au domaine

### Prérequis techniques

Avant de joindre un poste au domaine, vérifier :

1. **Connectivité réseau** :
    
    - La machine peut joindre le contrôleur de domaine
    - Port 389 (LDAP) et 88 (Kerberos) ouverts
2. **Configuration DNS** :
    
    - Le serveur DNS configuré peut résoudre le domaine AD
    - Test : `nslookup domaine.local`
3. **Permissions** :
    
    - Compte avec droits de jonction au domaine
    - Par défaut, tout utilisateur peut joindre jusqu'à 10 machines

> [!info] Quota de jonction par défaut L'attribut `ms-DS-MachineAccountQuota` définit combien de machines un utilisateur standard peut joindre au domaine. La valeur par défaut est 10.

### Méthode 1 : Jonction via interface graphique (Windows)

**Étapes sur le poste client :**

1. Ouvrir les propriétés système :
    
    - `Windows + Pause` ou `Paramètres > Système > Informations système`
2. Cliquer sur **"Modifier les paramètres"** puis **"Modifier"**
    
3. Sélectionner **"Domaine"** et saisir le nom du domaine
    
4. Fournir les identifiants d'un compte autorisé
    
5. Redémarrer l'ordinateur
    

> [!example] Processus en arrière-plan Lors de la jonction, Windows :
> 
> 1. Contacte le contrôleur de domaine via DNS
> 2. Crée un compte ordinateur dans l'AD
> 3. Établit une relation de confiance Kerberos
> 4. Configure le canal sécurisé Netlogon
> 5. Place le compte dans le container `CN=Computers` par défaut

### Méthode 2 : Jonction via PowerShell (recommandé)

```powershell
# Jonction simple au domaine
Add-Computer -DomainName "entreprise.local" -Credential (Get-Credential) -Restart

# Jonction avec spécification de l'OU de destination
Add-Computer -DomainName "entreprise.local" `
             -OUPath "OU=Postes_Comptabilite,OU=Ordinateurs,DC=entreprise,DC=local" `
             -Credential (Get-Credential) `
             -Restart

# Jonction sans redémarrage immédiat
Add-Computer -DomainName "entreprise.local" `
             -Credential (Get-Credential) `
             -Force

# Jonction avec un nom différent dans AD
Add-Computer -DomainName "entreprise.local" `
             -NewName "PC-COMPTA-15" `
             -Credential (Get-Credential) `
             -Restart
```

> [!tip] Bonnes pratiques
> 
> - Toujours utiliser `-OUPath` pour placer directement l'ordinateur dans la bonne OU
> - Cela évite de devoir le déplacer manuellement après
> - Les GPO appliquées seront correctes dès la première connexion

### Méthode 3 : Création préalable du compte puis jonction offline

**Étape 1 : Pré-créer le compte ordinateur dans AD**

```powershell
# Sur le contrôleur de domaine ou un poste avec RSAT
New-ADComputer -Name "PC-COMPTA-20" `
               -Path "OU=Postes_Comptabilite,OU=Ordinateurs,DC=entreprise,DC=local" `
               -Enabled $true `
               -Description "Poste comptabilité - Bureau 204"
```

**Étape 2 : Joindre avec le compte pré-créé**

```powershell
# Sur le poste client
Add-Computer -DomainName "entreprise.local" `
             -Credential (Get-Credential) `
             -Options JoinWithNewName,AccountCreate `
             -Restart
```

> [!info] Avantage de la pré-création
> 
> - Contrôle total sur l'emplacement dans l'AD
> - Possibilité d'appliquer des paramètres avant la jonction
> - Utile pour les déploiements automatisés (MDT, SCCM)

### Méthode 4 : Jonction hors ligne (Offline Domain Join)

Utile pour les machines sans connectivité au domaine pendant l'installation.

**Étape 1 : Générer le fichier de provisioning**

```powershell
# Sur le contrôleur de domaine
djoin.exe /provision /domain entreprise.local `
          /machine PC-ATELIER-05 `
          /savefile C:\provisioning\PC-ATELIER-05.txt `
          /machineou "OU=Atelier,OU=Ordinateurs,DC=entreprise,DC=local"
```

**Étape 2 : Appliquer sur le poste client**

```powershell
# Sur le poste client (avec droits admin local)
djoin.exe /requestODJ /loadfile C:\provisioning\PC-ATELIER-05.txt `
          /windowspath %SystemRoot% `
          /localos

# Redémarrer
Restart-Computer
```

> [!warning] Important Le fichier de provisioning contient des secrets cryptographiques. Il doit être :
> 
> - Transféré de manière sécurisée
> - Supprimé après utilisation
> - Utilisé une seule fois

### Vérification de la jonction

```powershell
# Vérifier que la machine est bien dans le domaine
Get-ComputerInfo | Select-Object CsDomain, CsDomainRole

# Tester le canal sécurisé avec le DC
Test-ComputerSecureChannel -Verbose

# Si le canal est cassé, le réparer
Test-ComputerSecureChannel -Repair -Credential (Get-Credential)

# Vérifier dans l'AD (depuis un DC ou avec RSAT)
Get-ADComputer -Identity "PC-COMPTA-20" -Properties *
```

> [!example] Résultat attendu pour CsDomainRole
> 
> - `0` = Poste de travail autonome
> - `1` = Poste de travail membre d'un groupe de travail
> - `3` = Poste de travail membre d'un domaine ✅
> - `4` = Serveur membre d'un domaine
> - `5` = Contrôleur de domaine

### Problèmes courants lors de la jonction

|Problème|Cause probable|Solution|
|---|---|---|
|Erreur DNS|Le client ne peut pas résoudre le domaine|Vérifier la config DNS du client|
|Erreur d'accès refusé|Compte sans droits de jonction|Utiliser un compte admin du domaine|
|Canal sécurisé cassé|Restauration système ou désynchronisation|Réinitialiser le compte ou rejoindre|
|Ordinateur déjà existant|Le nom existe déjà dans l'AD|Supprimer l'ancien compte ou choisir un autre nom|
|Erreur réseau|Pare-feu bloque les ports|Ouvrir 389, 88, 445, 135|

> [!tip] Astuce de dépannage
> 
> ```powershell
> # Activer les logs détaillés pour diagnostiquer
> nltest /dbflag:0x2080ffff
> 
> # Consulter les logs
> Get-EventLog -LogName System -Source Netlogon -Newest 20
> 
> # Désactiver les logs détaillés après dépannage
> nltest /dbflag:0x0
> ```

---

## 🔧 Gestion et déplacement des comptes ordinateurs

### Visualisation des comptes ordinateurs

```powershell
# Lister tous les ordinateurs du domaine
Get-ADComputer -Filter * | Select-Object Name, DNSHostName, Enabled

# Ordinateurs dans une OU spécifique
Get-ADComputer -Filter * -SearchBase "OU=Postes_Comptabilite,OU=Ordinateurs,DC=entreprise,DC=local"

# Ordinateurs avec critères multiples
Get-ADComputer -Filter {
    (Enabled -eq $true) -and 
    (OperatingSystem -like "*Windows 11*")
} -Properties OperatingSystem, LastLogonDate

# Recherche par nom avec wildcard
Get-ADComputer -Filter "Name -like 'PC-COMPTA*'" | Sort-Object Name

# Ordinateurs inactifs depuis plus de 90 jours
$Date = (Get-Date).AddDays(-90)
Get-ADComputer -Filter {LastLogonDate -lt $Date} -Properties LastLogonDate | 
    Select-Object Name, LastLogonDate | 
    Sort-Object LastLogonDate
```

> [!tip] Export pour documentation
> 
> ```powershell
> # Exporter la liste des ordinateurs en CSV
> Get-ADComputer -Filter * -Properties * | 
>     Select-Object Name, DNSHostName, OperatingSystem, IPv4Address, LastLogonDate |
>     Export-Csv -Path "C:\inventaire_ordinateurs.csv" -NoTypeInformation -Encoding UTF8
> ```

### Déplacement d'un ordinateur entre OUs

**Pourquoi déplacer un ordinateur ?**

- Appliquer différentes GPO selon l'emplacement
- Organiser par département, site géographique ou type de machine
- Faciliter la délégation d'administration

```powershell
# Déplacement simple d'un ordinateur
Move-ADObject -Identity "CN=PC-COMPTA-01,CN=Computers,DC=entreprise,DC=local" `
              -TargetPath "OU=Postes_Comptabilite,OU=Ordinateurs,DC=entreprise,DC=local"

# Déplacement en utilisant Get-ADComputer (plus lisible)
Get-ADComputer -Identity "PC-COMPTA-01" | 
    Move-ADObject -TargetPath "OU=Postes_Comptabilite,OU=Ordinateurs,DC=entreprise,DC=local"

# Déplacement de plusieurs ordinateurs
Get-ADComputer -Filter "Name -like 'PC-RH*'" | 
    Move-ADObject -TargetPath "OU=Postes_RH,OU=Ordinateurs,DC=entreprise,DC=local"

# Vérifier le déplacement
Get-ADComputer -Identity "PC-COMPTA-01" | Select-Object Name, DistinguishedName
```

> [!warning] Impact des GPO Après un déplacement d'OU, les nouvelles GPO seront appliquées au prochain :
> 
> - Redémarrage de la machine
> - Ou après `gpupdate /force` côté client

### Modification des propriétés d'un compte ordinateur

```powershell
# Modifier la description
Set-ADComputer -Identity "PC-COMPTA-01" -Description "Poste de Jean Dupont - Bureau 305"

# Désactiver un compte ordinateur
Disable-ADAccount -Identity "PC-COMPTA-01"

# Réactiver un compte ordinateur
Enable-ADAccount -Identity "PC-COMPTA-01"

# Modifier plusieurs attributs en une seule commande
Set-ADComputer -Identity "PC-COMPTA-01" `
               -Description "Poste comptabilité" `
               -Location "Bâtiment A - Étage 3" `
               -ManagedBy "CN=Jean Dupont,OU=Utilisateurs,DC=entreprise,DC=local"

# Ajouter une valeur dans un attribut multi-valué
Set-ADComputer -Identity "PC-COMPTA-01" -Add @{servicePrincipalName="HTTP/pc-compta-01.entreprise.local"}
```

> [!example] Cas d'usage réel Avant un remplacement de matériel, désactiver l'ancien compte plutôt que de le supprimer permet de :
> 
> - Garder l'historique des logs
> - Éviter la réutilisation accidentelle du SID
> - Permettre une restauration rapide en cas d'erreur

### Réinitialisation du compte ordinateur

```powershell
# Réinitialiser le mot de passe du compte machine
Reset-ComputerMachinePassword -Server "DC01.entreprise.local" -Credential (Get-Credential)

# Réinitialiser depuis l'AD (côté serveur)
Set-ADAccountPassword -Identity "PC-COMPTA-01$" -Reset

# Alternative pour forcer une nouvelle génération de mot de passe
Get-ADComputer -Identity "PC-COMPTA-01" | Set-ADAccountPassword -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "MotDePasseTemporaire123!" -Force)
```

> [!warning] Quand réinitialiser un compte ordinateur
> 
> - La machine ne peut plus s'authentifier sur le domaine
> - Message d'erreur : "La relation d'approbation entre ce poste de travail et le domaine principal a échoué"
> - Après une restauration système qui a restauré un ancien mot de passe machine

### Suppression d'un compte ordinateur

```powershell
# Suppression simple
Remove-ADComputer -Identity "PC-COMPTA-01" -Confirm:$false

# Avec confirmation
Remove-ADComputer -Identity "PC-COMPTA-01"

# Suppression en masse d'ordinateurs inactifs
$DateLimite = (Get-Date).AddDays(-180)
Get-ADComputer -Filter {LastLogonDate -lt $DateLimite} -Properties LastLogonDate |
    Where-Object {$_.LastLogonDate -ne $null} |
    Remove-ADComputer -Confirm:$false

# Suppression avec export préalable (sécurité)
Get-ADComputer -Filter {LastLogonDate -lt $DateLimite} -Properties * |
    Export-Csv "C:\ordinateurs_a_supprimer.csv" -NoTypeInformation

# Après validation du fichier, supprimer
Import-Csv "C:\ordinateurs_a_supprimer.csv" | 
    ForEach-Object { Remove-ADComputer -Identity $_.Name -Confirm:$false }
```

> [!tip] Bonnes pratiques de suppression
> 
> 1. Toujours désactiver le compte avant de le supprimer (période de grâce de 30-90 jours)
> 2. Exporter les informations avant suppression
> 3. Vérifier que la machine n'est plus utilisée
> 4. Documenter la raison de la suppression

### Renommage d'un ordinateur

```powershell
# Renommer dans AD uniquement (nécessite un redémarrage de la machine ensuite)
Rename-ADObject -Identity "CN=PC-COMPTA-01,OU=Comptabilite,DC=entreprise,DC=local" `
                -NewName "PC-FINANCE-01"

# Renommer la machine ET le compte AD simultanément (depuis le poste client)
Rename-Computer -NewName "PC-FINANCE-01" `
                -DomainCredential (Get-Credential) `
                -Restart

# Renommer avec changement d'OU en même temps
Rename-Computer -NewName "PC-FINANCE-01" -DomainCredential (Get-Credential) -Force
Get-ADComputer -Identity "PC-FINANCE-01" | 
    Move-ADObject -TargetPath "OU=Postes_Finance,OU=Ordinateurs,DC=entreprise,DC=local"
Restart-Computer
```

> [!warning] Attention au renommage
> 
> - Le SPN (Service Principal Name) peut nécessiter une mise à jour manuelle
> - Les certificats liés au nom de machine peuvent être invalidés
> - Les raccourcis UNC pointant vers l'ancien nom ne fonctionneront plus

### Gestion en masse des ordinateurs

```powershell
# Désactiver tous les ordinateurs d'une OU
Get-ADComputer -Filter * -SearchBase "OU=Anciens_Postes,OU=Ordinateurs,DC=entreprise,DC=local" |
    Disable-ADAccount

# Déplacer tous les ordinateurs Windows 10 dans une OU spécifique
Get-ADComputer -Filter {OperatingSystem -like "*Windows 10*"} -Properties OperatingSystem |
    Move-ADObject -TargetPath "OU=Win10_Migration,OU=Ordinateurs,DC=entreprise,DC=local"

# Ajouter une description standardisée à tous les postes d'un site
Get-ADComputer -Filter * -SearchBase "OU=Site_Paris,OU=Ordinateurs,DC=entreprise,DC=local" |
    ForEach-Object { 
        Set-ADComputer -Identity $_ -Description "Site de Paris - $($_.Name)"
    }

# Inventaire des systèmes d'exploitation
Get-ADComputer -Filter * -Properties OperatingSystem |
    Group-Object OperatingSystem |
    Select-Object Count, Name |
    Sort-Object Count -Descending
```

### Délégation de gestion des ordinateurs

```powershell
# Donner les droits de créer/supprimer des ordinateurs dans une OU
$OU = "OU=Postes_Comptabilite,OU=Ordinateurs,DC=entreprise,DC=local"
$Group = "CN=Support_Technique,OU=Groupes,DC=entreprise,DC=local"

# Importer le module AD
Import-Module ActiveDirectory

# Créer l'ACE pour la délégation
$ACL = Get-Acl "AD:$OU"
$User = New-Object System.Security.Principal.SecurityIdentifier (Get-ADGroup $Group).SID

# Droit de créer des objets ordinateurs
$CreateGUID = [GUID]"bf967a86-0de6-11d0-a285-00aa003049e2"
$ACE1 = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
    $User, "CreateChild", "Allow", $CreateGUID, "All"
)

# Droit de supprimer des objets ordinateurs
$ACE2 = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
    $User, "DeleteChild", "Allow", $CreateGUID, "All"
)

$ACL.AddAccessRule($ACE1)
$ACL.AddAccessRule($ACE2)
Set-Acl "AD:$OU" -AclObject $ACL
```

> [!info] Délégation courante pour l'helpdesk Droits typiquement délégués aux équipes de support :
> 
> - Réinitialiser les comptes ordinateurs
> - Joindre des machines au domaine
> - Déplacer des ordinateurs entre OUs
> - Modifier les propriétés (description, localisation)

### Requêtes avancées pour l'audit

```powershell
# Ordinateurs n'ayant jamais changé leur mot de passe
Get-ADComputer -Filter * -Properties PasswordLastSet |
    Where-Object {$_.PasswordLastSet -eq $null} |
    Select-Object Name, Enabled

# Ordinateurs avec un mot de passe trop ancien (>90 jours)
$DateLimite = (Get-Date).AddDays(-90)
Get-ADComputer -Filter * -Properties PasswordLastSet |
    Where-Object {$_.PasswordLastSet -lt $DateLimite} |
    Select-Object Name, PasswordLastSet, Enabled

# Ordinateurs activés mais jamais connectés
Get-ADComputer -Filter {Enabled -eq $true} -Properties LastLogonDate |
    Where-Object {$_.LastLogonDate -eq $null} |
    Select-Object Name, Created

# Compter les ordinateurs par OU
Get-ADOrganizationalUnit -Filter * | 
    ForEach-Object {
        $OU = $_.DistinguishedName
        $Count = (Get-ADComputer -Filter * -SearchBase $OU -SearchScope OneLevel).Count
        [PSCustomObject]@{
            OU = $OU
            NombreOrdinateurs = $Count
        }
    } | 
    Where-Object {$_.NombreOrdinateurs -gt 0} |
    Sort-Object NombreOrdinateurs -Descending
```

> [!tip] Maintenance préventive Planifier un script mensuel qui :
> 
> - Identifie les ordinateurs inactifs
> - Les déplace vers une OU de quarantaine
> - Envoie un rapport aux administrateurs
> - Après validation, les désactive puis les supprime après 90 jours

### Protection contre la suppression accidentelle

```powershell
# Activer la protection contre la suppression
Get-ADComputer -Identity "PC-CRITIQUE-01" | 
    Set-ADObject -ProtectedFromAccidentalDeletion $true

# Activer pour tous les ordinateurs d'une OU
Get-ADComputer -Filter * -SearchBase "OU=Serveurs,DC=entreprise,DC=local" |
    Set-ADObject -ProtectedFromAccidentalDeletion $true

# Vérifier la protection
Get-ADComputer -Identity "PC-CRITIQUE-01" -Properties ProtectedFromAccidentalDeletion |
    Select-Object Name, ProtectedFromAccidentalDeletion

# Désactiver la protection (si nécessaire pour suppression)
Get-ADComputer -Identity "PC-CRITIQUE-01" | 
    Set-ADObject -ProtectedFromAccidentalDeletion $false
```

---

## 📊 Tableau récapitulatif des commandes essentielles

|Action|Commande PowerShell|
|---|---|
|Créer un compte ordinateur|`New-ADComputer -Name "PC-01" -Path "OU=..."`|
|Joindre au domaine|`Add-Computer -DomainName "domain.local" -Credential ...`|
|Lister les ordinateurs|`Get-ADComputer -Filter *`|
|Déplacer un ordinateur|`Move-ADObject -Identity "CN=PC-01,..." -TargetPath "OU=..."`|
|Désactiver un compte|`Disable-ADAccount -Identity "PC-01"`|
|Réactiver un compte|`Enable-ADAccount -Identity "PC-01"`|
|Réinitialiser le mot de passe|`Reset-ComputerMachinePassword`|
|Supprimer un compte|`Remove-ADComputer -Identity "PC-01"`|
|Renommer|`Rename-Computer -NewName "PC-02" -DomainCredential ...`|
|Tester le canal sécurisé|`Test-ComputerSecureChannel -Verbose`|

---

## ⚠️ Pièges courants à éviter

> [!warning] Erreurs fréquentes
> 
> **1. Oublier le "$" dans les scripts**
> 
> - Les comptes ordinateurs se terminent par "$" dans leur SAM Account Name
> - `Get-ADComputer` gère cela automatiquement, mais attention dans les scripts bruts LDAP
> 
> **2. Ne pas spécifier l'OU lors de la jonction**
> 
> - Par défaut, les ordinateurs vont dans `CN=Computers`
> - Utilisez toujours `-OUPath` avec `Add-Computer`
> 
> **3. Supprimer au lieu de désactiver**
> 
> - Perdre l'historique et le SID de la machine
> - Préférez désactiver puis supprimer après une période de grâce
> 
> **4. Ignorer les ordinateurs obsolètes**
> 
> - Les comptes inactifs posent un risque de sécurité
> - Mettez en place un processus de nettoyage régulier
> 
> **5. Ne pas tester le canal après jonction**
> 
> - Toujours vérifier avec `Test-ComputerSecureChannel`
> - Évite les mauvaises surprises lors de l'application des GPO

---

## 🎯 Points clés à retenir

- Un compte ordinateur est nécessaire pour qu'une machine soit membre du domaine
- Le mot de passe du compte machine est géré automatiquement et change tous les 30 jours
- Plusieurs méthodes existent pour joindre un domaine : GUI, PowerShell, offline join
- Toujours placer les ordinateurs dans des OUs appropriées pour l'application des GPO
- La gestion en masse via PowerShell est indispensable dans un environnement de production
- Mettre en place un processus de nettoyage des comptes ordinateurs obsolètes
- Utiliser la protection contre la suppression accidentelle pour les machines critiques
- Le canal sécurisé entre la machine et le DC doit être fonctionnel pour l'authentification