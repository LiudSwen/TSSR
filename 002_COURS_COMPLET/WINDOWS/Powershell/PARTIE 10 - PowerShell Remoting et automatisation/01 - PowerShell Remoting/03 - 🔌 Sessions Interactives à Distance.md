

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

## 🎯 Vue d'ensemble

Les sessions PowerShell interactives à distance permettent d'établir une connexion en temps réel avec une machine distante, similaire à une connexion SSH. Une fois la session établie, toutes les commandes tapées s'exécutent directement sur la machine distante, comme si vous étiez physiquement devant elle.

> [!info] Concept clé `Enter-PSSession` crée une session **1-to-1** (une seule machine à la fois) où le contexte (variables, répertoire courant, etc.) est préservé tout au long de la session interactive.

**Pourquoi utiliser les sessions interactives ?**

- Dépannage en temps réel sur une machine distante
- Exploration interactive de l'environnement distant
- Configuration manuelle nécessitant des décisions au fil de l'eau
- Formation et démonstration en direct

---

## 🚪 Enter-PSSession

### Syntaxe et paramètres

La cmdlet `Enter-PSSession` établit une session PowerShell interactive avec un ordinateur distant.

```powershell
Enter-PSSession [-ComputerName] <String> 
    [-Credential <PSCredential>] 
    [-Authentication <AuthenticationMechanism>]
    [-ConfigurationName <String>]
    [-Port <Int32>]
    [-UseSSL]
    [-SessionOption <PSSessionOption>]
```

#### Paramètres principaux

|Paramètre|Description|Exemple|
|---|---|---|
|`-ComputerName`|Nom ou adresse IP de la machine cible|`Server01`, `192.168.1.50`|
|`-Credential`|Identifiants pour l'authentification|`(Get-Credential)`, `$cred`|
|`-ConfigurationName`|Configuration de session spécifique|`Microsoft.PowerShell` (par défaut)|
|`-Port`|Port TCP personnalisé|`5986` (HTTPS), `5985` (HTTP, défaut)|
|`-UseSSL`|Force l'utilisation de HTTPS|Switch sans valeur|
|`-Authentication`|Mécanisme d'authentification|`Default`, `Kerberos`, `Negotiate`, `CredSSP`|

> [!warning] Prérequis PowerShell Remoting doit être activé sur la machine cible avec `Enable-PSRemoting`. La communication se fait via WinRM (Windows Remote Management).

### Exemples pratiques

#### Connexion simple avec le compte actuel

```powershell
# Connexion avec les credentials actuels (si membre du domaine)
Enter-PSSession -ComputerName Server01

# Connexion avec une adresse IP
Enter-PSSession -ComputerName 192.168.1.100
```

#### Connexion avec authentification explicite

```powershell
# Demander interactivement les credentials
Enter-PSSession -ComputerName Server01 -Credential (Get-Credential)

# Utiliser des credentials stockés dans une variable
$cred = Get-Credential -UserName "DOMAIN\Admin" -Message "Entrez le mot de passe administrateur"
Enter-PSSession -ComputerName Server01 -Credential $cred
```

#### Connexion sécurisée via SSL

```powershell
# Forcer HTTPS (port 5986 par défaut)
Enter-PSSession -ComputerName Server01 -UseSSL -Credential (Get-Credential)

# Spécifier un port personnalisé
Enter-PSSession -ComputerName Server01 -Port 5986 -UseSSL
```

#### Connexion avec configuration spécifique

```powershell
# Utiliser une configuration de session personnalisée
Enter-PSSession -ComputerName Server01 -ConfigurationName "MyCustomConfig"

# Connexion avec authentification CredSSP (pour double-hop)
Enter-PSSession -ComputerName Server01 -Authentication CredSSP -Credential (Get-Credential)
```

### Comportement du prompt

Lorsque vous entrez dans une session distante, **le prompt PowerShell change** pour indiquer clairement que vous êtes connecté à une machine distante.

