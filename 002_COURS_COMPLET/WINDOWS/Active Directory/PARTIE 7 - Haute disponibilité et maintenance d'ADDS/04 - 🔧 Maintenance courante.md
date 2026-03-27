

> [!info] Vue d'ensemble La maintenance d'Active Directory est essentielle pour garantir des performances optimales, la fiabilité de la réplication et l'intégrité des données. Cette section couvre les opérations de maintenance critiques à effectuer régulièrement.

---

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

## 🗜️ Défragmentation de la base AD

### Concepts fondamentaux

La base de données Active Directory (fichier `ntds.dit`) accumule de l'espace inutilisé au fil du temps lorsque des objets sont supprimés. Active Directory effectue automatiquement une **défragmentation en ligne** qui réorganise les données mais ne réduit pas la taille du fichier.

> [!warning] Défragmentation en ligne vs hors ligne
> 
> - **En ligne** : automatique, quotidienne, ne réduit pas la taille du fichier
> - **Hors ligne** : manuelle, nécessite un arrêt du service, compacte réellement le fichier

### Pourquoi défragmenter ?

La défragmentation hors ligne est nécessaire quand :

- Le fichier `ntds.dit` est devenu excessivement volumineux
- Après des suppressions massives d'objets
- Pour libérer de l'espace disque
- Pour améliorer les performances de lecture/écriture

> [!tip] Quand défragmenter ? Effectuez une défragmentation hors ligne annuellement ou après avoir supprimé plus de 30% des objets de votre annuaire.

### Procédure de défragmentation hors ligne

#### Étape 1 : Redémarrer en mode restauration

```powershell
# Redémarrer le contrôleur de domaine en mode DSRM
# Utilisez F8 au démarrage et sélectionnez "Directory Services Restore Mode"
# Ou utilisez msconfig pour configurer le démarrage
```

#### Étape 2 : Vérifier l'intégrité de la base

```bash
# Ouvrir une invite de commandes en administrateur
cd C:\Windows\NTDS

# Vérifier l'intégrité avant défragmentation
ntdsutil
activate instance ntds
files
integrity
# Attendez la fin de la vérification
quit
quit
```

#### Étape 3 : Défragmenter la base

```bash
ntdsutil
activate instance ntds
files
compact to C:\Temp
# Le processus crée un nouveau fichier ntds.dit compacté
quit
quit
```

> [!example] Exemple de sortie
> 
> ```
> Opening database [Current] ...
> Database defragmentation completed
> Old database size: 4 GB
> New database size: 2.5 GB
> Space saved: 1.5 GB
> ```

#### Étape 4 : Remplacer l'ancienne base

```bash
# Créer une sauvegarde de sécurité
move C:\Windows\NTDS\ntds.dit C:\Windows\NTDS\ntds.dit.old

# Copier la nouvelle base défragmentée
move C:\Temp\ntds.dit C:\Windows\NTDS\ntds.dit

# Supprimer les fichiers journaux
del C:\Windows\NTDS\*.log

# Redémarrer normalement
shutdown /r /t 0
```

> [!warning] Précautions critiques
> 
> - Effectuez TOUJOURS une sauvegarde complète avant la défragmentation
> - Assurez-vous d'avoir au moins 120% de l'espace du fichier ntds.dit disponible
> - Ne défragmentez JAMAIS tous les DC simultanément
> - Testez d'abord sur un DC non-production si possible

### Vérification post-défragmentation

```powershell
# Vérifier que les services AD fonctionnent
Get-Service NTDS, DNS, Netlogon | Format-Table Status, Name

# Tester la réplication
repadmin /replsummary

# Vérifier les événements système
Get-EventLog -LogName "Directory Service" -Newest 50 | 
    Where-Object {$_.EntryType -eq "Error"}
```

---

## 🗑️ Gestion de la corbeille Active Directory

### Présentation de la fonctionnalité

La corbeille Active Directory permet de restaurer des objets supprimés avec tous leurs attributs, sans nécessiter de restauration autoritaire depuis une sauvegarde.

> [!info] Prérequis
> 
> - Niveau fonctionnel de forêt : Windows Server 2008 R2 minimum
> - Une fois activée, la corbeille ne peut pas être désactivée
> - Augmente légèrement la taille de la base AD

### Activation de la corbeille AD

#### Via PowerShell (méthode recommandée)

```powershell
# Vérifier le niveau fonctionnel de la forêt
Get-ADForest | Select-Object ForestMode

# Activer la corbeille AD
Enable-ADOptionalFeature -Identity 'Recycle Bin Feature' `
    -Scope ForestOrConfigurationSet `
    -Target 'contoso.com' `
    -Confirm:$false

# Vérifier l'activation
Get-ADOptionalFeature -Filter {Name -like "Recycle*"}
```

> [!example] Sortie attendue
> 
> ```
> DistinguishedName : CN=Recycle Bin Feature,CN=Optional Features,...
> EnabledScopes     : {DC=contoso,DC=com}
> FeatureGUID       : 766ddcd8-acd0-445e-f3b9-a7f9b6744f2a
> Name              : Recycle Bin Feature
> ```

#### Via le Centre d'administration Active Directory

1. Ouvrir **Centre d'administration Active Directory**
2. Sélectionner le domaine racine
3. Volet **Tâches** → **Activer la corbeille**
4. Confirmer l'activation

### Restauration d'objets supprimés

#### Restaurer un objet simple

```powershell
# Lister les objets supprimés récemment
Get-ADObject -Filter {isDeleted -eq $true -and Name -like "*Jean*"} `
    -IncludeDeletedObjects | 
    Select-Object Name, DistinguishedName, WhenChanged

# Restaurer un utilisateur spécifique
Get-ADObject -Filter {Name -eq "Jean Dupont"} `
    -IncludeDeletedObjects | 
    Restore-ADObject

