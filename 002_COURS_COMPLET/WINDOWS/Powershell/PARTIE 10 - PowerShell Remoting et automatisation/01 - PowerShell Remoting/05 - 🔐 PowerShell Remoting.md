# 🔐 PowerShell Remoting - Configuration et Sécurité

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

## 🔑 Authentication

L'authentification est le processus de vérification de l'identité d'un utilisateur lors d'une connexion PowerShell Remoting. Le choix du mécanisme d'authentification dépend de votre environnement (domaine Active Directory ou workgroup) et de vos exigences de sécurité.

### Kerberos

**Qu'est-ce que c'est ?** Kerberos est le mécanisme d'authentification par défaut et le plus sécurisé dans un environnement de domaine Active Directory. Il utilise un système de tickets pour authentifier les utilisateurs sans transmettre les mots de passe sur le réseau.

**Pourquoi l'utiliser ?**

- Authentification mutuelle (client et serveur se vérifient mutuellement)
- Aucun mot de passe transmis sur le réseau
- Support de la délégation d'authentification
- Résistant aux attaques de type "replay"

> [!info] Fonctionnement
> 
> 1. L'utilisateur demande un ticket au Key Distribution Center (KDC)
> 2. Le KDC émet un Ticket Granting Ticket (TGT)
> 3. Le TGT est utilisé pour obtenir des tickets de service
> 4. Ces tickets permettent l'accès aux ressources

**Utilisation :**

```powershell
# Kerberos est utilisé automatiquement dans un domaine
New-PSSession -ComputerName Server01

# Vérifier l'authentification utilisée
$session = New-PSSession -ComputerName Server01
$session | Select-Object ComputerName, State, ConfigurationName, Availability

# Forcer explicitement Kerberos
New-PSSession -ComputerName Server01 -Authentication Kerberos
```

> [!tip] Astuce Pour diagnostiquer les problèmes Kerberos, utilisez `klist` pour voir les tickets en cache et `klist purge` pour les supprimer en cas de problème.

> [!warning] Prérequis
> 
> - Les machines doivent être membres d'un domaine Active Directory
> - Les DNS doivent être correctement configurés
> - Les horloges système doivent être synchronisées (tolérance de 5 minutes par défaut)

---

### NTLM

**Qu'est-ce que c'est ?** NTLM (NT LAN Manager) est un protocole d'authentification challenge-response utilisé dans les environnements sans domaine Active Directory (workgroups) ou en fallback si Kerberos échoue.

**Pourquoi l'utiliser ?**

- Compatible avec les environnements workgroup
- Fonctionne sans infrastructure Active Directory
- Utilisé automatiquement si Kerberos n'est pas disponible

**Limitations :**

- Authentification unidirectionnelle uniquement (pas de vérification mutuelle)
- Plus vulnérable aux attaques que Kerberos
- Ne supporte pas la délégation d'authentification

```powershell
# NTLM est utilisé automatiquement en workgroup
# Nécessite la configuration de TrustedHosts (voir section dédiée)
New-PSSession -ComputerName 192.168.1.100 -Credential (Get-Credential)

# Forcer explicitement NTLM
New-PSSession -ComputerName Server01 -Authentication Negotiate -Credential $cred
# Note: "Negotiate" tente Kerberos puis NTLM en fallback

# Forcer uniquement NTLM (sans tentative Kerberos)
$sessionOption = New-PSSessionOption -IncludePortInSPN $false
New-PSSession -ComputerName Server01 -Authentication Ntlm -Credential $cred -SessionOption $sessionOption
```

> [!warning] Sécurité NTLM est considéré comme obsolète et moins sécurisé. Microsoft recommande de migrer vers Kerberos dans la mesure du possible.

> [!example] Cas d'usage typique Connexion à un serveur standalone (non-domaine) ou connexion par adresse IP dans un domaine.

---

### CredSSP

**Qu'est-ce que c'est ?** CredSSP (Credential Security Support Provider) est un protocole qui permet la délégation des credentials. Il envoie les identifiants de l'utilisateur au serveur distant, permettant au serveur d'agir au nom de l'utilisateur sur d'autres ressources (double-hop).

**Pourquoi l'utiliser ?**

- Résout le problème du "double-hop" (accès à une ressource tierce depuis une session distante)
- Permet d'utiliser vos credentials sur le serveur distant
- Utile pour les scripts nécessitant l'accès à des ressources réseau depuis la machine distante

**Le problème du double-hop :**

```powershell
# Scénario problématique sans CredSSP
Invoke-Command -ComputerName Server01 -ScriptBlock {
    # Cette commande échouera car vos credentials ne sont pas délégués
    Get-Content \\FileServer\Share\file.txt
}
```

**Solution avec CredSSP :**

```powershell
# 1. Activer CredSSP sur le client
Enable-WSManCredSSP -Role Client -DelegateComputer "Server01"

# 2. Activer CredSSP sur le serveur (à exécuter sur Server01)
Enable-WSManCredSSP -Role Server

# 3. Utiliser CredSSP pour la connexion
$cred = Get-Credential
New-PSSession -ComputerName Server01 -Authentication CredSSP -Credential $cred

# 4. Maintenant le double-hop fonctionne
Invoke-Command -ComputerName Server01 -Authentication CredSSP -Credential $cred -ScriptBlock {
    Get-Content \\FileServer\Share\file.txt
}

# 5. Désactiver CredSSP après utilisation (sécurité)
Disable-WSManCredSSP -Role Client
```

> [!warning] Risques de sécurité critiques
> 
> - Vos credentials sont envoyés en clair au serveur distant (même si la connexion est chiffrée)
> - Le serveur distant peut utiliser vos credentials pour accéder à n'importe quelle ressource
> - Risque élevé si le serveur distant est compromis
> - Vulnérable aux attaques "Pass-the-Hash"

> [!tip] Bonnes pratiques CredSSP
> 
> - N'activez CredSSP que temporairement, pour une tâche spécifique
> - Limitez les machines autorisées avec `-DelegateComputer`
> - Désactivez-le immédiatement après utilisation
> - Privilégiez des alternatives comme Resource-Based Kerberos Constrained Delegation
> - Utilisez uniquement avec des serveurs de confiance

**Vérifier la configuration CredSSP :**

```powershell
# Voir les paramètres CredSSP
Get-WSManCredSSP

# Vérifier les stratégies de groupe qui affectent CredSSP
Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation"
```

**Piège courant :**

```powershell
# ❌ Erreur : CredSSP non activé
New-PSSession -ComputerName Server01 -Authentication CredSSP -Credential $cred
# Erreur: "The client cannot connect to the destination..."

# ✅ Solution : Activer d'abord CredSSP comme montré ci-dessus
```

---

### Certificate-based

**Qu'est-ce que c'est ?** L'authentification par certificat utilise des certificats X.509 pour identifier et authentifier les utilisateurs, sans nécessiter de mot de passe.

**Pourquoi l'utiliser ?**

- Sécurité renforcée (pas de mot de passe à gérer)
- Idéal pour l'automatisation et les comptes de service
- Support de l'authentification mutuelle
- Fonctionne en workgroup et domaine

**Prérequis :**

- Certificat client avec usage "Client Authentication"
- Certificat serveur avec usage "Server Authentication"
- Infrastructure PKI (Public Key Infrastructure) ou certificats auto-signés pour les tests

```powershell
# 1. Créer un certificat auto-signé pour test (PowerShell 5.1+)
$cert = New-SelfSignedCertificate -DnsName "Server01" `
    -CertStoreLocation "Cert:\LocalMachine\My" `
    -KeyUsage DigitalSignature,KeyEncipherment `
    -Type SSLServerAuthentication

# 2. Configurer WinRM pour utiliser HTTPS avec le certificat
New-Item -Path WSMan:\localhost\Listener -Transport HTTPS `
    -Address * -CertificateThumbprint $cert.Thumbprint -Force

# 3. Créer un certificat client
$clientCert = New-SelfSignedCertificate -DnsName "ClientUser" `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -KeyUsage DigitalSignature,KeyEncipherment `
    -Type Custom `
    -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")

# 4. Mapper le certificat à un compte utilisateur (sur le serveur)
New-Item -Path WSMan:\localhost\ClientCertificate `
    -Subject "CN=ClientUser" `
    -URI * `
    -Issuer $clientCert.Thumbprint `
    -Credential (Get-Credential) -Force

# 5. Se connecter avec le certificat
$sessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck
New-PSSession -ComputerName Server01 `
    -UseSSL `
    -CertificateThumbprint $clientCert.Thumbprint `
    -SessionOption $sessionOption
```

> [!info] Environnement de production Dans un environnement de production, utilisez des certificats émis par une autorité de certification (CA) de confiance plutôt que des certificats auto-signés.

**Configuration avancée - Mapping de certificats :**

```powershell
# Voir les mappings de certificats existants
Get-ChildItem WSMan:\localhost\ClientCertificate

# Supprimer un mapping
Remove-Item -Path "WSMan:\localhost\ClientCertificate\ClientCertificate_1234567890"

# Mapper un certificat à un utilisateur local
$certThumbprint = "A1B2C3D4E5F6..."
$username = "DOMAIN\User"
New-Item -Path WSMan:\localhost\ClientCertificate `
    -Subject $certThumbprint `
    -URI * `
    -Issuer $certThumbprint `
    -Credential $username `
    -Force
