

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

## 🎯 Introduction à Resolve-DnsName {#introduction}

`Resolve-DnsName` est la cmdlet PowerShell moderne pour effectuer des requêtes DNS. Elle remplace avantageusement les anciens outils comme `nslookup` en offrant une interface orientée objet, plus puissante et facilement scriptable.

> [!info] Pourquoi utiliser Resolve-DnsName ?
> 
> - **Output structuré** : Retourne des objets PowerShell manipulables
> - **Intégration native** : S'intègre parfaitement dans les pipelines PowerShell
> - **Plus de contrôle** : Paramètres avancés pour des requêtes précises
> - **Diagnostic réseau** : Outil essentiel pour le troubleshooting DNS

### Cas d'usage principaux

- Vérifier la résolution de noms de domaine
- Diagnostiquer des problèmes de connectivité
- Valider la configuration DNS d'un serveur
- Auditer les enregistrements DNS
- Automatiser des tests de disponibilité
- Vérifier la propagation DNS après modification

---

## 📝 Syntaxe de base {#syntaxe-de-base}

### Structure minimale

```powershell
# Résolution simple d'un nom de domaine
Resolve-DnsName -Name "google.com"

# Avec alias (équivalent plus court)
Resolve-DnsName google.com
```

### Paramètres principaux

```powershell
Resolve-DnsName -Name <string> [-Type <RecordType>] [-Server <string>]
```

> [!example] Exemples de base
> 
> ```powershell
> # Résolution standard (retourne enregistrements A et AAAA)
> Resolve-DnsName microsoft.com
> 
> # Spécifier le type d'enregistrement
> Resolve-DnsName -Name microsoft.com -Type A
> 
> # Utiliser un serveur DNS spécifique
> Resolve-DnsName -Name google.com -Server 8.8.8.8
> ```

---

## 🗂️ Types d'enregistrements DNS {#types-denregistrements-dns}

### Vue d'ensemble des types principaux

|Type|Description|Usage typique|
|---|---|---|
|**A**|Adresse IPv4|Résolution nom → IP (IPv4)|
|**AAAA**|Adresse IPv6|Résolution nom → IP (IPv6)|
|**CNAME**|Alias canonique|Redirection vers autre nom|
|**MX**|Serveur mail|Configuration messagerie|
|**NS**|Serveur de noms|Délégation DNS|
|**PTR**|Pointeur inverse|Résolution IP → nom|
|**TXT**|Texte arbitraire|SPF, DKIM, vérifications|
|**SOA**|Start of Authority|Informations zone DNS|
|**SRV**|Service|Localisation services (AD, etc.)|

---

### 🔹 Type A (IPv4)

Enregistrement le plus courant, associe un nom de domaine à une adresse IPv4.

```powershell
# Obtenir l'adresse IPv4
Resolve-DnsName -Name "example.com" -Type A

# Filtrer uniquement les IP
(Resolve-DnsName -Name "example.com" -Type A).IPAddress
```

> [!tip] Astuce Par défaut, `Resolve-DnsName` retourne A et AAAA. Spécifiez `-Type A` pour limiter aux IPv4 uniquement.

---

### 🔹 Type AAAA (IPv6)

Enregistrement pour les adresses IPv6.

```powershell
# Obtenir l'adresse IPv6
Resolve-DnsName -Name "google.com" -Type AAAA

# Vérifier si IPv6 est supporté
if (Resolve-DnsName -Name "example.com" -Type AAAA -ErrorAction SilentlyContinue) {
    Write-Host "IPv6 supporté"
} else {
    Write-Host "IPv6 non disponible"
}
```

---

### 🔹 Type CNAME (Canonical Name)

Alias pointant vers un autre nom de domaine.

```powershell
# Résoudre un CNAME
Resolve-DnsName -Name "www.microsoft.com" -Type CNAME

# Suivre la chaîne complète de CNAME
Resolve-DnsName -Name "www.microsoft.com"
```

> [!info] Comportement par défaut Sans spécifier `-Type CNAME`, PowerShell suit automatiquement la chaîne de CNAME jusqu'à l'IP finale.

```powershell
# Exemple de chaîne CNAME
# www.example.com → cdn.example.com → cdn-provider.net → 203.0.113.1
```

---

### 🔹 Type MX (Mail Exchange)

Serveurs de messagerie pour un domaine.