# Restaurer avec confirmation
$user = Get-ADObject -Filter {SamAccountName -eq "jdupont"} `
    -IncludeDeletedObjects -Properties *
Restore-ADObject -Identity $user -Confirm
```

#### Restaurer une OU avec tous ses objets enfants

```powershell
# Identifier l'OU supprimée
$ou = Get-ADObject -Filter {Name -eq "ServiceComptabilite" -and ObjectClass -eq "organizationalUnit"} `
    -IncludeDeletedObjects

# Restaurer l'OU
Restore-ADObject -Identity $ou

# Restaurer tous les objets qui étaient dans cette OU
Get-ADObject -Filter {LastKnownParent -eq $ou.DistinguishedName} `
    -IncludeDeletedObjects | 
    Restore-ADObject
```

> [!tip] Astuce pour les restaurations massives Utilisez `-WhatIf` pour prévisualiser les restaurations avant de les effectuer :
> 
> ```powershell
> Get-ADObject -Filter {isDeleted -eq $true} -IncludeDeletedObjects | 
>     Restore-ADObject -WhatIf
> ```

#### Restaurer vers un emplacement différent

```powershell
# Restaurer un objet vers une nouvelle OU
$user = Get-ADObject -Filter {Name -eq "Jean Dupont"} `
    -IncludeDeletedObjects

Restore-ADObject -Identity $user `
    -TargetPath "OU=NouvelEmplacement,DC=contoso,DC=com"
```

### Durée de conservation des objets

```powershell
# Vérifier la durée de vie des objets supprimés (tombstone lifetime)
(Get-ADObject "CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,DC=contoso,DC=com" `
    -Properties tombstoneLifetime).tombstoneLifetime

# Modifier la durée (en jours, valeur par défaut : 180 jours)
Set-ADObject "CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,DC=contoso,DC=com" `
    -Replace @{tombstoneLifetime=365}
```

> [!warning] Impact de la modification
> 
> - Une augmentation de la durée augmente la taille de la base AD
> - Une diminution peut rendre des objets irrécupérables
> - Les modifications s'appliquent à toute la forêt

### Surveillance de la corbeille

```powershell
# Compter les objets dans la corbeille
(Get-ADObject -Filter {isDeleted -eq $true} -IncludeDeletedObjects).Count

# Voir les suppressions récentes (dernières 24h)
Get-ADObject -Filter {isDeleted -eq $true} `
    -IncludeDeletedObjects -Properties WhenChanged |
    Where-Object {$_.WhenChanged -gt (Get-Date).AddDays(-1)} |
    Select-Object Name, ObjectClass, WhenChanged |
    Sort-Object WhenChanged -Descending
```

---

## 🏥 Surveillance de la santé d'AD

### Outils de diagnostic principaux

Active Directory fournit deux outils essentiels pour la surveillance : `dcdiag` et `repadmin`. Ces utilitaires doivent être exécutés régulièrement pour détecter les problèmes avant qu'ils n'affectent les utilisateurs.

### DCDiag : Diagnostic complet du contrôleur

#### Tests de base

```bash
# Diagnostic complet du DC local
dcdiag /v

# Diagnostic d'un DC spécifique
dcdiag /s:DC01 /v

# Diagnostic rapide (tests essentiels uniquement)
dcdiag /q
```

> [!info] Interprétation des résultats
> 
> - **passed** : test réussi ✅
> - **failed** : problème détecté ❌
> - **warning** : attention requise ⚠️

#### Tests spécifiques critiques

```bash
# Test de la connectivité réseau
dcdiag /test:connectivity

# Test de la réplication
dcdiag /test:replications

# Test DNS (crucial pour AD)
dcdiag /test:dns

# Test des rôles FSMO
dcdiag /test:fsmocheck

# Test de la sécurité et des permissions
dcdiag /test:objectsreplicated
dcdiag /test:kccevent

# Test de l'intégrité de la base
dcdiag /test:systemlog
```

#### Diagnostic de tous les DC de la forêt

```bash
# Tester tous les contrôleurs de domaine
dcdiag /a /e /v > C:\Logs\dcdiag_all.txt

# Options :
# /a : tous les DC du site
# /e : tous les DC de l'entreprise (forêt)
# /v : mode verbeux
```

> [!example] Exemple de sortie pour un problème DNS
> 
> ```
> TEST: DNS (Diagnostic)
>    Error: DNS server: 10.0.0.1 timeout
>    Failed test DNS
> 
> RECOMMENDATION: Verify DNS configuration
> Check network connectivity to DNS server
> Validate DNS zones are correctly configured
> ```

#### Automatiser la surveillance avec DCDiag

```powershell
# Script de surveillance quotidienne
$dcdiagOutput = dcdiag /e /v
$errors = $dcdiagOutput | Select-String "failed|error"