```powershell
# Avant la connexion (session locale)
PS C:\Users\Admin>

# Après Enter-PSSession
[Server01]: PS C:\Users\Admin\Documents\WindowsPowerShell>
```

> [!tip] Indicateur visuel Le nom de la machine distante apparaît entre crochets `[Server01]` au début du prompt. C'est un rappel constant que vos commandes s'exécutent à distance.

**Préservation du contexte durant la session :**

```powershell
# Entrer dans la session
[Server01]: PS C:\> Set-Location C:\Logs

# Le répertoire courant est préservé
[Server01]: PS C:\Logs> $myVar = "Test"

# Les variables créées persistent dans la session
[Server01]: PS C:\Logs> Write-Host $myVar
Test

# Le contexte reste jusqu'à la sortie de la session
[Server01]: PS C:\Logs> Get-Location
Path
----
C:\Logs
```

---

## 🚶 Exit-PSSession

La cmdlet `Exit-PSSession` permet de quitter une session interactive distante et de revenir à votre session PowerShell locale.

```powershell
# Méthode 1 : Cmdlet complète
Exit-PSSession

# Méthode 2 : Alias simplifié
exit

# Les deux méthodes sont équivalentes
```

**Comportement à la sortie :**

```powershell
# Dans la session distante
[Server01]: PS C:\Logs> Exit-PSSession

# Retour immédiat à la session locale
PS C:\Users\Admin>
```

> [!info] Fermeture de session `Exit-PSSession` **ferme la session distante**. Toutes les variables et le contexte créés pendant la session sont perdus. Si vous souhaitez préserver une session pour y retourner plus tard, utilisez plutôt les `PSSession` persistantes (qui seront abordées dans une autre partie du cours).

---

## ⚠️ Limitations des sessions interactives

Les sessions interactives avec `Enter-PSSession` ont des contraintes importantes à comprendre :

### 1. Une seule machine à la fois (1-to-1)

```powershell
# ❌ Impossible de se connecter à plusieurs machines simultanément
Enter-PSSession -ComputerName Server01
# Vous êtes maintenant sur Server01

Enter-PSSession -ComputerName Server02
# Erreur : vous devez d'abord sortir de Server01
```

> [!warning] Limitation fondamentale Vous ne pouvez avoir qu'**une seule session interactive active** à la fois. Pour gérer plusieurs machines simultanément, il faut utiliser `Invoke-Command` (abordé dans une autre partie).

### 2. Pas d'exécution parallèle

```powershell
# ❌ Impossible d'exécuter des tâches en parallèle
[Server01]: PS C:\> Start-Job { Get-Process }
# Les jobs ne fonctionnent pas comme attendu dans une session distante interactive
```

### 3. Pas adapté aux scripts automatisés

```powershell
# ❌ Mauvaise pratique : utiliser Enter-PSSession dans un script
# Le script s'arrête et attend une interaction manuelle
Enter-PSSession -ComputerName Server01
Get-Service
Exit-PSSession

# ✅ Bonne pratique : utiliser Invoke-Command pour l'automatisation
Invoke-Command -ComputerName Server01 -ScriptBlock { Get-Service }
```

> [!warning] Scripts automatisés `Enter-PSSession` est **exclusivement pour l'interaction manuelle**. Dans les scripts, utilisez toujours `Invoke-Command` ou les `PSSession` avec `Invoke-Command`.

### 4. Pas de redirection de sortie élégante

```powershell
# ❌ Difficile de capturer la sortie dans un fichier local
[Server01]: PS C:\> Get-Process > C:\local\processes.txt
# Ceci créera le fichier sur Server01, pas localement !
```

---

## 💼 Cas d'usage recommandés

### 1. Dépannage interactif

Lorsqu'un serveur rencontre un problème et que vous devez investiguer en temps réel.