```powershell
# Obtenir les serveurs mail
Resolve-DnsName -Name "gmail.com" -Type MX

# Trier par priorité (plus bas = prioritaire)
Resolve-DnsName -Name "outlook.com" -Type MX | 
    Sort-Object Preference |
    Select-Object Preference, NameExchange
```

> [!example] Sortie typique MX
> 
> ```
> Preference NameExchange
> ---------- ------------
> 10         mail1.example.com
> 20         mail2.example.com
> ```

**Importance de la priorité** : Les valeurs plus basses sont contactées en premier. En cas d'échec, le serveur avec la priorité suivante est utilisé.

---

### 🔹 Type NS (Name Server)

Serveurs de noms autoritaires pour une zone DNS.

```powershell
# Identifier les serveurs DNS autoritaires
Resolve-DnsName -Name "microsoft.com" -Type NS

# Obtenir uniquement les noms des serveurs
(Resolve-DnsName -Name "github.com" -Type NS).NameHost
```

> [!tip] Usage en troubleshooting Utile pour vérifier quelle organisation gère le DNS d'un domaine.

---

### 🔹 Type PTR (Pointer - Résolution inverse)

Résolution inverse : IP → nom de domaine (voir section dédiée plus bas).

```powershell
# Résolution inverse d'une IP
Resolve-DnsName -Name "8.8.8.8" -Type PTR

# Vérification reverse DNS
Resolve-DnsName -Name "142.250.185.78" -Type PTR
```

---

### 🔹 Type TXT (Text)

Enregistrements texte pour diverses validations (SPF, DKIM, vérification domaine).

```powershell
# Obtenir les enregistrements TXT
Resolve-DnsName -Name "google.com" -Type TXT

# Filtrer pour SPF spécifiquement
(Resolve-DnsName -Name "gmail.com" -Type TXT).Strings | 
    Where-Object { $_ -like "*spf*" }

# Vérifier l'enregistrement de vérification Google
Resolve-DnsName -Name "_dmarc.example.com" -Type TXT
```

> [!info] Usages courants des TXT
> 
> - **SPF** : Politique d'envoi d'emails (`v=spf1...`)
> - **DKIM** : Signature emails (`v=DKIM1...`)
> - **DMARC** : Politique anti-usurpation
> - **Vérification de domaine** : Google, Microsoft, etc.

---

### 🔹 Type SOA (Start of Authority)

Informations sur la zone DNS (serveur primaire, contact, numéros de série).

```powershell
# Obtenir les informations SOA
Resolve-DnsName -Name "microsoft.com" -Type SOA

# Extraire le numéro de série (utile pour tracking des changements)
(Resolve-DnsName -Name "example.com" -Type SOA).SerialNumber
```

**Propriétés SOA importantes** :

- `PrimaryServer` : Serveur DNS maître
- `NameAdministrator` : Email administrateur (format DNS)
- `SerialNumber` : Version de la zone (YYYYMMDDNN)
- `TimeToZoneRefresh` : Intervalle de rafraîchissement
- `TimeToZoneFailureRetry` : Délai avant nouvelle tentative
- `TimeToExpiration` : Durée de validité

---

### 🔹 Type SRV (Service)

Localisation de services spécifiques (très utilisé dans Active Directory).

```powershell
# Localiser contrôleurs de domaine Active Directory
Resolve-DnsName -Name "_ldap._tcp.dc._msdcs.contoso.com" -Type SRV

# Autres services courants
Resolve-DnsName -Name "_sip._tls.example.com" -Type SRV
Resolve-DnsName -Name "_xmpp-server._tcp.jabber.org" -Type SRV
```

**Format des enregistrements SRV** : `_service._protocol.domain`

> [!example] Propriétés SRV
> 
> - `Priority` : Priorité du serveur
> - `Weight` : Poids pour load balancing
> - `Port` : Port du service
> - `NameTarget` : Nom du serveur cible

---

## ⚙️ Paramètres avancés {#paramètres-avancés}

### `-Server` : Spécifier un serveur DNS

Permet d'interroger un serveur DNS particulier plutôt que celui configuré par défaut.

```powershell
# Utiliser Google DNS
Resolve-DnsName -Name "example.com" -Server 8.8.8.8

# Utiliser Cloudflare DNS
Resolve-DnsName -Name "example.com" -Server 1.1.1.1

# Interroger un serveur DNS interne
Resolve-DnsName -Name "server01.contoso.local" -Server 192.168.1.10
```