if ($errors.Count -gt 0) {
    # Envoyer une alerte email
    Send-MailMessage -To "admin@contoso.com" `
        -From "monitoring@contoso.com" `
        -Subject "ALERTE : Problèmes détectés sur AD" `
        -Body ($errors | Out-String) `
        -SmtpServer "smtp.contoso.com"
}
```

### Repadmin : Surveillance de la réplication

#### Vérifications essentielles de réplication

```bash
# Vue d'ensemble de la réplication
repadmin /replsummary

# État détaillé de la réplication
repadmin /showrepl

# Afficher la topologie de réplication
repadmin /showrepl * /csv > C:\Logs\replication.csv
```

> [!tip] Astuce d'analyse Importez le CSV dans Excel pour analyser facilement la topologie :
> 
> ```powershell
> Import-Csv C:\Logs\replication.csv | 
>     Where-Object {$_.'Number of Failures' -gt 0} |
>     Format-Table
> ```

#### Forcer la réplication

```bash
# Forcer la réplication avec tous les partenaires
repadmin /syncall /AdeP

# Options :
# /A : toutes les partitions
# /d : identifier les serveurs par DN
# /e : réplication entreprise (tous sites)
# /P : pousser les changements depuis ce DC

# Forcer la réplication entre deux DC spécifiques
repadmin /replicate DC02 DC01 DC=contoso,DC=com

# Synchronisation immédiate du KCC
repadmin /kcc
```

#### Diagnostiquer les échecs de réplication

```bash
# Voir les échecs de réplication
repadmin /showrepl /errorsonly

# Informations sur les partenaires de réplication
repadmin /showreps

# Voir la file d'attente de réplication
repadmin /queue

# Obtenir les métadonnées de réplication d'un objet
repadmin /showobjmeta DC01 "CN=Jean Dupont,OU=Users,DC=contoso,DC=com"
```

> [!example] Analyse des métadonnées
> 
> ```
> Attribute              Ver   Originating DC        Time/Date         USN
> ============           ===   =================     =============     ======
> cn                      1    DC01                  2024-12-15 10:23  45678
> displayName             2    DC02                  2024-12-16 14:45  45892
> userAccountControl      3    DC01                  2024-12-17 08:12  46123
> ```
> 
> Cela montre quel DC a modifié quel attribut et quand.

#### Tester la latence de réplication

```bash
# Mesurer le temps de réplication entre sites
repadmin /showrepl /csv | findstr "Last Success"

# Voir les liens de sites et leurs coûts
repadmin /bridgeheads

# Informations sur la réplication inter-sites
repadmin /showism
```

### Surveillance de la santé avec PowerShell

#### Vérifications automatisées

```powershell
# Module Active Directory requis
Import-Module ActiveDirectory

# Vérifier l'état de tous les DC
Get-ADDomainController -Filter * | ForEach-Object {
    $dc = $_.HostName
    $pingResult = Test-Connection -ComputerName $dc -Count 2 -Quiet
    
    [PSCustomObject]@{
        DC = $dc
        Accessible = $pingResult
        Site = $_.Site
        IsGlobalCatalog = $_.IsGlobalCatalog
        OperatingSystem = $_.OperatingSystem
    }
} | Format-Table -AutoSize

# Vérifier les services critiques sur tous les DC
Get-ADDomainController -Filter * | ForEach-Object {
    $dc = $_.HostName
    
    Get-Service -ComputerName $dc -Name NTDS, DNS, Netlogon, W32Time -ErrorAction SilentlyContinue |
        Select-Object @{N='DC';E={$dc}}, Name, Status
} | Format-Table -AutoSize
```

#### Surveiller les événements critiques

```powershell
# Vérifier les erreurs AD récentes
Get-EventLog -LogName "Directory Service" -After (Get-Date).AddHours(-24) |
    Where-Object {$_.EntryType -eq "Error"} |
    Select-Object TimeGenerated, Source, Message |
    Format-List

# Surveiller les échecs d'authentification
Get-EventLog -LogName Security -InstanceId 4625 -After (Get-Date).AddHours(-24) |
    Group-Object -Property Message |
    Select-Object Count, Name |
    Sort-Object Count -Descending
```

#### Dashboard de santé AD

```powershell
# Script complet de surveillance
function Get-ADHealthReport {
    $report = @()
    
    # Test DCDiag
    $dcdiagResult = dcdiag /q
    $dcdiagStatus = if ($LASTEXITCODE -eq 0) { "✅ Sain" } else { "❌ Problèmes détectés" }
    
    # Test Replication
    $replResult = repadmin /replsummary
    $replErrors = ($replResult | Select-String "error|fail").Count
    $replStatus = if ($replErrors -eq 0) { "✅ OK" } else { "❌ $replErrors erreurs" }
    
    # Services
    $services = Get-Service NTDS, DNS, Netlogon
    $servicesStatus = if (($services | Where-Object Status -ne 'Running').Count -eq 0) { 
        "✅ Tous démarrés" 
    } else { 
        "❌ Services arrêtés" 
    }
    
    [PSCustomObject]@{
        Date = Get-Date -Format "yyyy-MM-dd HH:mm"
        DCDiag = $dcdiagStatus
        Réplication = $replStatus
        Services = $servicesStatus
    }
}