```

> [!tip] Avantage pour l'automatisation L'authentification par certificat est idéale pour les scripts automatisés car elle ne nécessite pas de stocker ou de transmettre des mots de passe.

---

## 🤝 TrustedHosts

**Qu'est-ce que c'est ?** TrustedHosts est une liste de machines considérées comme "de confiance" pour les connexions PowerShell Remoting lorsque l'authentification mutuelle n'est pas possible (par exemple, en workgroup ou lors de connexions par IP).

**Pourquoi est-ce nécessaire ?** En l'absence d'authentification mutuelle (comme avec Kerberos), PowerShell refuse par défaut les connexions pour des raisons de sécurité. TrustedHosts permet de contourner cette protection en déclarant explicitement quelles machines sont dignes de confiance.

### Configuration de base

```powershell
# Voir la configuration actuelle
Get-Item WSMan:\localhost\Client\TrustedHosts

# Ajouter une machine spécifique
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "Server01"

# Ajouter plusieurs machines (séparées par des virgules)
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "Server01,Server02,192.168.1.100"

# Ajouter à la liste existante (ne pas écraser)
$currentValue = (Get-Item WSMan:\localhost\Client\TrustedHosts).Value
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "$currentValue,Server03"

# Méthode alternative pour ajouter sans écraser
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "Server04" -Concatenate

# Autoriser toutes les machines (⚠️ DANGEREUX)
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*"

# Vider la liste
Clear-Item WSMan:\localhost\Client\TrustedHosts

# Utiliser des wildcards
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*.contoso.com"
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "192.168.1.*"
```

> [!warning] Risques de sécurité majeurs **TrustedHosts n'authentifie PAS le serveur distant !**
> 
> Problèmes de sécurité :
> 
> - Vulnérable aux attaques "Man-in-the-Middle"
> - Aucune vérification de l'identité du serveur
> - Un attaquant peut se faire passer pour le serveur
> - Vos credentials peuvent être interceptés
> 
> **L'utilisation de "*" est particulièrement dangereuse** car elle fait confiance à n'importe quelle machine sur le réseau.

### Alternatives plus sécurisées

**Option 1 : Utiliser SSL/TLS avec certificats**

```powershell
# Se connecter avec SSL (vérifie le certificat du serveur)
New-PSSession -ComputerName Server01 -UseSSL -Credential $cred

# Avec vérification stricte du certificat
$sessionOption = New-PSSessionOption
New-PSSession -ComputerName Server01 -UseSSL -SessionOption $sessionOption -Credential $cred
```

**Option 2 : Rejoindre un domaine Active Directory**

```powershell
# Dans un domaine, Kerberos fournit l'authentification mutuelle
# TrustedHosts n'est pas nécessaire
New-PSSession -ComputerName Server01 -Credential $cred
```

**Option 3 : Authentification par certificat**

```powershell
# Voir section Certificate-based ci-dessus
New-PSSession -ComputerName Server01 -CertificateThumbprint $thumbprint -UseSSL
```

### Bonnes pratiques

|❌ Mauvaise pratique|✅ Bonne pratique|
|---|---|
|`Set-Item ... -Value "*"`|Spécifier les machines exactes|
|Laisser TrustedHosts permanent|Configurer temporairement, nettoyer après|
|Utiliser en production|Utiliser uniquement en dev/test|
|Ignorer les avertissements|Comprendre les risques avant d'utiliser|

```powershell
# ✅ Exemple de configuration temporaire sécurisée
# 1. Sauvegarder la configuration actuelle
$originalTrustedHosts = (Get-Item WSMan:\localhost\Client\TrustedHosts).Value

# 2. Ajouter temporairement une machine
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "192.168.1.100" -Force

# 3. Effectuer votre travail
$session = New-PSSession -ComputerName 192.168.1.100 -Credential $cred
Invoke-Command -Session $session -ScriptBlock { Get-Service }
Remove-PSSession $session

# 4. Restaurer la configuration originale
Set-Item WSMan:\localhost\Client\TrustedHosts -Value $originalTrustedHosts -Force
```

> [!tip] Conseil pour les environnements workgroup Si vous devez utiliser TrustedHosts en workgroup, utilisez HTTPS avec des certificats pour ajouter une couche de sécurité :
> 
> ```powershell
> Set-Item WSMan:\localhost\Client\TrustedHosts -Value "Server01"
> New-PSSession -ComputerName Server01 -UseSSL -Credential $cred
> ```

**Débogage des problèmes TrustedHosts :**

```powershell
# Vérifier si TrustedHosts est le problème
# Erreur typique : "The WinRM client cannot process the request..."
# Mention de "trusted hosts list"

# Vérifier la configuration WinRM complète
Get-ChildItem WSMan:\localhost\Client

# Tester la connectivité de base
Test-WSMan -ComputerName Server01

# Forcer une nouvelle tentative de connexion
$session = New-PSSession -ComputerName Server01 -Credential $cred -ErrorAction Stop
```

---

## ⚙️ Configurations de session

**Qu'est-ce que c'est ?** Les configurations de session (aussi appelées "endpoints" ou "session configurations") définissent l'environnement PowerShell disponible lors d'une connexion distante. Elles permettent de contrôler quelles commandes, modules et fonctionnalités sont disponibles pour les utilisateurs distants.

**Pourquoi l'utiliser ?**

- Limiter les commandes disponibles (principe du moindre privilège)
- Créer des environnements personnalisés pour différents rôles
- Contrôler les ressources système (mémoire, CPU)
- Faciliter l'administration déléguée
- Implémenter JEA (Just Enough Administration)

### Voir les configurations existantes

```powershell
# Lister toutes les configurations de session
Get-PSSessionConfiguration

# Voir les détails d'une configuration spécifique
Get-PSSessionConfiguration -Name Microsoft.PowerShell | Format-List *

# Voir les permissions sur une configuration
Get-PSSessionConfiguration -Name Microsoft.PowerShell | 
    Select-Object -ExpandProperty Permission
```

**Configurations par défaut :**

|Configuration|Description|Usage|
|---|---|---|
|`Microsoft.PowerShell`|Configuration standard complète|Sessions PowerShell normales|
|`Microsoft.PowerShell.Workflow`|Pour les workflows PowerShell|Exécution de workflows|
|`Microsoft.PowerShell32`|PowerShell 32-bit|Compatibilité avec modules 32-bit|
|`PowerShell.6` / `PowerShell.7`|PowerShell Core|Sessions PowerShell Core|

### Créer une configuration de session personnalisée

**Méthode 1 : Configuration simple**

```powershell
# Créer une configuration qui limite les commandes disponibles
Register-PSSessionConfiguration -Name "LimitedSession" `
    -StartupScript "C:\Scripts\SessionStartup.ps1" `
    -RunAsCredential (Get-Credential) `
    -Force

# Contenu de SessionStartup.ps1
# Définir quelles commandes sont visibles
$visibleCmdlets = 'Get-Service', 'Get-Process', 'Get-EventLog'
$sessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateRestricted('RemoteServer')
$sessionState.Commands.Clear()
foreach ($cmdlet in $visibleCmdlets) {
    $sessionState.Commands.Add((Get-Command $cmdlet))
}
```

**Méthode 2 : Fichier de configuration de session (.pssc)**

```powershell
# 1. Créer un fichier de configuration
New-PSSessionConfigurationFile -Path "C:\Config\CustomEndpoint.pssc" `
    -SessionType RestrictedRemoteServer `
    -LanguageMode RestrictedLanguage `
    -ExecutionPolicy Restricted `
    -VisibleCmdlets 'Get-Service', 'Get-Process', 'Restart-Service' `
    -VisibleFunctions 'Get-MyCustomInfo' `
    -FunctionDefinitions @{
        Name = 'Get-MyCustomInfo'
        ScriptBlock = { Get-ComputerInfo | Select-Object CsName, OsVersion }
    }

# 2. Tester le fichier de configuration
Test-PSSessionConfigurationFile -Path "C:\Config\CustomEndpoint.pssc"

# 3. Enregistrer la configuration
Register-PSSessionConfiguration -Name "CustomEndpoint" `
    -Path "C:\Config\CustomEndpoint.pssc" `
    -Force

# 4. Redémarrer WinRM pour appliquer les changements
Restart-Service WinRM
```

### Options de configuration de session

**Contrôles d'accès :**

```powershell
# Définir qui peut utiliser cette configuration
$sddl = "O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;RM)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)"

Register-PSSessionConfiguration -Name "HelpDeskEndpoint" `
    -SecurityDescriptorSddl $sddl `
    -Force

# Alternative : utiliser ShowSecurityDescriptorUI pour une interface graphique
Register-PSSessionConfiguration -Name "HelpDeskEndpoint" `
    -ShowSecurityDescriptorUI `
    -Force
```

**Limites de ressources :**

```powershell
# Créer une configuration avec des limites de ressources
New-PSSessionConfigurationFile -Path "C:\Config\ResourceLimited.pssc" `
    -SessionType RestrictedRemoteServer `
    -MaximumReceivedDataSizePerCommandMB 50 `
    -MaximumReceivedObjectSizeMB 10 `
    -ScriptBlockLoggingEnabled $true

Register-PSSessionConfiguration -Name "ResourceLimited" `
    -Path "C:\Config\ResourceLimited.pssc" `
    -MaximumReceivedDataSizePerCommandMB 50 `
    -MaximumReceivedObjectSizeMB 10 `
    -Force
```

**Modes de langage :**

```powershell
# Différents niveaux de restriction

# FullLanguage : Aucune restriction (par défaut)
-LanguageMode FullLanguage

# RestrictedLanguage : Syntaxe de base uniquement
# - Pas de variables
# - Pas de boucles
# - Pas de scriptblocks
-LanguageMode RestrictedLanguage

# NoLanguage : Commandes uniquement (pas de scripting)
-LanguageMode NoLanguage

# ConstrainedLanguage : Syntaxe complète mais types restreints
# - Empêche l'accès à certaines API .NET dangereuses
-LanguageMode ConstrainedLanguage
```

