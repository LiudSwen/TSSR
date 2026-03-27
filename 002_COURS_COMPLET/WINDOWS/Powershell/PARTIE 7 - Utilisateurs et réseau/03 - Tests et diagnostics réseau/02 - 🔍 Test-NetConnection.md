

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

## 🎯 Vue d'ensemble

`Test-NetConnection` est une cmdlet PowerShell avancée de diagnostic réseau introduite dans **Windows 8.1** et **Windows Server 2012 R2**. Elle combine plusieurs outils de diagnostic réseau classiques (ping, traceroute, test de port) en une seule commande puissante.

> [!info] Pourquoi Test-NetConnection ?
> 
> - **Tout-en-un** : Remplace ping, telnet, tracert en une seule cmdlet
> - **Orienté objet** : Retourne des objets PowerShell exploitables
> - **Flexible** : S'adapte à différents scénarios de diagnostic
> - **Intégration** : Compatible avec le pipeline PowerShell

> [!warning] Prérequis
> 
> - Windows 8.1+ / Windows Server 2012 R2+
> - PowerShell 4.0+
> - Droits réseau appropriés (certains tests peuvent nécessiter des privilèges)

### Quand utiliser Test-NetConnection ?

- **Diagnostic de connectivité** : Vérifier si une machine est joignable
- **Test de services** : Confirmer qu'un port spécifique est ouvert
- **Troubleshooting réseau** : Identifier où se situe un problème de connexion
- **Validation de configuration** : Vérifier que les services sont accessibles après déploiement
- **Scripts d'automatisation** : Intégrer des vérifications réseau dans vos workflows

---

## ⚙️ Paramètres principaux

### Syntaxe de base

```powershell
Test-NetConnection [[-ComputerName] <String>] [-Port <Int32>] [-InformationLevel <String>]
```

### `-ComputerName`