# Exécuter le rapport
Get-ADHealthReport | Format-List
```

> [!warning] Alertes à surveiller
> 
> - **Event ID 1311** : Échec de réplication
> - **Event ID 2042** : Réplication n'a pas eu lieu depuis longtemps
> - **Event ID 1083** : Problème de cohérence de la base
> - **Event ID 1539** : Base AD corrompue

### Métriques de performance à surveiller

|Compteur|Seuil d'alerte|Description|
|---|---|---|
|`NTDS\DRA Pending Replication Synchronizations`|> 100|File d'attente de réplication|
|`NTDS\LDAP Client Sessions`|> 5000|Sessions LDAP actives|
|`NTDS\DRA Inbound Values Total/sec`|Tendance à la baisse|Débit de réplication entrante|
|`Database\Database Cache % Hit`|< 90%|Efficacité du cache|

```powershell
# Collecter les compteurs de performance
Get-Counter '\NTDS\DRA Pending Replication Synchronizations' -SampleInterval 5 -MaxSamples 12
```

---

## 🧹 Nettoyage des métadonnées

### Qu'est-ce que les métadonnées orphelines ?

Les métadonnées orphelines sont des références à des contrôleurs de domaine qui n'existent plus physiquement mais dont les informations persistent dans Active Directory. Cela se produit généralement lors d'une décommission forcée ou d'une panne matérielle.

> [!warning] Conséquences des métadonnées orphelines
> 
> - Échecs de réplication
> - Avertissements constants dans les logs
> - Problèmes avec les rôles FSMO
> - Impossibilité d'ajouter de nouveaux DC avec le même nom
> - Dégradation des performances

### Identifier les métadonnées orphelines

```powershell
# Lister tous les DC dans AD
Get-ADDomainController -Filter * | 
    Select-Object Name, OperatingSystem, IPv4Address, IsGlobalCatalog

# Tenter de contacter chaque DC
Get-ADDomainController -Filter * | ForEach-Object {
    $dc = $_.HostName
    $online = Test-Connection -ComputerName $dc -Count 2 -Quiet
    
    [PSCustomObject]@{
        DC = $dc
        Online = $online
        LastLogon = $_.LastLogonDate
    }
} | Where-Object {$_.Online -eq $false}
```

#### Vérifier dans les sites et services

```bash
# Voir tous les serveurs dans la configuration
repadmin /viewlist *

# Identifier les serveurs avec des échecs de réplication constants
repadmin /showrepl * /errorsonly
```

### Méthode 1 : Nettoyage avec NTDSUTIL (Windows Server 2008 R2+)

```bash
# Lancer ntdsutil
ntdsutil

# Entrer dans le contexte de nettoyage
metadata cleanup

# Lister les sites
select operation target
list sites

# Sélectionner le site (ex: site 0)
select site 0

# Lister les serveurs dans ce site
list servers in site

# Sélectionner le serveur à nettoyer (ex: serveur 1)
select server 1

# Supprimer les métadonnées
quit
remove selected server

# Confirmer avec "yes"
# Quitter
quit
quit
```

> [!example] Session complète de nettoyage
> 
> ```
> C:\> ntdsutil
> ntdsutil: metadata cleanup
> metadata cleanup: select operation target
> select operation target: list sites
> Found 2 site(s)
> 0 - CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=contoso,DC=com
> 1 - CN=Paris,CN=Sites,CN=Configuration,DC=contoso,DC=com
> 
> select operation target: select site 0
> Site - CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=contoso,DC=com
> 
> select operation target: list servers in site
> Found 3 server(s)
> 0 - CN=DC01,CN=Servers,CN=Default-First-Site-Name,CN=Sites,...
> 1 - CN=DC02,CN=Servers,CN=Default-First-Site-Name,CN=Sites,...
> 2 - CN=DC03-OLD,CN=Servers,CN=Default-First-Site-Name,CN=Sites,...
> 
> select operation target: select server 2
> Server - CN=DC03-OLD,CN=Servers,CN=Default-First-Site-Name,CN=Sites,...
> 
> select operation target: quit
> metadata cleanup: remove selected server
> "CN=DC03-OLD" removed from server "DC01"
> ```

### Méthode 2 : Nettoyage avec PowerShell (Windows Server 2012+)

```powershell
# Supprimer un DC de façon propre (méthode recommandée)
# Remplacer DC03-OLD par le nom du DC à supprimer

$deadDC = "DC03-OLD"
$domain = "contoso.com"

# Obtenir l'objet du DC
$dcObject = Get-ADObject -Filter {Name -eq $deadDC} -SearchBase "CN=Configuration,DC=contoso,DC=com" -SearchScope Subtree

if ($dcObject) {
    # Supprimer l'objet du DC
    Remove-ADObject -Identity $dcObject -Recursive -Confirm:$false
    Write-Host "✅ Métadonnées de $deadDC supprimées" -ForegroundColor Green
} else {
    Write-Host "❌ DC $deadDC non trouvé" -ForegroundColor Red
}

# Nettoyer les enregistrements DNS
Remove-DnsServerResourceRecord -ZoneName $domain -Name $deadDC -RRType A -Force
```

### Nettoyage complet post-décommission

#### Étape 1 : Supprimer les objets du DC

```powershell
$dcName = "DC03-OLD"
$domainDN = "DC=contoso,DC=com"

