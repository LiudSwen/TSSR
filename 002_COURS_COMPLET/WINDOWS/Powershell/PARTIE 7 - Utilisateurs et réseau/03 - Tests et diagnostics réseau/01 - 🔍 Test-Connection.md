

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

## 🎯 Introduction {#introduction}

Les tests et diagnostics réseau constituent une compétence essentielle pour tout administrateur système. PowerShell modernise ces opérations avec `Test-Connection`, une cmdlet qui remplace avantageusement la commande `ping` traditionnelle tout en offrant des capacités bien supérieures.

> [!info] Pourquoi Test-Connection plutôt que ping ?
> 
> - Retourne des objets structurés exploitables en pipeline
> - Intégration native dans les scripts PowerShell
> - Options avancées (remoting, timeout personnalisé, tests silencieux)
> - Compatible avec l'automatisation et le monitoring

---

## 🌐 Test-Connection - L'outil de base {#test-connection}

`Test-Connection` est l'équivalent moderne et amélioré de la commande `ping`. Elle envoie des paquets ICMP Echo Request pour tester la connectivité réseau vers une ou plusieurs machines.

### 📝 Syntaxe et paramètres fondamentaux {#syntaxe-fondamentaux}

#### Syntaxe de base

```powershell
# Forme simple (PowerShell 5.1)
Test-Connection -ComputerName "google.com"

# Forme moderne (PowerShell 6+)
Test-Connection -TargetName "google.com"

# Accepte IP ou nom DNS
Test-Connection -ComputerName "192.168.1.1"
Test-Connection -ComputerName "serveur01.domaine.local"
```

> [!tip] Astuce de compatibilité `-ComputerName` fonctionne dans toutes les versions de PowerShell. `-TargetName` est l'alias moderne introduit dans PowerShell Core 6+.

#### Paramètres principaux

|Paramètre|Type|Description|Valeur par défaut|
|---|---|---|---|
|`-Count`|Int32|Nombre de pings à envoyer|4|
|`-Quiet`|Switch|Retourne uniquement $true/$false|Non activé|
|`-Source`|String|Machine source (pour remoting)|Machine locale|
|`-BufferSize`|Int32|Taille du paquet en octets|32|
|`-TimeoutSeconds`|Int32|Délai d'attente maximal|5 (PS 7+)|

#### Exemples d'utilisation des paramètres

```powershell
# Envoyer seulement 2 pings
Test-Connection -ComputerName "google.com" -Count 2

# Test rapide avec retour booléen uniquement
Test-Connection -ComputerName "192.168.1.10" -Quiet
# Retourne : True ou False

# Test avec timeout personnalisé de 2 secondes (PowerShell 7+)
Test-Connection -TargetName "serveur-lent.local" -Count 1 -TimeoutSeconds 2

# Test avec paquet de grande taille (1400 octets)
Test-Connection -ComputerName "192.168.1.1" -BufferSize 1400

# Test depuis une machine distante (nécessite remoting)
Test-Connection -ComputerName "google.com" -Source "Serveur01"
```

> [!warning] Attention au remoting L'utilisation de `-Source` nécessite que PowerShell Remoting soit activé sur la machine source. Cette fonctionnalité sera abordée dans une autre partie du cours.

---

### 📊 Propriétés retournées {#propriétés-retournées}

`Test-Connection` retourne un objet riche en informations exploitables. Comprendre ces propriétés est crucial pour l'automatisation.

#### Structure de l'objet retourné

```powershell
# Capture du résultat dans une variable
$result = Test-Connection -ComputerName "google.com" -Count 1

# Exploration de l'objet
$result | Get-Member
$result | Format-List *
```

#### Propriétés clés

|Propriété|Type|Description|Exemple|
|---|---|---|---|
|`Source`|String|Machine ayant effectué le test|"MON-PC"|
|`Destination`|String|Cible du test|"google.com"|
|`IPV4Address`|IPAddress|Adresse IP résolue|142.250.185.46|
|`Status`|String|Résultat du test|"Success" ou "TimedOut"|
|`ResponseTime`|Int32|Latence en millisecondes|23|
|`Reply`|PingReply|Objet détaillé de la réponse|[Objet complexe]|