### Utiliser une configuration personnalisée

```powershell
# Se connecter à une configuration spécifique
New-PSSession -ComputerName Server01 -ConfigurationName "CustomEndpoint"

# Avec Invoke-Command
Invoke-Command -ComputerName Server01 -ConfigurationName "CustomEndpoint" -ScriptBlock {
    Get-Service
}

# Entrer dans une session interactive
Enter-PSSession -ComputerName Server01 -ConfigurationName "CustomEndpoint"
```

### Gérer les configurations

```powershell
# Désactiver temporairement une configuration
Disable-PSSessionConfiguration -Name "CustomEndpoint"

# Réactiver une configuration
Enable-PSSessionConfiguration -Name "CustomEndpoint"

# Supprimer une configuration
Unregister-PSSessionConfiguration -Name "CustomEndpoint"

# Modifier une configuration existante
Set-PSSessionConfiguration -Name "CustomEndpoint" `
    -MaximumReceivedDataSizePerCommandMB 100 `
    -Force
```

### Exemple complet : Endpoint pour Help Desk

```powershell
# 1. Créer le fichier de configuration
$configPath = "C:\Config\HelpDesk.pssc"

New-PSSessionConfigurationFile -Path $configPath `
    -SessionType RestrictedRemoteServer `
    -LanguageMode ConstrainedLanguage `
    -ExecutionPolicy Restricted `
    -VisibleCmdlets @(
        'Get-Service',
        'Restart-Service',
        'Get-Process',
        'Stop-Process',
        'Get-EventLog',
        'Clear-EventLog'
    ) `
    -VisibleFunctions @('Reset-UserPassword', 'Unlock-UserAccount') `
    -FunctionDefinitions @(
        @{
            Name = 'Reset-UserPassword'
            ScriptBlock = {
                param([string]$Username)
                # Code pour réinitialiser le mot de passe
                Set-ADAccountPassword -Identity $Username -Reset
            }
        },
        @{
            Name = 'Unlock-UserAccount'
            ScriptBlock = {
                param([string]$Username)
                Unlock-ADAccount -Identity $Username
            }
        }
    ) `
    -ModulesToImport 'ActiveDirectory' `
    -ScriptBlockLoggingEnabled $true

# 2. Tester la configuration
Test-PSSessionConfigurationFile -Path $configPath -Verbose

# 3. Enregistrer la configuration
Register-PSSessionConfiguration -Name "HelpDeskEndpoint" `
    -Path $configPath `
    -RunAsCredential (Get-Credential "DOMAIN\HelpDeskServiceAccount") `
    -Force

# 4. Configurer les permissions (groupe Help Desk)
$helpDeskSID = (Get-ADGroup "HelpDesk").SID.Value
$sddl = "O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;$helpDeskSID)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)"

Set-PSSessionConfiguration -Name "HelpDeskEndpoint" `
    -SecurityDescriptorSddl $sddl `
    -Force

# 5. Utilisation par le Help Desk
New-PSSession -ComputerName DC01 -ConfigurationName "HelpDeskEndpoint"
```

> [!tip] Astuces pour les configurations de session
> 
> - Utilisez `-RunAsCredential` pour exécuter les commandes avec un compte de service spécifique
> - Activez toujours la journalisation (`-ScriptBlockLoggingEnabled $true`) pour l'audit
> - Testez soigneusement vos configurations avant de les déployer en production
> - Documentez les commandes disponibles pour les utilisateurs finaux

> [!warning] Piège courant Après avoir enregistré une configuration, vous devez parfois redémarrer le service WinRM pour que les changements soient pris en compte :
> 
> ```powershell
> Restart-Service WinRM
> ```

**Débogage des configurations :**

```powershell
# Voir le contenu d'un fichier .pssc
Get-Content "C:\Config\HelpDesk.pssc"

# Tester une session avec une configuration
$session = New-PSSession -ComputerName Server01 -ConfigurationName "CustomEndpoint"
Invoke-Command -Session $session -ScriptBlock {
    Get-Command  # Voir quelles commandes sont disponibles
}
```

---

## 🛡️ JEA (Just Enough Administration)

**Qu'est-ce que c'est ?** JEA (Just Enough Administration) est un framework de sécurité PowerShell qui permet de créer des endpoints d'administration avec des privilèges strictement limités. Il combine les configurations de session avec des contraintes de rôles pour implémenter le principe du moindre privilège.

**Pourquoi l'utiliser ?**

- **Sécurité renforcée** : Les utilisateurs n'ont accès qu'aux commandes strictement nécessaires
- **Administration déléguée** : Permettre à des non-administrateurs d'effectuer des tâches spécifiques
- **Audit complet** : Toutes les actions sont enregistrées
- **Conformité** : Répondre aux exigences de séparation des privilèges
- **Réduction des risques** : Limiter l'impact d'une compromission de compte

### Architecture JEA

JEA se compose de deux fichiers principaux :

1. **Session Configuration File (.pssc)** : Définit l'endpoint et ses paramètres généraux
2. **Role Capability File (.psrc)** : Définit les commandes disponibles pour un rôle spécifique

### Créer un endpoint JEA complet

**Étape 1 : Créer la structure de dossiers**

```powershell
# Créer la structure de dossiers recommandée
$modulePath = "C:\Program Files\WindowsPowerShell\Modules\JEA_Module"
New-Item -Path $modulePath -ItemType Directory -Force
New-Item -Path "$modulePath\RoleCapabilities" -ItemType Directory -Force

# Créer le manifeste de module
New-ModuleManifest -Path "$modulePath\JEA_Module.psd1" `
    -Description "Module JEA pour administration limitée"
```

**Étape 2 : Créer un Role Capability File**

```powershell
# Créer un role capability pour le redémarrage de services
$rcPath = "$modulePath\RoleCapabilities\ServiceManager.psrc"

New-PSRoleCapabilityFile -Path $rcPath `
    -VisibleCmdlets @(
        'Get-Service',
        @{
            Name = 'Restart-Service'
            Parameters = @{
                Name = 'Name'
                ValidateSet = 'Spooler', 'W3SVC', 'WinRM'
            }
        },
        @{
            Name = 'Stop-Service'
            Parameters = @{
                Name = 'Name'
                ValidateSet = 'Spooler', 'W3SVC'
            }
        }
    ) `
    -VisibleFunctions @('Get-ServiceStatus') `
    -FunctionDefinitions @{
        Name = 'Get-ServiceStatus'
        ScriptBlock = {
            param([string]$ServiceName)
            Get-Service -Name $ServiceName | 
                Select-Object Name, Status, StartType, DisplayName
        }
    }

# Contenu typique d'un fichier .psrc
Get-Content $rcPath
```

**Étape 3 : Créer le Session Configuration File**

```powershell
# Créer la configuration de session JEA
$scPath = "$modulePath\ServiceManagerEndpoint.pssc"

New-PSSessionConfigurationFile -Path $scPath `
    -SessionType RestrictedRemoteServer `
    -LanguageMode NoLanguage `
    -ExecutionPolicy Restricted `
    -RunAsVirtualAccount `
    -TranscriptDirectory "C:\ProgramData\JEA\Transcripts" `
    -RoleDefinitions @{
        'CONTOSO\ServiceManagers' = @{ RoleCapabilities = 'ServiceManager' }
        'CONTOSO\HelpDesk' = @{ RoleCapabilities = 'ServiceManager' }
    } `
    -ModulesToImport "$modulePath"

# Vérifier la configuration
Test-PSSessionConfigurationFile -Path $scPath -Verbose
```

**Étape 4 : Enregistrer l'endpoint JEA**

```powershell
# Enregistrer la configuration JEA
Register-PSSessionConfiguration -Name "ServiceManagement.JEA" `
    -Path $scPath `
    -Force

# Redémarrer WinRM
Restart-Service WinRM

# Vérifier l'enregistrement
Get-PSSessionConfiguration -Name "ServiceManagement.JEA"
```

**Étape 5 : Utiliser l'endpoint JEA**

```powershell
# Se connecter à l'endpoint JEA
$session = New-PSSession -ComputerName localhost -ConfigurationName "ServiceManagement.JEA"

# Voir les commandes disponibles (limitées)
Invoke-Command -Session $session -ScriptBlock {
    Get-Command
}

# Utiliser les commandes autorisées
Invoke-Command -Session $session -ScriptBlock {
    Get-Service -Name Spooler
    Restart-Service -Name Spooler
}

# Tenter une commande non autorisée (sera refusée)
Invoke-Command -Session $session -ScriptBlock {
    Get-Process  # ❌ Erreur : commande non disponible
}

Remove-PSSession $session
```

### Fonctionnalités avancées de JEA

**Run As Virtual Account**

```powershell
# Le Virtual Account est un compte local temporaire avec des privilèges admin
# Créé automatiquement pour chaque session JEA
New-PSSessionConfigurationFile -Path $scPath `
    -RunAsVirtualAccount `
    -RunAsVirtualAccountGroups 'Remote Desktop Users', 'Backup Operators'
```

> [!info] Avantage du Virtual Account
> 
> - Pas besoin de gérer des mots de passe de comptes de service
> - Compte créé et détruit automatiquement pour chaque session
> - Peut avoir des privilèges élevés sans risque de réutilisation
> - Identité unique pour l'audit

**Group Managed Service Account (gMSA)**

```powershell
# Alternative au Virtual Account : utiliser un gMSA
New-PSSessionConfigurationFile -Path $scPath `
    -GroupManagedServiceAccount "CONTOSO\JEA_ServiceAccount$"