# Supprimer l'objet ordinateur du DC
Get-ADComputer -Identity $dcName | Remove-ADObject -Recursive -Confirm:$false

# Supprimer les objets de configuration
$configDN = "CN=Configuration,$domainDN"
Get-ADObject -Filter {Name -eq $dcName} -SearchBase $configDN -SearchScope Subtree |
    Remove-ADObject -Recursive -Confirm:$false
```

#### Étape 2 : Nettoyer les enregistrements DNS

```powershell
# DNS forward lookup zones
$zones = @("contoso.com", "_msdcs.contoso.com")

foreach ($zone in $zones) {
    # Supprimer les enregistrements A
    Get-DnsServerResourceRecord -ZoneName $zone -RRType A |
        Where-Object {$_.HostName -like "*$dcName*"} |
        Remove-DnsServerResourceRecord -ZoneName $zone -Force
    
    # Supprimer les enregistrements SRV
    Get-DnsServerResourceRecord -ZoneName $zone -RRType Srv |
        Where-Object {$_.RecordData.DomainName -like "*$dcName*"} |
        Remove-DnsServerResourceRecord -ZoneName $zone -Force
}

# DNS reverse lookup zones
$reverseZone = "0.0.10.in-addr.arpa"
Get-DnsServerResourceRecord -ZoneName $reverseZone -RRType PTR |
    Where-Object {$_.RecordData.PtrDomainName -like "*$dcName*"} |
    Remove-DnsServerResourceRecord -ZoneName $reverseZone -Force
```

#### Étape 3 : Vérifier les rôles FSMO

```powershell
# Vérifier que le DC supprimé ne détient pas de rôles FSMO
Get-ADDomain | Select-Object PDCEmulator, RIDMaster, InfrastructureMaster
Get-ADForest | Select-Object SchemaMaster, DomainNamingMaster

# Si le DC détient des rôles, les transférer (voir documentation sur les FSMO)
```

#### Étape 4 : Forcer la réplication

```bash
# Forcer la réplication de la configuration sur tous les DC
repadmin /syncall /AdeP

# Vérifier que la réplication s'est bien passée
repadmin /replsummary
```

### Vérification post-nettoyage

```powershell
# Vérifier qu'aucun objet du DC ne reste
$dcName = "DC03-OLD"
$domainDN = "DC=contoso,DC=com"

Get-ADObject -Filter {Name -like "*$dcName*"} -SearchBase $domainDN -SearchScope Subtree
Get-ADObject -Filter {Name -like "*$dcName*"} -SearchBase "CN=Configuration,$domainDN" -SearchScope Subtree

# Vérifier les enregistrements DNS
nslookup $dcName
```

```bash
# Vérifier avec dcdiag et repadmin
dcdiag /v | findstr /i $dcName
repadmin /showrepl | findstr /i $dcName
```

> [!tip] Checklist de validation
> 
> - [ ] Aucun objet trouvé dans AD avec le nom du DC
> - [ ] Aucun enregistrement DNS ne pointe vers le DC
> - [ ] Aucune erreur de réplication liée à ce DC
> - [ ] Les rôles FSMO sont sur des DC actifs
> - [ ] DCDiag ne mentionne pas le DC supprimé

### Cas particulier : DC Global Catalog

Si le DC supprimé était un Global Catalog, vérifiez qu'il reste au moins un GC par site :

```powershell
# Vérifier les GC par site
Get-ADDomainController -Filter * | 
    Group-Object Site | 
    Select-Object Name, @{N='GC_Count';E={($_.Group | Where-Object IsGlobalCatalog).Count}} |
    Where-Object {$_.GC_Count -eq 0}

# Promouvoir un DC en Global Catalog si nécessaire
$dc = Get-ADDomainController -Identity "DC02"
Set-ADObject -Identity $dc.NTDSSettingsObjectDN -Replace @{options='1'}
```

### Automatiser la détection de métadonnées orphelines

```powershell
# Script de détection automatique
function Find-OrphanedDCMetadata {
    $allDCs = Get-ADDomainController -Filter *
    $orphans = @()
    
    foreach ($dc in $allDCs) {
        $isOnline = Test-Connection -ComputerName $dc.HostName -Count 2 -Quiet
        
        if (-not $isOnline) {
            $lastRepl = (repadmin /showrepl $dc.HostName 2>&1 | Select-String "Last Success Time")
            
            $orphans += [PSCustomObject]@{
                Name = $dc.Name
                HostName = $dc.HostName
                Site = $dc.Site
                LastLogon = $dc.LastLogonDate
                IsGC = $dc.IsGlobalCatalog
                Status = "Potentiellement orphelin"
            }
        }
    }
    
    return $orphans
}