```powershell
# Se connecter au serveur problématique
Enter-PSSession -ComputerName ProdServer01 -Credential (Get-Credential)

# Investiguer en temps réel
[ProdServer01]: PS C:\> Get-EventLog -LogName System -Newest 50 | Where-Object {$_.EntryType -eq "Error"}
[ProdServer01]: PS C:\> Get-Service | Where-Object {$_.Status -eq "Stopped"}
[ProdServer01]: PS C:\> Test-NetConnection -ComputerName DatabaseServer -Port 1433

# Corriger le problème identifié
[ProdServer01]: PS C:\> Restart-Service -Name "MyAppService"

# Vérifier la correction
[ProdServer01]: PS C:\> Get-Service -Name "MyAppService"

Exit-PSSession
```

### 2. Exploration à distance

Découvrir la configuration d'un serveur ou explorer son contenu.

```powershell
Enter-PSSession -ComputerName FileServer01

# Explorer la structure des répertoires
[FileServer01]: PS C:\> Get-ChildItem C:\Shares -Recurse -Directory

# Vérifier les permissions
[FileServer01]: PS C:\> Get-Acl C:\Shares\Finance

# Examiner l'espace disque
[FileServer01]: PS C:\> Get-PSDrive -PSProvider FileSystem

Exit-PSSession
```

### 3. Configuration manuelle interactive

Quand vous devez configurer quelque chose avec des décisions à prendre au fil de l'eau.

```powershell
Enter-PSSession -ComputerName WebServer01 -Credential (Get-Credential)

# Vérifier la configuration IIS existante
[WebServer01]: PS C:\> Import-Module WebAdministration
[WebServer01]: PS C:\> Get-Website

# Décider de la suite en fonction des résultats
[WebServer01]: PS C:\> New-Website -Name "NewSite" -Port 8080 -PhysicalPath "C:\inetpub\newsite"

# Tester immédiatement
[WebServer01]: PS C:\> Invoke-WebRequest http://localhost:8080

Exit-PSSession
```

### 4. Formation et démonstration

Montrer en direct le fonctionnement d'un serveur ou d'une infrastructure.

```powershell
# Parfait pour des sessions de formation en live
Enter-PSSession -ComputerName DemoServer

[DemoServer]: PS C:\> # Montrer les processus en cours
[DemoServer]: PS C:\> Get-Process | Sort-Object CPU -Descending | Select-Object -First 10

[DemoServer]: PS C:\> # Démontrer la gestion des services
[DemoServer]: PS C:\> Get-Service | Where-Object {$_.Status -eq "Running"} | Measure-Object

Exit-PSSession
```

---

## ⚖️ Comparaison avec d'autres approches

|Critère|Enter-PSSession|Invoke-Command|PSSession persistante|
|---|---|---|---|
|**Type**|Interactif|Non-interactif|Les deux|
|**Nombre de machines**|1 seule|Plusieurs simultanément|Plusieurs|
|**Parallélisme**|Non|Oui|Oui|
|**Dans un script**|❌ Non recommandé|✅ Recommandé|✅ Recommandé|
|**Préservation contexte**|Durant la session|Non (chaque commande = nouveau contexte)|Oui|
|**Cas d'usage**|Dépannage manuel|Automatisation|Automatisation avec état|

> [!tip] Choisir la bonne approche
> 
> - **Humain qui dépanne** → `Enter-PSSession`
> - **Script qui automatise** → `Invoke-Command`
> - **Script avec contexte à préserver** → `PSSession` + `Invoke-Command`

---

## 🪤 Pièges courants

### 1. Oublier qu'on est en session distante

```powershell
[Server01]: PS C:\> # On pense être sur la machine locale
[Server01]: PS C:\> Remove-Item C:\ImportantLocalFile.txt
# ❌ Oups ! Le fichier est supprimé sur Server01, pas localement !
```

> [!warning] Vigilance constante Vérifiez toujours le prompt avant d'exécuter des commandes destructrices. Le `[ServerName]` au début du prompt est votre seul garde-fou.

### 2. Chemins locaux vs distants

