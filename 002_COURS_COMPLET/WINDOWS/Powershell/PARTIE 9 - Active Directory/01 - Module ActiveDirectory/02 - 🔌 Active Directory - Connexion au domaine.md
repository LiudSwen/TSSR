

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

## Vue d'ensemble

La connexion à Active Directory via PowerShell est la première étape pour administrer votre infrastructure. Le module Active Directory pour PowerShell offre plusieurs méthodes de connexion adaptées à différents scénarios : connexion automatique avec vos credentials, connexion explicite à un contrôleur de domaine spécifique, ou utilisation de credentials alternatifs pour des opérations privilégiées.

> [!info] Prérequis Le module Active Directory pour PowerShell doit être installé sur votre machine. Il est disponible via les RSAT (Remote Server Administration Tools) ou directement sur les contrôleurs de domaine.

---

## 1. Connexion automatique

### Principe de fonctionnement

Par défaut, lorsque vous exécutez une cmdlet Active Directory sans spécifier de paramètres de connexion, PowerShell utilise automatiquement le contexte de sécurité de l'utilisateur actuellement connecté. Cette méthode est la plus simple et la plus couramment utilisée dans les environnements d'entreprise.

### Comment ça fonctionne

PowerShell effectue automatiquement les opérations suivantes :

- Récupère le token Kerberos de l'utilisateur connecté
- Interroge le DNS pour localiser les contrôleurs de domaine disponibles
- Sélectionne le DC le plus proche en fonction de la topologie des sites AD
- Établit la connexion en utilisant les permissions de l'utilisateur

```powershell
# Connexion automatique - aucun paramètre nécessaire
Get-ADUser -Identity "jdupont"

# Recherche d'utilisateurs avec connexion automatique
Get-ADUser -Filter "Department -eq 'IT'"

# Modification d'un attribut avec le contexte actuel
Set-ADUser -Identity "jdupont" -Description "Administrateur système"
```

### Quand utiliser la connexion automatique

> [!tip] Cas d'usage idéaux
> 
> - Scripts exécutés sur un poste joint au domaine
> - Administration quotidienne depuis votre session utilisateur
> - Tâches planifiées exécutées avec un compte de service
> - Environnement mono-domaine avec un seul contrôleur de domaine

### Avantages et limitations

**Avantages :**

- Simplicité d'utilisation, aucune configuration requise
- Pas de gestion de credentials dans les scripts
- Utilisation automatique de l'authentification Kerberos
- Sélection optimale du contrôleur de domaine

**Limitations :**

- Nécessite que l'utilisateur ait les droits appropriés
- Impossible de s'authentifier avec un compte différent
- Pas de contrôle sur le DC utilisé
- Ne fonctionne pas hors domaine (workgroup)

> [!warning] Attention aux permissions La connexion automatique utilise VOS permissions. Si une cmdlet échoue, vérifiez d'abord que votre compte dispose des droits nécessaires dans Active Directory.

---

## 2. Spécification du serveur

### Pourquoi spécifier un serveur

Dans certains scénarios, vous devez cibler un contrôleur de domaine spécifique plutôt que de laisser PowerShell en choisir un automatiquement :

- Environnements multi-sites avec latence réseau
- Besoin de garantir la cohérence des lectures/écritures
- Troubleshooting de problèmes de réplication
- Accès à un DC spécifique pour des raisons de proximité

### Utilisation du paramètre -Server

Le paramètre `-Server` est disponible sur toutes les cmdlets Active Directory et accepte plusieurs formats de nom.

```powershell
# Spécification par nom DNS court
Get-ADUser -Identity "jdupont" -Server "DC01"

# Spécification par FQDN (recommandé)
Get-ADUser -Identity "jdupont" -Server "DC01.contoso.local"

# Utilisation d'une adresse IP (déconseillé)
Get-ADUser -Identity "jdupont" -Server "192.168.1.10"

# Stockage du serveur dans une variable
$PreferredDC = "DC-PARIS-01.contoso.local"
Get-ADUser -Filter * -Server $PreferredDC
```

### Choix du format de nom

|Format|Exemple|Avantage|Inconvénient|
|---|---|---|---|
|Nom court|`DC01`|Concis, lisible|Dépend de la résolution DNS|
|FQDN|`DC01.contoso.local`|Non-ambigu, recommandé|Plus verbeux|
|IP|`192.168.1.10`|Fonctionne sans DNS|Pas de Kerberos, moins sécurisé|

> [!tip] Bonne pratique Utilisez toujours le FQDN du contrôleur de domaine. Cela garantit une résolution DNS correcte et permet l'authentification Kerberos.

### Cas d'usage avancés

```powershell
# Cibler un DC dans un site distant
$RemoteDC = "DC-LYON-01.contoso.local"
Get-ADUser -Filter "City -eq 'Lyon'" -Server $RemoteDC

# Forcer l'utilisation d'un DC spécifique pour des modifications critiques
$ProductionDC = "DC-PROD-01.contoso.local"
Set-ADUser -Identity "admin.prod" -Enabled $false -Server $ProductionDC

# Comparer les données entre deux DCs (vérification de réplication)
$DC1 = "DC01.contoso.local"
$DC2 = "DC02.contoso.local"
$User1 = Get-ADUser -Identity "jdupont" -Server $DC1 -Properties Modified
$User2 = Get-ADUser -Identity "jdupont" -Server $DC2 -Properties Modified

Compare-Object $User1.Modified $User2.Modified
```

### Environnements multi-sites