# Exécuter la détection
$orphanedDCs = Find-OrphanedDCMetadata
if ($orphanedDCs.Count -gt 0) {
    Write-Warning "⚠️ $($orphanedDCs.Count) DC(s) potentiellement orphelins détectés"
    $orphanedDCs | Format-Table -AutoSize
}
```

---

## 📊 Résumé des bonnes pratiques

> [!tip] Maintenance régulière recommandée

|Tâche|Fréquence|Outil|
|---|---|---|
|Vérification santé (dcdiag)|Quotidienne|`dcdiag /q`|
|Surveillance réplication|Quotidienne|`repadmin /replsummary`|
|Analyse corbeille AD|Hebdomadaire|`Get-ADObject -IncludeDeletedObjects`|
|Vérification logs événements|Hebdomadaire|Event Viewer / PowerShell|
|Sauvegarde state system|Quotidienne|Windows Server Backup|
|Défragmentation hors ligne|Annuelle|`ntdsutil`|
|Nettoyage métadonnées|À la demande|`ntdsutil` / PowerShell|
|Revue des objets obsolètes|Mensuelle|PowerShell|

### 🔑 Points clés à retenir

> [!info] Défragmentation
> 
> - La défragmentation en ligne est automatique mais ne réduit pas la taille du fichier
> - La défragmentation hors ligne nécessite le mode DSRM et compacte réellement la base
> - Toujours faire une sauvegarde complète avant de défragmenter
> - Ne jamais défragmenter tous les DC simultanément

> [!info] Corbeille Active Directory
> 
> - Permet la restauration complète des objets avec tous leurs attributs
> - Une fois activée, elle ne peut pas être désactivée
> - Les objets sont conservés selon la valeur `tombstoneLifetime` (180 jours par défaut)
> - Utilisez `Get-ADObject -IncludeDeletedObjects` et `Restore-ADObject`

> [!info] Surveillance
> 
> - **dcdiag** : diagnostic complet du contrôleur de domaine
> - **repadmin** : surveillance et gestion de la réplication
> - Automatisez les vérifications quotidiennes avec des scripts PowerShell
> - Surveillez les Event IDs critiques (1311, 2042, 1083, 1539)

> [!info] Nettoyage des métadonnées
> 
> - Nécessaire après une décommission forcée ou une panne de DC
> - Utilisez `ntdsutil metadata cleanup` ou PowerShell
> - Nettoyez également les enregistrements DNS associés
> - Vérifiez que le DC ne détenait pas de rôles FSMO

---

## 🎯 Pièges courants à éviter

> [!warning] Erreurs fréquentes

**Défragmentation**

- ❌ Défragmenter sans sauvegarde préalable
- ❌ Manquer d'espace disque (besoin de 120% de la taille de ntds.dit)
- ❌ Oublier de supprimer les fichiers journaux après la défragmentation
- ❌ Défragmenter plusieurs DC simultanément

**Corbeille AD**

- ❌ Oublier de vérifier le niveau fonctionnel de la forêt avant activation
- ❌ Ne pas informer les utilisateurs que les données partagées seront visibles par tous
- ❌ Réduire drastiquement la durée `tombstoneLifetime` sans analyse d'impact
- ❌ Restaurer des objets sans vérifier leur emplacement cible

**Surveillance**

- ❌ Ne surveiller qu'un seul DC au lieu de toute l'infrastructure
- ❌ Ignorer les avertissements (warnings) dans les logs
- ❌ Ne pas automatiser les vérifications quotidiennes
- ❌ Oublier de surveiller les compteurs de performance

**Nettoyage des métadonnées**

- ❌ Supprimer les métadonnées d'un DC encore actif
- ❌ Ne pas vérifier les rôles FSMO avant le nettoyage
- ❌ Oublier de nettoyer les enregistrements DNS
- ❌ Ne pas forcer la réplication après le nettoyage

---

## 💡 Astuces d'expert

### Automatisation de la maintenance

```powershell
# Script de maintenance hebdomadaire complet
$logPath = "C:\Logs\AD_Maintenance_$(Get-Date -Format 'yyyyMMdd').log"