```

**Paramètres ValidateSet et ValidatePattern**

```powershell
# Créer un role capability avec validation stricte
New-PSRoleCapabilityFile -Path $rcPath `
    -VisibleCmdlets @(
        @{
            Name = 'Restart-Service'
            Parameters = @{
                Name = 'Name'
                # Seuls ces services peuvent être redémarrés
                ValidateSet = 'Spooler', 'W3SVC', 'WinRM'
            }
        },
        @{
            Name = 'Get-EventLog'
            Parameters = @{
                Name = 'LogName'
                ValidateSet = 'Application', 'System'
            },
            @{
                Name = 'Newest'
                ValidateRange = 1, 100  # Maximum 100 événements
            }
        },
        @{
            Name = 'Remove-Item'
            Parameters = @{
                Name = 'Path'
                # Seulement les fichiers .tmp dans ce dossier
                ValidatePattern = '^C:\\Temp\\.*\.tmp
            }
        }
    )
```

**Fonctions personnalisées avec proxy**

```powershell
# Créer une fonction proxy qui encapsule une commande complexe
New-PSRoleCapabilityFile -Path $rcPath `
    -VisibleFunctions 'Reset-WebApplication' `
    -FunctionDefinitions @{
        Name = 'Reset-WebApplication'
        ScriptBlock = {
            param(
                [ValidateSet('WebApp1', 'WebApp2', 'WebApp3')]
                [string]$AppName
            )
            
            # Cette fonction peut exécuter plusieurs commandes
            # que l'utilisateur ne pourrait pas exécuter directement
            Stop-Service -Name "W3SVC"
            Remove-Item "C:\inetpub\wwwroot\$AppName\*.cache" -Force
            Clear-EventLog -LogName Application
            Start-Service -Name "W3SVC"
            
            Write-Output "Application $AppName réinitialisée avec succès"
        }
    }
```

### Exemple complet : JEA pour DNS Management

```powershell
# 1. Structure de dossiers
$modulePath = "C:\Program Files\WindowsPowerShell\Modules\DNSManagement"
New-Item -Path "$modulePath\RoleCapabilities" -ItemType Directory -Force

# 2. Créer le manifeste de module
New-ModuleManifest -Path "$modulePath\DNSManagement.psd1" `
    -Description "Module JEA pour gestion DNS"

# 3. Role Capability pour DNS Junior Admin
$rcPath = "$modulePath\RoleCapabilities\DNSJuniorAdmin.psrc"

New-PSRoleCapabilityFile -Path $rcPath `
    -ModulesToImport 'DnsServer' `
    -VisibleCmdlets @(
        'Get-DnsServerZone',
        'Get-DnsServerResourceRecord',
        @{
            Name = 'Add-DnsServerResourceRecordA'
            Parameters = @{
                Name = 'ZoneName'
                ValidateSet = 'contoso.com', 'internal.contoso.com'
            }
        },
        @{
            Name = 'Remove-DnsServerResourceRecord'
            Parameters = @{
                Name = 'ZoneName'
                ValidateSet = 'contoso.com', 'internal.contoso.com'
            },
            @{
                Name = 'RRType'
                ValidateSet = 'A', 'CNAME'  # Pas de suppression de MX ou NS
            }
        }
    ) `
    -VisibleFunctions 'Get-DNSReport' `
    -FunctionDefinitions @{
        Name = 'Get-DNSReport'
        ScriptBlock = {
            $zones = Get-DnsServerZone
            $report = foreach ($zone in $zones) {
                [PSCustomObject]@{
                    ZoneName = $zone.ZoneName
                    ZoneType = $zone.ZoneType
                    RecordCount = (Get-DnsServerResourceRecord -ZoneName $zone.ZoneName).Count
                }
            }
            $report | Format-Table -AutoSize
        }
    }

# 4. Session Configuration
$scPath = "$modulePath\DNSManagementEndpoint.pssc"

New-PSSessionConfigurationFile -Path $scPath `
    -SessionType RestrictedRemoteServer `
    -LanguageMode NoLanguage `
    -ExecutionPolicy Restricted `
    -RunAsVirtualAccount `
    -RunAsVirtualAccountGroups 'DnsAdmins' `
    -TranscriptDirectory "C:\ProgramData\JEA\Transcripts\DNS" `
    -RoleDefinitions @{
        'CONTOSO\DNS-JuniorAdmins' = @{ RoleCapabilities = 'DNSJuniorAdmin' }
    } `
    -ModulesToImport "$modulePath"

# 5. Enregistrer
Register-PSSessionConfiguration -Name "DNSManagement.JEA" `
    -Path $scPath `
    -Force

Restart-Service WinRM
```

### Logging et audit dans JEA

```powershell
# Configuration avec logging complet
New-PSSessionConfigurationFile -Path $scPath `
    -TranscriptDirectory "C:\ProgramData\JEA\Transcripts" `
    -SessionType RestrictedRemoteServer `
    -RunAsVirtualAccount

# Les transcripts sont créés automatiquement
# Emplacement typique : C:\ProgramData\JEA\Transcripts\[Endpoint]\[User]\[Timestamp].txt

# Voir les transcripts
Get-ChildItem "C:\ProgramData\JEA\Transcripts" -Recurse -Filter "*.txt" |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 10 FullName, LastWriteTime

# Lire un transcript
Get-Content "C:\ProgramData\JEA\Transcripts\ServiceManagement.JEA\john.doe\20241212_143022.txt"
```

**Event Logs pour JEA :**

```powershell
# Activer le logging détaillé dans Windows
# Les événements JEA sont dans : Applications and Services Logs > Microsoft > Windows > PowerShell

# Voir les événements JEA
Get-WinEvent -LogName 'Microsoft-Windows-PowerShell/Operational' |
    Where-Object { $_.Message -like "*JEA*" -or $_.Id -eq 4104 } |
    Select-Object TimeCreated, Id, Message |
    Format-Table -AutoSize

# Module logging (enregistre toutes les commandes exécutées)
Get-WinEvent -LogName 'Microsoft-Windows-PowerShell/Operational' -FilterXPath "*[System[(EventID=4103)]]" |
    Where-Object { $_.Message -like "*ServiceManagement*" }
```

### Tester et déboguer JEA

```powershell
# 1. Tester le fichier de configuration
Test-PSSessionConfigurationFile -Path $scPath -Verbose

# 2. Se connecter et voir les commandes disponibles
$session = New-PSSession -ComputerName localhost -ConfigurationName "ServiceManagement.JEA"
Invoke-Command -Session $session -ScriptBlock { Get-Command }

# 3. Voir sous quelle identité les commandes s'exécutent
Invoke-Command -Session $session -ScriptBlock { whoami }
# Retourne : "NT AUTHORITY\VIRTUAL ACCOUNT"

# 4. Tester les restrictions
Invoke-Command -Session $session -ScriptBlock {
    # Cette commande devrait fonctionner
    Get-Service -Name Spooler
    
    # Cette commande devrait échouer
    Get-Process
}

# 5. Voir les capacités du rôle
$session = New-PSSession -ComputerName localhost -ConfigurationName "ServiceManagement.JEA"
Invoke-Command -Session $session -ScriptBlock {
    (Get-Command).Count  # Nombre limité de commandes
    Get-Command | Select-Object Name, CommandType
}

Remove-PSSession $session
```

### Déploiement JEA à grande échelle

```powershell
# Script de déploiement pour plusieurs serveurs
$servers = 'Server01', 'Server02', 'Server03'
$modulePath = "\\FileServer\Share\JEA_Module"

foreach ($server in $servers) {
    # Copier le module JEA
    $destination = "\\$server\C$\Program Files\WindowsPowerShell\Modules\JEA_Module"
    Copy-Item -Path $modulePath -Destination $destination -Recurse -Force
    
    # Enregistrer l'endpoint via remoting
    Invoke-Command -ComputerName $server -ScriptBlock {
        $scPath = "C:\Program Files\WindowsPowerShell\Modules\JEA_Module\ServiceManagerEndpoint.pssc"
        Register-PSSessionConfiguration -Name "ServiceManagement.JEA" `
            -Path $scPath `
            -Force
        Restart-Service WinRM
    }
}

# Vérifier le déploiement
foreach ($server in $servers) {
    Invoke-Command -ComputerName $server -ScriptBlock {
        Get-PSSessionConfiguration -Name "ServiceManagement.JEA" | 
            Select-Object Name, PSComputerName, Permission
    }
}
```

> [!tip] Meilleures pratiques JEA
> 
> - Commencez avec des rôles très restrictifs et élargissez progressivement
> - Utilisez toujours `-RunAsVirtualAccount` pour isoler les privilèges
> - Activez la transcription pour l'audit complet
> - Testez exhaustivement avant le déploiement en production
> - Documentez clairement les commandes disponibles pour chaque rôle
> - Utilisez des groupes AD pour gérer l'accès aux endpoints JEA
> - Surveillez régulièrement les transcripts et les event logs

> [!warning] Erreurs courantes
> 
> - Oublier de redémarrer WinRM après l'enregistrement
> - Chemin de module incorrect dans le RoleDefinitions
> - Permissions NTFS insuffisantes sur le dossier du module
> - Oublier d'ajouter les groupes dans le RoleDefinitions

---

## 🔒 SSL/TLS

**Qu'est-ce que c'est ?** SSL/TLS (Secure Sockets Layer / Transport Layer Security) chiffre les communications PowerShell Remoting pour protéger les données en transit. Par défaut, WinRM utilise HTTP (non chiffré) sur le port 5985. HTTPS avec SSL/TLS utilise le port 5986.

