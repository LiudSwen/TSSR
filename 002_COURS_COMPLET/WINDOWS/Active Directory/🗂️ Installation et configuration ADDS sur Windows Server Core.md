

## Prérequis

- Windows Server Core installé
- Adresse IP statique configurée
- Privilèges administrateur local
- Nom du serveur défini

---

## 1. Préparation du serveur

### 1.1 Vérification configuration réseau

```powershell
# Afficher la configuration IP
Get-NetIPAddress

# Vérifier le nom de l'ordinateur
hostname

# ✅ Vérification DNS (doit pointer vers lui-même une fois DC)
Get-DnsClientServerAddress
```

### 1.2 Définir IP statique (si nécessaire)

```powershell
# Lister les interfaces réseau
Get-NetAdapter

# Configurer IP statique - adapter les valeurs
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.1.10 -PrefixLength 24 -DefaultGateway 192.168.1.1

# Configurer DNS (pointe vers lui-même)
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 192.168.1.10,8.8.8.8
```

### 1.3 Renommer le serveur (si nécessaire)

```powershell
# Renommer - adapter [NOM-SERVEUR]
Rename-Computer -NewName "DC01" -Restart
```

---

## 2. Installation du rôle AD DS

### 2.1 Installer le rôle

```powershell
# Installation du rôle Active Directory Domain Services
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# ✅ Vérification installation
Get-WindowsFeature | Where-Object {$_.Name -eq "AD-Domain-Services"}
```

**Résultat attendu :** `Install State = Installed`

---

## 3. Promotion en contrôleur de domaine

### 3.1 Créer une nouvelle forêt (premier DC)

```powershell
# Promotion en DC - nouvelle forêt
# Adapter: [DOMAINE.LOCAL] et mot de passe DSRM
Install-ADDSForest `
  -DomainName "contoso.local" `
  -DomainNetbiosName "CONTOSO" `
  -ForestMode "WinThreshold" `
  -DomainMode "WinThreshold" `
  -InstallDns:$true `
  -NoRebootOnCompletion:$false `
  -Force:$true
```

**Saisir :** Mot de passe DSRM (Directory Services Restore Mode) - **À CONSERVER PRÉCIEUSEMENT**

> [!warning] Le serveur redémarre automatiquement après la promotion

### 3.2 Ajouter un DC supplémentaire (domaine existant)

```powershell
# Ajouter DC à domaine existant
# Adapter: [DOMAINE.LOCAL] et credentials
Install-ADDSDomainController `
  -DomainName "contoso.local" `
  -Credential (Get-Credential "CONTOSO\Administrator") `
  -InstallDns:$true `
  -NoRebootOnCompletion:$false `
  -Force:$true
```

---

## 4. Vérification post-installation

### 4.1 Vérifier les services AD

```powershell
# Services AD DS et DNS
Get-Service NTDS,DNS,KDC,Netlogon | Select-Object Name,Status

# ✅ Tous les services doivent être "Running"
```

### 4.2 Vérifier le domaine

```powershell
# Informations domaine
Get-ADDomain | Select-Object Name,Forest,DomainMode

# Informations forêt
Get-ADForest | Select-Object Name,ForestMode,RootDomain

# Vérifier rôles FSMO
Get-ADDomainController | Select-Object Name,OperationMasterRoles
```

### 4.3 Tester réplication

```powershell
# Test réplication (si plusieurs DC)
repadmin /replsummary

# Vérifier topologie de réplication
repadmin /showrepl
```

### 4.4 Vérifier DNS

```powershell
# Zones DNS
Get-DnsServerZone

# Enregistrements SRV critiques
nslookup -type=SRV _ldap._tcp.dc._msdcs.[DOMAINE]
```

---

## 5. Configuration post-installation

### 5.1 Créer unités organisationnelles

```powershell
# Créer OUs de base
New-ADOrganizationalUnit -Name "Utilisateurs" -Path "DC=contoso,DC=local"
New-ADOrganizationalUnit -Name "Ordinateurs" -Path "DC=contoso,DC=local"
New-ADOrganizationalUnit -Name "Serveurs" -Path "DC=contoso,DC=local"
New-ADOrganizationalUnit -Name "Groupes" -Path "DC=contoso,DC=local"

# ✅ Vérification
Get-ADOrganizationalUnit -Filter * | Select-Object Name,DistinguishedName
```

### 5.2 Créer utilisateur de test

```powershell
# Créer utilisateur - adapter valeurs
New-ADUser -Name "Jean Dupont" `
  -GivenName "Jean" `
  -Surname "Dupont" `
  -SamAccountName "jdupont" `
  -UserPrincipalName "jdupont@contoso.local" `
  -Path "OU=Utilisateurs,DC=contoso,DC=local" `
  -AccountPassword (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force) `
  -Enabled $true

# ✅ Vérification
Get-ADUser -Identity jdupont
```

### 5.3 Configurer la corbeille AD (recommandé)

```powershell
# Activer la corbeille AD (irréversible)
Enable-ADOptionalFeature -Identity "Recycle Bin Feature" `
  -Scope ForestOrConfigurationSet `
  -Target "contoso.local" `
  -Confirm:$false

# ✅ Vérification
Get-ADOptionalFeature -Filter {Name -like "Recycle*"}
```

---

## 6. Sécurisation basique

### 6.1 Configurer stratégie de mot de passe

```powershell
# Afficher stratégie actuelle
Get-ADDefaultDomainPasswordPolicy

# Modifier stratégie - adapter selon besoins
Set-ADDefaultDomainPasswordPolicy -Identity contoso.local `
  -MinPasswordLength 12 `
  -PasswordHistoryCount 24 `
  -MaxPasswordAge 90.00:00:00 `
  -MinPasswordAge 1.00:00:00 `
  -ComplexityEnabled $true