Dans une infrastructure distribuée géographiquement, spécifier le serveur permet d'optimiser les performances et de réduire le trafic WAN.

```powershell
# Fonction pour sélectionner le DC local automatiquement
function Get-LocalDomainController {
    $Site = (Get-ADDomainController -Discover).Site
    $LocalDC = Get-ADDomainController -Filter "Site -eq '$Site'" | 
               Select-Object -First 1 -ExpandProperty HostName
    return $LocalDC
}

$LocalDC = Get-LocalDomainController
Get-ADUser -Filter * -Server $LocalDC
```

> [!warning] Attention à la cohérence Lors de modifications successives, utilisez le même DC pour éviter les problèmes de latence de réplication. Les modifications peuvent prendre plusieurs secondes (voire minutes) pour se propager.

---

## 3. Credentials alternatifs

### Pourquoi utiliser des credentials différents

L'utilisation de credentials alternatifs est essentielle dans plusieurs situations :

- Élévation de privilèges pour des tâches administratives
- Exécution de scripts avec un compte de service dédié
- Administration à distance depuis une machine non jointe au domaine
- Séparation des comptes (principe du moindre privilège)

### Méthode interactive avec Get-Credential

La méthode la plus simple pour obtenir des credentials alternatifs est d'utiliser `Get-Credential`, qui affiche une boîte de dialogue Windows.

```powershell
# Prompt interactif pour les credentials
$Cred = Get-Credential

# Utilisation des credentials pour une opération AD
Get-ADUser -Identity "jdupont" -Credential $Cred

# Spécification d'un nom d'utilisateur par défaut
$Cred = Get-Credential -UserName "CONTOSO\admin.ad" -Message "Entrez le mot de passe administrateur"
Get-ADUser -Filter * -Credential $Cred
```

### Création de credentials en mémoire

Pour les scripts non-interactifs, vous pouvez créer des objets PSCredential programmatiquement.

```powershell
# Création d'un SecureString pour le mot de passe
$Username = "CONTOSO\admin.ad"
$Password = ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential($Username, $Password)

# Utilisation du credential
Get-ADUser -Filter * -Credential $Cred
```

> [!warning] Sécurité des mots de passe Ne stockez JAMAIS de mots de passe en clair dans vos scripts ! Cette méthode est présentée à titre pédagogique uniquement. Utilisez plutôt les méthodes de stockage sécurisé ci-dessous.

### Stockage sécurisé de credentials

PowerShell offre plusieurs méthodes pour stocker des credentials de manière sécurisée.

#### Méthode 1 : Export-Clixml (recommandé pour usage personnel)

```powershell
# Sauvegarde sécurisée des credentials
$Cred = Get-Credential
$Cred | Export-Clixml -Path "C:\Secure\ADAdmin.xml"

# Réutilisation ultérieure
$Cred = Import-Clixml -Path "C:\Secure\ADAdmin.xml"
Get-ADUser -Filter * -Credential $Cred
```

> [!info] Fonctionnement de Export-Clixml Les credentials sont chiffrés avec DPAPI (Data Protection API) en utilisant le profil de l'utilisateur. Seul l'utilisateur qui a créé le fichier peut le déchiffrer, et uniquement sur la même machine.

#### Méthode 2 : SecureString depuis fichier

```powershell
# Création et sauvegarde d'un SecureString
$SecurePassword = Read-Host "Mot de passe" -AsSecureString
$SecurePassword | ConvertFrom-SecureString | Out-File "C:\Secure\password.txt"

# Chargement et utilisation
$Username = "CONTOSO\admin.ad"
$SecurePassword = Get-Content "C:\Secure\password.txt" | ConvertTo-SecureString
$Cred = New-Object System.Management.Automation.PSCredential($Username, $SecurePassword)

Get-ADUser -Filter * -Credential $Cred
```

#### Méthode 3 : Azure Key Vault (environnements entreprise)

Pour les environnements de production, utilisez Azure Key Vault ou un gestionnaire de secrets d'entreprise.

```powershell
# Exemple conceptuel avec Azure Key Vault (nécessite le module Az)
# $Secret = Get-AzKeyVaultSecret -VaultName "MyVault" -Name "ADAdminPassword"
# $SecurePassword = $Secret.SecretValue
# $Cred = New-Object System.Management.Automation.PSCredential($Username, $SecurePassword)
```

### Combinaison Server et Credential

```powershell
# Connexion à un DC distant avec des credentials spécifiques
$RemoteDC = "DC-REMOTE-01.contoso.local"
$Cred = Get-Credential -Message "Credentials pour $RemoteDC"

Get-ADUser -Filter "Enabled -eq `$true" -Server $RemoteDC -Credential $Cred

# Utile pour administration cross-domain
$TrustedDomain = "filiale.contoso.local"
$TrustedDC = "DC01.filiale.contoso.local"
$TrustedCred = Get-Credential -UserName "FILIALE\administrator"

Get-ADUser -Filter * -Server $TrustedDC -Credential $TrustedCred
```

> [!tip] Script réutilisable Créez une fonction qui gère automatiquement le chargement des credentials stockés, avec un fallback vers Get-Credential si le fichier n'existe pas.

```powershell
function Get-StoredCredential {
    param(
        [string]$Path = "C:\Secure\ADAdmin.xml",
        [string]$Username
    )
    
    if (Test-Path $Path) {
        return Import-Clixml -Path $Path
    } else {
        $Cred = Get-Credential -UserName $Username -Message "Credentials non trouvés, veuillez les saisir"
        $Cred | Export-Clixml -Path $Path
        return $Cred
    }
}