Spécifie la cible du test (nom d'hôte, FQDN ou adresse IP).

```powershell
# Par nom d'hôte
Test-NetConnection -ComputerName SERVER01

# Par FQDN
Test-NetConnection -ComputerName server01.contoso.com

# Par adresse IP
Test-NetConnection -ComputerName 192.168.1.100

# Sans paramètre (teste la passerelle par défaut)
Test-NetConnection
```

> [!tip] Astuce Si `-ComputerName` n'est pas spécifié, Test-NetConnection teste la connectivité Internet en tentant de résoudre "internetbeacon.msedge.net".

### `-Port`

Teste la connectivité TCP sur un port spécifique.

```powershell
# Test du port 80 (HTTP)
Test-NetConnection -ComputerName webserver.contoso.com -Port 80

# Test du port 3389 (RDP)
Test-NetConnection -ComputerName 192.168.1.50 -Port 3389

# Test du port 443 (HTTPS)
Test-NetConnection -ComputerName api.example.com -Port 443
```

> [!info] Fonctionnement Le test de port établit une connexion TCP complète (Three-Way Handshake), puis ferme immédiatement la connexion. C'est plus fiable qu'un simple scan de port.

### `-CommonTCPPort`

Raccourci pour tester des ports standards sans mémoriser les numéros.

```powershell
# Test du port SMB (445)
Test-NetConnection -ComputerName fileserver -CommonTCPPort SMB

# Test du port HTTP (80)
Test-NetConnection -ComputerName webserver -CommonTCPPort HTTP

# Test du port RDP (3389)
Test-NetConnection -ComputerName workstation01 -CommonTCPPort RDP

# Test du port WinRM (5985)
Test-NetConnection -ComputerName server01 -CommonTCPPort WINRM
```

**Valeurs acceptées :**

- `SMB` : Port 445
- `HTTP` : Port 80
- `RDP` : Port 3389
- `WINRM` : Port 5985

### `-InformationLevel`

Contrôle le niveau de détail de la sortie.

```powershell
# Mode silencieux (retourne seulement True/False)
Test-NetConnection -ComputerName server01 -Port 80 -InformationLevel Quiet

# Mode détaillé (informations complètes)
Test-NetConnection -ComputerName server01 -Port 80 -InformationLevel Detailed
```

|Niveau|Description|Utilisation|
|---|---|---|
|`Quiet`|Retourne uniquement un booléen|Scripts où vous voulez juste savoir si ça marche|
|`Detailed`|Affiche toutes les informations disponibles|Diagnostic approfondi|
|_Défaut_|Niveau intermédiaire avec infos essentielles|Usage général|

### `-TraceRoute`

Effectue un traceroute vers la cible.

```powershell
# Traceroute vers une cible
Test-NetConnection -ComputerName google.com -TraceRoute

# Avec un nombre de sauts maximum personnalisé
Test-NetConnection -ComputerName remote-server.com -TraceRoute -Hops 20
```

> [!example] Exemple de sortie avec TraceRoute
> 
> ```
> ComputerName           : google.com
> RemoteAddress          : 142.250.74.46
> TraceRoute             : {192.168.1.1, 10.0.0.1, 172.16.5.1, 8.8.8.8...}
> PingSucceeded          : True
> ```

### `-Hops`

Définit le nombre maximum de sauts pour le traceroute (par défaut : 30).

```powershell
# Limiter à 15 sauts
Test-NetConnection -ComputerName server.example.com -TraceRoute -Hops 15
```

### `-DiagnoseRouting`

Active les diagnostics de routage avancés (nécessite des privilèges administrateur).

```powershell
# Diagnostic complet du routage
Test-NetConnection -ComputerName 10.20.30.40 -DiagnoseRouting
```

> [!warning] Privilèges requis `-DiagnoseRouting` nécessite l'exécution en tant qu'administrateur.

---

## 📊 Propriétés retournées

`Test-NetConnection` retourne un objet avec plusieurs propriétés exploitables.

### Propriétés de base

```powershell
$result = Test-NetConnection -ComputerName server01.contoso.com -Port 443

# Accéder aux propriétés individuelles
$result.ComputerName       # Nom de la cible
$result.RemoteAddress      # Adresse IP résolue
$result.PingSucceeded      # Résultat du ping (True/False)
$result.TcpTestSucceeded   # Résultat du test TCP (True/False si -Port utilisé)
```

### Tableau des propriétés

|Propriété|Type|Description|
|---|---|---|
|`ComputerName`|String|Nom ou adresse de la cible testée|
|`RemoteAddress`|IPAddress|Adresse IP résolue de la cible|
|`RemotePort`|Int32|Port testé (si `-Port` utilisé)|
|`InterfaceAlias`|String|Nom de l'interface réseau utilisée|
|`SourceAddress`|IPAddress|Adresse IP locale utilisée pour le test|
|`PingSucceeded`|Boolean|Indique si le ping ICMP a réussi|
|`PingReplyDetails`|Object|Détails de la réponse ping (RTT, TTL)|
|`TcpTestSucceeded`|Boolean|Indique si la connexion TCP a réussi|
|`TraceRoute`|String[]|Tableau des adresses IP du traceroute|

### Exemples d'utilisation des propriétés

```powershell
# Test et exploitation des résultats
$test = Test-NetConnection -ComputerName webserver -Port 443

if ($test.TcpTestSucceeded) {
    Write-Host "✅ Le serveur HTTPS est accessible" -ForegroundColor Green
    Write-Host "IP résolue : $($test.RemoteAddress)"
    Write-Host "Interface utilisée : $($test.InterfaceAlias)"
} else {
    Write-Host "❌ Le port 443 est bloqué ou le service n'écoute pas" -ForegroundColor Red
}

# Vérifier uniquement le ping
if ($test.PingSucceeded) {
    Write-Host "Latence : $($test.PingReplyDetails.RoundtripTime) ms"
}
```

> [!tip] Mode pipeline
> 
> ```powershell
> # Filtrer les serveurs accessibles
> $servers = @("srv01", "srv02", "srv03")
> $servers | ForEach-Object {
>     Test-NetConnection -ComputerName $_ -Port 80 -InformationLevel Quiet
> } | Where-Object { $_ -eq $true }
> ```

---

## 🔌 Tests de ports courants

### Port 80 (HTTP)

```powershell
# Test basique
Test-NetConnection -ComputerName webapp.contoso.com -Port 80

# Avec CommonTCPPort
Test-NetConnection -ComputerName webapp.contoso.com -CommonTCPPort HTTP

# Version silencieuse pour scripts
if (Test-NetConnection -ComputerName webapp -Port 80 -InformationLevel Quiet) {
    Write-Host "Site web accessible"
}
```

> [!info] Usage typique
> 
> - Vérifier qu'un serveur web écoute sur HTTP
> - Tester avant une migration HTTP → HTTPS
> - Diagnostiquer les problèmes d'accès web

### Port 443 (HTTPS)

```powershell
# Test HTTPS
Test-NetConnection -ComputerName secure.contoso.com -Port 443

# Vérifier plusieurs sites
$sites = @("site1.com", "site2.com", "api.site3.com")
$sites | ForEach-Object {
    $result = Test-NetConnection -ComputerName $_ -Port 443 -InformationLevel Quiet
    [PSCustomObject]@{
        Site = $_
        Accessible = $result
    }
} | Format-Table -AutoSize
```

### Port 3389 (RDP)

```powershell
# Test RDP
Test-NetConnection -ComputerName workstation01 -Port 3389
Test-NetConnection -ComputerName 192.168.1.100 -CommonTCPPort RDP

# Script de vérification RDP pour plusieurs machines
$computers = Get-Content C:\computers.txt
foreach ($computer in $computers) {
    $rdp = Test-NetConnection -ComputerName $computer -Port 3389 -InformationLevel Quiet
    if ($rdp) {
        Write-Host "✅ $computer : RDP disponible" -ForegroundColor Green
    } else {
        Write-Host "❌ $computer : RDP inaccessible" -ForegroundColor Red
    }
}
```

> [!warning] Sécurité RDP Le port 3389 est souvent ciblé par les attaques. Pensez à :
> 
> - Utiliser des groupes restreints
> - Activer l'authentification au niveau réseau (NLA)
> - Changer le port par défaut si exposé sur Internet
> - Utiliser des VPN pour l'accès distant

### Port 445 (SMB)

```powershell
# Test SMB (partages de fichiers)
Test-NetConnection -ComputerName fileserver -Port 445
Test-NetConnection -ComputerName fileserver -CommonTCPPort SMB

# Vérifier l'accès aux partages avant montage
$fileServers = @("FS01", "FS02", "FS03")
$fileServers | ForEach-Object {
    $smb = Test-NetConnection -ComputerName $_ -Port 445 -InformationLevel Quiet
    if ($smb) {
        Write-Host "$_ : Partages accessibles"
        # Vous pouvez ensuite monter le partage
        # New-PSDrive -Name "X" -PSProvider FileSystem -Root "\\$_\Share"
    }
}
```

> [!info] SMB et sécurité
> 
> - SMB est crucial pour les partages de fichiers Windows
> - Le port 445 doit être protégé (firewall, VLAN)
> - SMB v1 est obsolète et vulnérable (désactivez-le)

### Port 5985/5986 (WinRM)

```powershell
# Test WinRM HTTP (5985)
Test-NetConnection -ComputerName server01 -Port 5985
Test-NetConnection -ComputerName server01 -CommonTCPPort WINRM

# Test WinRM HTTPS (5986)
Test-NetConnection -ComputerName server01 -Port 5986

# Vérifier WinRM avant PowerShell Remoting
$servers = @("SRV01", "SRV02", "SRV03")
foreach ($srv in $servers) {
    $winrm = Test-NetConnection -ComputerName $srv -Port 5985 -InformationLevel Quiet
    if ($winrm) {
        Write-Host "✅ $srv : WinRM prêt pour remoting"
        # Vous pouvez ensuite utiliser Enter-PSSession ou Invoke-Command
    } else {
        Write-Host "❌ $srv : WinRM non accessible" -ForegroundColor Red
    }
}
```

### Tableau récapitulatif des ports

|Port|Service|CommonTCPPort|Usage principal|
|---|---|---|---|
|80|HTTP|`HTTP`|Serveurs web non sécurisés|
|443|HTTPS|_(aucun)_|Serveurs web sécurisés|
|3389|RDP|`RDP`|Bureau à distance Windows|
|445|SMB|`SMB`|Partages de fichiers réseau|
|5985|WinRM HTTP|`WINRM`|PowerShell Remoting|
|5986|WinRM HTTPS|_(aucun)_|PowerShell Remoting sécurisé|

---

## 🛡️ Diagnostic de firewall

`Test-NetConnection` est un outil précieux pour diagnostiquer les problèmes de firewall.

### Méthodologie de diagnostic

```powershell
# 1. Tester d'abord le ping (ICMP)
$ping = Test-NetConnection -ComputerName server01

if ($ping.PingSucceeded) {
    Write-Host "✅ Le serveur répond au ping (ICMP autorisé)"
    
    # 2. Tester ensuite le port spécifique
    $port = Test-NetConnection -ComputerName server01 -Port 443
    
    if ($port.TcpTestSucceeded) {
        Write-Host "✅ Le port 443 est ouvert"
    } else {
        Write-Host "❌ Le port 443 est bloqué (probablement firewall)" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Le serveur ne répond pas au ping" -ForegroundColor Yellow
    Write-Host "Causes possibles : firewall bloque ICMP, serveur éteint, problème réseau"
}
```

### Scénarios courants de blocage firewall

> [!example] Scénario 1 : ICMP bloqué, TCP autorisé
> 
> ```powershell
> $test = Test-NetConnection -ComputerName server01 -Port 443
> # PingSucceeded = False
> # TcpTestSucceeded = True
> ```
> 
> **Interprétation** : Le firewall bloque ICMP mais autorise le port 443. C'est courant sur Internet.

> [!example] Scénario 2 : ICMP autorisé, TCP bloqué
> 
> ```powershell
> $test = Test-NetConnection -ComputerName server01 -Port 3389
> # PingSucceeded = True
> # TcpTestSucceeded = False
> ```
> 
> **Interprétation** : Le serveur est joignable mais le port spécifique est bloqué par un firewall ou le service n'écoute pas.

### Script de diagnostic complet

```powershell
function Test-FirewallConnectivity {
    param(
        [string]$ComputerName,
        [int[]]$Ports = @(80, 443, 3389, 445, 5985)
    )
    
    Write-Host "`n=== Diagnostic firewall pour $ComputerName ===" -ForegroundColor Cyan
    
    # Test ICMP
    $icmp = Test-NetConnection -ComputerName $ComputerName -InformationLevel Quiet
    Write-Host "ICMP (Ping) : $(if($icmp){'✅ OK'}else{'❌ Bloqué'})"
    
    # Test ports
    foreach ($port in $Ports) {
        $tcp = Test-NetConnection -ComputerName $ComputerName -Port $port -InformationLevel Quiet -WarningAction SilentlyContinue
        $status = if($tcp){'✅ Ouvert'}else{'❌ Fermé/Filtré'}
        Write-Host "Port $port : $status"
    }
}