#### Exploitation des propriétés

```powershell
# Récupérer uniquement la latence
$ping = Test-Connection -ComputerName "8.8.8.8" -Count 1
Write-Host "Latence: $($ping.ResponseTime) ms"

# Vérifier le statut
if ($ping.Status -eq "Success") {
    Write-Host "Machine accessible"
}

# Obtenir l'adresse IP résolue
$ip = (Test-Connection -ComputerName "google.com" -Count 1).IPV4Address
Write-Host "IP résolvée: $ip"

# Accéder aux détails via Reply
$details = $ping.Reply
Write-Host "TTL: $($details.Options.Ttl)"
Write-Host "Buffer: $($details.Buffer.Length) octets"
```

> [!example] Exemple pratique : Mesurer la latence moyenne
> 
> ```powershell
> # Effectuer 10 pings et calculer la moyenne
> $pings = Test-Connection -ComputerName "google.com" -Count 10
> $moyenne = ($pings | Measure-Object -Property ResponseTime -Average).Average
> Write-Host "Latence moyenne: $moyenne ms"
> ```

---

### 💼 Cas d'usage pratiques {#cas-usage}

#### 1. Tests de connectivité de base

Le cas le plus simple : vérifier si une machine répond sur le réseau.

```powershell
# Test simple avec affichage
Test-Connection -ComputerName "serveur01" -Count 2

# Test silencieux pour condition
if (Test-Connection -ComputerName "192.168.1.100" -Quiet -Count 1) {
    Write-Host "Serveur accessible" -ForegroundColor Green
} else {
    Write-Host "Serveur inaccessible" -ForegroundColor Red
}
```

#### 2. Vérification de machines avant actions

Avant d'effectuer des opérations sur des machines distantes, il est prudent de vérifier leur disponibilité.

```powershell
# Liste de serveurs à vérifier
$serveurs = @("SRV01", "SRV02", "SRV03", "SRV04")

# Vérification avant maintenance
foreach ($srv in $serveurs) {
    if (Test-Connection -ComputerName $srv -Quiet -Count 1) {
        Write-Host "✓ $srv : Disponible - Maintenance possible" -ForegroundColor Green
        # Ici, lancer les opérations de maintenance
    } else {
        Write-Host "✗ $srv : Indisponible - Maintenance impossible" -ForegroundColor Red
        # Logger l'incident ou envoyer une alerte
    }
}
```

> [!tip] Astuce d'optimisation Utilisez `-Count 1` avec `-Quiet` pour des tests rapides. Pas besoin de 4 pings pour savoir si une machine répond.

#### 3. Surveillance de disponibilité

Monitoring continu de la disponibilité d'un service critique.

```powershell
# Surveillance d'un serveur web critique
$serveurWeb = "web-prod-01.entreprise.local"
$logFile = "C:\Logs\monitoring_web.log"

while ($true) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    if (Test-Connection -ComputerName $serveurWeb -Quiet -Count 1) {
        $message = "$timestamp - $serveurWeb : EN LIGNE"
        Write-Host $message -ForegroundColor Green
    } else {
        $message = "$timestamp - $serveurWeb : HORS LIGNE ⚠️"
        Write-Host $message -ForegroundColor Red
        # Envoi d'alerte (mécanisme à définir)
    }
    
    # Enregistrer dans le fichier log
    Add-Content -Path $logFile -Value $message
    
    # Attendre 30 secondes avant le prochain test
    Start-Sleep -Seconds 30
}
```

#### 4. Mesure de latence réseau

Analyser la qualité de la connexion réseau entre deux points.