> [!tip] Cas d'usage
> 
> - Tester la configuration d'un serveur DNS spécifique
> - Comparer les résultats entre différents DNS
> - Contourner un DNS local problématique
> - Valider la propagation DNS

---

### `-DnsOnly` : Ignorer cache et fichier hosts

Force une requête DNS pure en ignorant le cache local et le fichier hosts.

```powershell
# Requête DNS pure (bypass cache et hosts)
Resolve-DnsName -Name "localhost" -DnsOnly
```

> [!warning] Attention Cette option force une requête réseau même si l'information est en cache, ce qui peut être plus lent.

---

### `-NoHostsFile` : Ignorer le fichier hosts

Ignore uniquement le fichier hosts (`C:\Windows\System32\drivers\etc\hosts`) mais utilise le cache DNS.

```powershell
# Ignorer les entrées du fichier hosts
Resolve-DnsName -Name "blocked-site.com" -NoHostsFile
```

**Utile pour** :

- Tester si un blocage vient du fichier hosts
- Vérifier la vraie résolution DNS d'un domaine modifié localement

---

### `-CacheOnly` : Utiliser uniquement le cache

Retourne uniquement les informations présentes dans le cache DNS local, sans requête réseau.

```powershell
# Consulter le cache uniquement
Resolve-DnsName -Name "microsoft.com" -CacheOnly
```

> [!info] Comportement Si l'entrée n'est pas en cache, la cmdlet échoue plutôt que d'interroger le DNS.

**Usage** :