```powershell
# ❌ Confusion fréquente
Enter-PSSession -ComputerName Server01
[Server01]: PS C:\> Get-Content C:\Users\MyUser\Documents\config.txt
# Cherche le fichier sur Server01, pas sur votre machine locale !

# ✅ Si vous voulez lire un fichier local, il faut le copier d'abord
Exit-PSSession
Copy-Item C:\Users\MyUser\Documents\config.txt -Destination \\Server01\C$\Temp\
Enter-PSSession -ComputerName Server01
[Server01]: PS C:\> Get-Content C:\Temp\config.txt
```

### 3. Modules non disponibles à distance

```powershell
[Server01]: PS C:\> Import-Module MyCustomModule
# ❌ Erreur : le module n'existe que sur votre machine locale !
```

> [!info] Modules distants Les modules doivent être installés sur la machine distante pour être disponibles dans la session. Votre environnement local n'est pas transféré.

### 4. Oublier de sortir de la session

```powershell
[Server01]: PS C:\> # Session ouverte depuis 2 heures
[Server01]: PS C:\> # Consomme des ressources inutilement
```

> [!tip] Hygiène des sessions Prenez l'habitude de faire `Exit-PSSession` dès que vous avez terminé. Les sessions ouvertes consomment des ressources sur le serveur distant.

---

## ✅ Bonnes pratiques

### 1. Utilisez toujours des credentials explicites en production

```powershell
# ❌ Évitez en production
Enter-PSSession -ComputerName ProdServer

# ✅ Toujours spécifier les credentials
$cred = Get-Credential -UserName "PROD\ServiceAccount"
Enter-PSSession -ComputerName ProdServer -Credential $cred
```

### 2. Vérifiez votre emplacement avant toute action destructrice

```powershell
[Server01]: PS C:\> # Avant de supprimer/modifier quoi que ce soit
[Server01]: PS C:\> hostname
Server01

[Server01]: PS C:\> Get-Location
Path
----
C:\Production\Data

# Maintenant je suis sûr de ma position
```

### 3. Utilisez UseSSL en environnement sensible

```powershell
# ✅ Communications chiffrées
Enter-PSSession -ComputerName SensitiveServer -UseSSL -Credential (Get-Credential)
```

### 4. Documentez vos actions dans un transcript

```powershell
# Démarrer un transcript local avant la session
Start-Transcript -Path "C:\Logs\RemoteSession_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

Enter-PSSession -ComputerName Server01
# ... vos commandes ...
Exit-PSSession

Stop-Transcript
# Tout est enregistré pour audit/documentation
```

### 5. Limitez la durée des sessions

```powershell
# ✅ Session courte et ciblée
Enter-PSSession -ComputerName Server01
[Server01]: PS C:\> # Faire uniquement ce qui est nécessaire
[Server01]: PS C:\> Get-EventLog -LogName Application -Newest 10
Exit-PSSession

# ❌ Session qui traîne
Enter-PSSession -ComputerName Server01
# ... pause café de 30 minutes ...
```

### 6. Préférez Invoke-Command pour les scripts

```powershell
# ❌ Ne faites jamais ceci dans un script
function Get-RemoteInfo {
    param($ComputerName)
    Enter-PSSession -ComputerName $ComputerName
    Get-Service
    Exit-PSSession
}

# ✅ Utilisez plutôt Invoke-Command
function Get-RemoteInfo {
    param($ComputerName)
    Invoke-Command -ComputerName $ComputerName -ScriptBlock {
        Get-Service
    }
}
```

---

> [!tip] Astuce finale Créez un alias personnel pour faciliter vos connexions fréquentes :
> 
> ```powershell
> # Dans votre profil PowerShell
> function Connect-ProdServer {
>     $cred = Get-Credential -UserName "PROD\MyAdmin"
>     Enter-PSSession -ComputerName ProdServer01 -Credential $cred -UseSSL
> }
> ```
> 
> Ensuite, tapez simplement `Connect-ProdServer` pour vous connecter rapidement !