function Write-Log {
    param($Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Tee-Object -FilePath $logPath -Append
}

Write-Log "=== Début de la maintenance AD ==="

# 1. Vérification de la santé
Write-Log "1. Exécution DCDiag..."
$dcdiagResult = dcdiag /q
if ($LASTEXITCODE -ne 0) {
    Write-Log "⚠️ ALERTE : DCDiag a détecté des problèmes"
    $dcdiagResult | Out-File -FilePath $logPath -Append
}

# 2. Vérification de la réplication
Write-Log "2. Vérification de la réplication..."
$replErrors = (repadmin /showrepl /errorsonly | Select-String "error|fail").Count
Write-Log "Erreurs de réplication : $replErrors"

# 3. Analyse de la corbeille
Write-Log "3. Analyse de la corbeille AD..."
$deletedCount = (Get-ADObject -Filter {isDeleted -eq $true} -IncludeDeletedObjects).Count
Write-Log "Objets dans la corbeille : $deletedCount"

# 4. Vérification de l'espace disque
Write-Log "4. Vérification de l'espace disque..."
$ntdsDrive = (Get-Item "C:\Windows\NTDS\ntds.dit").Directory.Root.Name
$disk = Get-PSDrive -Name $ntdsDrive.TrimEnd(':')
$freeSpaceGB = [math]::Round($disk.Free / 1GB, 2)
Write-Log "Espace libre sur ${ntdsDrive} : $freeSpaceGB GB"

if ($freeSpaceGB -lt 10) {
    Write-Log "⚠️ ALERTE : Espace disque faible !"
}

# 5. Vérification des services
Write-Log "5. Vérification des services AD..."
$services = Get-Service NTDS, DNS, Netlogon, W32Time
$stoppedServices = $services | Where-Object {$_.Status -ne 'Running'}
if ($stoppedServices) {
    Write-Log "⚠️ ALERTE : Services arrêtés détectés"
    $stoppedServices | ForEach-Object {
        Write-Log "Service arrêté : $($_.Name)"
    }
}

Write-Log "=== Fin de la maintenance AD ==="
```

### Surveillance proactive des objets obsolètes

```powershell
# Détecter les comptes utilisateurs inactifs
Get-ADUser -Filter {Enabled -eq $true} -Properties LastLogonDate |
    Where-Object {
        $_.LastLogonDate -lt (Get-Date).AddDays(-90) -or 
        $_.LastLogonDate -eq $null
    } |
    Select-Object Name, SamAccountName, LastLogonDate, DistinguishedName |
    Export-Csv "C:\Reports\InactiveUsers_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation

# Détecter les ordinateurs obsolètes
Get-ADComputer -Filter * -Properties LastLogonDate, OperatingSystem |
    Where-Object {$_.LastLogonDate -lt (Get-Date).AddDays(-180)} |
    Select-Object Name, LastLogonDate, OperatingSystem, DistinguishedName |
    Export-Csv "C:\Reports\ObsoleteComputers_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation
```

### Optimisation des performances de réplication

```powershell
# Identifier les goulots d'étranglement de réplication
$dcs = Get-ADDomainController -Filter *

foreach ($dc in $dcs) {
    Write-Host "Analyse de $($dc.HostName)..." -ForegroundColor Cyan
    
    # Compteur de files d'attente
    $queue = (Get-Counter "\NTDS\DRA Pending Replication Synchronizations" -ComputerName $dc.HostName -ErrorAction SilentlyContinue).CounterSamples.CookedValue
    
    if ($queue -gt 50) {
        Write-Warning "⚠️ $($dc.HostName) : File d'attente élevée ($queue)"
    }
}
```

### Dashboard de santé en temps réel

```powershell
# Créer un dashboard HTML de santé AD
$html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Dashboard Active Directory</title>
    <style>
        body { font-family: Arial; margin: 20px; background: #f5f5f5; }
        .card { background: white; padding: 20px; margin: 10px 0; border-radius: 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .ok { color: green; } .warning { color: orange; } .error { color: red; }
        h1 { color: #0078d4; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background: #0078d4; color: white; }
    </style>
</head>
<body>
    <h1>🏥 Dashboard Active Directory</h1>
    <p>Généré le : $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")</p>
"@

# État des DC
$html += "<div class='card'><h2>Contrôleurs de domaine</h2><table><tr><th>DC</th><th>Site</th><th>État</th><th>GC</th></tr>"

Get-ADDomainController -Filter * | ForEach-Object {
    $status = if (Test-Connection -ComputerName $_.HostName -Count 1 -Quiet) { 
        "<span class='ok'>✅ En ligne</span>" 
    } else { 
        "<span class='error'>❌ Hors ligne</span>" 
    }
    
    $gc = if ($_.IsGlobalCatalog) { "✅" } else { "❌" }
    
    $html += "<tr><td>$($_.Name)</td><td>$($_.Site)</td><td>$status</td><td>$gc</td></tr>"
}

$html += "</table></div>"

# État de la réplication
$replSummary = repadmin /replsummary 2>&1
$replErrors = ($replSummary | Select-String "error").Count
$replStatus = if ($replErrors -eq 0) { 
    "<span class='ok'>✅ Aucune erreur</span>" 
} else { 
    "<span class='error'>❌ $replErrors erreurs détectées</span>" 
}

$html += "<div class='card'><h2>Réplication</h2><p>$replStatus</p></div>"

# Corbeille AD
$deletedCount = (Get-ADObject -Filter {isDeleted -eq $true} -IncludeDeletedObjects -ErrorAction SilentlyContinue).Count
$html += "<div class='card'><h2>Corbeille Active Directory</h2><p>Objets supprimés : <strong>$deletedCount</strong></p></div>"

$html += "</body></html>"

# Sauvegarder le dashboard
$html | Out-File "C:\Reports\AD_Dashboard.html" -Encoding UTF8

# Ouvrir automatiquement dans le navigateur
Start-Process "C:\Reports\AD_Dashboard.html"
```

### Alerte email automatique

```powershell
# Configuration SMTP
$smtpServer = "smtp.contoso.com"
$from = "monitoring@contoso.com"
$to = "admin@contoso.com"

# Vérifier les problèmes critiques
$issues = @()

# Test DCDiag
if ((dcdiag /q) -and $LASTEXITCODE -ne 0) {
    $issues += "❌ DCDiag a détecté des problèmes"
}

# Test Réplication
$replErrors = (repadmin /showrepl /errorsonly).Count
if ($replErrors -gt 0) {
    $issues += "❌ $replErrors erreurs de réplication"
}

# Test Services
$stoppedServices = Get-Service NTDS, DNS, Netlogon | Where-Object {$_.Status -ne 'Running'}
if ($stoppedServices) {
    $issues += "❌ Services arrêtés : $($stoppedServices.Name -join ', ')"
}

# Envoyer l'alerte si des problèmes sont détectés
if ($issues.Count -gt 0) {
    $body = @"
⚠️ ALERTE Active Directory

Les problèmes suivants ont été détectés :

$($issues | ForEach-Object { "• $_`n" })

Veuillez vérifier immédiatement l'infrastructure AD.

Rapport généré le : $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@

    Send-MailMessage -SmtpServer $smtpServer `
        -From $from `
        -To $to `
        -Subject "🚨 ALERTE : Problèmes détectés sur Active Directory" `
        -Body $body `
        -Priority High
}
```

---

## 📋 Checklist de maintenance mensuelle

> [!example] Tâches mensuelles recommandées

- [ ] **Exécuter un DCDiag complet** sur tous les DC avec rapport détaillé
- [ ] **Analyser les logs d'événements** sur 30 jours pour détecter les tendances
- [ ] **Vérifier la taille de la base AD** et planifier une défragmentation si nécessaire
- [ ] **Examiner la corbeille AD** et archiver les informations sur les suppressions importantes
- [ ] **Auditer les comptes inactifs** et désactiver ceux qui dépassent le seuil de 90 jours
- [ ] **Réviser les ordinateurs obsolètes** (> 180 jours sans connexion)
- [ ] **Tester la restauration** depuis une sauvegarde sur un DC de test
- [ ] **Vérifier les sauvegardes System State** et leur intégrité
- [ ] **Examiner la topologie de réplication** et optimiser si nécessaire
- [ ] **Mettre à jour la documentation** des changements d'infrastructure
- [ ] **Vérifier les certificats** du contrôleur de domaine
- [ ] **Analyser les performances** et ajuster les ressources si besoin

---

## 🔒 Sécurité et conformité

### Audit des modifications AD

```powershell
# Activer l'audit des modifications d'objets AD
auditpol /set /subcategory:"Directory Service Changes" /success:enable /failure:enable

# Consulter les modifications récentes
Get-EventLog -LogName Security -InstanceId 5136 -After (Get-Date).AddDays(-7) |
    Select-Object TimeGenerated, @{N='User';E={$_.ReplacementStrings[4]}}, 
                  @{N='Object';E={$_.ReplacementStrings[10]}},
                  @{N='Attribute';E={$_.ReplacementStrings[8]}} |
    Format-Table -AutoSize
```

### Protection contre les suppressions accidentelles

```powershell
# Activer la protection sur les OU critiques
Get-ADOrganizationalUnit -Filter * | 
    Where-Object {$_.Name -match "Production|Serveurs|Utilisateurs"} |
    Set-ADObject -ProtectedFromAccidentalDeletion $true

# Vérifier les objets protégés
Get-ADObject -Filter {ProtectedFromAccidentalDeletion -eq $true} -Properties ProtectedFromAccidentalDeletion |
    Select-Object Name, DistinguishedName
```

---

## 📚 Commandes de référence rapide

### DCDiag

```bash
dcdiag /v                    # Diagnostic complet verbeux
dcdiag /q                    # Diagnostic rapide (erreurs uniquement)
dcdiag /a                    # Tous les DC du site
dcdiag /e                    # Tous les DC de la forêt
dcdiag /test:replications    # Test spécifique de réplication
dcdiag /test:dns             # Test DNS
```

### Repadmin

```bash
repadmin /replsummary                    # Résumé de réplication
repadmin /showrepl                       # État détaillé
repadmin /syncall /AdeP                  # Forcer sync complète
repadmin /queue                          # File d'attente
repadmin /showrepl /errorsonly           # Erreurs uniquement
repadmin /replicate DC2 DC1 DC=contoso,DC=com  # Répliquer entre 2 DC
```

### NTDSUTIL

```bash
ntdsutil                          # Lancer l'outil
activate instance ntds            # Activer l'instance
files                             # Gestion des fichiers
integrity                         # Vérifier l'intégrité
compact to C:\Temp                # Défragmenter
metadata cleanup                  # Nettoyer métadonnées
```

### PowerShell - Corbeille AD

```powershell
# Activer
Enable-ADOptionalFeature -Identity 'Recycle Bin Feature' -Scope ForestOrConfigurationSet -Target 'contoso.com'

# Lister objets supprimés
Get-ADObject -Filter {isDeleted -eq $true} -IncludeDeletedObjects

# Restaurer
Get-ADObject -Filter {Name -eq "Jean Dupont"} -IncludeDeletedObjects | Restore-ADObject

# Restaurer vers nouvelle OU
Restore-ADObject -Identity $obj -TargetPath "OU=NewOU,DC=contoso,DC=com"
```

---

## 🎓 Points de vigilance finaux

> [!warning] Rappels critiques
> 
> **Avant toute opération de maintenance majeure :**
> 
> 1. ✅ Faire une sauvegarde System State complète
> 2. ✅ Vérifier qu'au moins 2 DC sont opérationnels
> 3. ✅ Planifier l'opération en dehors des heures de production
> 4. ✅ Prévenir les équipes concernées
> 5. ✅ Préparer un plan de retour arrière
> 
> **La maintenance régulière d'Active Directory n'est pas optionnelle**. Elle garantit la stabilité, les performances et la fiabilité de l'ensemble de votre infrastructure d'authentification et d'autorisation.

---

_Fin du cours - Maintenance courante d'Active Directory_