- Vérifier ce qui est actuellement en cache
- Tests de performance (pas d'attente réseau)
- Diagnostic de problèmes de cache

---

### `-QuickTimeout` : Timeout rapide

Réduit le délai d'attente pour une réponse DNS (utile pour tests rapides).

```powershell
# Timeout court pour test de disponibilité
Resolve-DnsName -Name "slow-server.example.com" -QuickTimeout
```

> [!tip] Utilisation recommandée Combiné avec des tests en masse pour identifier rapidement les serveurs lents ou injoignables.

---

## 📊 Propriétés retournées {#propriétés-retournées}

### Structure des objets retournés

`Resolve-DnsName` retourne des objets avec différentes propriétés selon le type d'enregistrement.

```powershell
# Examiner toutes les propriétés
Resolve-DnsName -Name "google.com" | Get-Member

# Sélectionner des propriétés spécifiques
Resolve-DnsName -Name "microsoft.com" | 
    Select-Object Name, Type, TTL, Section, IPAddress
```

---

### Propriétés communes

|Propriété|Description|Exemple|
|---|---|---|
|**Name**|Nom résolu|`google.com`|
|**Type**|Type d'enregistrement|`A`, `AAAA`, `CNAME`|
|**TTL**|Time To Live (secondes)|`300`|
|**Section**|Section de la réponse|`Answer`, `Authority`, `Additional`|

---

### Propriétés spécifiques selon le type

#### Pour les enregistrements A et AAAA

```powershell
# IPAddress contient l'adresse IP
$result = Resolve-DnsName -Name "google.com" -Type A
$result.IPAddress  # Ex: 142.250.185.78
```

#### Pour les CNAME

```powershell
# NameHost contient le nom canonique cible
$result = Resolve-DnsName -Name "www.microsoft.com" -Type CNAME
$result.NameHost  # Ex: www.microsoft.com-c-3.edgekey.net
```

#### Pour les MX

```powershell
# Preference (priorité) et NameExchange (serveur mail)
$mx = Resolve-DnsName -Name "gmail.com" -Type MX
$mx | Select-Object Preference, NameExchange
```

#### Pour les TXT

```powershell
# Strings contient le texte (peut être un tableau)
$txt = Resolve-DnsName -Name "google.com" -Type TXT
$txt.Strings
```

---

### Section de la réponse DNS

Les résultats sont classés en trois sections :

1. **Answer** : Réponse directe à la requête
2. **Authority** : Serveurs autoritaires pour la zone
3. **Additional** : Informations supplémentaires (souvent IPs des NS)

```powershell
# Filtrer par section
Resolve-DnsName -Name "microsoft.com" -Type NS | 
    Where-Object Section -eq "Answer"

# Voir toutes les sections
Resolve-DnsName -Name "example.com" | 
    Group-Object Section | 
    Select-Object Name, Count
```

---

### TTL (Time To Live)

Indique combien de temps (en secondes) l'enregistrement peut être mis en cache.

```powershell
# Vérifier le TTL d'un enregistrement
$dns = Resolve-DnsName -Name "google.com"
$dns.TTL  # Ex: 300 (5 minutes)

# Identifier les enregistrements avec TTL court
Resolve-DnsName -Name "example.com" | 
    Where-Object TTL -lt 300 |
    Select-Object Name, Type, TTL
```

> [!info] Valeurs TTL typiques
> 
> - **Courte (60-300s)** : Enregistrements susceptibles de changer (CDN, load balancing)
> - **Moyenne (3600s = 1h)** : Configuration standard
> - **Longue (86400s = 24h)** : Enregistrements très stables

---

## 💾 Gestion du cache DNS local {#gestion-du-cache-dns-local}

### Consulter le cache DNS

```powershell
# Afficher tout le cache DNS
Get-DnsClientCache

# Filtrer par nom de domaine
Get-DnsClientCache | Where-Object Entry -like "*google*"

# Afficher uniquement les types A
Get-DnsClientCache | Where-Object Type -eq "A"

# Trier par TTL restant
Get-DnsClientCache | 
    Sort-Object TimeToLive |
    Select-Object Entry, Type, Data, TimeToLive
```

---

### Propriétés du cache

```powershell
# Structure d'une entrée de cache
Get-DnsClientCache | Select-Object -First 1 | Format-List *
```

**Propriétés importantes** :

- `Entry` : Nom de domaine
- `Type` : Type d'enregistrement
- `Status` : État (Success, NoRecords, etc.)
- `Data` : Données (IP, nom, etc.)
- `TimeToLive` : TTL restant
- `DataLength` : Taille des données

---

### Vider le cache DNS

```powershell
# Vider tout le cache DNS (nécessite élévation)
Clear-DnsClientCache

# Vérification après vidage
Get-DnsClientCache | Measure-Object
```

> [!warning] Privilèges requis `Clear-DnsClientCache` nécessite des droits administrateur.

**Quand vider le cache ?**

- Après modification d'un enregistrement DNS
- Problèmes de résolution persistants
- Suspicion d'empoisonnement DNS
- Tests de propagation DNS

---

### Workflow complet de diagnostic cache

```powershell
# 1. Vérifier si l'entrée est en cache
$cached = Get-DnsClientCache | Where-Object Entry -eq "example.com"
if ($cached) {
    Write-Host "Trouvé en cache : $($cached.Data)"
    Write-Host "TTL restant : $($cached.TimeToLive) secondes"
}

# 2. Vider le cache si nécessaire
Clear-DnsClientCache

# 3. Nouvelle résolution (requête DNS fraîche)
$fresh = Resolve-DnsName -Name "example.com"
Write-Host "Nouvelle résolution : $($fresh.IPAddress)"
```

---

## 🔄 Résolution inverse (IP vers nom) {#résolution-inverse}

### Principe de la résolution inverse

La résolution inverse (reverse DNS) permet de retrouver le nom de domaine associé à une adresse IP via des enregistrements PTR.

> [!info] Format PTR Les enregistrements PTR utilisent un format inversé dans la zone `in-addr.arpa` (IPv4) ou `ip6.arpa` (IPv6).
> 
> **Exemple** : L'IP `192.0.2.1` devient `1.2.0.192.in-addr.arpa`

---

### Résolution inverse basique

```powershell
# Résolution inverse d'une IPv4
Resolve-DnsName -Name "8.8.8.8" -Type PTR

# Le nom sera dans la propriété NameHost
(Resolve-DnsName -Name "8.8.8.8" -Type PTR).NameHost
# Résultat: dns.google

# Résolution inverse avec gestion d'erreur
$ip = "203.0.113.1"
try {
    $ptr = Resolve-DnsName -Name $ip -Type PTR -ErrorAction Stop
    Write-Host "IP $ip résout vers : $($ptr.NameHost)"
} catch {
    Write-Host "Pas de PTR configuré pour $ip"
}
```

---

### Vérification bidirectionnelle (Forward + Reverse)

Technique importante pour valider la cohérence DNS, notamment pour les serveurs mail.

```powershell
# Fonction de validation complète
function Test-DnsConsistency {
    param([string]$Hostname)
    
    # 1. Forward lookup (nom → IP)
    $forward = Resolve-DnsName -Name $Hostname -Type A
    $ip = $forward.IPAddress
    Write-Host "Forward: $Hostname → $ip"
    
    # 2. Reverse lookup (IP → nom)
    $reverse = Resolve-DnsName -Name $ip -Type PTR
    $reverseName = $reverse.NameHost
    Write-Host "Reverse: $ip → $reverseName"
    
    # 3. Comparaison
    if ($reverseName -eq $Hostname) {
        Write-Host "✓ DNS cohérent" -ForegroundColor Green
        return $true
    } else {
        Write-Host "✗ Incohérence DNS détectée" -ForegroundColor Red
        return $false
    }
}

# Utilisation
Test-DnsConsistency -Hostname "mail.example.com"
```

> [!tip] Importance pour les serveurs mail De nombreux serveurs mail vérifient la cohérence forward/reverse et rejettent les emails si elle n'est pas valide (protection anti-spam).

---

### Résolution inverse sur plage d'IPs

```powershell
# Scanner une plage d'IPs pour PTR
$subnet = "192.168.1"
1..10 | ForEach-Object {
    $ip = "$subnet.$_"
    try {
        $ptr = Resolve-DnsName -Name $ip -Type PTR -ErrorAction Stop
        [PSCustomObject]@{
            IP = $ip
            Hostname = $ptr.NameHost
            Status = "OK"
        }
    } catch {
        [PSCustomObject]@{
            IP = $ip
            Hostname = "N/A"
            Status = "No PTR"
        }
    }
} | Format-Table -AutoSize
```

---

## 🔧 Diagnostic et troubleshooting {#diagnostic-et-troubleshooting}

### Vérification de configuration DNS

#### Test de résolution complète

```powershell
# Script de diagnostic DNS complet pour un domaine
function Test-DnsConfiguration {
    param([string]$Domain)
    
    Write-Host "`n=== Diagnostic DNS pour $Domain ===" -ForegroundColor Cyan
    
    # 1. Enregistrements A
    Write-Host "`n[A Records]" -ForegroundColor Yellow
    try {
        $a = Resolve-DnsName -Name $Domain -Type A -ErrorAction Stop
        $a | Select-Object Name, IPAddress, TTL | Format-Table
    } catch {
        Write-Host "Aucun enregistrement A trouvé" -ForegroundColor Red
    }
    
    # 2. Enregistrements AAAA
    Write-Host "`n[AAAA Records (IPv6)]" -ForegroundColor Yellow
    try {
        $aaaa = Resolve-DnsName -Name $Domain -Type AAAA -ErrorAction Stop
        $aaaa | Select-Object Name, IPAddress, TTL | Format-Table
    } catch {
        Write-Host "Pas d'IPv6 configuré" -ForegroundColor Gray
    }
    
    # 3. Serveurs de noms
    Write-Host "`n[Name Servers]" -ForegroundColor Yellow
    $ns = Resolve-DnsName -Name $Domain -Type NS
    $ns | Select-Object NameHost | Format-Table
    
    # 4. Serveurs mail
    Write-Host "`n[Mail Servers]" -ForegroundColor Yellow
    try {
        $mx = Resolve-DnsName -Name $Domain -Type MX -ErrorAction Stop
        $mx | Sort-Object Preference | 
            Select-Object Preference, NameExchange | Format-Table
    } catch {
        Write-Host "Aucun serveur mail configuré" -ForegroundColor Gray
    }
    
    # 5. Enregistrements TXT (SPF, DMARC, etc.)
    Write-Host "`n[TXT Records]" -ForegroundColor Yellow
    try {
        $txt = Resolve-DnsName -Name $Domain -Type TXT -ErrorAction Stop
        $txt.Strings | ForEach-Object { Write-Host "  $_" }
    } catch {
        Write-Host "Aucun enregistrement TXT" -ForegroundColor Gray
    }
}