# Utilisation
Test-FirewallConnectivity -ComputerName "server01.contoso.com"
```

### Diagnostic avec TraceRoute

```powershell
# Identifier où le trafic est bloqué
$trace = Test-NetConnection -ComputerName remote-server.com -TraceRoute

Write-Host "Chemin réseau :"
$trace.TraceRoute | ForEach-Object -Begin { $hop = 1 } -Process {
    Write-Host "  Saut $hop : $_"
    $hop++
}

# Le dernier saut avant échec indique souvent le firewall bloquant
```

> [!tip] Astuces de diagnostic
> 
> - Si ICMP échoue mais le port fonctionne → Firewall bloque ICMP (normal sur Internet)
> - Si tout échoue → Vérifier la connectivité réseau de base, DNS, routage
> - Si des ports spécifiques échouent → Firewall applicatif ou service non démarré
> - Utiliser `-TraceRoute` pour identifier où le blocage se produit

---

## ✅ Vérification de services accessibles

Au-delà du simple test de port, `Test-NetConnection` permet de valider que les services critiques sont bien accessibles.

### Vérification post-déploiement

```powershell
# Après déploiement d'un serveur web
function Test-WebServerDeployment {
    param([string]$ServerName)
    
    Write-Host "`n=== Vérification du déploiement web sur $ServerName ===" -ForegroundColor Cyan
    
    # Vérifier HTTP
    $http = Test-NetConnection -ComputerName $ServerName -Port 80 -InformationLevel Quiet
    Write-Host "HTTP (80) : $(if($http){'✅ Accessible'}else{'❌ Inaccessible'})"
    
    # Vérifier HTTPS
    $https = Test-NetConnection -ComputerName $ServerName -Port 443 -InformationLevel Quiet
    Write-Host "HTTPS (443) : $(if($https){'✅ Accessible'}else{'❌ Inaccessible'})"
    
    # Vérifier RDP pour administration
    $rdp = Test-NetConnection -ComputerName $ServerName -Port 3389 -InformationLevel Quiet
    Write-Host "RDP (3389) : $(if($rdp){'✅ Accessible'}else{'❌ Inaccessible'})"
    
    # Résumé
    if ($http -and $https -and $rdp) {
        Write-Host "`n✅ Déploiement réussi - Tous les services sont accessibles" -ForegroundColor Green
        return $true
    } else {
        Write-Host "`n❌ Problèmes détectés - Vérifier la configuration" -ForegroundColor Red
        return $false
    }
}

# Utilisation
Test-WebServerDeployment -ServerName "webserver.contoso.com"
```

### Monitoring de services critiques

```powershell
# Script de monitoring à exécuter régulièrement
$criticalServices = @(
    @{Name="WebServer1"; Host="web01.contoso.com"; Port=443},
    @{Name="Database"; Host="sql01.contoso.com"; Port=1433},
    @{Name="FileServer"; Host="fs01.contoso.com"; Port=445},
    @{Name="DomainController"; Host="dc01.contoso.com"; Port=389}
)

foreach ($service in $criticalServices) {
    $test = Test-NetConnection -ComputerName $service.Host -Port $service.Port -InformationLevel Quiet -WarningAction SilentlyContinue
    
    if ($test) {
        Write-Host "✅ $($service.Name) : Opérationnel" -ForegroundColor Green
    } else {
        Write-Host "❌ $($service.Name) : INDISPONIBLE !" -ForegroundColor Red
        # Ici, vous pourriez envoyer une alerte email, SMS, etc.
    }
}
```

### Validation de configuration réseau

```powershell
# Vérifier que toutes les machines d'un cluster sont joignables
$clusterNodes = @("node1", "node2", "node3", "node4")
$requiredPorts = @(135, 445, 3389, 5985) # RPC, SMB, RDP, WinRM

Write-Host "=== Validation du cluster ===" -ForegroundColor Cyan

$allOK = $true
foreach ($node in $clusterNodes) {
    Write-Host "`nVérification de $node :"
    
    foreach ($port in $requiredPorts) {
        $test = Test-NetConnection -ComputerName $node -Port $port -InformationLevel Quiet -WarningAction SilentlyContinue
        
        if ($test) {
            Write-Host "  ✅ Port $port : OK" -ForegroundColor Green
        } else {
            Write-Host "  ❌ Port $port : ÉCHEC" -ForegroundColor Red
            $allOK = $false
        }
    }
}

if ($allOK) {
    Write-Host "`n✅ Cluster validé - Tous les nœuds sont correctement configurés" -ForegroundColor Green
} else {
    Write-Host "`n❌ Problèmes détectés dans le cluster" -ForegroundColor Red
}
```

---

## 🔧 Alternative graphique à telnet

`Test-NetConnection` remplace avantageusement l'ancienne commande `telnet` pour tester les ports.

### Pourquoi préférer Test-NetConnection à telnet ?

|Aspect|telnet|Test-NetConnection|
|---|---|---|
|**Disponibilité**|Doit être installé manuellement|Inclus par défaut|
|**Sortie**|Texte brut, difficile à parser|Objet PowerShell structuré|
|**Automatisation**|Difficile à scripter|Facile à intégrer dans scripts|
|**Informations**|Connexion seulement|Ping, traceroute, détails réseau|
|**Mode silencieux**|Non disponible|`-InformationLevel Quiet`|

### Comparaison des commandes

```powershell
# Ancienne méthode avec telnet (nécessite installation)
# telnet webserver.com 80
# Sortie interactive, difficile à scripter

# Nouvelle méthode avec Test-NetConnection
Test-NetConnection -ComputerName webserver.com -Port 80
# Retourne un objet PowerShell exploitable
```

### Test de port simple (équivalent telnet)

```powershell
# Test rapide : le port est-il ouvert ?
$result = Test-NetConnection -ComputerName server.com -Port 443 -InformationLevel Quiet

if ($result) {
    Write-Host "✅ Port 443 ouvert"
} else {
    Write-Host "❌ Port 443 fermé ou filtré"
}
```

### Script de test de ports multiples

```powershell
function Test-PortRange {
    param(
        [string]$ComputerName,
        [int[]]$Ports
    )
    
    Write-Host "Test des ports sur $ComputerName :" -ForegroundColor Cyan
    
    $results = foreach ($port in $Ports) {
        $test = Test-NetConnection -ComputerName $ComputerName -Port $port -InformationLevel Quiet -WarningAction SilentlyContinue
        
        [PSCustomObject]@{
            Port = $port
            Status = if($test){"Ouvert"}else{"Fermé"}
            Accessible = $test
        }
    }
    
    $results | Format-Table -AutoSize
}

# Utilisation : scanner les ports web courants
Test-PortRange -ComputerName "webserver.com" -Ports @(80, 443, 8080, 8443)
```

### Avantages pour l'automatisation

```powershell
# Exemple : tester une liste de serveurs et ports
$serversToTest = @(
    @{Host="web01"; Port=80},
    @{Host="web02"; Port=443},
    @{Host="db01"; Port=1433},
    @{Host="mail01"; Port=25}
)