```powershell
# Fonction de test de latence avancée
function Test-NetworkLatency {
    param(
        [string]$Target,
        [int]$Count = 50
    )
    
    Write-Host "Test de latence vers $Target ($Count pings)..." -ForegroundColor Cyan
    
    $results = Test-Connection -ComputerName $Target -Count $Count
    
    # Calculs statistiques
    $stats = $results | Measure-Object -Property ResponseTime -Average -Minimum -Maximum
    
    # Calcul du taux de perte
    $success = ($results | Where-Object { $_.Status -eq "Success" }).Count
    $loss = (($Count - $success) / $Count) * 100
    
    # Affichage des résultats
    Write-Host "`nRésultats pour $Target :" -ForegroundColor Yellow
    Write-Host "  Paquets envoyés : $Count"
    Write-Host "  Paquets reçus   : $success"
    Write-Host "  Perte           : $($loss)%"
    Write-Host "  Latence min     : $($stats.Minimum) ms"
    Write-Host "  Latence max     : $($stats.Maximum) ms"
    Write-Host "  Latence moyenne : $([math]::Round($stats.Average, 2)) ms"
}

# Utilisation
Test-NetworkLatency -Target "8.8.8.8" -Count 100
```

#### 5. Tests en boucle pour monitoring

Scanner un sous-réseau ou plusieurs cibles simultanément.

```powershell
# Scanner une plage IP
$subnet = "192.168.1"
$range = 1..254

Write-Host "Scan du réseau $subnet.0/24..." -ForegroundColor Cyan

$machines = foreach ($ip in $range) {
    $adresse = "$subnet.$ip"
    
    if (Test-Connection -ComputerName $adresse -Quiet -Count 1) {
        [PSCustomObject]@{
            IP = $adresse
            Status = "Active"
            Timestamp = Get-Date
        }
    }
}

# Affichage des machines trouvées
$machines | Format-Table -AutoSize
Write-Host "`nTotal: $($machines.Count) machines actives" -ForegroundColor Green
```

> [!warning] Attention aux performances Scanner 254 adresses IP de manière séquentielle peut prendre plusieurs minutes. Pour des scans rapides, considérez l'utilisation de jobs parallèles (sujet d'une autre partie).

---

### 🔄 Différences entre versions PowerShell {#différences-versions}

Les comportements et fonctionnalités de `Test-Connection` ont évolué entre PowerShell 5.1 (Windows PowerShell) et PowerShell 7+ (PowerShell Core).

#### Comparaison des versions

|Fonctionnalité|PowerShell 5.1|PowerShell 7+|
|---|---|---|
|Paramètre principal|`-ComputerName`|`-TargetName` (+ `-ComputerName`)|
|Timeout par défaut|Non configurable|`-TimeoutSeconds` disponible|
|Type d'objet retourné|`Win32_PingStatus`|`TestConnectionCommand+PingStatus`|
|Support IPv6|Limité|Natif avec `-IPv6`|
|Traceroute|Non|`-Traceroute` disponible|
|Performance|Standard|Optimisée|

#### Exemple de code cross-version

```powershell
# Code compatible avec toutes les versions
$target = "google.com"

# Vérifier la version de PowerShell
if ($PSVersionTable.PSVersion.Major -ge 7) {
    # PowerShell 7+ : utiliser les nouvelles fonctionnalités
    $result = Test-Connection -TargetName $target -Count 1 -TimeoutSeconds 2
} else {
    # PowerShell 5.1 : syntaxe classique
    $result = Test-Connection -ComputerName $target -Count 1
}

# Le traitement reste identique
if ($result.Status -eq "Success") {
    Write-Host "Connectivité OK"
}
```

#### Nouveautés PowerShell 7+

```powershell
# Test avec traceroute intégré (PS 7+ uniquement)
Test-Connection -TargetName "google.com" -Traceroute

# Test IPv6 explicite
Test-Connection -TargetName "ipv6.google.com" -IPv6