# Utilisation
Test-DnsConfiguration -Domain "microsoft.com"
```

---

### Tests de propagation DNS

Après modification d'enregistrements DNS, vérifier la propagation sur différents serveurs.

```powershell
# Comparer la résolution sur plusieurs serveurs DNS publics
function Test-DnsPropagation {
    param(
        [string]$Domain,
        [string]$Type = "A"
    )
    
    $dnsServers = @{
        "Google Primary" = "8.8.8.8"
        "Google Secondary" = "8.8.4.4"
        "Cloudflare" = "1.1.1.1"
        "Quad9" = "9.9.9.9"
        "OpenDNS" = "208.67.222.222"
    }
    
    $results = foreach ($name in $dnsServers.Keys) {
        $server = $dnsServers[$name]
        try {
            $result = Resolve-DnsName -Name $Domain -Type $Type -Server $server -ErrorAction Stop
            $data = if ($Type -eq "A" -or $Type -eq "AAAA") {
                $result.IPAddress
            } elseif ($Type -eq "CNAME") {
                $result.NameHost
            } else {
                $result.Name
            }
            
            [PSCustomObject]@{
                Server = $name
                IP = $server
                Result = $data
                Status = "✓"
            }
        } catch {
            [PSCustomObject]@{
                Server = $name
                IP = $server
                Result = "FAIL"
                Status = "✗"
            }
        }
    }
    
    $results | Format-Table -AutoSize
    
    # Vérifier si tous les serveurs retournent la même chose
    $uniqueResults = $results.Result | Where-Object { $_ -ne "FAIL" } | Select-Object -Unique
    if ($uniqueResults.Count -eq 1) {
        Write-Host "`n✓ DNS propagé uniformément" -ForegroundColor Green
    } else {
        Write-Host "`n⚠ Propagation DNS incomplète ou incohérente" -ForegroundColor Yellow
    }
}