$report = foreach ($server in $serversToTest) {
    $test = Test-NetConnection -ComputerName $server.Host -Port $server.Port -InformationLevel Quiet -WarningAction SilentlyContinue
    
    [PSCustomObject]@{
        Server = $server.Host
        Port = $server.Port
        Status = if($test){"✅ Accessible"}else{"❌ Inaccessible"}
        TestedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
}

# Exporter en CSV pour suivi
$report | Export-Csv -Path "C:\Logs\PortTests.csv" -NoTypeInformation -Append

# Afficher à l'écran
$report | Format-Table -AutoSize
```

---

## 🔍 Troubleshooting de connectivité

`Test-NetConnection` est l'outil idéal pour diagnostiquer méthodiquement les problèmes réseau.

### Méthodologie de troubleshooting en 5 étapes

```powershell
function Invoke-ConnectivityTroubleshooting {
    param(
        [string]$TargetHost,
        [int]$TargetPort = 443
    )
    
    Write-Host "`n=== Diagnostic de connectivité vers $TargetHost ===" -ForegroundColor Cyan
    
    # ÉTAPE 1 : Résolution DNS
    Write-Host "`n[1/5] Résolution DNS..." -ForegroundColor Yellow
    try {
        $dns = Resolve-DnsName -Name $TargetHost -ErrorAction Stop
        Write-Host "✅ DNS résolu : $($dns.IPAddress -join ', ')" -ForegroundColor Green
    } catch {
        Write-Host "❌ ÉCHEC : Impossible de résoudre le nom DNS" -ForegroundColor Red
        Write-Host "   Vérifier : Configuration DNS, connectivité au serveur DNS"
        return
    }
    
    # ÉTAPE 2 : Test ICMP (Ping)
    Write-Host "`n[2/5] Test ICMP (Ping)..." -ForegroundColor Yellow
    $ping = Test-NetConnection -ComputerName $TargetHost -InformationLevel Quiet
    if ($ping) {
        Write-Host "✅ Ping réussi" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Ping échoué (peut être normal si ICMP est bloqué)" -ForegroundColor Yellow
    }
    
    # ÉTAPE 3 : Test du port TCP
    Write-Host "`n[3/5] Test du port $TargetPort..." -ForegroundColor Yellow
    $port = Test-NetConnection -ComputerName $TargetHost -Port $TargetPort -WarningAction SilentlyContinue
    if ($port.TcpTestSucceeded) {
        Write-Host "✅ Port $TargetPort accessible" -ForegroundColor Green
    } else {
        Write-Host "❌ Port $TargetPort inaccessible" -ForegroundColor Red
        Write-Host "   Causes possibles : Firewall, service non démarré, mauvais port"
    }
    
    # ÉTAPE 4 : Vérification de la route réseau
    Write-Host "`n[4/5] Analyse de la route réseau..." -ForegroundColor Yellow
    $trace = Test-NetConnection -ComputerName $TargetHost -TraceRoute -WarningAction SilentlyContinue
    if ($trace.TraceRoute) {
        Write-Host "✅ Traceroute effectué ($($trace.TraceRoute.Count) sauts)"
        Write-Host "   Dernier saut : $($trace.TraceRoute[-1])"
    }
    
    # ÉTAPE 5 : Informations réseau locales
    Write-Host "`n[5/5] Informations réseau locales..." -ForegroundColor Yellow
    Write-Host "   Interface source : $($port.InterfaceAlias)"
    Write-Host "   Adresse IP source : $($port.SourceAddress)"
    Write-Host "   Adresse IP cible : $($port.RemoteAddress)"
    
    # RÉSUMÉ
    Write-Host "`n=== RÉSUMÉ ===" -ForegroundColor Cyan
    if ($port.TcpTestSucceeded) {
        Write-Host "✅ DIAGNOSTIC : Connectivité OK" -ForegroundColor Green
    } else {
        Write-Host "❌ DIAGNOSTIC : Problème de connectivité détecté" -ForegroundColor Red
        Write-Host "`nActions recommandées :"
        if (-not $dns) {
            Write-Host "  1. Vérifier la configuration DNS"
        }
        if (-not $ping) {
            Write-Host "  2. Vérifier la connectivité réseau de base"
        }
        if (-not $port.TcpTestSucceeded) {
            Write-Host "  3. Vérifier le firewall et que le service écoute sur le port $TargetPort"
        }
    }
}

# Utilisation
Invoke-ConnectivityTroubleshooting -TargetHost "webserver.contoso.com" -TargetPort 443
```

### Diagnostic par couche réseau

```powershell
# Approche systématique par couche OSI
function Test-NetworkLayers {
    param([string]$Target)
    
    Write-Host "`n=== Diagnostic par couches réseau ===" -ForegroundColor Cyan
    
    # Couche 3 : Réseau (IP)
    Write-Host "`n📍 Couche 3 (Réseau) - Test ICMP"
    $layer3 = Test-NetConnection -ComputerName $Target
    if ($layer3.PingSucceeded) {
        Write-Host "  ✅ Connectivité IP OK (RTT: $($layer3.PingReplyDetails.RoundtripTime)ms)"
    } else {
        Write-Host "  ❌ Pas de réponse ICMP"
        return
    }
    
    # Couche 4 : Transport (TCP)
    Write-Host "`n📍 Couche 4 (Transport) - Test TCP"
    $layer4 = Test-NetConnection -ComputerName $Target -Port 443
    if ($layer4.TcpTestSucceeded) {
        Write-Host "  ✅ Connexion TCP établie sur le port 443"
    } else {
        Write-Host "  ❌ Connexion TCP échouée"
    }
    
    # Analyse de la route
    Write-Host "`n🗺️  Analyse du chemin réseau"
    $route = Test-NetConnection -ComputerName $Target -TraceRoute
    Write-Host "  Nombre de sauts : $($route.TraceRoute.Count)"
    Write-Host "  Passerelle : $($route.TraceRoute[0])"
}

# Utilisation
Test-NetworkLayers -Target "google.com"
```

### Diagnostic de latence

```powershell
# Mesurer la latence sur plusieurs tests
function Measure-NetworkLatency {
    param(
        [string]$ComputerName,
        [int]$Count = 10
    )
    
    Write-Host "Mesure de latence vers $ComputerName ($Count tests)..." -ForegroundColor Cyan
    
    $latencies = @()
    
    for ($i = 1; $i -le $Count; $i++) {
        $test = Test-NetConnection -ComputerName $ComputerName -InformationLevel Detailed
        if ($test.PingSucceeded) {
            $rtt = $test.PingReplyDetails.RoundtripTime
            $latencies += $rtt
            Write-Host "  Test $i : $rtt ms"
        }
        Start-Sleep -Milliseconds 500
    }
    
    if ($latencies.Count -gt 0) {
        $stats = $latencies | Measure-Object -Average -Minimum -Maximum
        
        Write-Host "`n📊 Statistiques :" -ForegroundColor Cyan
        Write-Host "  Minimum   : $($stats.Minimum) ms"
        Write-Host "  Maximum   : $($stats.Maximum) ms"
        Write-Host "  Moyenne   : $([math]::Round($stats.Average, 2)) ms"
        Write-Host "  Packets   : $($latencies.Count)/$Count"
        
        # Évaluation de la qualité
        $avgLatency = $stats.Average
        if ($avgLatency -lt 50) {
            Write-Host "`n✅ Excellente latence" -ForegroundColor Green
        } elseif ($avgLatency -lt 100) {
            Write-Host "`n✅ Bonne latence" -ForegroundColor Green
        } elseif ($avgLatency -lt 200) {
            Write-Host "`n⚠️  Latence moyenne" -ForegroundColor Yellow
        } else {
            Write-Host "`n❌ Latence élevée" -ForegroundColor Red
        }
    }
}

# Utilisation
Measure-NetworkLatency -ComputerName "dns.google" -Count 10
```

### Diagnostic de perte de paquets

```powershell
# Détecter les pertes de paquets
function Test-PacketLoss {
    param(
        [string]$ComputerName,
        [int]$Count = 20
    )
    
    Write-Host "Test de perte de paquets vers $ComputerName..." -ForegroundColor Cyan
    
    $successful = 0
    $failed = 0
    
    for ($i = 1; $i -le $Count; $i++) {
        $test = Test-NetConnection -ComputerName $ComputerName -InformationLevel Quiet
        
        if ($test) {
            $successful++
            Write-Host "." -NoNewline -ForegroundColor Green
        } else {
            $failed++
            Write-Host "X" -NoNewline -ForegroundColor Red
        }
        
        Start-Sleep -Milliseconds 200
    }
    
    $lossPercent = ($failed / $Count) * 100
    
    Write-Host "`n`n📊 Résultats :" -ForegroundColor Cyan
    Write-Host "  Paquets envoyés : $Count"
    Write-Host "  Reçus           : $successful"
    Write-Host "  Perdus          : $failed ($([math]::Round($lossPercent, 2))%)"
    
    if ($lossPercent -eq 0) {
        Write-Host "`n✅ Aucune perte de paquets" -ForegroundColor Green
    } elseif ($lossPercent -lt 5) {
        Write-Host "`n⚠️  Perte mineure de paquets" -ForegroundColor Yellow
    } else {
        Write-Host "`n❌ Perte significative de paquets - Problème réseau" -ForegroundColor Red
    }
}

# Utilisation
Test-PacketLoss -ComputerName "8.8.8.8" -Count 20
```

---

## 💡 Exemples de tests complets

### Exemple 1 : Audit de sécurité réseau

```powershell
# Script d'audit de sécurité pour identifier les ports ouverts
function Invoke-SecurityAudit {
    param(
        [string]$TargetHost,
        [int[]]$PortsToScan = @(21, 22, 23, 25, 80, 110, 135, 139, 143, 443, 445, 3389, 5985, 8080)
    )
    
    Write-Host "`n=== AUDIT DE SÉCURITÉ : $TargetHost ===" -ForegroundColor Cyan
    Write-Host "Date : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
    
    $openPorts = @()
    $closedPorts = @()
    
    foreach ($port in $PortsToScan) {
        Write-Host "Scan du port $port..." -NoNewline
        
        $test = Test-NetConnection -ComputerName $TargetHost -Port $port -InformationLevel Quiet -WarningAction SilentlyContinue
        
        if ($test) {
            Write-Host " ⚠️  OUVERT" -ForegroundColor Yellow
            $openPorts += $port
        } else {
            Write-Host " ✅ Fermé" -ForegroundColor Green
            $closedPorts += $port
        }
    }
    
    # Rapport de sécurité
    Write-Host "`n=== RAPPORT DE SÉCURITÉ ===" -ForegroundColor Cyan
    Write-Host "Ports ouverts : $($openPorts.Count)"
    Write-Host "Ports fermés  : $($closedPorts.Count)"
    
    if ($openPorts.Count -gt 0) {
        Write-Host "`n⚠️  PORTS OUVERTS DÉTECTÉS :" -ForegroundColor Yellow
        foreach ($port in $openPorts) {
            $service = switch ($port) {
                21 { "FTP" }
                22 { "SSH" }
                23 { "Telnet (NON SÉCURISÉ)" }
                25 { "SMTP" }
                80 { "HTTP" }
                110 { "POP3" }
                135 { "RPC" }
                139 { "NetBIOS" }
                143 { "IMAP" }
                443 { "HTTPS" }
                445 { "SMB" }
                3389 { "RDP" }
                5985 { "WinRM" }
                8080 { "HTTP-Alt" }
                default { "Inconnu" }
            }
            Write-Host "  Port $port : $service"
        }
        
        # Recommandations
        Write-Host "`n📋 RECOMMANDATIONS :" -ForegroundColor Cyan
        if (23 -in $openPorts) {
            Write-Host "  🔴 CRITIQUE : Telnet (port 23) est ouvert - Désactiver immédiatement"
        }
        if (21 -in $openPorts) {
            Write-Host "  ⚠️  FTP (port 21) est ouvert - Considérer SFTP/FTPS"
        }
        if (3389 -in $openPorts) {
            Write-Host "  ⚠️  RDP (port 3389) est ouvert - Restreindre l'accès ou utiliser un VPN"
        }
        if (445 -in $openPorts) {
            Write-Host "  ⚠️  SMB (port 445) est ouvert - Vérifier les ACL et désactiver SMBv1"
        }
    } else {
        Write-Host "`n✅ Aucun port ouvert détecté dans la liste scannée" -ForegroundColor Green
    }
    
    # Export du rapport
    $report = [PSCustomObject]@{
        Target = $TargetHost
        ScanDate = Get-Date
        OpenPorts = $openPorts -join ', '
        ClosedPorts = $closedPorts -join ', '
    }
    
    return $report
}

# Utilisation
$auditResult = Invoke-SecurityAudit -TargetHost "server01.contoso.com"
$auditResult | Export-Csv -Path "C:\Audits\SecurityAudit_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation
```

### Exemple 2 : Validation de haute disponibilité

```powershell
# Vérifier la redondance et la disponibilité des services critiques
function Test-HighAvailability {
    param(
        [string[]]$PrimaryServers,
        [string[]]$SecondaryServers,
        [int]$ServicePort = 443
    )
    
    Write-Host "`n=== TEST DE HAUTE DISPONIBILITÉ ===" -ForegroundColor Cyan
    
    # Test des serveurs primaires
    Write-Host "`n📍 Serveurs primaires :" -ForegroundColor Yellow
    $primaryStatus = @()
    foreach ($server in $PrimaryServers) {
        $test = Test-NetConnection -ComputerName $server -Port $ServicePort -InformationLevel Quiet -WarningAction SilentlyContinue
        $status = if($test){"✅ Opérationnel"}else{"❌ Indisponible"}
        Write-Host "  $server : $status"
        $primaryStatus += $test
    }
    
    # Test des serveurs secondaires
    Write-Host "`n📍 Serveurs secondaires (backup) :" -ForegroundColor Yellow
    $secondaryStatus = @()
    foreach ($server in $SecondaryServers) {
        $test = Test-NetConnection -ComputerName $server -Port $ServicePort -InformationLevel Quiet -WarningAction SilentlyContinue
        $status = if($test){"✅ Opérationnel"}else{"❌ Indisponible"}
        Write-Host "  $server : $status"
        $secondaryStatus += $test
    }
    
    # Analyse de disponibilité
    $primaryAvailable = ($primaryStatus | Where-Object {$_}).Count
    $secondaryAvailable = ($secondaryStatus | Where-Object {$_}).Count
    $totalPrimary = $PrimaryServers.Count
    $totalSecondary = $SecondaryServers.Count
    
    Write-Host "`n📊 ANALYSE :" -ForegroundColor Cyan
    Write-Host "  Primaires disponibles   : $primaryAvailable/$totalPrimary"
    Write-Host "  Secondaires disponibles : $secondaryAvailable/$totalSecondary"
    
    # Évaluation du niveau de service
    if ($primaryAvailable -eq $totalPrimary -and $secondaryAvailable -eq $totalSecondary) {
        Write-Host "`n✅ EXCELLENT : Redondance complète assurée" -ForegroundColor Green
    } elseif ($primaryAvailable -gt 0 -and $secondaryAvailable -gt 0) {
        Write-Host "`n⚠️  ACCEPTABLE : Service disponible mais redondance partielle" -ForegroundColor Yellow
    } elseif ($primaryAvailable -gt 0) {
        Write-Host "`n⚠️  RISQUE : Aucun backup disponible" -ForegroundColor Yellow
    } else {
        Write-Host "`n🔴 CRITIQUE : Service totalement indisponible !" -ForegroundColor Red
    }
}

# Utilisation
Test-HighAvailability `
    -PrimaryServers @("web01.contoso.com", "web02.contoso.com") `
    -SecondaryServers @("web03.contoso.com", "web04.contoso.com") `
    -ServicePort 443
```

### Exemple 3 : Monitoring continu avec alertes

```powershell
# Script de monitoring avec log et alertes
function Start-ContinuousMonitoring {
    param(
        [hashtable[]]$Targets,
        [int]$IntervalSeconds = 300,
        [string]$LogPath = "C:\Logs\NetworkMonitoring.log"
    )
    
    Write-Host "🔍 Démarrage du monitoring continu..." -ForegroundColor Cyan
    Write-Host "Intervalle : $IntervalSeconds secondes"
    Write-Host "Log : $LogPath`n"
    
    while ($true) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        
        foreach ($target in $Targets) {
            $test = Test-NetConnection -ComputerName $target.Host -Port $target.Port -InformationLevel Quiet -WarningAction SilentlyContinue
            
            $status = if($test){"OK"}else{"FAILED"}
            $logEntry = "$timestamp | $($target.Name) | $($target.Host):$($target.Port) | $status"
            
            # Écrire dans le log
            Add-Content -Path $LogPath -Value $logEntry
            
            # Affichage console
            if ($test) {
                Write-Host "[$timestamp] ✅ $($target.Name)" -ForegroundColor Green
            } else {
                Write-Host "[$timestamp] ❌ $($target.Name) - ALERTE !" -ForegroundColor Red
                
                # Ici, vous pourriez envoyer une alerte
                # Send-MailMessage -To "admin@contoso.com" -Subject "ALERTE" -Body $logEntry
            }
        }
        
        Write-Host "`nProchain test dans $IntervalSeconds secondes...`n"
        Start-Sleep -Seconds $IntervalSeconds
    }
}