**Pourquoi l'utiliser ?**

- **Chiffrement des données** : Protège les commandes et les résultats en transit
- **Protection des credentials** : Empêche l'interception des identifiants
- **Authentification du serveur** : Vérifie l'identité du serveur distant
- **Conformité** : Requis dans de nombreux environnements sécurisés
- **Protection contre les attaques Man-in-the-Middle**

### Configuration SSL/TLS pour WinRM

**Étape 1 : Obtenir un certificat SSL**

```powershell
# Option 1 : Créer un certificat auto-signé (test uniquement)
$cert = New-SelfSignedCertificate `
    -DnsName "Server01.contoso.com" `
    -CertStoreLocation "Cert:\LocalMachine\My" `
    -KeyUsage KeyEncipherment,DigitalSignature `
    -KeyAlgorithm RSA `
    -KeyLength 2048 `
    -Provider "Microsoft RSA SChannel Cryptographic Provider" `
    -HashAlgorithm SHA256 `
    -NotAfter (Get-Date).AddYears(3)

# Voir le certificat créé
Get-ChildItem Cert:\LocalMachine\My | Where-Object Subject -like "*Server01*"

# Option 2 : Demander un certificat à une CA d'entreprise (production)
# Via MMC (certlm.msc) ou via PowerShell
$template = "WebServer"  # Nom du template de certificat
Get-Certificate -Template $template -CertStoreLocation "Cert:\LocalMachine\My" `
    -SubjectName "CN=Server01.contoso.com" -DnsName "Server01.contoso.com"
```

> [!info] Exigences du certificat
> 
> - **Subject ou SAN** doit correspondre au nom d'hôte utilisé pour la connexion
> - **Enhanced Key Usage** doit inclure "Server Authentication" (OID 1.3.6.1.5.5.7.3.1)
> - Le certificat doit être dans le magasin "LocalMachine\My"
> - La clé privée doit être présente sur le serveur

**Étape 2 : Créer un listener HTTPS dans WinRM**

```powershell
# Récupérer le thumbprint du certificat
$cert = Get-ChildItem Cert:\LocalMachine\My | 
    Where-Object { $_.Subject -like "*Server01*" } |
    Select-Object -First 1

$thumbprint = $cert.Thumbprint

# Créer le listener HTTPS
New-Item -Path WSMan:\localhost\Listener -Transport HTTPS `
    -Address * `
    -CertificateThumbprint $thumbprint `
    -Force

# Vérifier le listener
Get-ChildItem WSMan:\localhost\Listener

# Voir les détails du listener HTTPS
Get-ChildItem WSMan:\localhost\Listener | 
    Where-Object { $_.Keys -contains "Transport=HTTPS" } |
    Get-ChildItem
```

**Étape 3 : Configurer le pare-feu**

```powershell
# Créer la règle de pare-feu pour HTTPS (port 5986)
New-NetFirewallRule -Name "WinRM-HTTPS-In-TCP" `
    -DisplayName "Windows Remote Management (HTTPS-In)" `
    -Description "Permet le trafic WinRM via HTTPS" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 5986 `
    -Action Allow `
    -Profile Domain,Private

# Vérifier la règle
Get-NetFirewallRule -Name "WinRM-HTTPS-In-TCP" | 
    Select-Object DisplayName, Enabled, Direction, Action
```

**Étape 4 : Se connecter via HTTPS**

```powershell
# Connexion avec SSL (validation complète du certificat)
New-PSSession -ComputerName Server01.contoso.com `
    -UseSSL `
    -Credential (Get-Credential)

# Si le certificat est auto-signé ou non approuvé, options de contournement
$sessionOption = New-PSSessionOption `
    -SkipCACheck `        # Ignore la validation de l'autorité de certification
    -SkipCNCheck `        # Ignore la correspondance du nom commun
    -SkipRevocationCheck  # Ignore la vérification de révocation

New-PSSession -ComputerName Server01 `
    -UseSSL `
    -SessionOption $sessionOption `
    -Credential (Get-Credential)

# Avec Invoke-Command
Invoke-Command -ComputerName Server01.contoso.com `
    -UseSSL `
    -Credential (Get-Credential) `
    -ScriptBlock { Get-Service }

# Connexion interactive
Enter-PSSession -ComputerName Server01.contoso.com `
    -UseSSL `
    -Credential (Get-Credential)
```

> [!warning] Options SkipCACheck, SkipCNCheck et SkipRevocationCheck Ces options désactivent des vérifications de sécurité importantes :
> 
> - **SkipCACheck** : Accepte les certificats auto-signés ou non approuvés
> - **SkipCNCheck** : Accepte les certificats dont le nom ne correspond pas au serveur
> - **SkipRevocationCheck** : N'vérifie pas si le certificat a été révoqué
> 
> **À utiliser uniquement** :
> 
> - En environnement de test
> - Pour des certificats auto-signés pendant la phase de développement
> - Jamais en production avec des données sensibles

### Configuration avancée SSL/TLS

**Configurer plusieurs listeners**

```powershell
# Listener HTTP (par défaut)
New-Item -Path WSMan:\localhost\Listener -Transport HTTP -Address * -Force

# Listener HTTPS sur une IP spécifique
New-Item -Path WSMan:\localhost\Listener -Transport HTTPS `
    -Address 192.168.1.100 `
    -CertificateThumbprint $thumbprint `
    -Force

# Listener HTTPS pour toutes les IPs
New-Item -Path WSMan:\localhost\Listener -Transport HTTPS `
    -Address * `
    -CertificateThumbprint $thumbprint `
    -Force

# Lister tous les listeners
Get-ChildItem WSMan:\localhost\Listener
```

**Forcer HTTPS uniquement (désactiver HTTP)**

```powershell
# Supprimer le listener HTTP
Get-ChildItem WSMan:\localhost\Listener | 
    Where-Object { $_.Keys -contains "Transport=HTTP" } |
    Remove-Item -Recurse -Force

# Désactiver le port HTTP dans le pare-feu
Disable-NetFirewallRule -Name "WINRM-HTTP-In-TCP-PUBLIC"
Disable-NetFirewallRule -Name "WINRM-HTTP-In-TCP"

# Vérifier qu'il ne reste que HTTPS
Get-ChildItem WSMan:\localhost\Listener
Test-NetConnection -ComputerName localhost -Port 5985  # Devrait échouer
Test-NetConnection -ComputerName localhost -Port 5986  # Devrait réussir
```

**Configuration des protocoles TLS**

```powershell
# Voir les protocoles TLS disponibles
[Net.ServicePointManager]::SecurityProtocol

# Forcer TLS 1.2 minimum (recommandé)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Désactiver les anciens protocoles via registre (nécessite redémarrage)
# Désactiver SSL 2.0
New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server' -Force
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server' -Name 'Enabled' -Value 0 -PropertyType 'DWord'

# Désactiver SSL 3.0
New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server' -Force
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server' -Name 'Enabled' -Value 0 -PropertyType 'DWord'

# Désactiver TLS 1.0
New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' -Force
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' -Name 'Enabled' -Value 0 -PropertyType 'DWord'

# Activer TLS 1.2
New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -Force
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -Name 'Enabled' -Value 1 -PropertyType 'DWord'

# Activer TLS 1.3 (Windows Server 2022+)
New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Server' -Force
New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Server' -Name 'Enabled' -Value 1 -PropertyType 'DWord'
```

### Renouvellement de certificats

```powershell
# 1. Obtenir le nouveau certificat (voir Étape 1)
$newCert = Get-ChildItem Cert:\LocalMachine\My | Where-Object Subject -like "*Server01*" | Select-Object -First 1

# 2. Mettre à jour le listener HTTPS
Get-ChildItem WSMan:\localhost\Listener | 
    Where-Object { $_.Keys -contains "Transport=HTTPS" } |
    ForEach-Object {
        $listenerPath = $_.PSPath
        Set-Item -Path "$listenerPath\CertificateThumbprint" -Value $newCert.Thumbprint -Force
    }

# 3. Redémarrer WinRM
Restart-Service WinRM

# 4. Vérifier la mise à jour
Get-ChildItem WSMan:\localhost\Listener | 
    Where-Object { $_.Keys -contains "Transport=HTTPS" } |
    Get-ChildItem | Where-Object Name -eq "CertificateThumbprint"
```

### Débogage SSL/TLS

```powershell
# Tester la connectivité HTTPS
Test-NetConnection -ComputerName Server01.contoso.com -Port 5986

# Tester WinRM sur HTTPS
Test-WSMan -ComputerName Server01.contoso.com -UseSSL

# Voir les détails de l'erreur
Test-WSMan -ComputerName Server01.contoso.com -UseSSL -ErrorAction Stop

# Vérifier le certificat utilisé
$listener = Get-ChildItem WSMan:\localhost\Listener | 
    Where-Object { $_.Keys -contains "Transport=HTTPS" }
$thumbprint = ($listener | Get-ChildItem | Where-Object Name -eq "CertificateThumbprint").Value
Get-ChildItem Cert:\LocalMachine\My\$thumbprint | Format-List *

