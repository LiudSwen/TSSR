# Plan détaillé PowerShell - Parties 7 à 10

---

## 📘 PARTIE 7 : Utilisateurs et réseau

**Fichier Obsidian suggéré :** `07-utilisateurs-reseau.md`

### 1. Utilisateurs et groupes locaux

#### 1.1 Get-LocalUser, New-LocalUser, Set-LocalUser

- **Get-LocalUser**
    - Liste de tous les utilisateurs locaux
    - Filtrage par nom (`-Name`)
    - Filtrage par SID (`-SID`)
    - Propriétés des objets utilisateur
        - Name, Enabled, Description
        - PasswordRequired, PasswordExpires
        - LastLogon, AccountExpires
        - SID (Security Identifier)
        - UserMayChangePassword
        - PasswordChangeableDate, PasswordLastSet
    - Wildcards dans les noms
    - Identification d'utilisateurs désactivés
    - Compte intégré (Administrator, Guest)
- **New-LocalUser**
    - Création de nouveaux utilisateurs locaux
    - Paramètres obligatoires
        - `-Name` (nom d'utilisateur)
        - `-Password` (SecureString)
    - Paramètres optionnels
        - `-Description` pour description
        - `-FullName` pour nom complet
        - `-AccountExpires` pour expiration
        - `-AccountNeverExpires` pour compte permanent
        - `-PasswordNeverExpires` pour mot de passe permanent
        - `-UserMayNotChangePassword` pour verrouiller mot de passe
    - `-NoPassword` pour compte sans mot de passe (déconseillé)
    - Création de SecureString pour mot de passe
        - `Read-Host -AsSecureString`
        - `ConvertTo-SecureString`
    - Droits administrateur requis
    - Bonnes pratiques de sécurité
- **Set-LocalUser**
    - Modification d'utilisateurs existants
    - `-Name` pour identifier utilisateur
    - Modification de propriétés
        - `-Password` pour changer mot de passe
        - `-Description` pour mettre à jour
        - `-FullName` pour nom complet
        - `-PasswordNeverExpires` ($true/$false)
        - `-UserMayChangePassword` ($true/$false)
        - `-AccountExpires` pour date d'expiration
    - `-PasswordNeverExpires $false` pour forcer expiration
    - Gestion des comptes en masse
    - Scripts de mise à jour

#### 1.2 Remove-LocalUser, Enable-LocalUser, Disable-LocalUser

- **Remove-LocalUser**
    - Suppression d'utilisateurs locaux
    - `-Name` ou `-SID` pour identifier
    - `-Confirm` pour confirmation
    - `-WhatIf` pour simulation
    - Précautions avant suppression
    - Impossible de supprimer utilisateurs intégrés
    - Impact sur fichiers et dossiers personnels
    - Sauvegarde avant suppression
- **Enable-LocalUser**
    - Activation de comptes désactivés
    - `-Name` ou `-SID`
    - Utilisation après suspension temporaire
    - Vérification de l'état avant/après
    - Logs d'activation
- **Disable-LocalUser**
    - Désactivation de comptes
    - Alternative à la suppression
    - Préservation des données et permissions
    - Utilisé pour départs temporaires
    - Comptes de service inactifs
    - Sécurité : désactiver plutôt que supprimer
    - Audit des comptes désactivés

#### 1.3 Get-LocalGroup, New-LocalGroup

- **Get-LocalGroup**
    - Liste des groupes locaux
    - Filtrage par `-Name` ou `-SID`
    - Propriétés des groupes
        - Name, Description, SID
        - ObjectClass, PrincipalSource
    - Groupes intégrés Windows
        - Administrators
        - Users
        - Guests
        - Power Users
        - Remote Desktop Users
        - Backup Operators
    - Identification de groupes personnalisés
    - Wildcards dans recherche
- **New-LocalGroup**
    - Création de nouveaux groupes locaux
    - `-Name` (obligatoire)
    - `-Description` pour documenter usage
    - Cas d'usage
        - Groupes départementaux
        - Groupes d'application
        - Groupes de permissions spécifiques
    - Droits administrateur nécessaires
    - Nommage cohérent et standardisé

#### 1.4 Add-LocalGroupMember, Remove-LocalGroupMember

- **Add-LocalGroupMember**
    - Ajout de membres à un groupe
    - `-Group` pour spécifier groupe cible
    - `-Member` pour utilisateur/groupe à ajouter
        - Peut être nom ou SID
        - Peut être utilisateur local ou domaine
        - Peut être autre groupe (imbrication)
    - Ajout de multiples membres
    - `-Confirm` pour confirmation
    - Vérification de l'appartenance existante
    - Gestion des permissions par groupe
    - Scripts d'onboarding
- **Remove-LocalGroupMember**
    - Retrait de membres d'un groupe
    - Mêmes paramètres que Add
    - `-Confirm` pour sécurité
    - Retrait de multiples membres
    - Scripts d'offboarding
    - Audit de permissions
- **Get-LocalGroupMember**
    - Liste des membres d'un groupe
    - `-Group` pour spécifier
    - Propriétés des membres
        - Name, PrincipalSource, ObjectClass
        - SID
    - Identification des membres domaine vs locaux
    - Audit d'appartenance
    - Rapports de sécurité

---

### 2. Configuration réseau

#### 2.1 Get-NetIPAddress, Get-NetIPConfiguration

- **Get-NetIPAddress**
    - Liste toutes les adresses IP configurées
    - Filtrage par interface (`-InterfaceAlias` ou `-InterfaceIndex`)
    - Filtrage par famille d'adresses (`-AddressFamily`)
        - IPv4
        - IPv6
    - Propriétés des adresses
        - IPAddress, InterfaceAlias, InterfaceIndex
        - AddressFamily, Type (Unicast, Anycast)
        - PrefixLength (masque en notation CIDR)
        - PrefixOrigin (Manual, DHCP, WellKnown)
        - SuffixOrigin
        - AddressState (Preferred, Tentative, etc.)
        - ValidLifetime, PreferredLifetime
    - Filtrage des adresses
        - Loopback vs physiques
        - Statiques vs DHCP
    - Identification de configuration
- **Get-NetIPConfiguration**
    - Vue d'ensemble de la configuration réseau
    - Informations par interface
    - Inclut
        - Adresses IP
        - Passerelles par défaut
        - Serveurs DNS
        - Suffixes DNS
    - Paramètre `-Detailed` pour infos complètes
    - `-InterfaceAlias` pour interface spécifique
    - `-All` pour toutes les interfaces (incluant désactivées)
    - Équivalent moderne de `ipconfig`
    - Diagnostic rapide de connectivité
    - Export de configuration

#### 2.2 Get-NetAdapter, Set-NetAdapter

- **Get-NetAdapter**
    - Liste des adaptateurs réseau
    - Propriétés principales
        - Name (alias d'interface)
        - InterfaceDescription
        - Status (Up, Down, Disconnected)
        - MacAddress
        - LinkSpeed (vitesse de connexion)
        - MediaType
        - PhysicalMediaType
    - Filtrage par état (`-Physical` pour adaptateurs physiques)
    - `-Name` avec wildcards
    - Identification d'adaptateurs
        - Ethernet
        - Wi-Fi
        - Virtuels (Hyper-V, VPN)
        - Bluetooth
    - Statistiques d'interface (`Get-NetAdapterStatistics`)
- **Set-NetAdapter**
    - Modification de configuration d'adaptateur
    - `-Name` pour identifier
    - Paramètres modifiables
        - `-MACAddress` (certains adaptateurs)
    - Renommage avec `Rename-NetAdapter`
    - Activation/désactivation
        - `Enable-NetAdapter`
        - `Disable-NetAdapter`
        - `-Confirm` recommandé
    - Redémarrage avec `Restart-NetAdapter`
    - Impact sur connectivité
    - Droits administrateur requis
    - Tests après modification

#### 2.3 New-NetIPAddress, Remove-NetIPAddress

- **New-NetIPAddress**
    - Configuration d'adresse IP statique
    - Paramètres obligatoires
        - `-InterfaceAlias` ou `-InterfaceIndex`
        - `-IPAddress`
        - `-PrefixLength` (masque CIDR, ex: 24 pour /24)
    - Paramètres optionnels
        - `-DefaultGateway` pour passerelle
        - `-AddressFamily` (IPv4 ou IPv6)
        - `-Type` (Unicast par défaut)
    - Configuration complète réseau
    - Remplacement de DHCP par statique
    - Adresses multiples sur même interface
    - Validation de configuration
    - Tests de connectivité après
- **Remove-NetIPAddress**
    - Suppression d'adresse IP
    - `-IPAddress` pour spécifier
    - `-InterfaceAlias` pour interface
    - `-Confirm` pour sécurité
    - Retour à DHCP après suppression
    - Précautions pour connexions distantes
    - Impact sur services réseau
- **Set-NetIPAddress**
    - Modification d'adresse existante
    - Changement de propriétés
- **Configuration DNS**
    - `Set-DnsClientServerAddress` pour serveurs DNS
    - `-InterfaceAlias` et `-ServerAddresses`
    - Configuration primaire et secondaire
    - Reset avec `-ResetServerAddresses`

---

### 3. Tests et diagnostics réseau

#### 3.1 Test-Connection

- Équivalent moderne de `ping`
- Syntaxe de base
    - `-ComputerName` ou `-TargetName` (PS 6+)
    - Accepte IP ou nom DNS
- Paramètres principaux
    - `-Count` pour nombre de pings (défaut 4)
    - `-Quiet` pour retour booléen simple
    - `-Source` pour machine source (remoting)
    - `-BufferSize` pour taille du paquet
    - `-TimeoutSeconds` pour timeout
- Propriétés retournées
    - Source, Destination, IPV4Address
    - Status (Success/TimedOut)
    - ResponseTime (latence en ms)
    - Reply (détails complets)
- Tests de connectivité de base
- Vérification de machines avant actions
- Surveillance de disponibilité
- Mesure de latence réseau
- Tests en boucle pour monitoring
- Différences PowerShell 5.1 vs 7+

#### 3.2 Test-NetConnection

- Cmdlet avancée de diagnostic (Windows 8.1+/Server 2012 R2+)
- Tests multiples en une commande
- Paramètres principaux
    - `-ComputerName` pour cible
    - `-Port` pour test de port TCP spécifique
    - `-CommonTCPPort` (SMB, HTTP, RDP, WINRM)
    - `-InformationLevel` (Quiet, Detailed)
    - `-TraceRoute` pour traceroute
    - `-Hops` pour nombre de sauts max
    - `-DiagnoseRouting` pour diagnostics routage
- Propriétés retournées
    - ComputerName, RemoteAddress
    - PingSucceeded (test ICMP)
    - TcpTestSucceeded (si port testé)
    - SourceAddress
    - InterfaceAlias
    - TraceRoute (si demandé)
- Tests de ports courants
    - Port 80 (HTTP)
    - Port 443 (HTTPS)
    - Port 3389 (RDP)
    - Port 445 (SMB)
    - Port 5985/5986 (WinRM)
- Diagnostic de firewall
- Vérification de services accessibles
- Alternative graphique à telnet
- Troubleshooting de connectivité
- Exemples de tests complets

#### 3.3 Resolve-DnsName

- Résolution DNS (équivalent de `nslookup`)
- Syntaxe de base
    - `-Name` pour nom à résoudre
    - `-Type` pour type d'enregistrement
- Types d'enregistrements DNS
    - A (IPv4)
    - AAAA (IPv6)
    - CNAME (alias)
    - MX (serveurs mail)
    - NS (serveurs de noms)
    - PTR (résolution inverse)
    - TXT (texte, SPF, DKIM)
    - SOA (Start of Authority)
    - SRV (services)
- Paramètres avancés
    - `-Server` pour serveur DNS spécifique
    - `-DnsOnly` pour ignorer cache et hosts
    - `-NoHostsFile` pour ignorer fichier hosts
    - `-CacheOnly` pour utiliser seulement cache
    - `-QuickTimeout` pour timeout rapide
- Propriétés retournées
    - Name, Type, TTL
    - Section (Answer, Authority, Additional)
    - IPAddress, NameHost (selon type)
- Cache DNS local
    - `Get-DnsClientCache`
    - `Clear-DnsClientCache` (flush DNS)
- Résolution inverse (IP vers nom)
- Vérification de configuration DNS
- Diagnostic de problèmes de résolution
- Tests de propagation DNS
- Validation d'enregistrements DNS
- Exemples pratiques de troubleshooting

---

## 📘 PARTIE 8 : WMI et informations système

**Fichier Obsidian suggéré :** `08-wmi-informations.md`

### 1. Introduction WMI/CIM

#### 1.1 Différence Get-WmiObject vs Get-CimInstance

- **WMI (Windows Management Instrumentation)**
    - Ancienne technologie Windows
    - Protocole DCOM
    - Get-WmiObject (cmdlet legacy)
    - Disponible Windows PowerShell uniquement
    - Objets .NET retournés
    - Méthodes via `.InvokeMethod()`
- **CIM (Common Information Model)**
    - Standard multiplateforme (DMTF)
    - Protocole WS-MAN (plus moderne)
    - Get-CimInstance (cmdlet recommandée)
    - Compatible PowerShell Core/7+
    - Objets CIM retournés
    - Meilleure gestion mémoire
    - Support sessions CIM
- **Différences clés**
    - Performance (CIM plus rapide)
    - Remoting (CIM utilise WinRM)
    - Compatibilité (CIM cross-platform)
    - Syntaxe similaire mais objets différents
- **Migration WMI vers CIM**
    - Get-WmiObject → Get-CimInstance
    - Invoke-WmiMethod → Invoke-CimMethod
    - Set-WmiInstance → Set-CimInstance
    - Remove-WmiObject → Remove-CimInstance
- **Recommandation**
    - Toujours utiliser CIM pour nouveau code
    - WMI pour compatibilité anciennes versions

#### 1.2 Classes WMI courantes

- **Structure namespace WMI**
    - Root\CIMv2 (namespace principal)
    - Root\SecurityCenter2 (antivirus, firewall)
    - Root\Microsoft\Windows (fonctionnalités Windows)
    - Root\WMI (pilotes et matériel bas niveau)
- **Découverte des classes**
    - `Get-CimClass` pour lister classes
    - `-ClassName` avec wildcards
    - `-Namespace` pour namespace spécifique
    - Filtrage par nom : `Get-CimClass -ClassName Win32_*`
- **Classes système essentielles**
    - Win32_ComputerSystem (infos système)
    - Win32_OperatingSystem (OS)
    - Win32_Processor (CPU)
    - Win32_LogicalDisk (disques)
    - Win32_NetworkAdapter (réseau)
    - Win32_Service (services)
    - Win32_Process (processus)
    - Win32_Product (logiciels installés)
    - Win32_BIOS (BIOS/UEFI)
    - Win32_PhysicalMemory (mémoire RAM)
- **Exploration de classes**
    - Propriétés avec `Get-CimInstance | Get-Member`
    - Méthodes disponibles
    - Qualifiers et métadonnées
- **Documentation classes**
    - Microsoft Docs pour référence
    - MOF (Managed Object Format)
- **Requêtes WQL**
    - WQL (WMI Query Language, similaire SQL)
    - `Get-CimInstance -Query "SELECT * FROM Win32_Service WHERE State='Running'"`
    - Filtrage côté serveur pour performance

#### 1.3 Invoke-CimMethod

- Exécution de méthodes sur instances CIM
- Syntaxe de base
    - `-MethodName` pour méthode à appeler
    - `-Arguments` pour paramètres (hashtable)
    - `-InputObject` pour instance cible
    - Ou `-ClassName` avec `-CimSession`
- **Méthodes courantes**
    - **Win32_Service**
        - StartService() : démarrer service
        - StopService() : arrêter service
        - PauseService() : mettre en pause
        - ResumeService() : reprendre
        - ChangeStartMode() : modifier type démarrage
    - **Win32_Process**
        - Create() : créer nouveau processus
        - Terminate() : terminer processus
        - GetOwner() : obtenir propriétaire
    - **Win32_OperatingSystem**
        - Reboot() : redémarrer système
        - Shutdown() : arrêter système
        - Win32Shutdown() : options avancées
    - **Win32_Product**
        - Install() : installer logiciel
        - Uninstall() : désinstaller
        - Upgrade() : mettre à jour
- Valeurs de retour
    - ReturnValue (code de retour)
    - 0 = succès généralement
    - Autres codes selon méthode
- Paramètres de méthodes
    - Types de paramètres requis
    - Hashtable pour passage multiple
- Exemples pratiques
    - Redémarrage de services
    - Création de processus
    - Désinstallation de logiciels
- Gestion d'erreurs et codes retour
- Droits nécessaires selon méthode

---

### 2. Récupération d'informations système

#### 2.1 Win32_ComputerSystem

- Informations générales sur l'ordinateur
- Propriétés principales
    - **Identification**
        - Name (nom NetBIOS)
        - DNSHostName (nom DNS complet)
        - Domain (domaine ou workgroup)
        - Workgroup
        - PartOfDomain (booléen)
    - **Matériel**
        - Manufacturer (fabricant)
        - Model (modèle)
        - SystemType (x64, x86, ARM)
        - PCSystemType (Desktop, Laptop, Tablet, etc.)
        - SystemFamily
    - **Mémoire**
        - TotalPhysicalMemory (RAM totale en octets)
        - Conversion en GB : `[math]::Round($mem/1GB, 2)`
    - **Processeurs**
        - NumberOfProcessors (sockets physiques)
        - NumberOfLogicalProcessors (cœurs logiques)
    - **Utilisateur**
        - UserName (utilisateur connecté)
        - PrimaryOwnerName
    - **État**
        - Status
        - PowerState
        - BootupState
- Utilisation typique
    - Inventaire matériel
    - Identification de machines
    - Vérification d'appartenance domaine
    - Rapports système
- Exemples de requêtes courantes

#### 2.2 Win32_OperatingSystem

- Informations sur le système d'exploitation
- Propriétés principales
    - **Version et édition**
        - Caption (nom complet : "Microsoft Windows 11 Pro")
        - Version (numéro version : "10.0.22000")
        - BuildNumber (build)
        - OSArchitecture (32-bit ou 64-bit)
        - OperatingSystemSKU
        - ProductType (1=Workstation, 2=Domain Controller, 3=Server)
    - **Installation**
        - InstallDate (date installation)
        - LastBootUpTime (dernier démarrage)
        - LocalDateTime (heure actuelle système)
        - Uptime (calcul : LocalDateTime - LastBootUpTime)
    - **Localisation**
        - CountryCode
        - Locale
        - OSLanguage
        - MUILanguages (langues d'interface)
    - **Mémoire**
        - TotalVisibleMemorySize (RAM visible en KB)
        - FreePhysicalMemory (RAM libre en KB)
        - TotalVirtualMemorySize (mémoire virtuelle)
        - FreeVirtualMemory
        - Calculs d'utilisation mémoire
    - **Système**
        - SystemDirectory (C:\Windows\system32)
        - WindowsDirectory (C:\Windows)
        - SystemDrive (C:)
        - BootDevice
    - **État**
        - Status
        - EncryptionLevel
        - ServicePackMajorVersion
        - ServicePackMinorVersion
    - **Organisation**
        - Organization
        - RegisteredUser
        - SerialNumber (clé produit)
- Calculs utiles
    - Uptime en jours/heures
    - Pourcentage mémoire utilisée
    - Date dernière installation
- Surveillance système
- Inventaire de parc
- Rapports de conformité

#### 2.3 Win32_LogicalDisk

- Informations sur les disques logiques
- Filtrage recommandé : `-Filter "DriveType=3"` (disques fixes)
- Types de disques (DriveType)
    - 0 : Unknown
    - 1 : No Root Directory
    - 2 : Removable Disk
    - 3 : Local Disk (disques durs)
    - 4 : Network Drive
    - 5 : Compact Disc
    - 6 : RAM Disk
- Propriétés principales
    - **Identification**
        - DeviceID (lettre de lecteur : "C:")
        - VolumeName (nom du volume)
        - VolumeSerialNumber
        - Description
    - **Capacité**
        - Size (taille totale en octets)
        - FreeSpace (espace libre en octets)
        - Conversion en GB/TB : `[math]::Round($size/1GB, 2)`
        - Calcul espace utilisé : Size - FreeSpace
        - Calcul pourcentage libre : (FreeSpace / Size) * 100
    - **Système de fichiers**
        - FileSystem (NTFS, FAT32, exFAT, ReFS)
        - Compressed (compression activée)
        - SupportsFileBasedCompression
    - **État**
        - Status
        - Access (0=Unknown, 1=Readable, 2=Writable, 3=Read/Write)
        - MediaType
- Surveillance d'espace disque
- Alertes si espace faible
- Rapports de capacité
- Nettoyage automatique

#### 2.4 Win32_NetworkAdapter

- Informations sur adaptateurs réseau
- Filtrage recommandé
    - Physical adapters : `-Filter "PhysicalAdapter=True"`
    - Adapters avec IP : `-Filter "NetEnabled=True"`
- Propriétés principales
    - **Identification**
        - Name (nom descriptif)
        - Description
        - ProductName
        - AdapterType (Ethernet, Wireless, etc.)
        - InterfaceIndex (index système)
    - **Matériel**
        - Manufacturer
        - MACAddress (adresse physique)
        - PhysicalAdapter (booléen)
        - PNPDeviceID
    - **Configuration**
        - NetEnabled (activé pour réseau)
        - NetConnectionStatus
            - 0 : Disconnected
            - 2 : Connected
            - 7 : Media disconnected
        - Speed (vitesse en bps)
        - ServiceName (pilote)
    - **Connexion**
        - NetConnectionID (nom de connexion réseau)
        - GUID
- Win32_NetworkAdapterConfiguration (configuration IP)
    - IPAddress, IPSubnet
    - DefaultIPGateway
    - DNSServerSearchOrder
    - DHCPEnabled
    - MACAddress
- Inventaire réseau
- Diagnostic de connectivité
- Identification d'adaptateurs
- Gestion de configuration

---

### 3. Inventaire matériel

#### 3.1 Win32_Processor

- Informations sur processeur(s)
- Propriétés principales
    - **Identification**
        - Name (nom commercial : "Intel Core i7-10700K")
        - Manufacturer (Intel, AMD, ARM)
        - ProcessorId (ID unique)
        - DeviceID (Processor0, Processor1, etc.)
    - **Architecture**
        - Architecture (0=x86, 9=x64, 12=ARM64)
        - AddressWidth (32 ou 64 bits)
        - DataWidth
        - Family, Model, Stepping
    - **Cœurs et threads**
        - NumberOfCores (cœurs physiques)
        - NumberOfLogicalProcessors (threads)
        - ThreadCount
    - **Performance**
        - MaxClockSpeed (MHz max)
        - CurrentClockSpeed (MHz actuel)
        - LoadPercentage (charge actuelle)
        - L2CacheSize, L3CacheSize
    - **Caractéristiques**
        - Characteristics (tableau de capacités)
        - VirtualizationFirmwareEnabled
        - VMMonitorModeExtensions
        - SecondLevelAddressTranslationExtensions
    - **État**
        - Status
        - Availability
        - CpuStatus
- Calculs et analyses
    - Total threads dans système
    - Charge moyenne
    - Détection virtualisation
- Inventaire CPU
- Vérification compatibilité
- Rapports de performance

#### 3.2 Win32_PhysicalMemory

- Informations sur barrettes RAM physiques
- Une instance par barrette installée
- Propriétés principales
    - **Capacité**
        - Capacity (taille en octets)
        - Conversion en GB : `[math]::Round($cap/1GB, 2)`
    - **Type de mémoire**
        - MemoryType (codes numériques)
            - 20 : DDR
            - 21 : DDR2
            - 24 : DDR3
            - 26 : DDR4
            - 34 : DDR5
        - SMBIOSMemoryType
        - FormFactor (8=DIMM, 12=SO-DIMM)
    - **Performance**
        - Speed (vitesse en MHz : 2400, 3200, etc.)
        - ConfiguredClockSpeed
        - ConfiguredVoltage
    - **Emplacement**
        - BankLabel (Bank 0, Bank 1)
        - DeviceLocator (DIMM0, DIMM1, etc.)
        - Tag (Physical Memory 0)
    - **Fabricant**
        - Manufacturer
        - PartNumber
        - SerialNumber
    - **État**
        - Status
        - DataWidth (64 pour 64-bit)
- Calculs utiles
    - RAM totale installée (somme de toutes capacités)
    - Emplacements libres
    - Configuration mémoire
- Inventaire RAM
- Planification d'upgrades
- Vérification de compatibilité
- Diagnostic de pannes

#### 3.3 Win32_BIOS

- Informations sur BIOS/UEFI
- Propriétés principales
    - **Version et fabricant**
        - Manufacturer (fabricant carte mère)
        - Name (nom BIOS)
        - Version (version BIOS)
        - SMBIOSBIOSVersion
        - SMBIOSMajorVersion, SMBIOSMinorVersion
    - **Identification**
        - SerialNumber (numéro série machine)
        - BIOSVersion (tableau de versions)
    - **Dates**
        - ReleaseDate (date release BIOS)
        - Parsing de date : format WMI DateTime
    - **Caractéristiques**
        - BIOSCharacteristics (tableau de capacités)
        - PrimaryBIOS (booléen)
        - SoftwareElementState
    - **État**
        - Status
        - Description
- **Autres classes BIOS utiles**
    - Win32_BaseBoard (carte mère)
        - Manufacturer, Product, Version
        - SerialNumber
    - Win32_SystemEnclosure (châssis)
        - Manufacturer, Model
        - ChassisTypes (Desktop, Laptop, Rack, etc.)
        - SerialNumber, SMBIOSAssetTag
- Détection type de machine
- Inventaire complet matériel
- Suivi numéros de série
- Vérification garanties
- Audit de parc informatique

---

## 📘 PARTIE 9 : Active Directory

**Fichier Obsidian suggéré :** `09-active-directory.md`

### 1. Module ActiveDirectory

#### 1.1 Installation et import

- **Module ActiveDirectory**
    - Fait partie de RSAT (Remote Server Administration Tools)
    - Disponible sur serveurs avec rôle AD DS
    - Installation sur clients Windows
- **Installation Windows 10/11**
    - Via Paramètres → Apps → Fonctionnalités facultatives
    - Chercher "RSAT: Active Directory Domain Services"
    - Ou via PowerShell :
        
        ```powershell
        Get-WindowsCapability -Name RSAT.ActiveDirectory* -OnlineAdd-WindowsCapability -Name "RSAT.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0" -Online
        ```
        
- **Installation Windows Server**
    - Via Server Manager → Add Roles and Features
    - Ou via PowerShell :
        
        ```powershell
        Install-WindowsFeature RSAT-AD-PowerShell
        ```
        
- **Import du module**
    - `Import-Module ActiveDirectory`
    - Import automatique si installé (PS 3.0+)
    - Vérification : `Get-Module -Name ActiveDirectory -ListAvailable`
    - Liste cmdlets : `Get-Command -Module ActiveDirectory`
- **Prérequis**
    - Droits appropriés sur AD
    - Connectivité réseau vers contrôleur domaine
    - Ports nécessaires ouverts
- **Versions et compatibilité**
    - Compatible Windows PowerShell 5.1
    - Disponible sur PowerShell 7+ (avec limitations)
    - Nécessite .NET Framework sur Windows

#### 1.2 Connexion au domaine

- **Connexion automatique**
    - Utilise credentials de l'utilisateur connecté
    - Détection automatique du contrôleur de domaine
    - Contexte de sécurité de la session
- **Spécification du serveur**
    - `-Server` paramètre pour contrôleur spécifique
    - Nom DNS du DC ou FQDN
    - Utile pour multi-domaines ou sites distants
- **Credentials alternatifs**
    - `-Credential` pour compte différent
    - `Get-Credential` pour prompt
    - Stockage sécurisé de credentials
- **Contexte d'authentification**
    - Kerberos par défaut
    - NTLM en fallback
    - Authentification SSL/TLS possible
- **Vérification de connexion**
    - Test avec `Get-ADDomain`
    - Vérification des droits
    - Diagnostic de problèmes de connexion
- **Variables de session**
    - `$ADDefaultDomainNamingContext`
    - `$ADRootDSE` pour infos domaine
- **Multi-domaines et forêts**
    - Travail avec plusieurs domaines
    - Trusts et authentification cross-domain
    - Global Catalog pour recherches forêt

---

### 2. Gestion des utilisateurs

#### 2.1 Get-ADUser, New-ADUser

- **Get-ADUser**
    - Récupération d'utilisateurs AD
    - Paramètres de recherche
        - `-Identity` pour utilisateur spécifique (SamAccountName, DN, GUID, SID)
        - `-Filter` pour critères de recherche (obligatoire sans Identity)
        - `-LDAPFilter` pour filtres LDAP avancés
        - `-SearchBase` pour OU spécifique
        - `-SearchScope` (Base, OneLevel, Subtree)
    - Propriétés par défaut limitées
    - `-Properties` pour propriétés supplémentaires
        - `-Properties *` pour toutes (attention performance)
        - Liste spécifique : `-Properties EmailAddress,Department,Title`
    - Propriétés courantes
        - SamAccountName, UserPrincipalName (UPN)
        - DistinguishedName (DN)
        - GivenName, Surname, DisplayName
        - EmailAddress, Title, Department
        - Enabled, LockedOut, PasswordExpired
        - LastLogonDate, WhenCreated, WhenChanged
        - Manager, MemberOf (groupes)
    - Filtres courants
        - `Get-ADUser -Filter "Enabled -eq $true"`
        - `Get-ADUser -Filter "Department -eq 'IT'"`
        - `Get-ADUser -Filter "EmailAddress -like '*@domain.com'"`
    - Export et rapports
- **New-ADUser**
    - Création de nouveaux utilisateurs
    - Paramètres obligatoires
        - `-Name` (CN dans AD)
        - `-SamAccountName` (nom de connexion pré-Windows 2000)
    - Paramètres essentiels
        - `-GivenName` et `-Surname` (prénom, nom)
        - `-UserPrincipalName` (login@domain.com)
        - `-Path` (OU destination, DN)
        - `-AccountPassword` (SecureString)
        - `-Enabled $true` pour activer immédiatement
    - Propriétés supplémentaires
        - `-DisplayName` (nom d'affichage)
        - `-EmailAddress`
        - `-Title`, `-Department`, `-Company`
        - `-Office`, `-OfficePhone`, `-MobilePhone`
        - `-Manager` (DN du manager)
        - `-Description`
        - `-StreetAddress`, `-City`, `-State`, `-PostalCode`, `-Country`
    - Options de mot de passe
        - `-ChangePasswordAtLogon $true`
        - `-PasswordNeverExpires $true/$false`
        - `-CannotChangePassword $true/$false`
    - Options de compte
        - `-AccountExpirationDate`
        - `-AllowReversiblePasswordEncryption`
    - Création de SecureString pour mot de passe
        
        ```powershell
        $Password = ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force
        ```
        
    - Scripts de provisioning en masse
    - Import depuis CSV
    - Templates d'utilisateurs
    - Droits requis : création d'objets dans OU

#### 2.2 Set-ADUser, Remove-ADUser

- **Set-ADUser**
    - Modification d'utilisateurs existants
    - `-Identity` pour identifier utilisateur
    - Modification de propriétés standard
        - `-GivenName`, `-Surname`, `-DisplayName`
        - `-EmailAddress`, `-Title`, `-Department`
        - `-Manager`, `-Office`, `-OfficePhone`
        - `-Description`
    - Options de compte
        - `-Enabled $true/$false`
        - `-ChangePasswordAtLogon $true/$false`
        - `-PasswordNeverExpires $true/$false`
        - `-AccountExpirationDate`
    - Modification d'attributs étendus
        - `-Add` pour ajouter valeurs (attributs multi-valués)
        - `-Remove` pour retirer valeurs
        - `-Replace` pour remplacer valeurs
        - `-Clear` pour vider attribut
    - Exemples d'attributs étendus
        
        ```powershell
        Set-ADUser -Identity jdoe -Add @{proxyAddresses="smtp:alias@domain.com"}Set-ADUser -Identity jdoe -Replace @{extensionAttribute1="Value"}
        ```
        
    - Opérations en masse avec pipeline
    - Scripts de mise à jour départementale
    - Synchronisation d'attributs
- **Remove-ADUser**
    - Suppression d'utilisateurs
    - `-Identity` pour identifier
    - `-Confirm` pour confirmation (recommandé)
    - `-WhatIf` pour simulation
    - Précautions avant suppression
        - Sauvegarde des données
        - Vérification des dépendances
        - Permissions héritées
        - Boîtes mail Exchange
    - Alternative : désactivation plutôt que suppression
    - Récupération depuis Corbeille AD (si activée)
    - Archivage d'informations
    - Offboarding automatisé
    - Droits requis : suppression d'objets

#### 2.3 Enable-ADAccount, Disable-ADAccount

- **Enable-ADAccount**
    - Activation de comptes désactivés
    - `-Identity` pour identifier utilisateur
    - Réactivation après suspension
    - Scripts de réintégration
    - Pas de modification d'autres attributs
- **Disable-ADAccount**
    - Désactivation de comptes
    - Empêche toute connexion
    - Préserve toutes les données et permissions
    - Utilisé pour
        - Départs temporaires (congés, sabbatiques)
        - Suspensions
        - Comptes inactifs
        - Sécurité préventive
    - Bonne pratique vs suppression
    - Scripts d'offboarding
    - Audit des comptes désactivés
- Vérification statut avec `Get-ADUser -Properties Enabled`

#### 2.4 Unlock-ADAccount

- Déverrouillage de comptes verrouillés
- `-Identity` pour identifier utilisateur
- Verrouillage après tentatives échecs mot de passe
- Propriété `LockedOut` dans Get-ADUser
- Vérification avec `-Properties LockedOut,LockoutTime`
- `Search-ADAccount -LockedOut` pour trouver comptes verrouillés
- Scripts de surveillance de verrouillages
- Helpdesk et support utilisateurs
- Logs de verrouillage dans Event Viewer
- Analyse de tentatives de connexion
- Sécurité : vérification avant déverrouillage

---

### 3. Gestion des groupes

#### 3.1 Get-ADGroup, New-ADGroup

- **Get-ADGroup**
    - Récupération de groupes AD
    - Paramètres de recherche
        - `-Identity` pour groupe spécifique
        - `-Filter` pour critères
        - `-SearchBase` pour OU
    - `-Properties` pour attributs étendus
        - `Members` (membres directs)
        - `MemberOf` (groupes parents)
        - `Description`, `ManagedBy`
    - Propriétés principales
        - Name, SamAccountName, DistinguishedName
        - GroupCategory (Security, Distribution)
        - GroupScope (DomainLocal, Global, Universal)
    - Types de groupes
        - **Security** : permissions et droits
        - **Distribution** : listes de distribution (email)
    - Portées de groupes
        - **DomainLocal** : permissions dans domaine local
        - **Global** : membres du domaine, utilisable partout
        - **Universal** : membres et utilisable dans toute la forêt
    - Filtres courants
        - `Get-ADGroup -Filter "GroupCategory -eq 'Security'"`
        - `Get-ADGroup -Filter "Name -like 'IT-*'"`
- **New-ADGroup**
    - Création de nouveaux groupes
    - Paramètres obligatoires
        - `-Name` (nom du groupe)
        - `-GroupScope` (DomainLocal, Global, Universal)
    - Paramètres optionnels
        - `-GroupCategory` (Security par défaut, ou Distribution)
        - `-Path` (OU destination)
        - `-Description`
        - `-DisplayName`
        - `-SamAccountName` (auto-généré si omis)
        - `-ManagedBy` (DN du gestionnaire)
    - Conventions de nommage
    - Structure de groupes
    - Groupes imbriqués (nesting)
    - Scripts de provisioning
    - Droits requis : création dans OU

#### 3.2 Add-ADGroupMember, Remove-ADGroupMember

- **Add-ADGroupMember**
    - Ajout de membres à un groupe
    - `-Identity` pour groupe cible
    - `-Members` pour membre(s) à ajouter
        - Peut être utilisateur, ordinateur, ou autre groupe
        - Accepte DN, GUID, SID, SamAccountName
        - Accepte tableau pour ajouts multiples
    - Exemples
        
        ```powershell
        Add-ADGroupMember -Identity "IT-Team" -Members "jdoe","asmith"Add-ADGroupMember -Identity "Admins" -Members (Get-ADUser -Filter "Department -eq 'IT'")
        ```
        
    - Groupes imbriqués (groupes dans groupes)
    - Ajout en masse depuis CSV
    - Scripts d'onboarding
    - Vérification avant ajout (éviter doublons)
- **Remove-ADGroupMember**
    - Retrait de membres d'un groupe
    - Mêmes paramètres que Add
    - `-Confirm` pour confirmation
    - Retrait en masse
    - Scripts d'offboarding
    - Nettoyage de groupes
    - Audit de permissions

#### 3.3 Get-ADGroupMember

- Liste des membres d'un groupe
- `-Identity` pour groupe
- `-Recursive` pour membres des sous-groupes
- Propriétés retournées
    - Name, SamAccountName, DistinguishedName
    - ObjectClass (user, group, computer)
- Différence membres directs vs récursifs
- Export de listes de membres
- Audit d'appartenance
- Rapports de sécurité
- Vérification de permissions
- Groupes imbriqués complexes
- Performance : récursivité sur gros groupes

---

### 4. Gestion des ordinateurs

#### 4.1 Get-ADComputer, New-ADComputer

- **Get-ADComputer**
    - Récupération d'ordinateurs AD
    - Paramètres similaires à Get-ADUser
        - `-Identity`, `-Filter`, `-SearchBase`
    - `-Properties` pour attributs étendus
    - Propriétés principales
        - Name, SamAccountName, DNSHostName
        - DistinguishedName
        - Enabled, OperatingSystem, OperatingSystemVersion
        - LastLogonDate, WhenCreated
        - IPv4Address, MemberOf
    - Filtres courants
        - `Get-ADComputer -Filter "OperatingSystem -like '*Windows 11*'"`
        - `Get-ADComputer -Filter "Enabled -eq $true"`
    - Inventaire de parc
    - Identification d'OS obsolètes
    - Comptes obsolètes (LastLogonDate ancienne)
- **New-ADComputer**
    - Pré-création de comptes ordinateurs
    - Paramètres obligatoires
        - `-Name` (nom de l'ordinateur)
    - Paramètres optionnels
        - `-SamAccountName` (Name$ par défaut)
        - `-Path` (OU destination)
        - `-Description`
        - `-Enabled $true`
        - `-DNSHostName`
        - `-Location`
        - `-ManagedBy`
    - Provisioning de machines
    - Deployment automatisé
    - Placement dans OUs appropriées
    - Scripts de staging

#### 4.2 Remove-ADComputer

- Suppression de comptes ordinateurs
- `-Identity` pour identifier
- `-Confirm` et `-WhatIf` recommandés
- Précautions
    - Vérifier que machine n'est plus utilisée
    - Désactivation préalable recommandée
    - Sauvegarde d'informations
- Nettoyage de comptes obsolètes
- Scripts de maintenance
- Désactivation vs suppression
- Droits requis
- Récupération depuis Corbeille AD

---

### 5. Recherches AD

#### 5.1 Search-ADAccount

- Cmdlet spécialisée pour recherches de comptes
- Recherches préconfigurées utiles
    - `-AccountDisabled` : comptes désactivés
    - `-AccountExpired` : comptes expirés
    - `-AccountExpiring -TimeSpan` : expirant bientôt
    - `-AccountInactive -TimeSpan` : inactifs depuis X jours
    - `-LockedOut` : comptes verrouillés
    - `-PasswordExpired` : mots de passe expirés
    - `-PasswordNeverExpires` : mots de passe sans expiration
- `-UsersOnly` ou `-ComputersOnly` pour filtrer type
- `-SearchBase` pour OU spécifique
- `-ResultSetSize` pour limiter résultats
- Cas d'usage
    - Audit de sécurité
    - Nettoyage de comptes
    - Conformité
    - Rapports de comptes problématiques
    - Identification de risques
- Exemples pratiques
    
    ```powershell
    # Comptes inactifs depuis 90 joursSearch-ADAccount -AccountInactive -TimeSpan 90.00:00:00 -UsersOnly# Comptes expirant dans 30 joursSearch-ADAccount -AccountExpiring -TimeSpan 30.00:00:00
    ```
    

#### 5.2 Filtres LDAP

- **Syntaxe de filtres AD**
    - `-Filter` : syntaxe PowerShell
    - `-LDAPFilter` : syntaxe LDAP pure
- **Opérateurs de filtre PowerShell**
    - `-eq`, `-ne`, `-gt`, `-ge`, `-lt`, `-le`
    - `-like` (avec wildcards * et ?)
    - `-and`, `-or`, `-not`
- **Syntaxe LDAP**
    - Entre parenthèses
    - Opérateurs : `=`, `>=`, `<=`, `~=`
    - Wildcards : `*`
    - AND : `(&(condition1)(condition2))`
    - OR : `(|(condition1)(condition2))`
    - NOT : `(!(condition))`
- **Filtres LDAP courants**
    
    ```powershell
    # Utilisateurs avec email spécifiqueGet-ADUser -LDAPFilter "(mail=*@domain.com)"# Utilisateurs actifs d'un départementGet-ADUser -LDAPFilter "(&(department=IT)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))"# Groupes de sécurité universelsGet-ADGroup -LDAPFilter "(&(groupType:1.2.840.113556.1.4.803:=2)(groupType:1.2.840.113556.1.4.803:=8))"
    ```
    
- **Attributs LDAP spéciaux**
    - `userAccountControl` (UAC flags)
        - Bit 2 : ACCOUNTDISABLE
        - Bit 65536 : DONT_EXPIRE_PASSWORD
    - `pwdLastSet` (dernier changement mot de passe)
    - `lastLogonTimestamp` (dernière connexion)
- **Performance**
    - Filtres côté serveur (indexed attributes)
    - Éviter filtrage côté client (Where-Object)
    - Attributs indexés pour recherches rapides
- **Requêtes complexes**
    - Combinaisons multiples de conditions
    - Recherches dans toute la forêt
    - Optimisation de requêtes lourdes
- **Documentation**
    - Schéma Active Directory
    - Attributs disponibles
    - LDAP syntax reference
    - Bitwise filters pour flags

---

## 📘 PARTIE 10 : PowerShell Remoting et automatisation

**Fichier Obsidian suggéré :** `10-remoting-automatisation.md`

### 1. PowerShell Remoting

#### 1.1 Enable-PSRemoting

- Activation de PowerShell Remoting
- Configuration automatique
    - Démarre service WinRM
    - Configure WinRM pour démarrage automatique
    - Crée listener sur ports 5985 (HTTP) et 5986 (HTTPS)
    - Configure règles de firewall
    - Active exceptions firewall pour WinRM
- Exécution
    - Droits administrateur requis
    - `Enable-PSRemoting -Force` (sans confirmation)
    - `-SkipNetworkProfileCheck` pour réseaux publics
- Prérequis
    - Windows Vista SP1+ ou Server 2008+
    - PowerShell 2.0+
    - Administrateur local
- Vérification
    - `Test-WSMan` pour tester WinRM
    - `Get-Service WinRM` pour statut service
    - `Get-PSSessionConfiguration` pour configurations
- Sécurité
    - Authentification par défaut : Kerberos
    - NTLM en fallback
    - Chiffrement du trafic
    - Configurations TrustedHosts pour workgroups
- Désactivation
    - `Disable-PSRemoting` (désactive endpoints)
    - `Stop-Service WinRM` pour arrêter service
- Configuration avancée
    - Ports personnalisés
    - HTTPS avec certificats
    - Restrictions d'accès

#### 1.2 Invoke-Command

- Exécution de commandes à distance
- **Syntaxe de base**
    - `-ComputerName` pour machine(s) cible(s)
    - `-ScriptBlock` pour code à exécuter
    - `-Credential` pour authentification
- **Exécution simple**
    
    ```powershell
    Invoke-Command -ComputerName Server01 -ScriptBlock { Get-Service }
    ```
    
- **Multiples ordinateurs**
    - Tableau de noms : `-ComputerName Server01,Server02,Server03`
    - Exécution parallèle (jusqu'à 32 par défaut)
    - `-ThrottleLimit` pour contrôler parallélisme
- **Passage d'arguments**
    
    - `-ArgumentList` pour paramètres
    - Variable `$using:` pour variables locales (PS 3.0+)
    
    ```powershell
    $service = "WinRM"
    Invoke-Command -ComputerName Server01 -ScriptBlock { 
        Get-Service $using:service 
    }
    ```
    
- **Sessions persistantes**
    - `-Session` au lieu de `-ComputerName`
    - Réutilisation de connexion
    - Contexte préservé entre commandes
- **Exécution de scripts**
    - `-FilePath` pour exécuter script local à distance
    - Script copié et exécuté sur machine distante
- **Options avancées**
    - `-AsJob` pour exécution en arrière-plan
    - `-InDisconnectedSession` pour sessions déconnectées
    - `-ConfigurationName` pour endpoint spécifique
- **Gestion des résultats**
    - Propriété `PSComputerName` ajoutée aux objets
    - Désérialisation d'objets
    - Limitation de types retournés
- **Gestion d'erreurs**
    - `-ErrorAction` pour contrôle
    - Erreurs par machine
    - Collection dans `$Error`

#### 1.3 Enter-PSSession, Exit-PSSession

- **Enter-PSSession**
    - Session interactive à distance
    - "SSH-like" pour PowerShell
    - `-ComputerName` pour connexion
    - `-Credential` si nécessaire
    - Prompt change pour indiquer machine distante
    - Session 1-to-1 (une machine à la fois)
    - Contexte préservé durant session
    - Exemples
        
        ```powershell
        Enter-PSSession -ComputerName Server01Enter-PSSession -ComputerName Server01 -Credential (Get-Credential)
        ```
        
- **Exit-PSSession**
    - Quitter session interactive
    - Retour à session locale
    - Alias : `exit`
- **Limitations**
    - Pas pour scripts automatisés
    - Une seule machine
    - Pas d'exécution parallèle
- **Cas d'usage**
    - Dépannage interactif
    - Exploration à distance
    - Configuration manuelle
    - Formation et démonstration

#### 1.4 New-PSSession et sessions persistantes

- **New-PSSession**
    - Création de session persistante
    - Connexion réutilisable
    - Paramètres
        - `-ComputerName` pour machine(s)
        - `-Credential` pour authentification
        - `-Name` pour identifier session
        - `-ConfigurationName` pour endpoint
        - `-SessionOption` pour options avancées
    - Retourne objet PSSession
    - Variables et état préservés
- **Avantages sessions persistantes**
    - Performance : pas de reconnexion
    - État préservé entre commandes
    - Variables persistent
    - Modules importés restent
    - Gestion explicite du cycle de vie
- **Gestion de sessions**
    - `Get-PSSession` : lister sessions
        - `-ComputerName` pour filtrer
        - `-Name` pour session spécifique
    - `Remove-PSSession` : fermer sessions
    - `Disconnect-PSSession` : déconnecter sans fermer
    - `Connect-PSSession` : reconnecter
- **Utilisation**
    
    ```powershell
    # Créer session$session = New-PSSession -ComputerName Server01# Utiliser sessionInvoke-Command -Session $session -ScriptBlock { Get-Process }Invoke-Command -Session $session -ScriptBlock { $var = 10 }Invoke-Command -Session $session -ScriptBlock { $var } # Retourne 10# Fermer sessionRemove-PSSession -Session $session
    ```
    
- **Sessions multiples**
    - Tableau de PSSessions
    - Gestion de pool de connexions
    - Parallélisme contrôlé
- **Options de session**
    - New-PSSessionOption
    - Timeouts
    - Culture et langue
    - Proxy
    - Compression

#### 1.5 Configuration et sécurité

- **Authentication**
    - Kerberos (domaine)
    - NTLM (workgroup)
    - CredSSP (délégation credentials)
    - Certificate-based
- **TrustedHosts**
    - Configuration pour workgroup
    - `Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*"`
    - Risques de sécurité
    - Préférer authentification mutuelle
- **Configurations de session**
    - `Get-PSSessionConfiguration`
    - Endpoints personnalisés
    - Restrictions de commandes
    - Contraintes de rôles (JEA - Just Enough Administration)
    - `Register-PSSessionConfiguration`
- **JEA (Just Enough Administration)**
    - Accès privilégié limité
    - Endpoints contraints
    - Commandes autorisées spécifiques
    - Logging et audit
    - Principe du moindre privilège
- **SSL/TLS**
    - Certificats pour HTTPS
    - Port 5986
    - `New-PSSession -UseSSL`
- **Firewall et ports**
    - 5985 (HTTP)
    - 5986 (HTTPS)
    - Règles Windows Firewall
- **Logging et audit**
    - Transcription PowerShell
    - Logging des modules
    - Event logs WinRM
    - Audit de sécurité

---

### 2. Modules

#### 2.1 Get-Module, Import-Module

- **Get-Module**
    - Liste modules chargés
    - `-ListAvailable` pour modules disponibles
    - `-Name` pour module spécifique
    - `-All` pour toutes versions
    - Propriétés
        - Name, Version, ModuleType
        - Path, ExportedCommands
        - Author, Description
- **Import-Module**
    - Chargement de module
    - `-Name` pour module à importer
    - `-Force` pour recharger
    - `-Prefix` pour préfixer cmdlets
    - `-RequiredVersion` pour version spécifique
    - `-Global` pour portée globale
    - Auto-import désactivable
    - Import explicite pour compatibilité
- **Chemins de modules**
    - `$env:PSModulePath` (chemins de recherche)
    - `C:\Program Files\PowerShell\Modules`
    - `C:\Windows\System32\WindowsPowerShell\v1.0\Modules`
    - `$HOME\Documents\PowerShell\Modules` (utilisateur)
- **Remove-Module**
    - Déchargement de module
    - Libération de mémoire
    - Résolution de conflits

#### 2.2 Find-Module, Install-Module

- **PowerShell Gallery**
    - Repository public de modules
    - https://www.powershellgallery.com
    - Milliers de modules communautaires
- **Find-Module**
    - Recherche de modules dans repository
    - `-Name` pour nom exact ou pattern
    - `-Tag` pour catégories
    - `-Filter` pour recherche texte
    - `-Repository` pour repository spécifique
    - Informations retournées
        - Name, Version, Description
        - Author, Published Date
        - Dependencies
- **Install-Module**
    - Installation depuis repository
    - `-Name` pour module
    - `-Scope` : CurrentUser ou AllUsers
    - `-Force` pour accepter sans confirmation
    - `-RequiredVersion` ou `-MinimumVersion`
    - Gestion des dépendances automatique
    - Nécessite NuGet provider
    - Droits admin pour AllUsers
- **Update-Module**
    - Mise à jour vers version récente
    - `-Name` pour module spécifique
    - Préserve anciennes versions par défaut
- **Uninstall-Module**
    - Désinstallation de module
    - Suppression de répertoire
- **Repositories**
    - `Get-PSRepository` : lister repositories
    - `Register-PSRepository` : ajouter repository
    - Repositories internes d'entreprise
    - NuGet feeds privés
- **Sécurité**
    - Signature de modules
    - Vérification d'éditeurs
    - ExecutionPolicy et modules

#### 2.3 Création de modules basiques

- **Structure d'un module**
    - Dossier avec nom du module
    - Fichier .psm1 (module script)
    - Fichier .psd1 (manifeste) optionnel
    - Fichiers de ressources
- **Module script (.psm1)**
    - Fichier PowerShell avec fonctions
    - Export explicite ou implicite
    - `Export-ModuleMember` pour contrôler exports
    - Variables, alias, fonctions
- **Manifeste (.psd1)**
    - `New-ModuleManifest` pour créer
    - Métadonnées
        - Author, CompanyName, Copyright
        - Description, Version
        - PowerShellVersion minimum
    - Dépendances (`RequiredModules`)
    - Exports (Functions, Cmdlets, Variables, Aliases)
    - Scripts à exécuter (`ScriptsToProcess`)
- **Organisation**
    - Fonctions publiques vs privées
    - Dossiers Public, Private
    - Dot-sourcing de fichiers
- **Bonnes pratiques**
    - Nommage cohérent
    - Help comments pour fonctions
    - Versioning sémantique
    - Tests avec Pester
- **Distribution**
    - Copie dans PSModulePath
    - Partage via repository interne
    - Publication sur PowerShell Gallery

---

### 3. Tâches planifiées

#### 3.1 Get-ScheduledTask, New-ScheduledTask

- **Get-ScheduledTask**
    - Liste tâches planifiées
    - `-TaskName` pour nom spécifique
    - `-TaskPath` pour dossier (ex: "\Microsoft\Windows")
    - Propriétés
        - TaskName, TaskPath, State (Ready, Running, Disabled)
        - Triggers, Actions, Principal
        - LastRunTime, NextRunTime
- **New-ScheduledTask**
    - Construction d'objet tâche (pas encore enregistré)
    - Composants requis
        - Action(s) : ce que fait la tâche
        - Trigger(s) : quand s'exécute
        - Principal : sous quel compte
        - Settings : options d'exécution
    - Retourne objet ScheduledTask
    - Doit être enregistré avec `Register-ScheduledTask`

#### 3.2 Register-ScheduledTask

- Enregistrement de tâche planifiée
- Paramètres principaux
    - `-TaskName` : nom de la tâche
    - `-Action` : action(s) à exécuter
    - `-Trigger` : déclencheur(s)
    - `-Settings` : paramètres optionnels
    - `-Principal` : contexte d'exécution
    - `-TaskPath` : chemin dans Task Scheduler
    - `-Description` : description de la tâche
- **Création d'Actions**
    - `New-ScheduledTaskAction`
    - `-Execute` : programme à lancer (ex: "powershell.exe")
    - `-Argument` : arguments (ex: "-File C:\Scripts\backup.ps1")
    - `-WorkingDirectory` : répertoire de travail
    - Actions multiples possibles
    - Exemples
        
        ```powershell
        $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\Scripts\test.ps1"
        ```
        
- **Création de Triggers**
    - `New-ScheduledTaskTrigger`
    - Types de déclencheurs
        - `-Once` : une fois à date/heure
        - `-Daily` : quotidien
        - `-Weekly` : hebdomadaire (avec `-DaysOfWeek`)
        - `-AtStartup` : au démarrage système
        - `-AtLogon` : à la connexion
        - `-AtLogOn -User` : connexion utilisateur spécifique
    - Paramètres temporels
        - `-At` : heure d'exécution
        - `-DaysInterval` : intervalle en jours
        - `-WeeksInterval` : intervalle en semaines
        - `-DaysOfWeek` : jours de la semaine
        - `-RepetitionInterval` : répétition
        - `-RepetitionDuration` : durée de répétition
    - Exemples
        
        ```powershell
        $trigger = New-ScheduledTaskTrigger -Daily -At 9am$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday,Friday -At 6pm
        ```
        
- **Principal (contexte de sécurité)**
    - `New-ScheduledTaskPrincipal`
    - `-UserId` : compte d'exécution
    - `-LogonType` : type de connexion
        - Password : avec mot de passe stocké
        - S4U : sans mot de passe stocké
        - Interactive : session interactive
        - ServiceAccount : compte de service (SYSTEM, LOCAL SERVICE, NETWORK SERVICE)
    - `-RunLevel` : Highest (admin) ou Limited
    - Exemple
        
        ```powershell
        $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
        ```
        
- **Settings**
    - `New-ScheduledTaskSettingsSet`
    - Options d'exécution
        - `-AllowStartIfOnBatteries`
        - `-DontStopIfGoingOnBatteries`
        - `-StartWhenAvailable` : démarrer dès que possible si manqué
        - `-RunOnlyIfNetworkAvailable`
        - `-ExecutionTimeLimit` : timeout
        - `-RestartCount` et `-RestartInterval` : tentatives
        - `-MultipleInstances` : comportement si déjà en cours
- **Exemple complet**
    
    ```powershell
    $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\Scripts\backup.ps1"$trigger = New-ScheduledTaskTrigger -Daily -At 3am$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount$settings = New-ScheduledTaskSettingsSet -StartWhenAvailableRegister-ScheduledTask -TaskName "Daily Backup" -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description "Backup quotidien"
    ```
    

#### 3.3 Start-ScheduledTask, Unregister-ScheduledTask

- **Start-ScheduledTask**
    - Exécution manuelle immédiate
    - `-TaskName` pour identifier
    - `-TaskPath` si nécessaire
    - Ignore déclencheurs
    - Utile pour tests
    - Retour immédiat (asynchrone)
- **Unregister-ScheduledTask**
    - Suppression de tâche
    - `-TaskName` et optionnellement `-TaskPath`
    - `-Confirm` pour confirmation
    - Suppression définitive
    - Scripts de nettoyage
- **Autres cmdlets utiles**
    - `Set-ScheduledTask` : modifier tâche existante
    - `Enable-ScheduledTask` : activer tâche
    - `Disable-ScheduledTask` : désactiver tâche
    - `Get-ScheduledTaskInfo` : infos d'exécution
        - LastRunTime, LastTaskResult
        - NextRunTime, NumberOfMissedRuns
    - `Stop-ScheduledTask` : arrêter exécution en cours
- **Gestion avancée**
    - Export de tâches (XML)
    - Import de tâches
    - Migration entre serveurs
    - Templates de tâches
- **Monitoring**
    - Vérification des exécutions
    - Logs dans Event Viewer (Task Scheduler)
    - Alertes sur échecs
    - Rapports d'exécution

---

### 4. Sécurité et credentials

#### 4.1 Get-Credential

- Prompt pour credentials utilisateur
- Retourne objet PSCredential
- Utilisation
    
    ```powershell
    $cred = Get-Credential$cred = Get-Credential -UserName "domain\user"$cred = Get-Credential -Message "Enter admin credentials"
    ```
    
- Composants PSCredential
    - `.UserName` : nom d'utilisateur (string)
    - `.Password` : SecureString
    - `.GetNetworkCredential()` : accès texte clair (danger)
- Utilisation avec cmdlets
    - Paramètre `-Credential`
    - Invoke-Command, New-PSSession, etc.
- Stockage temporaire en variable
- Ne JAMAIS logger mot de passe en clair
- Alternative graphique pour scripts interactifs

#### 4.2 ConvertTo-SecureString, ConvertFrom-SecureString

- **ConvertTo-SecureString**
    - Conversion texte → SecureString
    - Paramètres
        - `-String` : chaîne à convertir
        - `-AsPlainText` : indique texte clair
        - `-Force` : requis avec AsPlainText
    - Utilisation
        
        ```powershell
        $securePass = ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force
        ```
        
    - Création de PSCredential
        
        ```powershell
        $username = "domain\user"$password = ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force$cred = New-Object System.Management.Automation.PSCredential($username, $password)
        ```
        
    - **DANGER** : mot de passe en clair dans script
    - Utiliser pour automatisation uniquement
    - Sécuriser les scripts (permissions fichier)
- **ConvertFrom-SecureString**
    - Conversion SecureString → chaîne chiffrée
    - Chiffrement avec DPAPI (Data Protection API)
    - Lié à utilisateur et machine
    - Stockage sécurisé de mots de passe
    - Utilisation
        
        ```powershell
        $securePass | ConvertFrom-SecureString | Out-File "C:\secure\password.txt"
        ```
        
    - Récupération
        
        ```powershell
        $securePass = Get-Content "C:\secure\password.txt" | ConvertTo-SecureString
        ```
        
    - Limitations
        - Déchiffrable seulement par même utilisateur/machine
        - Alternative : `-Key` ou `-SecureKey` pour clé personnalisée
- **Clés de chiffrement personnalisées**
    - Pour partage entre machines/utilisateurs
    - Génération de clé
        
        ```powershell
        $key = New-Object byte[] 32[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($key)$key | Out-File "C:\secure\aes.key"
        ```
        
    - Chiffrement avec clé
        
        ```powershell
        $key = Get-Content "C:\secure\aes.key"$securePass | ConvertFrom-SecureString -Key $key | Out-File "C:\secure\password.txt"
        ```
        
    - Déchiffrement avec clé
        
        ```powershell
        $key = Get-Content "C:\secure\aes.key"$securePass = Get-Content "C:\secure\password.txt" | ConvertTo-SecureString -Key $key
        ```
        
    - **Sécurité de la clé critique**

#### 4.3 Signature de scripts

- **Pourquoi signer**
    - Vérification d'intégrité
    - Identification de l'auteur
    - Conformité ExecutionPolicy AllSigned
    - Protection contre modifications
- **Certificats de signature**
    - Certificat de signature de code (Code Signing)
    - Sources
        - Autorité de certification publique
        - CA d'entreprise (PKI interne)
        - Certificat auto-signé (tests)
    - Stockage dans magasin de certificats
- **Création certificat auto-signé**
    
    ```powershell
    $cert = New-SelfSignedCertificate -Type CodeSigningCert -Subject "CN=PowerShell Code Signing" -CertStoreLocation Cert:\CurrentUser\My
    ```
    
- **Signature de script**
    - `Set-AuthenticodeSignature`
    - Paramètres
        - `-FilePath` : script à signer
        - `-Certificate` : certificat
        - `-TimestampServer` : horodatage
    - Exemple
        
        ```powershell
        $cert = Get-ChildItem Cert:\CurrentUser\My -CodeSigningCertSet-AuthenticodeSignature -FilePath "C:\Scripts\test.ps1" -Certificate $cert -TimeStampServer "http://timestamp.digicert.com"
        ```
        
    - Bloc de signature ajouté au script
- **Vérification de signature**
    - `Get-AuthenticodeSignature`
    - Statut : Valid, Invalid, NotSigned, UnknownError
    - Informations signataire
- **Gestion de certificats**
    - `Get-ChildItem Cert:\` pour naviguer
    - Export/Import de certificats
    - Chaîne de confiance
- **Best practices**
    - Toujours horodater (timestamp)
    - Certificats d'autorité reconnue pour production
    - Renouvellement avant expiration
    - Ne pas signer scripts contenant secrets

---

### 5. Logs et journalisation

#### 5.1 Write-Verbose, Write-Warning, Write-Error

- **Streams de sortie PowerShell**
    - Output (1) : sortie normale
    - Error (2) : erreurs
    - Warning (3) : avertissements
    - Verbose (4) : informations détaillées
    - Debug (5) : informations de débogage
    - Information (6) : informations (PS 5+)
- **Write-Verbose**
    - Messages d'information détaillés
    - Masqués par défaut
    - Affichés avec `-Verbose` ou `$VerbosePreference`
    - Couleur : cyan dans console
    - Usage : traces d'exécution, étapes de progression
    - Exemple
        
        ```powershell
        Write-Verbose "Démarrage du traitement..."Write-Verbose "Connexion à $server"
        ```
        
- **Write-Warning**
    - Avertissements non critiques
    - Affichés par défaut (jaune)
    - Contrôle avec `-WarningAction` ou `$WarningPreference`
    - Usage : situations inhabituelles, recommandations
    - Exemple
        
        ```powershell
        Write-Warning "Le service n'est pas démarré"Write-Warning "Fichier de configuration manquant, utilisation valeurs par défaut"
        ```
        
- **Write-Error**
    - Erreurs non terminantes
    - Affichées en rouge
    - N'arrêtent pas l'exécution (sauf ErrorAction Stop)
    - Ajoutées à `$Error`
    - Paramètres
        - `-Message` : message d'erreur
        - `-Exception` : objet exception
        - `-ErrorAction` : comportement
        - `-Category` : catégorie d'erreur
        - `-TargetObject` : objet concerné
    - Exemple
        
        ```powershell
        Write-Error "Impossible de se connecter au serveur $server"Write-Error -Message "Fichier introuvable" -Category ObjectNotFound
        ```
        
- **Write-Debug**
    - Messages de débogage
    - Masqués par défaut
    - Affichés avec `-Debug` ou `$DebugPreference`
    - Peut demander confirmation
    - Usage : troubleshooting, valeurs de variables
- **Write-Information**
    - Messages informatifs (PS 5+)
    - Stream séparé pour structuration
    - Contrôle avec `-InformationAction`
    - Tags et catégories possibles
- **Write-Host**
    - Affichage direct console
    - **ÉVITER dans fonctions** (ne passe pas dans pipeline)
    - Usage : scripts interactifs uniquement
    - Couleurs avec `-ForegroundColor`, `-BackgroundColor`
- **Préférences de streams**
    - `$VerbosePreference` : SilentlyContinue (défaut) ou Continue
    - `$WarningPreference` : Continue (défaut)
    - `$ErrorActionPreference` : Continue (défaut)
    - `$DebugPreference` : SilentlyContinue (défaut)
    - `$InformationPreference` : SilentlyContinue (défaut)

#### 5.2 Start-Transcript, Stop-Transcript

- **Start-Transcript**
    - Enregistrement de session PowerShell
    - Capture toutes les commandes et sorties
    - Paramètres
        - `-Path` : fichier de sortie
        - `-Append` : ajouter à fichier existant
        - `-NoClobber` : ne pas écraser
        - `-IncludeInvocationHeader` : en-têtes détaillés
        - `-Force` : forcer création/écrasement
    - Nom auto-généré si pas de Path
    - Localisation par défaut : Documents
    - Exemple
        
        ```powershell
        Start-Transcript -Path "C:\Logs\session-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
        ```
        
- **Stop-Transcript**
    - Arrêt de l'enregistrement
    - Fermeture du fichier
    - Affiche chemin du transcript
    - Automatique à fermeture de PowerShell
- **Utilisation dans scripts**
    
    - Début de script : Start-Transcript
    - Fin de script : Stop-Transcript
    - Try/Finally pour garantir arrêt
    
    ```powershell
    Start-Transcript -Path "C:\Logs\script.log"
    try {
        # Code du script
    }
    finally {
        Stop-Transcript
    }
    ```
    
- **Contenu du transcript**
    - Horodatage de début/fin
    - Utilisateur et machine
    - Commandes exécutées
    - Sorties de commandes
    - Erreurs
- **Limitations**
    - Ne capture pas Write-Host (dans certaines versions)
    - Performance sur sessions longues
    - Taille de fichier peut croître
- **Audit et conformité**
    - Traçabilité des actions
    - Investigations de sécurité
    - Documentation d'opérations
    - Démonstration de conformité

#### 5.3 Logs personnalisés

- **Journalisation dans fichiers**
    - Fonction de logging personnalisée
    - Formats : CSV, JSON, texte structuré
    - Rotation de logs (par taille ou date)
    - Niveaux de log (Info, Warning, Error, Debug)
    - Exemple fonction de log
        
        ```powershell
        function Write-Log {    param(        [string]$Message,        [ValidateSet('Info','Warning','Error','Debug')]        [string]$Level = 'Info',        [string]$Path = "C:\Logs\app.log"    )    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"    $logMessage = "[$timestamp] [$Level] $Message"    Add-Content -Path $Path -Value $logMessage        switch ($Level) {        'Warning' { Write-Warning $Message }        'Error' { Write-Error $Message }        'Debug' { Write-Debug $Message }        default { Write-Verbose $Message }    }}
        ```
        
- **Journalisation Event Log Windows**
    - `Write-EventLog` (Windows PowerShell)
    - `New-WinEvent` (PowerShell 7+)
    - Création de sources personnalisées
        
        ```powershell
        New-EventLog -LogName Application -Source "MyScript"Write-EventLog -LogName Application -Source "MyScript" -EventId 1000 -EntryType Information -Message "Script exécuté"
        ```
        
    - Types d'entrées : Information, Warning, Error, SuccessAudit, FailureAudit
    - EventIDs personnalisés
    - Intégration avec monitoring système
- **Journalisation structurée**
    - JSON pour parsing facile
    - Export vers systèmes de log (Splunk, ELK, etc.)
    - Métadonnées (serveur, utilisateur, timestamp)
    - Contexte d'exécution
- **Best practices logging**
    - Niveaux de log cohérents
    - Messages descriptifs et actionnables
    - Pas de données sensibles (mots de passe, PII)
    - Rotation et archivage
    - Performance (logging asynchrone si nécessaire)
    - Centralisation pour environnements distribués
- **Outils et frameworks**
    - PSFramework (module communautaire)
    - Log4Net integration
    - Serilog pour .NET
    - Azure Log Analytics
    - Splunk Universal Forwarder
- **Surveillance et alertes**
    - Monitoring de logs
    - Alertes sur erreurs critiques
    - Tableaux de bord
    - Métriques d'exécution

---

## 📝 Notes d'utilisation du plan

### Comment utiliser ce plan détaillé

Ce plan est conçu pour être utilisé de manière modulaire. Lorsque vous copiez une section dans un prompt, tous les éléments importants sont inclus pour garantir une couverture complète du sujet.

### Structure hiérarchique

- **Parties** : 4 grandes sections thématiques (7-10)
- **Sections** : Sous-divisions logiques (1, 2, 3...)
- **Sous-sections** : Éléments spécifiques (1.1, 1.2, 1.3...)
- **Points détaillés** : Puces avec tous les aspects à couvrir

### Progression recommandée

1. Parties 7-10 sont avancées et spécialisées
2. Nécessitent maîtrise des parties 1-6
3. Partie 7 : Administration système locale
4. Partie 8 : Inventaire et WMI
5. Partie 9 : Active Directory (environnement domaine)
6. Partie 10 : Automatisation et remoting (niveau expert)

### Exemples d'extraction

Pour créer un cours sur une section spécifique, copiez :

- Le titre de la partie
- Le titre de la section
- Tous les points et sous-points associés

Exemple : Pour un cours sur "PowerShell Remoting", incluez toute la section 1 de la Partie 10.

---

## 🎯 Objectifs pédagogiques par partie

### Partie 7 - Utilisateurs et réseau

À la fin, l'apprenant saura :

- Gérer utilisateurs et groupes locaux
- Configurer et diagnostiquer le réseau
- Effectuer tests de connectivité

### Partie 8 - WMI et informations système

À la fin, l'apprenant saura :

- Utiliser WMI/CIM efficacement
- Collecter informations système
- Créer inventaires matériels

### Partie 9 - Active Directory

À la fin, l'apprenant saura :

- Gérer utilisateurs et groupes AD
- Administrer objets Active Directory
- Effectuer recherches LDAP complexes

### Partie 10 - Remoting et automatisation

À la fin, l'apprenant saura :

- Utiliser PowerShell Remoting
- Gérer modules et tâches planifiées
- Sécuriser scripts et automatisations
- Implémenter logging robuste

---

## ✅ Checklist de couverture

Pour chaque section enseignée, vérifier que sont couverts :

- [ ] Définition et contexte
- [ ] Syntaxe et exemples de base
- [ ] Paramètres principaux
- [ ] Cas d'usage pratiques
- [ ] Pièges courants et erreurs
- [ ] Bonnes pratiques de sécurité
- [ ] Exercices pratiques
- [ ] Exemples réels d'entreprise

---

## 🔒 Points de sécurité critiques

### À souligner particulièrement :

**Partie 7** :

- Gestion sécurisée des mots de passe
- Principe du moindre privilège
- Sécurisation des comptes administrateurs

**Partie 8** :

- Prudence avec Invoke-CimMethod
- Droits nécessaires pour actions système

**Partie 9** :

- Impact des modifications AD
- Tests en environnement non-production
- Sauvegardes avant modifications massives

**Partie 10** :

- Sécurisation PowerShell Remoting
- Gestion des credentials
- Ne JAMAIS stocker mots de passe en clair
- Signature de scripts en production
- Principe du moindre privilège pour tâches planifiées

---

## 💡 Conseils pédagogiques

### Approche pratique

- Démonstrations en direct pour chaque cmdlet
- Labs pratiques après chaque section
- Scénarios réels d'entreprise
- Troubleshooting d'erreurs courantes

### Progression

- Commencer simple, complexifier progressivement
- Nombreux exemples avant exercices
- Scripts commentés et expliqués
- Révision des parties précédentes

### Évaluation

- Exercices pratiques notés
- Projets finaux par partie
- QCM de validation de connaissances
- Certification ou badge de complétion

---

_Ce plan détaillé garantit qu'aucun élément important ne sera oublié lors de la création du contenu pédagogique pour les parties 7 à 10._