```

### 6.2 Désactiver compte Administrateur par défaut (facultatif)

```powershell
# Créer nouvel admin avant de désactiver le compte intégré
# Puis désactiver le compte Administrator
Disable-ADAccount -Identity Administrator

# Alternative: renommer le compte
Rename-ADObject -Identity "CN=Administrator,CN=Users,DC=contoso,DC=local" -NewName "Admin-Old"
```

---

## Récapitulatif des commandes principales

|Action|Commande|Phase|
|---|---|---|
|Installer rôle|`Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools`|Installation|
|Nouvelle forêt|`Install-ADDSForest -DomainName [DOMAINE]`|Promotion|
|DC additionnel|`Install-ADDSDomainController -DomainName [DOMAINE]`|Promotion|
|Vérifier services|`Get-Service NTDS,DNS,Netlogon`|Validation|
|Vérifier domaine|`Get-ADDomain`|Validation|
|Créer OU|`New-ADOrganizationalUnit -Name [NOM]`|Configuration|
|Créer utilisateur|`New-ADUser -Name [NOM]`|Configuration|
|Activer corbeille|`Enable-ADOptionalFeature -Identity "Recycle Bin Feature"`|Sécurité|

---

## 🔧 Dépannage

### Problème : Erreur lors de l'installation du rôle

**Symptômes :**

- Message d'erreur "The request to add or remove features on the specified server failed"
- Installation bloquée à 0%

**Vérifications :**

```powershell
# Vérifier mises à jour Windows
Get-HotFix | Sort-Object -Descending -Property InstalledOn | Select-Object -First 10

# Vérifier espace disque
Get-PSDrive C | Select-Object Used,Free
```

**Cause probable :** Mises à jour Windows en attente ou espace disque insuffisant

**Solution :**

```powershell
# Installer les mises à jour pendantes
Install-WindowsUpdate -AcceptAll -AutoReboot

# Ou redémarrer et réessayer
Restart-Computer
```

---

### Problème : Promotion échoue - "DNS server could not be contacted"

**Symptômes :**

- Erreur lors de `Install-ADDSForest`
- Message concernant DNS non joignable

**Vérifications :**

```powershell
# Vérifier configuration DNS actuelle
Get-DnsClientServerAddress

# Tester résolution DNS
nslookup google.com
```

**Cause probable :** DNS mal configuré ou serveur DNS externe inaccessible

**Solution :**

```powershell
# Configurer DNS vers serveur local (127.0.0.1) ou IP statique du serveur
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 127.0.0.1

# Réessayer la promotion
```

---

### Problème : Services AD ne démarrent pas après redémarrage

**Symptômes :**

- Service NTDS en état "Stopped"
- Impossibilité de se connecter au domaine

**Vérifications :**

```powershell
# État des services AD
Get-Service NTDS,DNS,KDC,Netlogon

# Vérifier logs événements
Get-EventLog -LogName "Directory Service" -Newest 20
```

**Cause probable :** Base de données AD corrompue ou problème disque

**Solution :**

```powershell
# Démarrer manuellement le service
Start-Service NTDS

# Si échec: démarrer en mode DSRM et réparer
# Redémarrer avec F8 > Directory Services Restore Mode
# Puis exécuter:
ntdsutil
activate instance ntds
files
integrity
quit
quit
```

---

### Problème : Réplication ne fonctionne pas entre DC

**Symptômes :**

- `repadmin /replsummary` montre des erreurs
- Objets créés sur DC1 n'apparaissent pas sur DC2

**Vérifications :**

```powershell
# Vérifier réplication
repadmin /showrepl

# Vérifier connectivité réseau entre DC
Test-Connection DC02

# Vérifier ports requis (135, 389, 636, 3268, 3269)
Test-NetConnection DC02 -Port 389
```

**Cause probable :** Pare-feu bloquant ou problème DNS

**Solution :**

```powershell
# Forcer réplication immédiate
repadmin /syncall /AdeP

# Si problème DNS:
ipconfig /registerdns

# Vérifier enregistrements DNS SRV
dcdiag /test:dns
```

---

### Problème : Compte administrateur verrouillé

**Symptômes :**

- Impossible de se connecter avec Administrator
- Message "Account is locked out"

**Vérifications :**

```powershell
# Depuis un autre DC ou en mode DSRM
# Vérifier état du compte
Get-ADUser Administrator -Properties LockedOut
```

**Cause probable :** Tentatives de connexion échouées multiples

**Solution :**

```powershell
# Déverrouiller le compte
Unlock-ADAccount -Identity Administrator

# Réinitialiser mot de passe si nécessaire
Set-ADAccountPassword -Identity Administrator -Reset
```

---

## Références rapides

### Niveaux fonctionnels

|Niveau|Valeur PowerShell|Windows Server|
|---|---|---|
|2012 R2|Win2012R2|2012 R2+|
|2016|WinThreshold|2016+|
|2019|WinThreshold|2019+|

### Ports AD essentiels

|Service|Port|Protocole|Usage|
|---|---|---|---|
|LDAP|389|TCP/UDP|Requêtes AD|
|LDAPS|636|TCP|LDAP sécurisé|
|Global Catalog|3268|TCP|Catalogue global|
|Kerberos|88|TCP/UDP|Authentification|
|DNS|53|TCP/UDP|Résolution noms|
|RPC|135|TCP|Réplication|

### Commandes de diagnostic rapides

```powershell
# Santé globale du DC
dcdiag /v

# Test DNS complet
dcdiag /test:dns

# État réplication
repadmin /replsummary

# Vérifier FSMO
netdom query fsmo
```