# Tester depuis un client
$sessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck
New-PSSession -ComputerName Server01 -UseSSL -SessionOption $sessionOption -Credential $cred -Verbose
```

> [!tip] Script de configuration complète HTTPS
> 
> ```powershell
> # Script complet pour configurer WinRM sur HTTPS
> param(
>     [Parameter(Mandatory=$true)]
>     [string]$Hostname
> )
> 
> # 1. Créer le certificat
> $cert = New-SelfSignedCertificate -DnsName $Hostname `
>     -CertStoreLocation "Cert:\LocalMachine\My"
> 
> # 2. Créer le listener
> New-Item -Path WSMan:\localhost\Listener -Transport HTTPS `
>     -Address * -CertificateThumbprint $cert.Thumbprint -Force
> 
> # 3. Configurer le pare-feu
> New-NetFirewallRule -Name "WinRM-HTTPS-In" `
>     -DisplayName "WinRM HTTPS" `
>     -Direction Inbound `
>     -Protocol TCP `
>     -LocalPort 5986 `
>     -Action Allow
> 
> # 4. Redémarrer WinRM
> Restart-Service WinRM
> 
> Write-Host "Configuration HTTPS terminée" -ForegroundColor Green
> Write-Host "Certificat Thumbprint : $($cert.Thumbprint)"
> ```

---

## 🚪 Firewall et ports

**Qu'est-ce que c'est ?** Le pare-feu Windows contrôle l'accès réseau aux services. PowerShell Remoting nécessite que certains ports soient ouverts pour permettre les connexions WinRM.

**Ports utilisés par PowerShell Remoting :**

|Port|Protocole|Usage|Par défaut|
|---|---|---|---|
|**5985**|HTTP|WinRM non chiffré|✅ Activé|
|**5986**|HTTPS|WinRM chiffré avec SSL/TLS|❌ Désactivé|

### Configuration automatique du pare-feu

```powershell
# Enable-PSRemoting configure automatiquement le pare-feu
Enable-PSRemoting -Force

# Cette commande crée les règles de pare-feu nécessaires :
# - WinRM HTTP (port 5985) pour les profils Domaine et Privé
# - Ne configure PAS HTTPS par défaut

# Voir les règles créées
Get-NetFirewallRule -Name "WINRM-HTTP-In-TCP*" | 
    Select-Object DisplayName, Enabled, Profile, Direction, Action

# Résultat typique :
# DisplayName                                  Enabled Profile        Direction Action
# -----------                                  ------- -------        --------- ------
# Windows Remote Management (HTTP-In)          True    Domain,Private Inbound   Allow
# Windows Remote Management - Compatibility... True    Public         Inbound   Allow
```

### Gestion manuelle des règles de pare-feu

**Créer des règles personnalisées :**

```powershell
# Règle HTTP (port 5985) pour tous les profils
New-NetFirewallRule -Name "WinRM-HTTP-In-TCP-Custom" `
    -DisplayName "WinRM HTTP (Custom)" `
    -Description "Autoriser WinRM HTTP sur tous les profils" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 5985 `
    -Action Allow `
    -Profile Domain,Private,Public `
    -Enabled True

# Règle HTTPS (port 5986)
New-NetFirewallRule -Name "WinRM-HTTPS-In-TCP-Custom" `
    -DisplayName "WinRM HTTPS (Custom)" `
    -Description "Autoriser WinRM HTTPS" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 5986 `
    -Action Allow `
    -Profile Domain,Private `
    -Enabled True

# Règle avec restriction d'IP source (sécurité renforcée)
New-NetFirewallRule -Name "WinRM-HTTP-RestrictedIP" `
    -DisplayName "WinRM HTTP (Restricted)" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 5985 `
    -RemoteAddress 192.168.1.0/24,10.0.0.0/8 `
    -Action Allow `
    -Profile Domain,Private

# Règle pour un groupe de sécurité spécifique
$adminSID = (Get-LocalGroup "Administrateurs").SID.Value
New-NetFirewallRule -Name "WinRM-HTTP-AdminOnly" `
    -DisplayName "WinRM HTTP (Admins Only)" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 5985 `
    -RemoteUser $adminSID `
    -Action Allow
```

**Gérer les règles existantes :**

```powershell
# Lister toutes les règles WinRM
Get-NetFirewallRule | Where-Object DisplayName -like "*Remote Management*" |
    Select-Object Name, DisplayName, Enabled, Profile, Direction

# Activer une règle
Enable-NetFirewallRule -Name "WINRM-HTTP-In-TCP"

# Désactiver une règle
Disable-NetFirewallRule -Name "WINRM-HTTP-In-TCP-PUBLIC"

# Supprimer une règle
Remove-NetFirewallRule -Name "WinRM-HTTP-In-TCP-Custom"

# Modifier une règle existante
Set-NetFirewallRule -Name "WINRM-HTTP-In-TCP" `
    -RemoteAddress 192.168.1.0/24 `
    -Profile Domain,Private

# Désactiver WinRM pour le profil Public (sécurité)
Get-NetFirewallRule -Name "WINRM-HTTP-In-TCP-PUBLIC" | Disable-NetFirewallRule
```

**Vérifier les règles :**

```powershell
# Voir les détails d'une règle spécifique
Get-NetFirewallRule -Name "WINRM-HTTP-In-TCP" | Format-List *

# Voir les ports et protocoles
Get-NetFirewallRule -Name "WINRM-HTTP-In-TCP" | Get-NetFirewallPortFilter

# Voir les adresses IP autorisées
Get-NetFirewallRule -Name "WINRM-HTTP-In-TCP" | Get-NetFirewallAddressFilter

# Voir le profil réseau
Get-NetFirewallRule -Name "WINRM-HTTP-In-TCP" | Get-NetFirewallProfile
```

### Profils réseau du pare-feu

Windows utilise trois profils de pare-feu :

|Profil|Usage|Niveau de sécurité|
|---|---|---|
|**Domain**|Ordinateur connecté au domaine AD|Modéré|
|**Private**|Réseau domestique ou de travail|Modéré|
|**Public**|Réseaux publics (WiFi, hôtels)|Élevé (très restrictif)|

```powershell
# Voir le profil réseau actuel
Get-NetConnectionProfile | Select-Object Name, InterfaceAlias, NetworkCategory

# Changer le profil réseau
Set-NetConnectionProfile -InterfaceAlias "Ethernet" -NetworkCategory Private

# Configurer WinRM pour différents profils
# Domaine et Privé : autoriser
Enable-NetFirewallRule -Name "WINRM-HTTP-In-TCP" -Profile Domain,Private

# Public : bloquer (recommandé pour la sécurité)
Disable-NetFirewallRule -Name "WINRM-HTTP-In-TCP-PUBLIC"
```

> [!warning] Attention au profil Public Par défaut, `Enable-PSRemoting` active WinRM sur les profils Domaine et Privé uniquement. Si vous êtes sur un réseau Public, vous devrez soit :
> 
> - Changer le profil réseau en Privé
> - Forcer l'activation avec `-SkipNetworkProfileCheck`
> 
> **Ne jamais exposer WinRM sur un réseau Public sans SSL/TLS !**

### Tester la connectivité du pare-feu

```powershell
# Tester si le port est ouvert depuis un client
Test-NetConnection -ComputerName Server01 -Port 5985

# Résultat attendu :
# ComputerName     : Server01
# RemoteAddress    : 192.168.1.100
# RemotePort       : 5985
# TcpTestSucceeded : True

# Tester HTTPS
Test-NetConnection -ComputerName Server01 -Port 5986

# Test complet avec timeout
Test-NetConnection -ComputerName Server01 -Port 5985 -InformationLevel Detailed

# Tester WinRM (plus complet que Test-NetConnection)
Test-WSMan -ComputerName Server01

# Si le port est bloqué :
# TcpTestSucceeded : False
# → Vérifier le pare-feu

# Scanner les ports ouverts
1..65535 | ForEach-Object {
    $connection = Test-NetConnection -ComputerName Server01 -Port $_ -WarningAction SilentlyContinue
    if ($connection.TcpTestSucceeded) {
        Write-Host "Port $_ ouvert" -ForegroundColor Green
    }
} # ⚠️ Long, utiliser uniquement pour diagnostiquer
```

### Pare-feu Windows Defender avancé

**Créer des règles avec interface graphique :**

```powershell
# Ouvrir le pare-feu avancé
wf.msc

# Ou via PowerShell
Start-Process "wf.msc"
```

**Logs et monitoring :**

```powershell
# Activer le logging du pare-feu
Set-NetFirewallProfile -Profile Domain,Private,Public -LogAllowed True -LogBlocked True

# Chemin des logs par défaut
$logPath = "$env:SystemRoot\System32\LogFiles\Firewall\pfirewall.log"

# Voir les connexions bloquées
Get-Content $logPath | Select-String "DROP" | Select-Object -Last 20

# Voir les connexions autorisées sur le port 5985
Get-Content $logPath | Select-String "5985" | Select-String "ALLOW"

# Voir les événements du pare-feu dans l'Event Log
Get-WinEvent -LogName "Microsoft-Windows-Windows Firewall With Advanced Security/Firewall" -MaxEvents 50 |
    Where-Object { $_.Message -like "*5985*" -or $_.Message -like "*5986*" } |
    Format-Table TimeCreated, Id, Message -AutoSize
```

### Configuration de sécurité renforcée

```powershell
# 1. Désactiver HTTP, utiliser uniquement HTTPS
Disable-NetFirewallRule -Name "WINRM-HTTP-In-TCP"
Enable-NetFirewallRule -Name "WINRM-HTTPS-In-TCP"

# 2. Restreindre par IP source
$allowedIPs = "192.168.1.10","192.168.1.20","10.0.0.0/8"
Set-NetFirewallRule -Name "WINRM-HTTPS-In-TCP" -RemoteAddress $allowedIPs

# 3. Restreindre par groupe de sécurité
$adminSID = (Get-ADGroup "Domain Admins").SID.Value
Set-NetFirewallRule -Name "WINRM-HTTPS-In-TCP" -RemoteUser $adminSID