# Utilisation
$Cred = Get-StoredCredential -Username "CONTOSO\admin.ad"
Get-ADUser -Filter * -Credential $Cred
```

---

## 4. Contexte d'authentification

### Mécanismes d'authentification

PowerShell et Active Directory supportent plusieurs protocoles d'authentification, chacun avec ses avantages et contraintes.

### Kerberos (protocole par défaut)

Kerberos est le protocole d'authentification préféré dans les environnements Active Directory.

**Caractéristiques :**

- Authentification mutuelle (client et serveur s'authentifient)
- Utilise des tickets à durée de vie limitée
- Ne transmet jamais le mot de passe sur le réseau
- Support du Single Sign-On (SSO)
- Nécessite une résolution DNS correcte

```powershell
# Kerberos est utilisé automatiquement lors d'une connexion par nom
Get-ADUser -Identity "jdupont" -Server "DC01.contoso.local"

# Vérification du ticket Kerberos actif
klist

# Purge des tickets (force une nouvelle authentification)
klist purge
```

> [!info] Fonctionnement de Kerberos Lorsque vous vous connectez à AD, votre client contacte le KDC (Key Distribution Center) sur le DC pour obtenir un TGT (Ticket Granting Ticket). Ce ticket est ensuite utilisé pour demander des tickets de service pour accéder aux ressources, sans retransmission du mot de passe.

### NTLM (protocole de secours)

NTLM est automatiquement utilisé si Kerberos ne peut pas fonctionner.

**Cas de fallback NTLM :**

- Connexion par adresse IP
- Problèmes de résolution DNS
- DC non trouvé dans Active Directory
- Problèmes de synchronisation horaire
- Connexion à travers un firewall bloquant Kerberos (port 88)

```powershell
# Force l'utilisation de NTLM (connexion par IP)
Get-ADUser -Identity "jdupont" -Server "192.168.1.10" -Credential $Cred

# NTLM sera aussi utilisé si le nom ne peut être résolu
Get-ADUser -Identity "jdupont" -Server "serveur-inconnu"
```

> [!warning] Limites de NTLM NTLM est moins sécurisé que Kerberos et ne supporte pas l'authentification mutuelle. Microsoft recommande de privilégier Kerberos et de désactiver NTLM dans les environnements modernes.

### Comparaison Kerberos vs NTLM

|Caractéristique|Kerberos|NTLM|
|---|---|---|
|Sécurité|Excellente (authentification mutuelle)|Moyenne (pas d'auth. mutuelle)|
|Performance|Meilleure (tickets réutilisables)|Plus lente (hash à chaque fois)|
|SSO|Oui|Limité|
|Requis DNS|Oui|Non|
|Requis horaire synchronisé|Oui (5 min tolérance)|Non|
|Port|TCP/UDP 88|TCP 445, 139|

### Authentification SSL/TLS (LDAPS)

Pour les connexions hautement sécurisées, vous pouvez utiliser LDAPS (LDAP over SSL) sur le port 636.

```powershell
# Connexion LDAPS explicite
$LDAPSServer = "DC01.contoso.local:636"
Get-ADUser -Identity "jdupont" -Server $LDAPSServer

# Vérification du certificat SSL du DC
$Connection = [ADSI]"LDAP://DC01.contoso.local:636"
$Connection.Path
```

> [!info] Configuration LDAPS LDAPS nécessite qu'un certificat SSL valide soit installé sur les contrôleurs de domaine. Le certificat doit être émis par une autorité de certification reconnue et contenir le FQDN du DC.

### Débogage des problèmes d'authentification

```powershell
# Test de connectivité réseau
Test-NetConnection -ComputerName "DC01.contoso.local" -Port 389  # LDAP
Test-NetConnection -ComputerName "DC01.contoso.local" -Port 636  # LDAPS
Test-NetConnection -ComputerName "DC01.contoso.local" -Port 88   # Kerberos

# Vérification de la résolution DNS
Resolve-DnsName "DC01.contoso.local"
Resolve-DnsName "_ldap._tcp.contoso.local" -Type SRV

# Test d'authentification basique
$TestPath = "LDAP://DC01.contoso.local"
$Authenticator = New-Object System.DirectoryServices.DirectoryEntry($TestPath)
if ($Authenticator.Name) {
    Write-Host "Authentification réussie" -ForegroundColor Green
} else {
    Write-Host "Échec d'authentification" -ForegroundColor Red
}
```

> [!tip] Problème de synchronisation horaire Si Kerberos échoue avec une erreur "clock skew too great", vérifiez que l'horloge de votre machine est synchronisée avec celle du DC (tolérance maximale : 5 minutes).

```powershell
# Vérification de l'heure du DC
$DC = "DC01.contoso.local"
$DCTime = Invoke-Command -ComputerName $DC -ScriptBlock {Get-Date}
$LocalTime = Get-Date
$TimeDifference = ($DCTime - $LocalTime).TotalMinutes

Write-Host "Différence horaire : $TimeDifference minutes"
if ([Math]::Abs($TimeDifference) -gt 5) {
    Write-Warning "Écart horaire trop important pour Kerberos!"
}
```

---

## 5. Vérification de connexion

### Test de connexion avec Get-ADDomain

La cmdlet `Get-ADDomain` est l'outil privilégié pour vérifier qu'une connexion Active Directory fonctionne correctement.

```powershell
# Test de connexion simple
Get-ADDomain

