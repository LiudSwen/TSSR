
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

## Introduction

`Start-Process` est la cmdlet PowerShell dédiée au lancement de nouveaux processus. Contrairement à l'opérateur d'appel `&` ou à l'invocation directe, `Start-Process` offre un contrôle granulaire sur l'exécution des programmes externes.

> [!info] Pourquoi utiliser Start-Process ?
> 
> - Contrôle précis du comportement du processus (fenêtre, privilèges, répertoire)
> - Gestion des arguments complexes
> - Récupération d'informations sur le processus lancé
> - Élévation de privilèges (Run as Administrator)
> - Attente de la fin d'exécution avec `-Wait`

> [!warning] Quand ne PAS utiliser Start-Process
> 
> - Pour exécuter des cmdlets PowerShell (utilisez l'appel direct)
> - Pour des scripts simples sans besoin de contrôle (l'opérateur `&` suffit)
> - Pour capturer la sortie standard facilement (préférez l'opérateur `&` ou `Invoke-Expression`)

---

## Syntaxe de base

```powershell
Start-Process [-FilePath] <String> 
    [-ArgumentList <String[]>] 
    [-WorkingDirectory <String>]
    [-Verb <String>]
    [-WindowStyle <ProcessWindowStyle>]
    [-Wait]
    [-PassThru]
    [-RedirectStandardOutput <String>]
    [-RedirectStandardError <String>]
    [-NoNewWindow]
    [<CommonParameters>]
```

**Forme minimale :**

```powershell
# Lancement simple d'un exécutable
Start-Process "notepad.exe"

# Équivalent avec alias
start notepad.exe
```

> [!tip] Alias disponibles `Start-Process` possède deux alias courants :
> 
> - `start` (Windows)
> - `saps` (abréviation de Start-Process)

---

## Paramètre `-FilePath`

Spécifie le chemin de l'exécutable ou du fichier à lancer.

```powershell
# Chemin absolu
Start-Process -FilePath "C:\Program Files\Mozilla Firefox\firefox.exe"

# Chemin relatif
Start-Process -FilePath ".\MonScript.ps1"

# Exécutable dans le PATH
Start-Process -FilePath "notepad.exe"

# Fichier avec association
Start-Process -FilePath "document.pdf"  # Ouvre avec le lecteur PDF par défaut
```

> [!info] Associations de fichiers Si vous spécifiez un fichier (non exécutable), Windows utilise l'application associée au type de fichier. Par exemple, un `.pdf` s'ouvrira avec Adobe Reader ou votre lecteur PDF par défaut.

**Avec guillemets pour les chemins avec espaces :**

```powershell
Start-Process -FilePath "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"

# Ou avec échappement
Start-Process -FilePath 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe'
```

---

## Paramètre `-ArgumentList`

Passe des arguments au processus lancé. Accepte un tableau de chaînes.

```powershell
# Un seul argument
Start-Process -FilePath "notepad.exe" -ArgumentList "C:\temp\fichier.txt"

# Plusieurs arguments
Start-Process -FilePath "chrome.exe" -ArgumentList "https://google.com", "--incognito"

# Arguments avec espaces (guillemets internes)
Start-Process -FilePath "robocopy.exe" -ArgumentList "C:\Source", "C:\Destination", "/MIR"
```

> [!warning] Attention aux guillemets Les arguments contenant des espaces doivent être échappés correctement. Utilisez des guillemets simples ou doubles selon le contexte.

**Exemples complexes :**

```powershell
# Compilation avec MSBuild
Start-Process -FilePath "msbuild.exe" -ArgumentList "MonProjet.sln", "/p:Configuration=Release", "/m"

# Git avec arguments multiples
Start-Process -FilePath "git.exe" -ArgumentList "clone", "https://github.com/user/repo.git", "C:\Projets\repo"

# Arguments avec guillemets imbriqués
$args = @(
    "/c",
    "echo 'Bonjour le monde' > output.txt"
)
Start-Process -FilePath "cmd.exe" -ArgumentList $args
```

> [!tip] Tableau d'arguments Pour une meilleure lisibilité avec de nombreux arguments, utilisez un tableau :
> 
> ```powershell
> $arguments = @(
>     "--arg1", "valeur1",
>     "--arg2", "valeur2",
>     "--verbose"
> )
> Start-Process -FilePath "programme.exe" -ArgumentList $arguments
> ```

---

## Paramètre `-WorkingDirectory`

Définit le répertoire de travail du processus. Utile quand l'application attend des fichiers dans un répertoire spécifique.

```powershell
# Lancer une application dans un répertoire spécifique
Start-Process -FilePath "cmd.exe" -WorkingDirectory "C:\Projets\MonApp"

# Exécuter un script depuis son répertoire
Start-Process -FilePath "python.exe" -ArgumentList "script.py" -WorkingDirectory "C:\Scripts"
```

> [!info] Pourquoi c'est important Certaines applications cherchent des fichiers de configuration ou des ressources relativement à leur répertoire de travail. Sans `-WorkingDirectory`, le processus hérite du répertoire actuel de PowerShell, ce qui peut causer des erreurs.

**Exemple pratique :**

```powershell
# Build d'un projet Node.js
Start-Process -FilePath "npm.exe" `
    -ArgumentList "run", "build" `
    -WorkingDirectory "C:\Projets\MonAppWeb" `
    -Wait

# Exécution de tests dans le bon répertoire
Start-Process -FilePath "dotnet.exe" `
    -ArgumentList "test" `
    -WorkingDirectory "C:\Projets\MonProjet.Tests"
```

---

## Paramètre `-Verb`

Spécifie une action à effectuer sur le fichier (verbe d'action Windows).

|Verbe|Description|
|---|---|
|`Open`|Ouvre le fichier (défaut)|
|`Edit`|Édite le fichier|
|`Print`|Imprime le fichier|
|`RunAs`|Exécute avec privilèges élevés (Administrateur)|
|`RunAsUser`|Exécute en tant qu'utilisateur spécifique|
|`Properties`|Affiche les propriétés|

```powershell
# Ouvrir un fichier pour édition
Start-Process -FilePath "document.txt" -Verb Edit

# Imprimer directement un document
Start-Process -FilePath "rapport.pdf" -Verb Print

# Afficher les propriétés d'un fichier
Start-Process -FilePath "image.jpg" -Verb Properties
```

> [!info] Lister les verbes disponibles Pour connaître les verbes disponibles pour un type de fichier :
> 
> ```powershell
> $file = Get-Item "fichier.txt"
> $file.GetType().GetMethod("GetVerbs").Invoke($file, $null)
> ```

**Le verbe `RunAs` (voir section Élévation de privilèges) :**

```powershell
# Lancer PowerShell en Administrateur
Start-Process -FilePath "powershell.exe" -Verb RunAs

# Lancer un script avec privilèges élevés
Start-Process -FilePath "powershell.exe" -ArgumentList "-File", "C:\Scripts\Install.ps1" -Verb RunAs
```

---

## Paramètre `-WindowStyle`

Contrôle l'apparence de la fenêtre du processus.

|Valeur|Description|
|---|---|
|`Normal`|Fenêtre normale (défaut)|
|`Hidden`|Fenêtre complètement cachée|
|`Minimized`|Fenêtre minimisée dans la barre des tâches|
|`Maximized`|Fenêtre maximisée (plein écran)|

```powershell
# Lancer en fenêtre cachée
Start-Process -FilePath "robocopy.exe" `
    -ArgumentList "C:\Source", "C:\Backup", "/MIR" `
    -WindowStyle Hidden

# Lancer maximisé
Start-Process -FilePath "chrome.exe" -WindowStyle Maximized

# Lancer minimisé
Start-Process -FilePath "spotify.exe" -WindowStyle Minimized
```

> [!warning] Hidden vs NoNewWindow
> 
> - `-WindowStyle Hidden` : Le processus s'exécute sans fenêtre visible, mais dans son propre processus Windows
> - `-NoNewWindow` : Le processus partage la console PowerShell actuelle (voir section dédiée)

**Exemple d'automatisation silencieuse :**

```powershell
# Backup silencieux en arrière-plan
Start-Process -FilePath "7z.exe" `
    -ArgumentList "a", "backup.7z", "C:\Data", "-mx9" `
    -WindowStyle Hidden `
    -Wait
```

---

## Paramètre `-Wait`

Force PowerShell à attendre la fin du processus avant de continuer.

```powershell
# Sans -Wait : le script continue immédiatement
Start-Process -FilePath "notepad.exe"
Write-Host "Cette ligne s'affiche tout de suite"

# Avec -Wait : attend la fermeture de notepad
Start-Process -FilePath "notepad.exe" -Wait
Write-Host "Cette ligne s'affiche après la fermeture de notepad"
```

> [!info] Cas d'usage `-Wait` est essentiel pour :
> 
> - Exécuter des tâches séquentielles (compilation, puis tests, puis déploiement)
> - Attendre la fin d'une installation
> - S'assurer qu'un processus est terminé avant de traiter ses résultats

**Exemple d'enchaînement de tâches :**

```powershell
# Pipeline de build
Write-Host "🔨 Compilation en cours..."
Start-Process -FilePath "msbuild.exe" `
    -ArgumentList "projet.sln", "/p:Configuration=Release" `
    -Wait

Write-Host "✅ Compilation terminée"

Write-Host "🧪 Exécution des tests..."
Start-Process -FilePath "dotnet.exe" `
    -ArgumentList "test" `
    -Wait

Write-Host "✅ Tests terminés"
```

**Avec timeout (nécessite PassThru) :**

```powershell
# Lancer un processus avec timeout de 30 secondes
$process = Start-Process -FilePath "longue-tache.exe" -PassThru

if (-not $process.WaitForExit(30000)) {  # 30000 ms = 30 secondes
    $process.Kill()
    Write-Warning "Processus arrêté : timeout dépassé"
}
```

---

## Paramètre `-PassThru`

Retourne un objet `System.Diagnostics.Process` représentant le processus lancé.

```powershell
# Sans -PassThru : aucun retour
Start-Process -FilePath "notepad.exe"

# Avec -PassThru : récupération de l'objet processus
$proc = Start-Process -FilePath "notepad.exe" -PassThru

# Propriétés disponibles
$proc.Id              # PID du processus
$proc.ProcessName     # Nom du processus
$proc.StartTime       # Heure de démarrage
$proc.HasExited       # Booléen : le processus est-il terminé ?
```

> [!info] Pourquoi utiliser PassThru ?
> 
> - Surveiller le processus
> - Obtenir le PID pour des opérations ultérieures
> - Tuer le processus si nécessaire
> - Vérifier le code de sortie

**Exemples pratiques :**

```powershell
# Lancer et surveiller un processus
$process = Start-Process -FilePath "backup.exe" -PassThru

Write-Host "Processus lancé avec PID: $($process.Id)"

# Attendre avec monitoring
while (-not $process.HasExited) {
    Write-Host "Processus toujours en cours... CPU: $($process.CPU)s"
    Start-Sleep -Seconds 5
}

Write-Host "Processus terminé avec code de sortie: $($process.ExitCode)"
```

**Tuer un processus après un certain temps :**

```powershell
# Lancer un processus
$proc = Start-Process -FilePath "application.exe" -PassThru

# Attendre 60 secondes
Start-Sleep -Seconds 60

# Tuer si toujours en cours
if (-not $proc.HasExited) {
    $proc.Kill()
    Write-Host "Processus forcé à se terminer"
}
```

**Récupérer le code de sortie :**

```powershell
$process = Start-Process -FilePath "programme.exe" -Wait -PassThru

if ($process.ExitCode -eq 0) {
    Write-Host "✅ Succès"
} else {
    Write-Host "❌ Erreur : code $($process.ExitCode)"
}
```

---

## Redirection des sorties

Capture la sortie standard et les erreurs dans des fichiers.

```powershell
# Rediriger la sortie standard
Start-Process -FilePath "ping.exe" `
    -ArgumentList "google.com" `
    -RedirectStandardOutput "C:\Logs\ping_output.txt" `
    -Wait

# Rediriger les erreurs
Start-Process -FilePath "robocopy.exe" `
    -ArgumentList "C:\Source", "C:\Dest", "/MIR" `
    -RedirectStandardError "C:\Logs\robocopy_errors.txt" `
    -Wait

# Rediriger les deux
Start-Process -FilePath "programme.exe" `
    -RedirectStandardOutput "C:\Logs\output.txt" `
    -RedirectStandardError "C:\Logs\errors.txt" `
    -Wait
```

> [!warning] Limitation importante Lorsque vous utilisez `-RedirectStandardOutput` ou `-RedirectStandardError`, vous **DEVEZ** également utiliser `-NoNewWindow`. Sinon, vous obtiendrez une erreur.

**Exemple complet avec redirection :**

```powershell
# Exécuter un script Python et capturer tout
$outputFile = "C:\Logs\script_output.txt"
$errorFile = "C:\Logs\script_errors.txt"

Start-Process -FilePath "python.exe" `
    -ArgumentList "mon_script.py" `
    -RedirectStandardOutput $outputFile `
    -RedirectStandardError $errorFile `
    -NoNewWindow `
    -Wait

# Lire les résultats
if (Test-Path $errorFile) {
    $errors = Get-Content $errorFile
    if ($errors) {
        Write-Warning "Erreurs détectées:"
        $errors | ForEach-Object { Write-Host $_ -ForegroundColor Red }
    }
}

$output = Get-Content $outputFile
Write-Host "Sortie du script:"
$output | ForEach-Object { Write-Host $_ }
```

> [!tip] Astuce pour éviter les fichiers temporaires Si vous voulez capturer la sortie sans créer de fichier, utilisez plutôt l'opérateur `&` :
> 
> ```powershell
> $output = & "programme.exe" argument1 argument2
> ```

---

## Paramètre `-NoNewWindow`

Lance le processus dans la même fenêtre console que PowerShell (pas de nouvelle fenêtre).

```powershell
# Sans -NoNewWindow : nouvelle fenêtre (défaut)
Start-Process -FilePath "ping.exe" -ArgumentList "google.com"

# Avec -NoNewWindow : dans la console actuelle
Start-Process -FilePath "ping.exe" -ArgumentList "google.com" -NoNewWindow
```

> [!info] Différence avec WindowStyle Hidden
> 
> |Paramètre|Comportement|
> |---|---|
> |`-WindowStyle Hidden`|Processus indépendant, fenêtre cachée|
> |`-NoNewWindow`|Processus partage la console PowerShell|
> |Aucun des deux|Nouvelle fenêtre visible|

**Cas d'usage de `-NoNewWindow` :**

```powershell
# Exécuter une commande et voir immédiatement le résultat
Start-Process -FilePath "ipconfig.exe" -ArgumentList "/all" -NoNewWindow -Wait

# Exécuter plusieurs commandes dans la même console
Start-Process -FilePath "npm.exe" -ArgumentList "install" -NoNewWindow -Wait
Start-Process -FilePath "npm.exe" -ArgumentList "run", "build" -NoNewWindow -Wait
```

> [!warning] Obligatoire avec redirections Si vous utilisez `-RedirectStandardOutput` ou `-RedirectStandardError`, vous **devez** ajouter `-NoNewWindow` :
> 
> ```powershell
> Start-Process -FilePath "programme.exe" `
>     -RedirectStandardOutput "output.txt" `
>     -NoNewWindow `
>     -Wait
> ```

---

## Élévation de privilèges

Exécution de processus avec des privilèges administrateur (UAC).

### Méthode 1 : Utiliser le verbe `RunAs`

```powershell
# Lancer PowerShell en tant qu'administrateur
Start-Process -FilePath "powershell.exe" -Verb RunAs

# Exécuter un script avec privilèges élevés
Start-Process -FilePath "powershell.exe" `
    -ArgumentList "-File", "C:\Scripts\Install.ps1" `
    -Verb RunAs

# Lancer une application en administrateur
Start-Process -FilePath "regedit.exe" -Verb RunAs
```

> [!warning] Interaction UAC L'utilisation de `-Verb RunAs` déclenche une invite UAC (User Account Control). L'utilisateur doit confirmer l'élévation manuellement.

### Méthode 2 : Exécuter un script entier en administrateur

```powershell
# Vérifier si le script est déjà en administrateur
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Relancer le script en administrateur
    Start-Process -FilePath "powershell.exe" `
        -ArgumentList "-File", $PSCommandPath `
        -Verb RunAs
    exit
}

# Le reste du script s'exécute avec privilèges élevés
Write-Host "Script en cours d'exécution avec privilèges administrateur"
```

### Exemples d'opérations nécessitant l'élévation

```powershell
# Installation d'un service Windows
Start-Process -FilePath "sc.exe" `
    -ArgumentList "create", "MonService", "binPath=", "C:\Services\MonService.exe" `
    -Verb RunAs `
    -Wait

# Modification du registre système
Start-Process -FilePath "reg.exe" `
    -ArgumentList "add", "HKLM\SOFTWARE\MaCle", "/v", "Valeur", "/d", "Donnee" `
    -Verb RunAs `
    -Wait

# Installation MSI
Start-Process -FilePath "msiexec.exe" `
    -ArgumentList "/i", "C:\Installers\application.msi", "/quiet" `
    -Verb RunAs `
    -Wait
```

> [!tip] Exécution silencieuse avec élévation Pour automatiser complètement (sans interaction), il faut :
> 
> - Utiliser un compte de service avec privilèges
> - Ou configurer une tâche planifiée avec privilèges élevés
> - Ou utiliser des solutions d'automatisation d'entreprise

---

## Exemples pratiques

### 🌐 Navigateurs Web

```powershell
# Ouvrir Chrome avec une URL
Start-Process -FilePath "chrome.exe" -ArgumentList "https://github.com"

# Firefox en mode privé
Start-Process -FilePath "firefox.exe" -ArgumentList "-private-window", "https://example.com"

# Edge avec plusieurs onglets
Start-Process -FilePath "msedge.exe" -ArgumentList "https://google.com", "https://github.com"

# Chrome en mode incognito et maximisé
Start-Process -FilePath "chrome.exe" `
    -ArgumentList "--incognito", "https://example.com" `
    -WindowStyle Maximized
```

### 📝 Éditeurs et IDE

```powershell
# Ouvrir VS Code dans un répertoire
Start-Process -FilePath "code.exe" `
    -ArgumentList "C:\Projets\MonProjet" `
    -WorkingDirectory "C:\Projets\MonProjet"

# Ouvrir Notepad++ avec un fichier
Start-Process -FilePath "notepad++.exe" -ArgumentList "C:\Scripts\script.ps1"

# Sublime Text avec plusieurs fichiers
Start-Process -FilePath "subl.exe" `
    -ArgumentList "fichier1.txt", "fichier2.txt", "fichier3.txt"
```

### 🛠️ Outils système

```powershell
# Gestionnaire des tâches
Start-Process -FilePath "taskmgr.exe"

# Éditeur de registre en administrateur
Start-Process -FilePath "regedit.exe" -Verb RunAs

# Nettoyage de disque
Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/d", "C:"

# Services Windows
Start-Process -FilePath "services.msc"

# Gestionnaire de périphériques
Start-Process -FilePath "devmgmt.msc"
```

### 💻 Compilation et Build

```powershell
# MSBuild d'un projet .NET
Start-Process -FilePath "msbuild.exe" `
    -ArgumentList "MonProjet.sln", "/p:Configuration=Release", "/m" `
    -WorkingDirectory "C:\Projets\MonProjet" `
    -Wait

# Build npm
Start-Process -FilePath "npm.exe" `
    -ArgumentList "run", "build" `
    -WorkingDirectory "C:\Projets\AppWeb" `
    -NoNewWindow `
    -Wait

# Compilation TypeScript
Start-Process -FilePath "tsc.exe" `
    -WorkingDirectory "C:\Projets\AppTS" `
    -NoNewWindow `
    -Wait
```

### 📦 Installations et déploiements

```powershell
# Installation MSI silencieuse
Start-Process -FilePath "msiexec.exe" `
    -ArgumentList "/i", "application.msi", "/quiet", "/norestart" `
    -Wait

# Installation Chocolatey d'un package
Start-Process -FilePath "choco.exe" `
    -ArgumentList "install", "git", "-y" `
    -Verb RunAs `
    -Wait

# Déploiement avec Robocopy
Start-Process -FilePath "robocopy.exe" `
    -ArgumentList "C:\Source", "\\Serveur\Partage", "/MIR", "/R:3", "/W:5" `
    -RedirectStandardOutput "C:\Logs\robocopy.log" `
    -NoNewWindow `
    -Wait
```

### 🎯 Automatisation avancée

```powershell
# Backup avec 7-Zip et vérification
$backupFile = "backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').7z"

$process = Start-Process -FilePath "7z.exe" `
    -ArgumentList "a", $backupFile, "C:\Data\*", "-mx9" `
    -WorkingDirectory "C:\Backups" `
    -WindowStyle Hidden `
    -PassThru `
    -Wait

if ($process.ExitCode -eq 0) {
    Write-Host "✅ Backup réussi: $backupFile"
} else {
    Write-Host "❌ Échec du backup: code $($process.ExitCode)"
}

# Pipeline de tests automatisés
$tests = @(
    @{Name = "Tests unitaires"; Command = "dotnet"; Args = @("test", "UnitTests.csproj")},
    @{Name = "Tests d'intégration"; Command = "dotnet"; Args = @("test", "IntegrationTests.csproj")},
    @{Name = "Tests E2E"; Command = "npm"; Args = @("run", "test:e2e")}
)

foreach ($test in $tests) {
    Write-Host "🧪 Exécution: $($test.Name)..."
    
    $proc = Start-Process -FilePath $test.Command `
        -ArgumentList $test.Args `
        -NoNewWindow `
        -Wait `
        -PassThru
    
    if ($proc.ExitCode -eq 0) {
        Write-Host "✅ $($test.Name) : SUCCÈS"
    } else {
        Write-Host "❌ $($test.Name) : ÉCHEC (code $($proc.ExitCode))"
        exit $proc.ExitCode
    }
}
```

### 🎮 Exemples créatifs

```powershell
# Lancer plusieurs instances d'une application
1..3 | ForEach-Object {
    Start-Process -FilePath "notepad.exe"
    Start-Sleep -Milliseconds 500
}

# Ouvrir plusieurs sites dans des onglets
$sites = @(
    "https://github.com",
    "https://stackoverflow.com",
    "https://docs.microsoft.com"
)

$sites | ForEach-Object {
    Start-Process -FilePath "chrome.exe" -ArgumentList $_
}

# Playlist de vidéos (VLC)
$videos = Get-ChildItem "C:\Videos\*.mp4"
$videos | ForEach-Object {
    Start-Process -FilePath "vlc.exe" -ArgumentList $_.FullName
    Start-Sleep -Seconds 2
}
```

---

## Pièges courants

### ❌ Piège 1 : Oubli de `-Wait` pour des tâches séquentielles

```powershell
# ❌ MAUVAIS : Le script continue sans attendre
Start-Process -FilePath "msbuild.exe" -ArgumentList "projet.sln"
Start-Process -FilePath "dotnet.exe" -ArgumentList "test"  # Peut échouer si build pas fini

# ✅ BON : Attendre la fin de chaque étape
Start-Process -FilePath "msbuild.exe" -ArgumentList "projet.sln" -Wait
Start-Process -FilePath "dotnet.exe" -ArgumentList "test" -Wait
```

### ❌ Piège 2 : Redirections sans `-NoNewWindow`

```powershell
# ❌ MAUVAIS : Erreur !
Start-Process -FilePath "ping.exe" `
    -ArgumentList "google.com" `
    -RedirectStandardOutput "output.txt" `
    -Wait

# ✅ BON : Ajout de -NoNewWindow
Start-Process -FilePath "ping.exe" `
    -ArgumentList "google.com" `
    -RedirectStandardOutput "output.txt" `
    -NoNewWindow `
    -Wait
```

### ❌ Piège 3 : Arguments mal échappés

```powershell
# ❌ MAUVAIS : Les espaces dans les chemins causent des erreurs
Start-Process -FilePath "robocopy.exe" -ArgumentList C:\Program Files\Source C:\Destination

# ✅ BON : Utiliser des guillemets ou un tableau
Start-Process -FilePath "robocopy.exe" `
    -ArgumentList "C:\Program Files\Source", "C:\Destination", "/MIR"
```

### ❌ Piège 4 : Utiliser Start-Process pour capturer une sortie simple

```powershell
# ❌ COMPLIQUÉ : Utiliser Start-Process alors que & suffit
Start-Process -FilePath "ipconfig.exe" `
    -RedirectStandardOutput "output.txt" `
    -NoNewWindow `
    -Wait
$output = Get-Content "output.txt"

# ✅ MIEUX : Opérateur d'appel
$output = & ipconfig.exe
```

### ❌ Piège 5 : Code de sortie non vérifié

```powershell
# ❌ MAUVAIS : Pas de vérification d'erreur
Start-Process -FilePath "programme.exe" -Wait

# ✅ BON : Vérifier le code de sortie
$proc = Start-Process -FilePath "programme.exe" -Wait -PassThru
if ($proc.ExitCode -ne 0) {
    Write-Error "Le programme a échoué avec le code $($proc.ExitCode)"
    exit $proc.ExitCode
}
```

### ❌ Piège 6 : Confondre `-WindowStyle Hidden` et `-NoNewWindow`

```powershell
# Ces deux ne font PAS la même chose !

# Lance dans une fenêtre cachée (processus séparé)
Start-Process -FilePath "robocopy.exe" -ArgumentList "..." -WindowStyle Hidden

# Lance dans la console actuelle (pas de nouvelle fenêtre)
Start-Process -FilePath "robocopy.exe" -ArgumentList "..." -NoNewWindow
```

---

## Bonnes pratiques

### ✅ 1. Toujours utiliser des chemins absolus en production

```powershell
# ❌ Éviter en production
Start-Process -FilePath "programme.exe"

# ✅ Préférer
Start-Process -FilePath "C:\Program Files\MonApp\programme.exe"

# ✅ Encore mieux : vérifier l'existence
$exePath = "C:\Program Files\MonApp\programme.exe"
if (Test-Path $exePath) {
    Start-Process -FilePath $exePath
} else {
    Write-Error "Programme introuvable: $exePath"
}
```

### ✅ 2. Utiliser `-PassThru` pour des opérations critiques

```powershell
# ✅ Récupérer le processus pour monitoring
$process = Start-Process -FilePath "backup.exe" `
    -ArgumentList "full" `
    -PassThru `
    -Wait

# Vérifier le succès
if ($process.ExitCode -eq 0) {
    Write-Host "✅ Backup réussi"
    # Logique de post-traitement
} else {
    Write-Error "❌ Backup échoué: code $($process.ExitCode)"
    # Alertes, notifications, etc.
}
```

### ✅ 3. Utiliser des tableaux pour des arguments complexes

```powershell
# ✅ Lisible et maintenable
$arguments = @(
    "/c",
    "echo Starting process",
    "&&",
    "timeout /t 5",
    "&&",
    "echo Process complete"
)

Start-Process -FilePath "cmd.exe" `
    -ArgumentList $arguments `
    -NoNewWindow `
    -Wait
```

### ✅ 4. Gérer les erreurs avec Try-Catch

```powershell
# ✅ Gestion robuste des erreurs
try {
    $process = Start-Process -FilePath "programme.exe" `
        -ArgumentList "param1", "param2" `
        -Wait `
        -PassThru `
        -ErrorAction Stop
    
    if ($process.ExitCode -ne 0) {
        throw "Le programme a retourné le code d'erreur: $($process.ExitCode)"
    }
    
    Write-Host "✅ Exécution réussie"
}
catch {
    Write-Error "❌ Erreur lors de l'exécution: $_"
    # Logging, notifications, rollback, etc.
}
```

### ✅ 5. Créer des fonctions réutilisables

```powershell
# ✅ Fonction wrapper pour Start-Process
function Invoke-ProcessWithLogging {
    param(
        [string]$FilePath,
        [string[]]$ArgumentList,
        [string]$Description
    )
    
    Write-Host "▶️ Démarrage: $Description" -ForegroundColor Cyan
    $startTime = Get-Date
    
    try {
        $process = Start-Process -FilePath $FilePath `
            -ArgumentList $ArgumentList `
            -Wait `
            -PassThru `
            -ErrorAction Stop
        
        $duration = (Get-Date) - $startTime
        
        if ($process.ExitCode -eq 0) {
            Write-Host "✅ Succès: $Description (durée: $($duration.TotalSeconds)s)" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ Échec: $Description (code: $($process.ExitCode))" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "❌ Erreur: $Description - $_" -ForegroundColor Red
        return $false
    }
}

# Utilisation
$success = Invoke-ProcessWithLogging `
    -FilePath "msbuild.exe" `
    -ArgumentList "projet.sln", "/p:Configuration=Release" `
    -Description "Compilation du projet"
```

### ✅ 6. Logger les sorties pour le débogage

```powershell
# ✅ Redirection avec horodatage
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logDir = "C:\Logs"
$outputLog = Join-Path $logDir "output_$timestamp.log"
$errorLog = Join-Path $logDir "error_$timestamp.log"

# Créer le répertoire si nécessaire
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

Start-Process -FilePath "programme.exe" `
    -ArgumentList "param1", "param2" `
    -RedirectStandardOutput $outputLog `
    -RedirectStandardError $errorLog `
    -NoNewWindow `
    -Wait

# Analyser les logs
if ((Get-Item $errorLog).Length -gt 0) {
    Write-Warning "Des erreurs ont été détectées. Consultez: $errorLog"
}
```

### ✅ 7. Utiliser des timeouts pour éviter les blocages

```powershell
# ✅ Timeout personnalisé
function Start-ProcessWithTimeout {
    param(
        [string]$FilePath,
        [string[]]$ArgumentList,
        [int]$TimeoutSeconds = 300
    )
    
    $process = Start-Process -FilePath $FilePath `
        -ArgumentList $ArgumentList `
        -PassThru
    
    $finished = $process.WaitForExit($TimeoutSeconds * 1000)
    
    if (-not $finished) {
        Write-Warning "Timeout atteint ($TimeoutSeconds s). Arrêt du processus..."
        $process.Kill()
        throw "Le processus a été arrêté après timeout"
    }
    
    return $process.ExitCode
}

# Utilisation
try {
    $exitCode = Start-ProcessWithTimeout `
        -FilePath "longue-tache.exe" `
        -TimeoutSeconds 60
    
    Write-Host "Processus terminé avec code: $exitCode"
}
catch {
    Write-Error "Erreur: $_"
}
```

### ✅ 8. Documenter les valeurs de retour

```powershell
# ✅ Commenter les codes de sortie possibles
<#
.SYNOPSIS
    Lance le processus de backup avec gestion d'erreurs
.DESCRIPTION
    Codes de sortie:
    0 = Succès
    1 = Erreur générale
    2 = Fichier introuvable
    3 = Permissions insuffisantes
#>
function Start-BackupProcess {
    $process = Start-Process -FilePath "backup.exe" `
        -ArgumentList "full", "C:\Data" `
        -Wait `
        -PassThru
    
    switch ($process.ExitCode) {
        0 { Write-Host "✅ Backup réussi" }
        1 { Write-Error "Erreur générale du backup" }
        2 { Write-Error "Fichier source introuvable" }
        3 { Write-Error "Permissions insuffisantes" }
        default { Write-Error "Code d'erreur inconnu: $($process.ExitCode)" }
    }
    
    return $process.ExitCode
}
```

### ✅ 9. Utiliser des splats pour la lisibilité

```powershell
# ✅ Splatting pour une meilleure lisibilité
$processParams = @{
    FilePath = "robocopy.exe"
    ArgumentList = @(
        "C:\Source",
        "\\Serveur\Backup",
        "/MIR",
        "/R:3",
        "/W:10",
        "/LOG:C:\Logs\robocopy.log"
    )
    WindowStyle = "Hidden"
    Wait = $true
    PassThru = $true
}

$process = Start-Process @processParams

if ($process.ExitCode -le 7) {  # Robocopy codes 0-7 sont OK
    Write-Host "✅ Copie réussie"
} else {
    Write-Error "❌ Échec de la copie: code $($process.ExitCode)"
}
```

### ✅ 10. Centraliser la configuration

```powershell
# ✅ Configuration centralisée
$config = @{
    Paths = @{
        MSBuild = "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
        Git = "C:\Program Files\Git\bin\git.exe"
        NodeJS = "C:\Program Files\nodejs\node.exe"
    }
    Directories = @{
        Projects = "C:\Projets"
        Logs = "C:\Logs"
        Backups = "C:\Backups"
    }
}

# Utilisation
if (Test-Path $config.Paths.MSBuild) {
    Start-Process -FilePath $config.Paths.MSBuild `
        -ArgumentList "projet.sln" `
        -WorkingDirectory $config.Directories.Projects `
        -Wait
} else {
    Write-Error "MSBuild introuvable"
}
```

---

## 🎓 Astuces avancées

### 💡 Astuce 1 : Exécuter avec des variables d'environnement personnalisées

```powershell
# Définir des variables d'environnement temporaires
$env:CUSTOM_VAR = "valeur"
$env:NODE_ENV = "production"

Start-Process -FilePath "node.exe" `
    -ArgumentList "app.js" `
    -WorkingDirectory "C:\App"

# Les variables sont héritées par le processus enfant
```

### 💡 Astuce 2 : Lancer plusieurs processus en parallèle

```powershell
# Lancer plusieurs tâches simultanément
$processes = @()

$tasks = @(
    @{File = "backup1.exe"; Args = @("task1")},
    @{File = "backup2.exe"; Args = @("task2")},
    @{File = "backup3.exe"; Args = @("task3")}
)

foreach ($task in $tasks) {
    $proc = Start-Process -FilePath $task.File `
        -ArgumentList $task.Args `
        -PassThru
    $processes += $proc
}

# Attendre que tous soient terminés
Write-Host "Attente de la fin de tous les processus..."
$processes | ForEach-Object { $_.WaitForExit() }

Write-Host "✅ Tous les processus sont terminés"
```

### 💡 Astuce 3 : Chaîner des processus avec dépendances

```powershell
# Pipeline avec gestion d'erreurs
$pipeline = @(
    @{Name = "Nettoyage"; Exe = "clean.exe"; Args = @()},
    @{Name = "Compilation"; Exe = "msbuild.exe"; Args = @("projet.sln")},
    @{Name = "Tests"; Exe = "dotnet.exe"; Args = @("test")},
    @{Name = "Packaging"; Exe = "pack.exe"; Args = @()}
)

foreach ($step in $pipeline) {
    Write-Host "▶️ $($step.Name)..." -ForegroundColor Cyan
    
    $proc = Start-Process -FilePath $step.Exe `
        -ArgumentList $step.Args `
        -Wait `
        -PassThru
    
    if ($proc.ExitCode -ne 0) {
        Write-Error "❌ Échec à l'étape: $($step.Name)"
        exit $proc.ExitCode
    }
    
    Write-Host "✅ $($step.Name) terminé" -ForegroundColor Green
}

Write-Host "🎉 Pipeline complet avec succès !" -ForegroundColor Green
```

### 💡 Astuce 4 : Créer un wrapper universel

```powershell
# Wrapper universel pour Start-Process
function Invoke-SafeProcess {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$FilePath,
        
        [string[]]$ArgumentList = @(),
        [string]$WorkingDirectory,
        [switch]$AsAdmin,
        [switch]$Hidden,
        [int]$TimeoutSeconds = 0,
        [switch]$LogOutput
    )
    
    $processParams = @{
        FilePath = $FilePath
        PassThru = $true
        Wait = ($TimeoutSeconds -eq 0)
    }
    
    if ($ArgumentList.Count -gt 0) {
        $processParams['ArgumentList'] = $ArgumentList
    }
    
    if ($WorkingDirectory) {
        $processParams['WorkingDirectory'] = $WorkingDirectory
    }
    
    if ($AsAdmin) {
        $processParams['Verb'] = 'RunAs'
    }
    
    if ($Hidden) {
        $processParams['WindowStyle'] = 'Hidden'
    }
    
    if ($LogOutput) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $processParams['RedirectStandardOutput'] = "output_$timestamp.log"
        $processParams['RedirectStandardError'] = "error_$timestamp.log"
        $processParams['NoNewWindow'] = $true
    }
    
    try {
        $process = Start-Process @processParams
        
        if ($TimeoutSeconds -gt 0) {
            $finished = $process.WaitForExit($TimeoutSeconds * 1000)
            if (-not $finished) {
                $process.Kill()
                throw "Timeout de $TimeoutSeconds secondes atteint"
            }
        }
        
        return @{
            Success = ($process.ExitCode -eq 0)
            ExitCode = $process.ExitCode
            Process = $process
        }
    }
    catch {
        Write-Error "Erreur lors de l'exécution: $_"
        return @{
            Success = $false
            ExitCode = -1
            Error = $_.Exception.Message
        }
    }
}