# 4. Limiter aux interfaces spécifiques
# Obtenir l'index de l'interface
Get-NetAdapter | Select-Object Name, InterfaceIndex

# Appliquer la règle à une interface spécifique
Set-NetFirewallRule -Name "WINRM-HTTPS-In-TCP" -InterfaceAlias "Ethernet"

# 5. Bloquer tout le reste
New-NetFirewallRule -Name "Block-All-WinRM-Ports" `
    -DisplayName "Bloquer autres ports WinRM" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 5985,5986 `
    -Action Block `
    -Priority 1000
```

> [!tip] Script de sécurisation du pare-feu
> 
> ```powershell
> # Configuration sécurisée du pare-feu pour WinRM
> 
> # 1. Supprimer les règles par défaut
> Remove-NetFirewallRule -Name "WINRM-HTTP-In-TCP*" -ErrorAction SilentlyContinue
> 
> # 2. Créer une règle HTTPS uniquement avec IPs restreintes
> $adminSubnets = "192.168.1.0/24", "10.0.0.0/8"
> New-NetFirewallRule -Name "WinRM-HTTPS-Secure" `
>     -DisplayName "WinRM HTTPS (Secured)" `
>     -Direction Inbound `
>     -Protocol TCP `
>     -LocalPort 5986 `
>     -RemoteAddress $adminSubnets `
>     -Action Allow `
>     -Profile Domain,Private `
>     -Enabled True
> 
> # 3. Activer le logging
> Set-NetFirewallProfile -All -LogBlocked True -LogAllowed True
> 
> # 4. Bloquer explicitement HTTP
> New-NetFirewallRule -Name "WinRM-HTTP-Block" `
>     -DisplayName "Bloquer WinRM HTTP" `
>     -Direction Inbound `
>     -Protocol TCP `
>     -LocalPort 5985 `
>     -Action Block
> 
> Write-Host "Pare-feu sécurisé configuré" -ForegroundColor Green
> ```

### Déploiement via GPO (Group Policy)

```powershell
# Les règles de pare-feu peuvent être déployées via GPO
# Chemin dans GPMC : Computer Configuration > Policies > Windows Settings > 
#                    Security Settings > Windows Firewall with Advanced Security

# Exporter une règle pour import GPO
$rule = Get-NetFirewallRule -Name "WINRM-HTTPS-In-TCP"
$rule | Export-Clixml -Path "C:\Export\WinRM-Rule.xml"

# Créer un script pour déploiement GPO
@"
# Script de déploiement WinRM via GPO
if (-not (Get-NetFirewallRule -Name "WinRM-HTTPS-In-TCP" -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -Name "WinRM-HTTPS-In-TCP" `
        -DisplayName "WinRM HTTPS" `
        -Direction Inbound `
        -Protocol TCP `
        -LocalPort 5986 `
        -Action Allow `
        -Profile Domain,Private
}
"@ | Out-File "C:\GPO-Scripts\Deploy-WinRM-Firewall.ps1"
```

> [!warning] Pièges courants
> 
> - **Oublier de redémarrer le service après modification** : `Restart-Service WinRM`
> - **Mauvais profil réseau** : Vérifier avec `Get-NetConnectionProfile`
> - **Conflit entre règles** : Les règles BLOCK ont priorité sur ALLOW
> - **Pare-feu tiers** : Certains antivirus ont leur propre pare-feu qui peut bloquer WinRM

---

## 📊 Logging et audit

**Qu'est-ce que c'est ?** Le logging et l'audit permettent de tracer toutes les activités PowerShell Remoting : qui s'est connecté, quelles commandes ont été exécutées, et quels résultats ont été obtenus. Essentiel pour la sécurité, la conformité et le dépannage.

**Pourquoi l'utiliser ?**

- **Sécurité** : Détecter les activités suspectes ou malveillantes
- **Conformité** : Répondre aux exigences réglementaires (SOX, HIPAA, PCI-DSS)
- **Dépannage** : Comprendre ce qui s'est passé lors d'un incident
- **Audit** : Tracer qui a fait quoi et quand
- **Forensics** : Investiguer les incidents de sécurité

### Types de logging PowerShell

|Type|Quoi|Où|Usage|
|---|---|---|---|
|**Transcription**|Capture complète de toutes les entrées/sorties|Fichiers texte|Audit détaillé|
|**Module Logging**|Enregistre l'exécution des commandes de modules|Event Log|Traçabilité des commandes|
|**Script Block Logging**|Enregistre le code exécuté|Event Log|Sécurité, détection malware|
|**WinRM Operational**|Événements de connexion/déconnexion|Event Log|Monitoring connexions|

### 1. Transcription PowerShell

**Configuration via GPO (recommandé) :**

```powershell
# Chemin GPO : Computer Configuration > Administrative Templates > 
#              Windows Components > Windows PowerShell > Turn on PowerShell Transcription

# Configuration manuelle via registre
$regPath = "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\Transcription"
New-Item -Path $regPath -Force

# Activer la transcription
Set-ItemProperty -Path $regPath -Name "EnableTranscripting" -Value 1

# Définir le chemin de sortie
Set-ItemProperty -Path $regPath -Name "OutputDirectory" -Value "C:\PSTranscripts"

# Inclure les en-têtes d'invocation (qui a exécuté quoi)
Set-ItemProperty -Path $regPath -Name "EnableInvocationHeader" -Value 1

# Créer le dossier de transcription
New-Item -Path "C:\PSTranscripts" -ItemType Directory -Force

# Définir les permissions NTFS (lecture pour admins uniquement)
$acl = Get-Acl "C:\PSTranscripts"
$acl.SetAccessRuleProtection($true, $false)
$adminRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "BUILTIN\Administrators", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
)
$acl.AddAccessRule($adminRule)
Set-Acl "C:\PSTranscripts" $acl
```

**Utilisation manuelle de la transcription :**

```powershell
# Démarrer une transcription manuellement
Start-Transcript -Path "C:\Logs\Session-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"

# Exécuter des commandes...
Get-Service
Get-Process

# Arrêter la transcription
Stop-Transcript

# Lire la transcription
Get-Content "C:\Logs\Session-*.txt" | Select-Object -Last 50
```

**Format d'une transcription :**

```
**********************
Windows PowerShell transcript start
Start time: 20241212143022
Username: CONTOSO\john.doe
RunAs User: CONTOSO\john.doe
Configuration Name: Microsoft.PowerShell
Machine: SERVER01 (Microsoft Windows NT 10.0.20348.0)
Host Application: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
Process ID: 12345
**********************

PS C:\> Get-Service -Name Spooler

Status   Name               DisplayName
------   ----               -----------
Running  Spooler            Print Spooler

PS C:\> Stop-Service -Name Spooler
PS C:\> Get-Service -Name Spooler

Status   Name               DisplayName
------   ----               -----------
Stopped  Spooler            Print Spooler

**********************
Windows PowerShell transcript end
End time: 20241212143156
**********************
```

### 2. Module Logging

**Configuration :**

```powershell
# Chemin GPO : Computer Configuration > Administrative Templates > 
#              Windows Components > Windows PowerShell > Turn on Module Logging

# Configuration manuelle via registre
$regPath = "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ModuleLogging"
New-Item -Path $regPath -Force
Set-ItemProperty -Path $regPath -Name "EnableModuleLogging" -Value 1

# Spécifier les modules à logger (ou * pour tous)
$regPath = "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames"
New-Item -Path $regPath -Force
Set-ItemProperty -Path $regPath -Name "*" -Value "*"  # Tous les modules

# Ou modules spécifiques
Set-ItemProperty -Path $regPath -Name "ActiveDirectory" -Value "ActiveDirectory"
Set-ItemProperty -Path $regPath -Name "Microsoft.PowerShell.Management" -Value "Microsoft.PowerShell.Management"
```

**Consulter les logs :**

```powershell
# Les événements de module logging sont dans l'Event Log
Get-WinEvent -LogName "Microsoft-Windows-PowerShell/Operational" -MaxEvents 100 |
    Where-Object { $_.Id -eq 4103 } |  # Event ID 4103 = Module Logging
    Select-Object TimeCreated, Message |
    Format-List

# Rechercher des commandes spécifiques
Get-WinEvent -LogName "Microsoft-Windows-PowerShell/Operational" |
    Where-Object { $_.Id -eq 4103 -and $_.Message -like "*Remove-Item*" } |
    Select-Object TimeCreated, Message

# Filtrer par utilisateur
Get-WinEvent -LogName "Microsoft-Windows-PowerShell/Operational" |
    Where-Object { $_.Id -eq 4103 -and $_.UserId -like "*john.doe*" }
```

### 3. Script Block Logging

**Configuration :**

```powershell
# Chemin GPO : Computer Configuration > Administrative Templates > 
#              Windows Components > Windows PowerShell > Turn on PowerShell Script Block Logging

# Configuration manuelle via registre
$regPath = "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
New-Item -Path $regPath -Force

# Activer le script block logging
Set-ItemProperty -Path $regPath -Name "EnableScriptBlockLogging" -Value 1

# Optionnel : Logger également les blocs non suspects
# (par défaut, seuls les blocs suspects sont loggés)
Set-ItemProperty -Path $regPath -Name "EnableScriptBlockInvocationLogging" -Value 1
```

**Consulter les logs :**

```powershell
# Event ID 4104 = Script Block Logging
Get-WinEvent -LogName "Microsoft-Windows-PowerShell/Operational" -MaxEvents 100 |
    Where-Object { $_.Id -eq 4104 } |
    Select-Object TimeCreated, Message |
    Format-List