# Vérification avec un serveur spécifique
Get-ADDomain -Server "DC01.contoso.local"

# Test avec credentials alternatifs
$Cred = Get-Credential
Get-ADDomain -Credential $Cred

# Affichage des informations essentielles
$Domain = Get-ADDomain
Write-Host "Domaine: $($Domain.DNSRoot)" -ForegroundColor Green
Write-Host "NetBIOS: $($Domain.NetBIOSName)" -ForegroundColor Green
Write-Host "Niveau fonctionnel: $($Domain.DomainMode)" -ForegroundColor Green
```

### Propriétés importantes de Get-ADDomain

```powershell
$Domain = Get-ADDomain

# Informations critiques à vérifier
$Domain.DNSRoot              # Nom DNS du domaine (ex: contoso.local)
$Domain.NetBIOSName          # Nom NetBIOS (ex: CONTOSO)
$Domain.DomainMode           # Niveau fonctionnel du domaine
$Domain.Forest               # Forêt parente
$Domain.PDCEmulator          # DC qui joue le rôle d'émulateur PDC
$Domain.RIDMaster            # DC qui gère les RID
$Domain.InfrastructureMaster # DC Infrastructure Master
$Domain.DomainSID            # SID du domaine
```

### Vérification des droits utilisateur

Avant d'effectuer des opérations, vérifiez que votre compte dispose des permissions nécessaires.

```powershell
# Vérification de l'identité actuelle
$CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
Write-Host "Utilisateur actuel: $($CurrentUser.Name)"

# Liste des groupes dont vous êtes membre
$Groups = $CurrentUser.Groups | ForEach-Object {
    $_.Translate([System.Security.Principal.NTAccount])
}
$Groups | Select-Object Value

# Test si membre du groupe Domain Admins
$IsDomainAdmin = $Groups.Value -contains "CONTOSO\Domain Admins"
if ($IsDomainAdmin) {
    Write-Host "Droits administrateur de domaine détectés" -ForegroundColor Green
} else {
    Write-Host "Droits administrateur de domaine non détectés" -ForegroundColor Yellow
}
```

### Tests de connexion avancés

```powershell
# Fonction complète de test de connexion
function Test-ADConnection {
    param(
        [string]$Server,
        [PSCredential]$Credential
    )
    
    $Results = @{
        Connected = $false
        Server = $Server
        Domain = $null
        Error = $null
        ResponseTime = $null
    }
    
    try {
        $StartTime = Get-Date
        
        $Params = @{}
        if ($Server) { $Params.Server = $Server }
        if ($Credential) { $Params.Credential = $Credential }
        
        $Domain = Get-ADDomain @Params -ErrorAction Stop
        
        $EndTime = Get-Date
        $Results.Connected = $true
        $Results.Domain = $Domain.DNSRoot
        $Results.ResponseTime = ($EndTime - $StartTime).TotalMilliseconds
        
        Write-Host "✓ Connexion réussie à $($Domain.DNSRoot)" -ForegroundColor Green
        Write-Host "  Temps de réponse: $([Math]::Round($Results.ResponseTime, 2)) ms" -ForegroundColor Cyan
        
    } catch {
        $Results.Error = $_.Exception.Message
        Write-Host "✗ Échec de connexion: $($Results.Error)" -ForegroundColor Red
    }
    
    return $Results
}