# Utilisation simple
$result = Invoke-SafeProcess -FilePath "programme.exe" -ArgumentList "arg1", "arg2"

if ($result.Success) {
    Write-Host "✅ Succès"
} else {
    Write-Host "❌ Échec: code $($result.ExitCode)"
}
```

### 💡 Astuce 5 : Monitoring en temps réel

```powershell
# Surveiller un processus pendant son exécution
function Start-ProcessWithMonitoring {
    param(
        [string]$FilePath,
        [string[]]$ArgumentList
    )
    
    $process = Start-Process -FilePath $FilePath `
        -ArgumentList $ArgumentList `
        -PassThru
    
    Write-Host "Processus lancé (PID: $($process.Id))"
    
    # Surveiller jusqu'à la fin
    while (-not $process.HasExited) {
        # Rafraîchir les données du processus
        $process.Refresh()
        
        $cpu = [math]::Round($process.TotalProcessorTime.TotalSeconds, 2)
        $memory = [math]::Round($process.WorkingSet64 / 1MB, 2)
        
        Write-Host "`r⏱️ CPU: ${cpu}s | 💾 RAM: ${memory}MB" -NoNewline
        
        Start-Sleep -Milliseconds 500
    }
    
    Write-Host "`n✅ Processus terminé avec code: $($process.ExitCode)"
    return $process.ExitCode
}