# Test TCP sur un port spécifique (alternative à Test-NetConnection)
Test-Connection -TargetName "google.com" -TcpPort 443
```

> [!info] Recommandation Si vous développez de nouveaux scripts et que votre environnement le permet, privilégiez PowerShell 7+ pour bénéficier des fonctionnalités avancées et des meilleures performances.

---

## ✅ Bonnes pratiques {#bonnes-pratiques}

1. **Utilisez `-Quiet` pour les tests conditionnels**
    
    ```powershell
    # ✓ Bon
    if (Test-Connection -ComputerName $srv -Quiet) { ... }
    
    # ✗ Moins optimal
    if ((Test-Connection -ComputerName $srv).Status -eq "Success") { ... }
    ```
    
2. **Limitez le nombre de pings pour l'efficacité**
    
    ```powershell
    # Pour un simple test de disponibilité, 1 ping suffit
    Test-Connection -ComputerName $target -Count 1 -Quiet
    ```
    
3. **Gérez les erreurs avec Try/Catch**
    
    ```powershell
    try {
        $result = Test-Connection -ComputerName $target -Count 1 -ErrorAction Stop
    } catch {
        Write-Host "Erreur lors du test: $($_.Exception.Message)"
    }
    ```
    
4. **Utilisez des objets structurés pour le reporting**
    
    ```powershell
    $rapport = foreach ($srv in $serveurs) {
        $test = Test-Connection -ComputerName $srv -Count 1 -Quiet
        [PSCustomObject]@{
            Serveur = $srv
            Disponible = $test
            DateTest = Get-Date
        }
    }
    $rapport | Export-Csv -Path "rapport_connectivite.csv" -NoTypeInformation
    ```
    
5. **Documentez les timeouts dans vos scripts**
    
    ```powershell
    # Timeout de 3 secondes pour réseaux lents
    Test-Connection -TargetName $remote -TimeoutSeconds 3 -Count 1
    ```
    

---

## ⚠️ Pièges courants {#pièges-courants}

1. **Confondre absence de réponse et problème réseau**
    
    > [!warning] Pare-feu et ICMP Beaucoup de serveurs bloquent les requêtes ICMP (ping) par sécurité. Une absence de réponse ne signifie pas forcément que le serveur est hors ligne. Pour tester la disponibilité d'un service, utilisez plutôt `Test-NetConnection` avec `-Port` (sujet d'une autre section).
    
2. **Oublier la résolution DNS**
    
    ```powershell
    # Si la résolution DNS échoue, Test-Connection échouera aussi
    # Tester d'abord la résolution
    try {
        [System.Net.Dns]::GetHostEntry("serveur-inconnu.local")
        Test-Connection -ComputerName "serveur-inconnu.local"
    } catch {
        Write-Host "Erreur de résolution DNS"
    }
    ```
    
3. **Négliger les permissions réseau**
    
    > [!info] Contexte de sécurité `Test-Connection` s'exécute avec les droits de l'utilisateur en cours. Certains réseaux ou pare-feu peuvent bloquer les pings selon le contexte.
    
4. **Scanner massivement sans optimisation**
    
    ```powershell
    # ✗ Lent : 254 tests séquentiels
    1..254 | ForEach-Object { Test-Connection "192.168.1.$_" -Count 1 }
    
    # ✓ Plus rapide : utiliser des jobs (technique avancée)
    # Cette approche sera détaillée dans la section sur les jobs
    ```
    
5. **Ignorer les différences de version**
    
    ```powershell
    # Ce code plante sur PowerShell 5.1
    Test-Connection -TargetName "google.com" -TimeoutSeconds 2 -TcpPort 443
    
    # Solution : vérifier la version avant
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        # Code PowerShell 7+
    }
    ```
    

---

> [!tip] 💡 Astuce finale `Test-Connection` est votre outil de premier niveau pour tester la connectivité réseau. Pour des tests plus avancés (ports TCP/UDP, chemins réseau, certificats SSL), vous utiliserez d'autres cmdlets complémentaires abordées dans les prochaines sections du cours.