# Utilisation
Test-DnsPropagation -Domain "example.com" -Type A
```

---

### Validation d'enregistrements DNS spécifiques

#### Vérifier la configuration SPF

```powershell
# Valider l'enregistrement SPF
function Test-SpfRecord {
    param([string]$Domain)
    
    $txt = Resolve-DnsName -Name $Domain -Type TXT
    $spf = $txt.Strings | Where-Object { $_ -like "v=spf1*" }
    
    if ($spf) {
        Write-Host "✓ Enregistrement SPF trouvé:" -ForegroundColor Green
        Write-Host "  $spf"
        
        # Vérifications basiques
        if ($spf -like "*-all") {
            Write-Host "  Mode strict (-all)" -ForegroundColor Yellow
        } elseif ($spf -like "*~all") {
            Write-Host "  Mode soft fail (~all)" -ForegroundColor Cyan
        } elseif ($spf -like "*+all") {
            Write-Host "  ⚠ ATTENTION: Mode permissif (+all) - NON RECOMMANDÉ" -ForegroundColor Red
        }
    } else {
        Write-Host "✗ Aucun enregistrement SPF trouvé" -ForegroundColor Red
    }
}

Test-SpfRecord -Domain "gmail.com"
```

#### Vérifier les enregistrements DMARC

```powershell
# Vérifier la politique DMARC
function Test-DmarcRecord {
    param([string]$Domain)
    
    try {
        $dmarc = Resolve-DnsName -Name "_dmarc.$Domain" -Type TXT -ErrorAction Stop
        Write-Host "✓ Enregistrement DMARC trouvé:" -ForegroundColor Green
        Write-Host "  $($dmarc.Strings)"
    } catch {
        Write-Host "✗ Pas d'enregistrement DMARC configuré" -ForegroundColor Red
    }
}

Test-DmarcRecord -Domain "microsoft.com"
```

---

### Diagnostic de problèmes courants

#### Problème : Impossible de résoudre un domaine

```powershell
# Diagnostic étape par étape
function Debug-DnsResolution {
    param([string]$Domain)
    
    Write-Host "`n=== Diagnostic de résolution pour $Domain ===" -ForegroundColor Cyan
    
    # 1. Tester résolution simple
    Write-Host "`n[1] Résolution standard"
    try {
        $standard = Resolve-DnsName -Name $Domain -ErrorAction Stop
        Write-Host "  ✓ Résolution OK" -ForegroundColor Green
        return
    } catch {
        Write-Host "  ✗ Échec résolution standard" -ForegroundColor Red
    }
    
    # 2. Tester sans cache
    Write-Host "`n[2] Résolution sans cache (DnsOnly)"
    try {
        $nocache = Resolve-DnsName -Name $Domain -DnsOnly -ErrorAction Stop
        Write-Host "  ✓ Résolution OK sans cache" -ForegroundColor Green
        Write-Host "  ⚠ Problème lié au cache DNS local" -ForegroundColor Yellow
        Write-Host "  → Exécuter: Clear-DnsClientCache"
        return
    } catch {
        Write-Host "  ✗ Échec même sans cache" -ForegroundColor Red
    }
    
    # 3. Tester avec
```