# Utilisation
Start-ProcessWithMonitoring -FilePath "longue-tache.exe" -ArgumentList "param"
```

---

## 📊 Tableau récapitulatif des paramètres

|Paramètre|Type|Description|Cas d'usage|
|---|---|---|---|
|`-FilePath`|String|Chemin de l'exécutable|**Obligatoire** - toujours nécessaire|
|`-ArgumentList`|String[]|Arguments du programme|Passer des paramètres à l'application|
|`-WorkingDirectory`|String|Répertoire de travail|Quand l'app attend des fichiers locaux|
|`-Verb`|String|Action Windows (Open, Edit, RunAs)|Élévation de privilèges, actions spéciales|
|`-WindowStyle`|Enum|Style de fenêtre (Hidden, Minimized, etc.)|Exécution en arrière-plan|
|`-Wait`|Switch|Attendre la fin du processus|Tâches séquentielles, pipelines|
|`-PassThru`|Switch|Retourner l'objet Process|Monitoring, contrôle, code de sortie|
|`-RedirectStandardOutput`|String|Fichier pour la sortie standard|Logging, capture de résultats|
|`-RedirectStandardError`|String|Fichier pour les erreurs|Debugging, gestion d'erreurs|
|`-NoNewWindow`|Switch|Partager la console actuelle|Nécessaire avec redirections|

---

## 🔄 Comparaison avec d'autres méthodes

|Méthode|Quand l'utiliser|Avantages|Inconvénients|
|---|---|---|---|
|`Start-Process`|Besoin de contrôle précis|Contrôle total, élévation, fenêtres|Plus verbeux|
|Opérateur `&`|Capture de sortie simple|Simple, capture directe|Moins de contrôle|
|`Invoke-Expression`|Commandes dynamiques|Flexibilité|Risques de sécurité|
|`cmd /c`|Commandes CMD/Batch|Compatibilité Windows|Moins PowerShell natif|
|Appel direct|Cmdlets PowerShell|Natif, simple|Seulement pour cmdlets|

**Exemples comparatifs :**

```powershell
# Méthode 1 : Start-Process (contrôle maximal)
Start-Process -FilePath "ping.exe" -ArgumentList "google.com" -Wait