# Rechercher des patterns suspects (obfuscation, encodage, etc.)
$suspiciousPatterns = @(
    "Invoke-Expression",
    "IEX",
    "Invoke-Command",
    "DownloadString",
    "DownloadFile",
    "FromBase64String",
    "EncodedCommand"
)

Get-WinEvent -LogName "Microsoft-Windows-PowerShell/Operational" |
    Where-Object { 
        $_.Id -eq 4104 -and 
        ($suspiciousPatterns | Where-Object { $_.Message -match $_ })
    } |
    Select-Object TimeCreated, Message |
    Format-List

# Extraire le code complet d'un script exécuté
$event = Get-WinEvent -LogName "Microsoft-Windows-PowerShell/Operational" |
    Where-Object { $_.Id -eq 4104 } |
    Select-Object -First 1

$event.Properties[2].Value  # Le code du script block
```

### 4. WinRM Operational Logs

**Consulter les logs WinRM :**

```powershell
# Événements de connexion WinRM
Get-WinEvent -LogName "Microsoft-Windows-WinRM/Operational" -MaxEvents 100 |
    Select-Object TimeCreated, Id, Message |
    Format-Table -AutoSize

# Event IDs importants pour WinRM :
# 6   : Connexion créée
# 8   : Authentification réussie
# 15  : Connexion fermée
# 142 : Échec d'authentification
# 193 : Erreur de connexion

# Voir toutes les connexions réussies
Get-WinEvent -LogName "Microsoft-Windows-WinRM/Operational" |
    Where-Object { $_.Id -eq 8 } |
    Select-Object TimeCreated, @{
        Name='User'
        Expression={$_.Properties[0].Value}
    }, @{
        Name='ClientIP'
        Expression={$_.Properties[1].Value}
    } |
    Format-Table -AutoSize

# Voir les échecs d'authentification
Get-WinEvent -LogName "Microsoft-Windows-WinRM/Operational" |
    Where-Object { $_.Id -eq 142 } |
    Select-Object TimeCreated, Message

# Statistiques de connexion par utilisateur
Get-WinEvent -LogName "Microsoft-Windows-WinRM/Operational" |
    Where-Object { $_.Id -eq 8 } |
    Group-Object { $_.Properties[0].Value } |
    Select-Object Count, Name |
    Sort-Object Count -Descending
```

### 5. Security Event Log

**Événements de sécurité liés à PowerShell Remoting :**

```powershell
# Event IDs de sécurité importants :
# 4624 : Connexion réussie (Type 3 = Network)
# 4625 : Échec de connexion
# 4648 : Connexion avec credentials explicites
# 4672 : Privilèges spéciaux assignés

# Voir les connexions distantes réussies
Get-WinEvent -LogName Security |
    Where-Object { 
        $_.Id -eq 4624 -and 
        $_.Properties[8].Value -eq 3  # Type 3 = Network logon
    } |
    Select-Object TimeCreated, @{
        Name='User'
        Expression={$_.Properties[5].Value}
    }, @{
        Name='SourceIP'
        Expression={$_.Properties[18].Value}
    } |
    Format-Table -AutoSize

# Voir les échecs d'authentification
Get-WinEvent -LogName Security |
    Where-Object { $_.Id -eq 4625 } |
    Select-Object TimeCreated, Message |
    Format-List
```

### Configuration centralisée du logging

**Forwarding des Event Logs (SIEM) :**

```powershell
# Configurer le forwarding vers un collecteur central
wecutil qc  # Quick Config pour le collecteur

# Sur le client, créer une souscription
$subscription = @"
<Subscription xmlns="http://schemas.microsoft.com/2006/03/windows/events/subscription">
    <SubscriptionId>PowerShell-Remoting-Logs</SubscriptionId>
    <SubscriptionType>SourceInitiated</SubscriptionType>
    <Description>Forward PowerShell Remoting events</Description>
    <Enabled>true</Enabled>
    <Uri>http://schemas.microsoft.com/wbem/wsman/1/windows/EventLog</Uri>
    <Query>
        <![CDATA[
        <QueryList>
            <Query Id="0">
                <Select Path="Microsoft-Windows-PowerShell/Operational">*[System[(EventID=4103 or EventID=4104)]]</Select>
                <Select Path="Microsoft-Windows-WinRM/Operational">*[System[(EventID=6 or EventID=8 or EventID=142)]]</Select>
            </Query>
        </QueryList>
        ]]>
    </Query>
</Subscription>
"@

$subscription | Out-File "C:\Subscriptions\PS-Remoting.xml"
wecutil cs "C:\Subscriptions\PS-Remoting.xml"
```

### Analyseet reporting

**Script d'analyse des logs :**

```powershell
# Script complet d'analyse de l'activité PowerShell Remoting
$startDate = (Get-Date).AddDays(-7)

# 1. Résumé des connexions
$connections = Get-WinEvent -LogName "Microsoft-Windows-WinRM/Operational" -FilterXPath "*[System[(EventID=8)]]" |
    Where-Object { $_.TimeCreated -gt $startDate } |
    Select-Object @{
        Name='User'
        Expression={$_.Properties[0].Value}
    }, @{
        Name='ClientIP'
        Expression={$_.Properties[1].Value}
    }, TimeCreated

Write-Host "`n=== Connexions des 7 derniers jours ===" -ForegroundColor Cyan
$connections | Group-Object User | Select-Object Count, Name | Format-Table

# 2. Commandes les plus exécutées
$commands = Get-WinEvent -LogName "Microsoft-Windows-PowerShell/Operational" |
    Where-Object { $_.Id -eq 4103 -and $_.TimeCreated -gt $startDate } |
    ForEach-Object {
        if ($_.Message -match "CommandLine=(.*)") {
            $matches[1]
        }
    }

Write-Host "`n=== Top 10 des commandes exécutées ===" -ForegroundColor Cyan
$commands | Group-Object | Sort-Object Count -Descending | Select-Object -First 10 Count, Name | Format-Table

# 3. Activité suspecte
$suspicious = Get-WinEvent -LogName "Microsoft-Windows-PowerShell/Operational" |
    Where-Object { 
        $_.Id -eq 4104 -and 
        $_.TimeCreated -gt $startDate -and
        ($_.Message -match "Invoke-Expression|IEX|DownloadString|FromBase64String")
    }

if ($suspicious) {
    Write-Host "`n⚠️  ALERTE : Activité suspecte détectée !" -ForegroundColor Red
    $suspicious | Select-Object TimeCreated, Message | Format-List
} else {
    Write-Host "`n✅ Aucune activité suspecte détectée" -ForegroundColor Green
}

# 4. Échecs d'authentification
$failures = Get-WinEvent -LogName "Microsoft-Windows-WinRM/Operational" |
    Where-Object { $_.Id -eq 142 -and $_.TimeCreated -gt $startDate }

Write-Host "`n=== Échecs d'authentification ===" -ForegroundColor Cyan
Write-Host "Total : $($failures.Count)"
if ($failures.Count -gt 0) {
    $failures | Select-Object TimeCreated, Message | Format-List | Select-Object -First 5
}
```

### Bonnes pratiques de logging

```powershell
# Configuration complète recommandée pour la production

# 1. Activer tous les types de logging
$loggingConfig = @{
    Transcription = @{
        Path = "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\Transcription"
        Settings = @{
            EnableTranscripting = 1
            OutputDirectory = "\\FileServer\PSLogs\Transcripts"
            EnableInvocationHeader = 1
        }
    }
    ModuleLogging = @{
        Path = "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ModuleLogging"
        Settings = @{
            EnableModuleLogging = 1
        }
    }
    ScriptBlockLogging = @{
        Path = "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
        Settings = @{
            EnableScriptBlockLogging = 1
            EnableScriptBlockInvocationLogging = 1
        }
    }
}

foreach ($type in $loggingConfig.Keys) {
    $config = $loggingConfig[$type]
    New-Item -Path $config.Path -Force | Out-Null
    foreach ($setting in $config.Settings.Keys) {
        Set-ItemProperty -Path $config.Path -Name $setting -Value $config.Settings[$setting]
    }
}

# 2. Augmenter la taille des Event Logs
$logs = @(
    "Microsoft-Windows-PowerShell/Operational",
    "Microsoft-Windows-WinRM/Operational",
    "Security"
)

foreach ($log in $logs) {
    $logObj = Get-WinEvent -ListLog $log
    $logObj.MaximumSizeInBytes = 512MB  # 512 Mo
    $logObj.SaveChanges()
}

# 3. Configurer la rétention
wevtutil sl "Microsoft-Windows-PowerShell/Operational" /rt:false /ab:true

Write-Host "✅ Configuration de logging complétée" -ForegroundColor Green
```

> [!tip] Recommandations de sécurité
> 
> - **Centraliser les logs** sur un serveur dédié pour éviter leur altération
> - **Protéger les transcripts** avec des permissions NTFS restrictives
> - **Archiver régulièrement** les logs pour éviter la perte de données
> - **Monitorer activement** les patterns suspects
> - **Mettre en place des alertes** pour les événements critiques (échecs d'auth multiples, commandes suspectes)
> - **Réviser régulièrement** les logs pour détecter les anomalies

> [!warning] Attention à la confidentialité Les logs peuvent contenir des informations sensibles :
> 
> - Mots de passe en clair si passés en paramètres
> - Données confidentielles manipulées
> - Tokens d'authentification
> 
> **Solutions** :
> 
> - Former les utilisateurs à ne jamais passer de credentials en clair
> - Utiliser des méthodes sécurisées (`Get-Credential`, `ConvertTo-SecureString`)
> - Protéger l'accès aux logs
> - Respecter les réglementations RGPD/GDPR