# Utilisation
Test-ADConnection
Test-ADConnection -Server "DC01.contoso.local"
Test-ADConnection -Credential (Get-Credential)
```

### Diagnostic des problèmes de connexion

```powershell
# Script de diagnostic complet
function Diagnose-ADConnection {
    Write-Host "`n=== DIAGNOSTIC DE CONNEXION AD ===" -ForegroundColor Cyan
    
    # 1. Test de connectivité réseau
    Write-Host "`n[1] Test de connectivité réseau..." -ForegroundColor Yellow
    $DC = (Get-ADDomainController -Discover).HostName
    $Ping = Test-Connection -ComputerName $DC -Count 2 -Quiet
    
    if ($Ping) {
        Write-Host "  ✓ DC accessible: $DC" -ForegroundColor Green
    } else {
        Write-Host "  ✗ DC inaccessible: $DC" -ForegroundColor Red
        return
    }
    
    # 2. Test des ports
    Write-Host "`n[2] Test des ports AD..." -ForegroundColor Yellow
    $Ports = @(389, 636, 88, 445)
    foreach ($Port in $Ports) {
        $Test = Test-NetConnection -ComputerName $DC -Port $Port -WarningAction SilentlyContinue
        if ($Test.TcpTestSucceeded) {
            Write-Host "  ✓ Port $Port ouvert" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Port $Port fermé" -ForegroundColor Red
        }
    }
    
    # 3. Test DNS
    Write-Host "`n[3] Test de résolution DNS..." -ForegroundColor Yellow
    try {
        $DNS = Resolve-DnsName $DC -ErrorAction Stop
        Write-Host "  ✓ Résolution DNS réussie" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ Échec de résolution DNS" -ForegroundColor Red
    }
    
    # 4. Test d'authentification
    Write-Host "`n[4] Test d'authentification..." -ForegroundColor Yellow
    try {
        $Domain = Get-ADDomain -ErrorAction Stop
        Write-Host "  ✓ Authentification réussie" -ForegroundColor Green
        Write-Host "  Domaine: $($Domain.DNSRoot)" -ForegroundColor Cyan
    } catch {
        Write-Host "  ✗ Échec d'authentification" -ForegroundColor Red
        Write-Host "  Erreur: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # 5. Vérification des tickets Kerberos
    Write-Host "`n[5] Vérification Kerberos..." -ForegroundColor Yellow
    $Tickets = klist | Select-String "krbtgt"
    if ($Tickets) {
        Write-Host "  ✓ Tickets Kerberos présents" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Aucun ticket Kerberos trouvé" -ForegroundColor Yellow
    }
    
    Write-Host "`n=== FIN DU DIAGNOSTIC ===`n" -ForegroundColor Cyan
}

# Exécution du diagnostic
Diagnose-ADConnection
```

> [!tip] Automatisation des tests Intégrez ces tests dans vos scripts d'administration pour détecter rapidement les problèmes de connexion avant d'exécuter des opérations critiques.

### Gestion des erreurs courantes

```powershell
# Gestion robuste des erreurs de connexion
try {
    $Domain = Get-ADDomain -ErrorAction Stop
    Write-Host "Connexion établie à $($Domain.DNSRoot)"
    
} catch [System.Security.Authentication.AuthenticationException] {
    Write-Error "Échec d'authentification - Vérifiez vos credentials"
    
} catch [System.ServiceModel.EndpointNotFoundException] {
    Write-Error "Contrôleur de domaine inaccessible - Vérifiez le réseau"
    
} catch [Microsoft.ActiveDirectory.Management.ADServerDownException] {
    Write-Error "Le serveur AD ne répond pas"
    
} catch {
    Write-Error "Erreur inattendue: $($_.Exception.Message)"
}
```

---

## 6. Variables de session

### Variables automatiques Active Directory

PowerShell crée automatiquement plusieurs variables lors de l'import du module Active Directory, facilitant l'accès aux informations du domaine.

### $ADDefaultDomainNamingContext

Cette variable contient le Distinguished Name (DN) par défaut du domaine.

```powershell
# Affichage du contexte de nommage par défaut
$ADDefaultDomainNamingContext
# Exemple de sortie: DC=contoso,DC=local

# Utilisation dans une recherche LDAP directe
$Searcher = [ADSISearcher]""
$Searcher.SearchRoot = [ADSI]"LDAP://$ADDefaultDomainNamingContext"
$Searcher.Filter = "(objectClass=user)"
$Searcher.FindAll()
```

> [!info] Qu'est-ce qu'un Distinguished Name ? Le DN est le chemin complet d'un objet dans l'annuaire Active Directory, similaire à un chemin de fichier. Par exemple : `CN=Jean Dupont,OU=Utilisateurs,OU=Paris,DC=contoso,DC=local`

### $ADRootDSE

La variable `$ADRootDSE` fournit des informations sur la racine de l'annuaire (RootDSE - Root Directory Service Entry).

```powershell
# Accès aux informations RootDSE
$RootDSE = Get-ADRootDSE

# Propriétés importantes
$RootDSE.defaultNamingContext        # Contexte de nommage du domaine
$RootDSE.configurationNamingContext  # Partition de configuration
$RootDSE.schemaNamingContext         # Partition de schéma
$RootDSE.rootDomainNamingContext     # Racine de la forêt
$RootDSE.dnsHostName                 # Nom DNS du DC
$RootDSE.serverName                  # DN du serveur
$RootDSE.supportedLDAPVersion        # Versions LDAP supportées
$RootDSE.forestFunctionality         # Niveau fonctionnel de la forêt
$RootDSE.domainFunctionality         # Niveau fonctionnel du domaine
```

### Utilisation pratique des variables de session

```powershell
# Construction de chemins LDAP dynamiques
$RootDSE = Get-ADRootDSE
$DomainDN = $RootDSE.defaultNamingContext
$ConfigDN = $RootDSE.configurationNamingContext

# Recherche dans la partition de configuration
Get-ADObject -SearchBase $ConfigDN -Filter "objectClass -eq 'site'"

# Recherche dans tout le domaine
Get-ADUser -SearchBase $DomainDN -Filter *

# Affichage des sites AD (dans la partition de configuration)
$SitesContainer = "CN=Sites,$ConfigDN"
Get-ADObject -SearchBase $SitesContainer -Filter "objectClass -eq 'site'" | 
    Select-Object Name, DistinguishedName
```

### Création de variables personnalisées

Pour faciliter vos scripts, créez des variables personnalisées en début de session.

```powershell
# Variables de contexte personnalisées
$Script:DefaultDC = (Get-ADDomainController -Discover).HostName
$Script:DomainDN = (Get-ADDomain).DistinguishedName
$Script:DomainNetBIOS = (Get-ADDomain).NetBIOSName
$Script:ForestRoot = (Get-ADForest).RootDomain

# Affichage des variables pour vérification
Write-Host "Variables de session configurées:" -ForegroundColor Cyan
Write-Host "  DC par défaut: $DefaultDC"
Write-Host "  DN du domaine: $DomainDN"
Write-Host "  Nom NetBIOS: $DomainNetBIOS"
Write-Host "  Racine forêt: $ForestRoot"
```

### Fonction d'initialisation de session

Créez une fonction qui initialise toutes les variables nécessaires au début de vos scripts.

```powershell
function Initialize-ADSession {
    <#
    .SYNOPSIS
    Initialise les variables de session Active Directory
    
    .DESCRIPTION
    Configure des variables globales contenant les informations
    essentielles du domaine pour faciliter les scripts AD
    
    .PARAMETER Server
    Serveur AD spécifique à utiliser
    
    .PARAMETER Credential
    Credentials alternatifs
    #>
    
    param(
        [string]$Server,
        [PSCredential]$Credential
    )
    
    $Params = @{}
    if ($Server) { $Params.Server = $Server }
    if ($Credential) { $Params.Credential = $Credential }
    
    try {
        # Récupération des informations de base
        $Global:ADDomain = Get-ADDomain @Params
        $Global:ADForest = Get-ADForest @Params
        $Global:ADRootDSE = Get-ADRootDSE @Params
        
        # Création de variables simplifiées
        $Global:DomainDN = $ADDomain.DistinguishedName
        $Global:DomainDNS = $ADDomain.DNSRoot
        $Global:DomainNetBIOS = $ADDomain.NetBIOSName
        $Global:ForestDN = $ADForest.RootDomain
        $Global:ConfigDN = $ADRootDSE.configurationNamingContext
        $Global:SchemaDN = $ADRootDSE.schemaNamingContext
        
        # Contrôleurs de domaine
        $Global:PDCEmulator = $ADDomain.PDCEmulator
        $Global:AllDCs = (Get-ADDomainController -Filter * @Params).HostName
        
        Write-Host "✓ Session AD initialisée avec succès" -ForegroundColor Green
        Write-Host "  Domaine: $DomainDNS" -ForegroundColor Cyan
        Write-Host "  Forêt: $ForestDN" -ForegroundColor Cyan
        Write-Host "  PDC Emulator: $PDCEmulator" -ForegroundColor Cyan
        
    } catch {
        Write-Error "Échec de l'initialisation AD: $($_.Exception.Message)"
        return $false
    }
    
    return $true
}

# Utilisation en début de script
Initialize-ADSession

# Maintenant vous pouvez utiliser les variables globales
Get-ADUser -Filter * -SearchBase $DomainDN
```

### Variables pour chemins courants

```powershell
# Définition des OUs courantes
$UsersOU = "OU=Utilisateurs,$DomainDN"
$ComputersOU = "OU=Ordinateurs,$DomainDN"
$GroupsOU = "OU=Groupes,$DomainDN"
$ServersOU = "OU=Serveurs,$DomainDN"

# Utilisation dans les scripts
New-ADUser -Name "Jean Dupont" -Path $UsersOU
New-ADComputer -Name "PC-001" -Path $ComputersOU
New-ADGroup -Name "Groupe_IT" -Path $GroupsOU -GroupScope Global
```

> [!tip] Profil PowerShell Ajoutez la fonction `Initialize-ADSession` à votre profil PowerShell (`$PROFILE`) pour qu'elle soit automatiquement disponible dans toutes vos sessions.

```powershell
# Ajout au profil PowerShell
Add-Content -Path $PROFILE -Value @"

# Initialisation automatique AD
if (Get-Module -ListAvailable -Name ActiveDirectory) {
    Import-Module ActiveDirectory
    # Ajoutez ici la fonction Initialize-ADSession
}
"@
```

---

## 7. Multi-domaines et forêts

### Comprendre les environnements multi-domaines

Dans les grandes organisations, Active Directory est souvent structuré avec plusieurs domaines dans une ou plusieurs forêts. PowerShell permet de naviguer et d'administrer ces environnements complexes.

### Hiérarchie Active Directory

**Structure typique :**

- **Forêt** : Conteneur de sécurité principal, partage un schéma commun
- **Arbre** : Collection de domaines partageant un espace de noms contigu
- **Domaine** : Unité administrative avec ses propres stratégies et objets
- **Domaine enfant** : Domaine qui hérite du domaine parent

```
Forêt: contoso.com
│
├── contoso.com (Domaine racine)
│   ├── europe.contoso.com (Domaine enfant)
│   │   └── france.europe.contoso.com
│   └── amerique.contoso.com
│
└── filiale.com (Arbre séparé dans la même forêt)
```

### Exploration de la forêt

```powershell
# Informations sur la forêt
$Forest = Get-ADForest
$Forest.Domains                    # Liste tous les domaines
$Forest.GlobalCatalogs             # Serveurs de catalogue global
$Forest.Sites                      # Sites AD
$Forest.RootDomain                 # Domaine racine
$Forest.ForestMode                 # Niveau fonctionnel

# Affichage formaté de tous les domaines
Write-Host "`nDomaines dans la forêt $($Forest.Name):" -ForegroundColor Cyan
foreach ($Domain in $Forest.Domains) {
    Write-Host "  • $Domain" -ForegroundColor Green
}

# Liste de tous les contrôleurs de domaine dans la forêt
Get-ADForest | Select-Object -ExpandProperty GlobalCatalogs
```

### Travail avec plusieurs domaines

Pour interroger un domaine spécifique, utilisez le paramètre `-Server` avec le FQDN du DC du domaine cible.

```powershell
# Connexion au domaine racine
$RootDomain = (Get-ADForest).RootDomain
Get-ADUser -Filter * -Server $RootDomain

# Connexion à un domaine enfant
$ChildDomain = "europe.contoso.com"
Get-ADUser -Filter * -Server $ChildDomain

# Comparaison d'utilisateurs entre domaines
$UsersRoot = Get-ADUser -Filter * -Server $RootDomain
$UsersChild = Get-ADUser -Filter * -Server $ChildDomain

Write-Host "Utilisateurs dans $RootDomain : $($UsersRoot.Count)"
Write-Host "Utilisateurs dans $ChildDomain : $($UsersChild.Count)"
```

### Trusts et relations d'approbation

Les trusts permettent aux utilisateurs d'un domaine d'accéder aux ressources d'un autre domaine.

```powershell
# Liste des trusts du domaine actuel
Get-ADTrust -Filter *

# Informations détaillées sur un trust
$Trust = Get-ADTrust -Filter "Name -eq 'filiale.contoso.com'"
$Trust.Direction          # Bidirectional, Inbound, Outbound
$Trust.TrustType         # TreeRoot, ParentChild, External, Forest
$Trust.TrustAttributes   # ForestTransitive, etc.

# Vérification de la santé d'un trust
Test-ComputerSecureChannel -Server "filiale.contoso.com"

# Liste des domaines approuvés
$Forest = Get-ADForest
$Forest.Domains | ForEach-Object {
    Write-Host "Domaine: $_" -ForegroundColor Cyan
    Get-ADTrust -Server $_ -Filter * | 
        Select-Object Name, Direction, TrustType |
        Format-Table -AutoSize
}
```

### Authentification cross-domain

Pour accéder à des ressources dans un domaine approuvé, vous devez fournir les credentials appropriés.

```powershell
# Credentials pour un domaine approuvé
$TrustedDomain = "filiale.contoso.com"
$TrustedCred = Get-Credential -UserName "FILIALE\administrateur" `
                              -Message "Credentials pour $TrustedDomain"

# Connexion au domaine approuvé
Get-ADUser -Filter * -Server $TrustedDomain -Credential $TrustedCred

# Recherche d'un utilisateur dans un domaine spécifique
$User = Get-ADUser -Identity "jdupont" -Server $TrustedDomain -Credential $TrustedCred
Write-Host "Utilisateur trouvé: $($User.Name) dans $TrustedDomain"
```

### Global Catalog (Catalogue global)

Le Global Catalog est un référentiel contenant une copie partielle de tous les objets de la forêt, permettant des recherches rapides à travers tous les domaines.

```powershell
# Identification des serveurs Global Catalog
$Forest = Get-ADForest
$GlobalCatalogs = $Forest.GlobalCatalogs

Write-Host "Serveurs Global Catalog:" -ForegroundColor Cyan
$GlobalCatalogs | ForEach-Object {
    Write-Host "  • $_" -ForegroundColor Green
}

# Recherche dans le Global Catalog (port 3268)
$GC = $GlobalCatalogs[0]
$GCServer = "${GC}:3268"

# Recherche d'un utilisateur dans toute la forêt via GC
Get-ADUser -Filter "Name -like '*dupont*'" -Server $GCServer

# Recherche de groupes universels (stockés dans le GC)
Get-ADGroup -Filter "GroupScope -eq 'Universal'" -Server $GCServer
```

> [!info] Pourquoi utiliser le Global Catalog ? Le GC permet de rechercher des objets dans toute la forêt sans avoir à interroger chaque domaine individuellement. Il est particulièrement utile pour les recherches de groupes universels et pour l'authentification cross-domain.

### Script de navigation multi-domaines

```powershell
function Search-ADUserInForest {
    <#
    .SYNOPSIS
    Recherche un utilisateur dans tous les domaines de la forêt
    
    .PARAMETER Identity
    Nom ou SamAccountName de l'utilisateur
    
    .EXAMPLE
    Search-ADUserInForest -Identity "jdupont"
    #>
    
    param(
        [Parameter(Mandatory=$true)]
        [string]$Identity
    )
    
    $Forest = Get-ADForest
    $Results = @()
    
    Write-Host "`nRecherche de '$Identity' dans la forêt $($Forest.Name)..." -ForegroundColor Cyan
    
    foreach ($Domain in $Forest.Domains) {
        Write-Host "  Recherche dans $Domain..." -ForegroundColor Yellow
        
        try {
            $User = Get-ADUser -Filter "SamAccountName -eq '$Identity'" `
                              -Server $Domain `
                              -Properties * `
                              -ErrorAction Stop
            
            if ($User) {
                $Results += [PSCustomObject]@{
                    Domain = $Domain
                    Name = $User.Name
                    SamAccountName = $User.SamAccountName
                    Email = $User.EmailAddress
                    Enabled = $User.Enabled
                    DistinguishedName = $User.DistinguishedName
                }
                Write-Host "    ✓ Trouvé!" -ForegroundColor Green
            }
        } catch {
            Write-Host "    ✗ Erreur: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    if ($Results.Count -eq 0) {
        Write-Host "`nAucun utilisateur trouvé." -ForegroundColor Yellow
    } else {
        Write-Host "`n$($Results.Count) utilisateur(s) trouvé(s):" -ForegroundColor Green
        $Results | Format-Table -AutoSize
    }
    
    return $Results
}

# Utilisation
Search-ADUserInForest -Identity "jdupont"
```

### Gestion des domaines externes avec trusts externes

Pour les domaines qui ne font pas partie de votre forêt mais qui ont un trust externe configuré :

```powershell
# Liste des trusts externes
Get-ADTrust -Filter "TrustType -eq 'External'"

# Connexion à un domaine externe via trust
$ExternalDomain = "partenaire.com"
$ExternalCred = Get-Credential -UserName "PARTENAIRE\admin"

# Interrogation du domaine externe
Get-ADUser -Filter * -Server $ExternalDomain -Credential $ExternalCred

# Vérification de la validité du trust externe
$Trust = Get-ADTrust -Filter "Name -eq '$ExternalDomain'"
if ($Trust.TrustDirection -eq "Bidirectional") {
    Write-Host "Trust bidirectionnel actif avec $ExternalDomain" -ForegroundColor Green
}
```

### Recherche optimisée multi-domaines

```powershell
function Get-ADObjectFromForest {
    <#
    .SYNOPSIS
    Recherche optimisée d'objets AD dans toute la forêt
    
    .DESCRIPTION
    Utilise le Global Catalog pour des recherches rapides,
    puis récupère les détails complets du domaine source
    
    .PARAMETER Filter
    Filtre LDAP pour la recherche
    
    .PARAMETER ObjectClass
    Type d'objet (user, group, computer)
    #>
    
    param(
        [Parameter(Mandatory=$true)]
        [string]$Filter,
        
        [ValidateSet("user", "group", "computer")]
        [string]$ObjectClass = "user"
    )
    
    # Utilisation du Global Catalog pour recherche initiale
    $GC = (Get-ADForest).GlobalCatalogs[0]
    $GCServer = "${GC}:3268"
    
    Write-Host "Recherche dans le Global Catalog..." -ForegroundColor Cyan
    
    $Objects = Get-ADObject -Filter $Filter `
                           -Server $GCServer `
                           -Properties CanonicalName
    
    if ($Objects) {
        Write-Host "$($Objects.Count) objet(s) trouvé(s)" -ForegroundColor Green
        
        # Récupération des détails complets depuis chaque domaine
        $DetailedObjects = @()
        
        foreach ($Obj in $Objects) {
            # Extraction du domaine depuis le CanonicalName
            $DomainFromCN = $Obj.CanonicalName.Split('/')[0]
            
            Write-Host "  Récupération des détails depuis $DomainFromCN..." -ForegroundColor Yellow
            
            try {
                $FullObject = Get-ADObject -Identity $Obj.DistinguishedName `
                                          -Server $DomainFromCN `
                                          -Properties * `
                                          -ErrorAction Stop
                
                $DetailedObjects += $FullObject
                
            } catch {
                Write-Warning "Impossible de récupérer les détails pour $($Obj.Name)"
            }
        }
        
        return $DetailedObjects
    } else {
        Write-Host "Aucun objet trouvé" -ForegroundColor Yellow
        return $null
    }
}

# Utilisation - Recherche de tous les groupes contenant "Admin"
Get-ADObjectFromForest -Filter "Name -like '*Admin*'" -ObjectClass group
```

### Considérations de performance

> [!warning] Performance multi-domaines Les requêtes cross-domain peuvent être lentes, surtout dans des environnements distribués géographiquement. Privilégiez le Global Catalog pour les recherches larges et interrogez directement les domaines pour les opérations de modification.

```powershell
# Bonne pratique : recherche initiale via GC, modifications ciblées
$GC = (Get-ADForest).GlobalCatalogs[0]

# 1. Recherche rapide dans le GC
$Users = Get-ADUser -Filter "Department -eq 'IT'" -Server "${GC}:3268"

# 2. Groupement par domaine
$UsersByDomain = $Users | Group-Object {
    $_.DistinguishedName -replace '^.*?,DC=' -replace ',DC=', '.'
}

# 3. Modifications par lot sur chaque domaine
foreach ($DomainGroup in $UsersByDomain) {
    $Domain = $DomainGroup.Name
    Write-Host "Mise à jour de $($DomainGroup.Count) utilisateurs dans $Domain"
    
    foreach ($User in $DomainGroup.Group) {
        Set-ADUser -Identity $User.DistinguishedName `
                  -Server $Domain `
                  -Description "Mis à jour le $(Get-Date)"
    }
}
```

### Tableau récapitulatif des scénarios multi-domaines

|Scénario|Méthode recommandée|Port|Commande exemple|
|---|---|---|---|
|Recherche dans toute la forêt|Global Catalog|3268|`Get-ADUser -Server "GC:3268"`|
|Requête domaine spécifique|DC du domaine cible|389|`Get-ADUser -Server "dc.domain.com"`|
|Domaine avec trust externe|Credentials + Server|389|`Get-ADUser -Server "ext.com" -Credential $Cred`|
|Recherche groupes universels|Global Catalog|3268|`Get-ADGroup -Server "GC:3268"`|
|Modification d'objets|DC du domaine source|389|`Set-ADUser -Server "source.domain.com"`|

> [!tip] Optimisation finale Dans les scripts qui interrogent régulièrement plusieurs domaines, mettez en cache les informations de forêt et les listes de DCs pour éviter les requêtes répétitives qui ralentissent l'exécution.

---

## 🎯 Résumé des points clés

La connexion à Active Directory via PowerShell est flexible et s'adapte à tous les scénarios :

1. **Connexion automatique** : Simple et transparente pour les tâches quotidiennes
2. **Spécification du serveur** : Contrôle précis pour les environnements complexes
3. **Credentials alternatifs** : Sécurité et élévation de privilèges
4. **Authentification** : Kerberos prioritaire, NTLM en fallback, LDAPS pour la sécurité maximale
5. **Vérification** : Toujours tester la connexion avant les opérations critiques
6. **Variables de session** : Automatisation et simplification des scripts
7. **Multi-domaines** : Global Catalog et trusts pour les environnements distribués

> [!tip] Bonne pratique globale Commencez toujours vos scripts d'administration AD par une fonction d'initialisation qui vérifie la connexion, configure les variables nécessaires, et valide les permissions. Cela évite les erreurs en cours d'exécution et facilite le débogage.