# Configuration des cibles à monitorer
$monitoringTargets = @(
    @{Name="WebServer1"; Host="web01.contoso.com"; Port=443},
    @{Name="WebServer2"; Host="web02.contoso.com"; Port=443},
    @{Name="Database"; Host="sql01.contoso.com"; Port=1433},
    @{Name="FileServer"; Host="fs01.contoso.com"; Port=445}
)

# Lancer le monitoring (Ctrl+C pour arrêter)
# Start-ContinuousMonitoring -Targets $monitoringTargets -IntervalSeconds 300
```

### Exemple 4 : Rapport de santé réseau complet

```powershell
# Générer un rapport HTML de santé réseau
function New-NetworkHealthReport {
    param(
        [hashtable[]]$Servers,
        [string]$OutputPath = "C:\Reports\NetworkHealth.html"
    )
    
    Write-Host "📄 Génération du rapport de santé réseau..." -ForegroundColor Cyan
    
    $results = foreach ($server in $Servers) {
        Write-Host "  Analyse de $($server.Name)..." -NoNewline
        
        $test = Test-NetConnection -ComputerName $server.Host -Port $server.Port -InformationLevel Detailed -WarningAction SilentlyContinue
        
        [PSCustomObject]@{
            Name = $server.Name
            Host = $server.Host
            Port = $server.Port
            PingStatus = if($test.PingSucceeded){"✅ OK"}else{"❌ FAILED"}
            PortStatus = if($test.TcpTestSucceeded){"✅ Open"}else{"❌ Closed"}
            Latency = if($test.PingSucceeded){"$($test.PingReplyDetails.RoundtripTime) ms"}else{"N/A"}
            IPAddress = $test.RemoteAddress
            TestedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
        
        Write-Host " ✅" -ForegroundColor Green
    }
    
    # Générer HTML
    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Rapport de Santé Réseau</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #2c3e50; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th { background-color: #3498db; color: white; padding: 12px; text-align: left; }
        td { border: 1px solid #ddd; padding: 10px; }
        tr:nth-child(even) { background-color: #f2f2f2; }
        .timestamp { color: #7f8c8d; font-size: 0.9em; }
    </style>
</head>
<body>
    <h1>🏥 Rapport de Santé Réseau</h1>
    <p class="timestamp">Généré le : $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")</p>
    
    <table>
        <thead>
            <tr>
                <th>Nom</th>
                <th>Hôte</th>
                <th>Port</th>
                <th>Ping</th>
                <th>Port</th>
                <th>Latence</th>
                <th>IP</th>
            </tr>
        </thead>
        <tbody>
"@
    
    foreach ($result in $results) {
        $html += @"
            <tr>
                <td>$($result.Name)</td>
                <td>$($result.Host)</td>
                <td>$($result.Port)</td>
                <td>$($result.PingStatus)</td>
                <td>$($result.PortStatus)</td>
                <td>$($result.Latency)</td>
                <td>$($result.IPAddress)</td>
            </tr>
"@
    }
    
    $html += @"
        </tbody>
    </table>
</body>
</html>
"@
    
    $html | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Host "`n✅ Rapport généré : $OutputPath" -ForegroundColor Green
    
    # Ouvrir le rapport
    Start-Process $OutputPath
}

# Configuration
$serversToTest = @(
    @{Name="Serveur Web Principal"; Host="web01.contoso.com"; Port=443},
    @{Name="Serveur Web Backup"; Host="web02.contoso.com"; Port=443},
    @{Name="Base de Données"; Host="sql01.contoso.com"; Port=1433},
    @{Name="Serveur de Fichiers"; Host="fs01.contoso.com"; Port=445},
    @{Name="Contrôleur de Domaine"; Host="dc01.contoso.com"; Port=389}
)

# Générer le rapport
New-NetworkHealthReport -Servers $serversToTest
```

---

## ⚠️ Pièges courants

### 1. Firewall Windows bloque ICMP localement

```powershell
# Problème : Test-NetConnection échoue sur la machine locale
Test-NetConnection -ComputerName localhost
# PingSucceeded : False

# Solution : Créer une règle de pare-feu pour autoriser ICMP
New-NetFirewallRule -DisplayName "Allow ICMPv4" `
    -Protocol ICMPv4 `
    -IcmpType 8 `
    -Action Allow
```

> [!warning] Attention Ne pas confondre l'échec du ping avec l'indisponibilité du service. Testez toujours le port spécifique avec `-Port`.

### 2. Timeout trop court pour réseaux lents

```powershell
# Problème : Test échoue sur connexions lentes
# Test-NetConnection n'a pas de paramètre -Timeout explicite

# Solution : Utiliser Test-Connection pour contrôler le timeout
$pingTest = Test-Connection -ComputerName "remote-server.com" -Count 1 -Quiet -TimeoutSeconds 10

if ($pingTest) {
    # Puis faire le test de port
    Test-NetConnection -ComputerName "remote-server.com" -Port 443
}
```

### 3. Résultats cachés par WarningAction

```powershell
# Problème : Warnings encombrent la sortie
Test-NetConnection -ComputerName "inexistant.local" -Port 443
# WARNING: TCP connect to (inexistant.local : 443) failed

# Solution : Supprimer les warnings dans les scripts
Test-NetConnection -ComputerName "inexistant.local" -Port 443 -WarningAction SilentlyContinue
```

### 4. Confusion entre ping réussi et port accessible

```powershell
# PIÈGE : Penser que le ping valide l'accès au service
$test = Test-NetConnection -ComputerName "server01"

# ❌ MAUVAIS : Se baser uniquement sur PingSucceeded
if ($test.PingSucceeded) {
    Write-Host "Service accessible" # FAUX !
}

# ✅ BON : Vérifier le port spécifique
$test = Test-NetConnection -ComputerName "server01" -Port 443
if ($test.TcpTestSucceeded) {
    Write-Host "Service HTTPS réellement accessible"
}
```

### 5. Ne pas gérer les erreurs réseau

```powershell
# ❌ MAUVAIS : Pas de gestion d'erreur
$test = Test-NetConnection -ComputerName $unresolvedHost -Port 443
# Peut générer des erreurs non gérées

# ✅ BON : Gestion avec try/catch
try {
    $test = Test-NetConnection -ComputerName $serverName -Port 443 -ErrorAction Stop -WarningAction SilentlyContinue
    
    if ($test.TcpTestSucceeded) {
        Write-Host "✅ Connexion réussie"
    }
} catch {
    Write-Host "❌ Erreur lors du test : $($_.Exception.Message)" -ForegroundColor Red
}
```

### 6. Oublier que TraceRoute nécessite des privilèges

```powershell
# Problème : TraceRoute échoue sans droits admin
Test-NetConnection -ComputerName "google.com" -TraceRoute
# Peut échouer si non-admin

# Solution : Vérifier les privilèges avant
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    Test-NetConnection -ComputerName "google.com" -TraceRoute
} else {
    Write-Host "⚠️  TraceRoute nécessite des privilèges administrateur" -ForegroundColor Yellow
    Test-NetConnection -ComputerName "google.com" -Port 443
}
```

### 7. Tests en boucle sans délai

```powershell
# ❌ MAUVAIS : Saturer le réseau
for ($i = 1; $i -le 100; $i++) {
    Test-NetConnection -ComputerName "server" -Port 443
}

# ✅ BON : Ajouter des délais
for ($i = 1; $i -le 100; $i++) {
    Test-NetConnection -ComputerName "server" -Port 443 -InformationLevel Quiet
    Start-Sleep -Milliseconds 500 # Pause entre tests
}
```

---

## ✅ Bonnes pratiques

### 1. Toujours utiliser -InformationLevel Quiet dans les scripts

```powershell
# ✅ Pour les scripts automatisés
$result = Test-NetConnection -ComputerName "server" -Port 443 -InformationLevel Quiet

if ($result) {
    # Logique si accessible
} else {
    # Logique si inaccessible
}
```

### 2. Combiner avec Test-Connection pour plus de contrôle

```powershell
# ✅ Test robuste avec timeout personnalisé
function Test-ServerAvailability {
    param(
        [string]$ComputerName,
        [int]$Port,
        [int]$TimeoutSeconds = 5
    )
    
    # D'abord, test ICMP rapide avec timeout
    $ping = Test-Connection -ComputerName $ComputerName -Count 1 -Quiet -TimeoutSeconds $TimeoutSeconds
    
    if (-not $ping) {
        return $false
    }
    
    # Ensuite, test du port
    $portTest = Test-NetConnection -ComputerName $ComputerName -Port $Port -InformationLevel Quiet -WarningAction SilentlyContinue
    
    return $portTest
}
```

### 3. Logger les résultats pour historique

```powershell
# ✅ Logging structuré
function Test-AndLog {
    param(
        [string]$ComputerName,
        [int]$Port,
        [string]$LogPath = "C:\Logs\connectivity.log"
    )
    
    $test = Test-NetConnection -ComputerName $ComputerName -Port $Port -WarningAction SilentlyContinue
    
    $logEntry = [PSCustomObject]@{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Target = $ComputerName
        Port = $Port
        PingSuccess = $test.PingSucceeded
        PortOpen = $test.TcpTestSucceeded
        Latency = if($test.PingSucceeded){$test.PingReplyDetails.RoundtripTime}else{$null}
        IP = $test.RemoteAddress
    }
    
    $logEntry | Export-Csv -Path $LogPath -Append -NoTypeInformation
    
    return $test
}
```

### 4. Créer des fonctions réutilisables

```powershell
# ✅ Fonction générique pour tests multiples
function Test-MultipleServices {
    param(
        [Parameter(Mandatory)]
        [hashtable[]]$Services
    )
    
    $results = foreach ($service in $Services) {
        $test = Test-NetConnection `
            -ComputerName $service.Host `
            -Port $service.Port `
            -InformationLevel Quiet `
            -WarningAction SilentlyContinue
        
        [PSCustomObject]@{
            ServiceName = $service.Name
            Host = $service.Host
            Port = $service.Port
            Status = if($test){"✅ OK"}else{"❌ FAIL"}
            Available = $test
        }
    }
    
    return $results
}

# Utilisation
$services = @(
    @{Name="Web"; Host="web01"; Port=443},
    @{Name="DB"; Host="sql01"; Port=1433}
)

Test-MultipleServices -Services $services | Format-Table
```

### 5. Utiliser des paramètres splatting pour lisibilité

```powershell
# ❌ Difficile à lire
Test-NetConnection -ComputerName "server.contoso.com" -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue -ErrorAction Stop

# ✅ Lisible avec splatting
$testParams = @{
    ComputerName = "server.contoso.com"
    Port = 443
    InformationLevel = "Quiet"
    WarningAction = "SilentlyContinue"
    ErrorAction = "Stop"
}

Test-NetConnection @testParams
```

### 6. Documenter les dépendances de services

```powershell
# ✅ Carte des dépendances de services
$serviceDependencies = @{
    "WebApp" = @(
        @{Name="LoadBalancer"; Host="lb01.contoso.com"; Port=443},
        @{Name="Database"; Host="sql01.contoso.com"; Port=1433},
        @{Name="FileStorage"; Host="fs01.contoso.com"; Port=445}
    )
}

foreach ($service in $serviceDependencies.Keys) {
    Write-Host "`n=== Vérification des dépendances de $service ===" -ForegroundColor Cyan
    
    $allOK = $true
    foreach ($dep in $serviceDependencies[$service]) {
        $test = Test-NetConnection -ComputerName $dep.Host -Port $dep.Port -InformationLevel Quiet -WarningAction SilentlyContinue
        
        if ($test) {
            Write-Host "  ✅ $($dep.Name) : OK"
        } else {
            Write-Host "  ❌ $($dep.Name) : ÉCHEC" -ForegroundColor Red
            $allOK = $false
        }
    }
    
    if ($allOK) {
        Write-Host "`n✅ Toutes les dépendances de $service sont satisfaites" -ForegroundColor Green
    } else {
        Write-Host "`n❌ $service ne peut pas démarrer - Dépendances manquantes" -ForegroundColor Red
    }
}
```

### 7. Implémenter une stratégie de retry

```powershell
# ✅ Retry avec backoff exponentiel
function Test-NetConnectionWithRetry {
    param(
        [string]$ComputerName,
        [int]$Port,
        [int]$MaxRetries = 3,
        [int]$InitialDelaySeconds = 2
    )
    
    $attempt = 1
    $delay = $InitialDelaySeconds
    
    while ($attempt -le $MaxRetries) {
        Write-Host "Tentative $attempt/$MaxRetries..." -NoNewline
        
        $test = Test-NetConnection -ComputerName $ComputerName -Port $Port -InformationLevel Quiet -WarningAction SilentlyContinue
        
        if ($test) {
            Write-Host " ✅ Succès" -ForegroundColor Green
            return $true
        } else {
            Write-Host " ❌ Échec" -ForegroundColor Red
            
            if ($attempt -lt $MaxRetries) {
                Write-Host "  Nouvelle tentative dans $delay secondes..."
                Start-Sleep -Seconds $delay
                $delay = $delay * 2 # Backoff exponentiel
            }
        }
        
        $attempt++
    }
    
    Write-Host "❌ Échec après $MaxRetries tentatives" -ForegroundColor Red
    return $false
}

# Utilisation
Test-NetConnectionWithRetry -ComputerName "unstable-server.com" -Port 443 -MaxRetries 5
```

---

## 💡 Astuces

### Astuce 1 : Tester sans attendre la résolution DNS

```powershell
# Si vous connaissez déjà l'IP, gagnez du temps
Test-NetConnection -ComputerName 192.168.1.100 -Port 443
# Plus rapide que d'utiliser le nom d'hôte
```

### Astuce 2 : Créer un alias pour les tests fréquents

```powershell
# Créer un alias court
function tnc { Test-NetConnection @args }

# Utilisation rapide
tnc google.com -Port 443
```

### Astuce 3 : Combiner avec Where-Object pour filtrer

```powershell
# Trouver tous les serveurs d'une liste qui répondent sur le port 443
$servers = @("web01", "web02", "web03", "web04")

$available = $servers | Where-Object {
    Test-NetConnection -ComputerName $_ -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue
}

Write-Host "Serveurs disponibles : $($available -join ', ')"
```

### Astuce 4 : Export rapide en CSV pour Excel

```powershell
# Tester plusieurs serveurs et exporter en CSV
$servers = @("srv01", "srv02", "srv03")

$results = $servers | ForEach-Object {
    $test = Test-NetConnection -ComputerName $_ -Port 443 -WarningAction SilentlyContinue
    
    [PSCustomObject]@{
        Server = $_
        IP = $test.RemoteAddress
        Ping = $test.PingSucceeded
        HTTPS = $test.TcpTestSucceeded
        Latency = if($test.PingSucceeded){$test.PingReplyDetails.RoundtripTime}else{"N/A"}
    }
}

$results | Export-Csv -Path "servers-test.csv" -NoTypeInformation
$results | Format-Table -AutoSize
```

### Astuce 5 : Utiliser -InformationLevel Detailed pour debug

```powershell
# En cas de problème, obtenez toutes les informations
Test-NetConnection -ComputerName problematic-server -Port 443 -InformationLevel Detailed

# Vous verrez :
# - Toutes les tentatives de connexion
# - Les détails de routage
# - Les informations d'interface
# - Les temps de réponse détaillés
```

### Astuce 6 : Intégration avec Pester pour tests automatisés

```powershell
# Tests d'infrastructure avec Pester
Describe "Infrastructure Tests" {
    It "Web server should be accessible on port 443" {
        $test = Test-NetConnection -ComputerName "web01.contoso.com" -Port 443 -InformationLevel Quiet
        $test | Should -Be $true
    }
    
    It "Database server should be accessible on port 1433" {
        $test = Test-NetConnection -ComputerName "sql01.contoso.com" -Port 1433 -InformationLevel Quiet
        $test | Should -Be $true
    }
}

# Exécuter les tests
Invoke-Pester
```

### Astuce 7 : Variable automatique $? pour vérification rapide

```powershell
# Test rapide avec vérification d'erreur
Test-NetConnection -ComputerName "server" -Port 443 -InformationLevel Quiet | Out-Null

if ($?) {
    Write-Host "✅ Test réussi"
} else {
    Write-Host "❌ Test échoué"
}
```

### Astuce 8 : Mesurer le temps d'exécution

```powershell
# Mesurer la performance du test
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

Test-NetConnection -ComputerName "remote-server.com" -Port 443 | Out-Null

$stopwatch.Stop()
Write-Host "Temps d'exécution : $($stopwatch.ElapsedMilliseconds) ms"
```

### Astuce 9 : Créer un tableau de bord PowerShell

```powershell
# Mini tableau de bord dans la console
function Show-ServiceDashboard {
    $services = @(
        @{Name="Web"; Host="web01"; Port=443},
        @{Name="API"; Host="api01"; Port=8080},
        @{Name="DB"; Host="sql01"; Port=1433}
    )
    
    Clear-Host
    Write-Host "╔════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║    TABLEAU DE BORD SERVICES        ║" -ForegroundColor Cyan
    Write-Host "║    $(Get-Date -Format 'HH:mm:ss')                      ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    foreach ($svc in $services) {
        $test = Test-NetConnection -ComputerName $svc.Host -Port $svc.Port -InformationLevel Quiet -WarningAction SilentlyContinue
        
        $status = if($test){"🟢 ONLINE "}else{"🔴 OFFLINE"}
        Write-Host "  $($svc.Name.PadRight(10)) : $status" -ForegroundColor $(if($test){"Green"}else{"Red"})
    }
}

# Rafraîchir toutes les 30 secondes
while ($true) {
    Show-ServiceDashboard
    Start-Sleep -Seconds 30
}
```

### Astuce 10 : Utiliser avec Invoke-Command pour tests distants

```powershell
# Tester depuis plusieurs machines sources
$sourceMachines = @("client01", "client02", "client03")

foreach ($source in $sourceMachines) {
    Write-Host "`nTest depuis $source :" -ForegroundColor Cyan
    
    Invoke-Command -ComputerName $source -ScriptBlock {
        param($target, $port)
        Test-NetConnection -ComputerName $target -Port $port -InformationLevel Quiet
    } -ArgumentList "webserver.com", 443
}
```

---

## 📚 Résumé des commandes essentielles

```powershell
# Test basique avec ping et résolution DNS
Test-NetConnection -ComputerName google.com

# Test d'un port spécifique
Test-NetConnection -ComputerName server01 -Port 443

# Test avec port commun
Test-NetConnection -ComputerName server01 -CommonTCPPort RDP

# Mode silencieux pour scripts
Test-NetConnection -ComputerName server01 -Port 443 -InformationLevel Quiet

# Avec traceroute
Test-NetConnection -ComputerName remote.com -TraceRoute

# Suppression des warnings
Test-NetConnection -ComputerName server01 -Port 443 -WarningAction SilentlyContinue

# Test détaillé pour debug
Test-NetConnection -ComputerName server01 -Port 443 -InformationLevel Detailed
```

---

> [!tip] Rappel important `Test-NetConnection` est votre outil principal pour le diagnostic réseau moderne dans PowerShell. Il remplace avantageusement ping, telnet et tracert tout en offrant une intégration parfaite avec PowerShell.

---

**🎓 Points clés à retenir :**

1. **Polyvalence** : Un seul outil pour ping, test de port, et traceroute
2. **Orienté objet** : Exploitez les propriétés retournées dans vos scripts
3. **Mode silencieux** : Utilisez `-InformationLevel Quiet` pour l'automatisation
4. **Gestion d'erreurs** : Toujours supprimer les warnings avec `-WarningAction SilentlyContinue`
5. **Diagnostic méthodique** : Testez d'abord ICMP, puis le port spécifique
6. **Logging** : Conservez un historique de vos tests pour analyse
7. **Retry logic** : Implémentez des tentatives multiples pour les réseaux instables