# Méthode 2 : Opérateur & (simple, capture facile)
$output = & ping.exe google.com

# Méthode 3 : Invoke-Expression (dynamique)
Invoke-Expression "ping google.com"

# Méthode 4 : Via cmd
cmd /c "ping google.com"

# Méthode 5 : Appel direct (seulement pour cmdlets)
Get-Process  # Pas besoin de Start-Process pour les cmdlets !
```

---

## 🎯 Résumé des points clés

> [!important] À retenir absolument
> 
> 1. **`-FilePath`** est obligatoire - spécifie l'exécutable
> 2. **`-Wait`** pour les tâches séquentielles - sinon le script continue
> 3. **`-PassThru`** pour récupérer le processus et vérifier le code de sortie
> 4. **`-NoNewWindow`** obligatoire avec `-RedirectStandardOutput/Error`
> 5. **`-Verb RunAs`** pour l'élévation de privilèges (UAC)
> 6. **Toujours vérifier le code de sortie** (`ExitCode`) en production
> 7. **Gérer les erreurs** avec try-catch et `-ErrorAction Stop`

> [!tip] Recommandations
> 
> - Utilisez des chemins absolus en production
> - Préférez les tableaux pour les arguments complexes
> - Créez des fonctions wrapper pour la réutilisabilité
> - Loggez les sorties pour le debugging
> - Implémentez des timeouts pour éviter les blocages

> [!warning] Pièges à éviter
> 
> - Oublier `-Wait` dans des pipelines séquentiels
> - Ne pas vérifier le code de sortie des processus critiques
> - Utiliser Start-Process quand l'opérateur `&` suffirait
> - Rediriger sans `-NoNewWindow`
> - Ne pas gérer les erreurs potentielles

---

**Fin du cours - Vous maîtrisez maintenant `Start-Process` ! 🎉**