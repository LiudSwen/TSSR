

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

## 🎯 Introduction aux alias

### Qu'est-ce qu'un alias ?

Un **alias** est un raccourci ou un nom alternatif pour une cmdlet, une fonction ou un exécutable. C'est comme un surnom qui permet d'exécuter une commande longue avec un nom plus court et familier.

> [!info] Pourquoi utiliser des alias ?
> 
> - **Gain de temps** : Taper `ls` au lieu de `Get-ChildItem`
> - **Familiarité** : Utiliser des commandes connues d'autres shells (Linux, CMD)
> - **Productivité** : Réduire la frappe dans les sessions interactives

### Quand utiliser les alias ?

- ✅ **Sessions interactives** : Pour travailler rapidement dans la console
- ✅ **Exploration** : Pour tester et expérimenter
- ✅ **Usage personnel** : Dans votre environnement de développement

> [!warning] Quand NE PAS utiliser les alias ?
> 
> - ❌ **Scripts de production** : Ils réduisent la lisibilité
> - ❌ **Code partagé** : D'autres utilisateurs peuvent avoir des alias différents
> - ❌ **Documentation** : Les noms complets sont plus clairs

---

## 📚 Comprendre les alias prédéfinis

PowerShell inclut de nombreux alias prédéfinis pour faciliter la transition depuis d'autres environnements.

### Alias de style Unix/Linux

|Alias|Cmdlet complète|Description|
|---|---|---|
|`ls`|`Get-ChildItem`|Liste les fichiers et dossiers|
|`pwd`|`Get-Location`|Affiche le répertoire courant|
|`cd`|`Set-Location`|Change de répertoire|
|`cp`|`Copy-Item`|Copie des fichiers/dossiers|
|`mv`|`Move-Item`|Déplace ou renomme|
|`rm`|`Remove-Item`|Supprime des fichiers/dossiers|
|`cat`|`Get-Content`|Affiche le contenu d'un fichier|
|`man`|`Get-Help`|Affiche l'aide|
|`ps`|`Get-Process`|Liste les processus|
|`kill`|`Stop-Process`|Arrête un processus|

### Alias de style CMD (Windows)

|Alias|Cmdlet complète|Description|
|---|---|---|
|`dir`|`Get-ChildItem`|Liste les fichiers et dossiers|
|`cls`|`Clear-Host`|Efface l'écran|
|`copy`|`Copy-Item`|Copie des fichiers|
|`move`|`Move-Item`|Déplace des fichiers|
|`del`|`Remove-Item`|Supprime des fichiers|
|`type`|`Get-Content`|Affiche le contenu|
|`md`|`New-Item -ItemType Directory`|Crée un répertoire|

### Alias abrégés PowerShell

|Alias|Cmdlet complète|Description|
|---|---|---|
|`gci`|`Get-ChildItem`|Liste les éléments|
|`gcm`|`Get-Command`|Recherche des commandes|
|`gal`|`Get-Alias`|Liste les alias|
|`sal`|`Set-Alias`|Définit un alias|
|`iwr`|`Invoke-WebRequest`|Requête web|
|`sls`|`Select-String`|Recherche de texte|
|`fl`|`Format-List`|Format liste|
|`ft`|`Format-Table`|Format tableau|

> [!example] Exemple d'utilisation
> 
> ```powershell
> # Ces trois commandes sont équivalentes
> Get-ChildItem C:\Users
> ls C:\Users
> dir C:\Users
> gci C:\Users
> ```

---

## 🔍 Lister les alias avec Get-Alias

### Syntaxe de base

```powershell
Get-Alias [[-Name] <String[]>] [-Scope <String>]
```

### Lister tous les alias

```powershell
# Affiche tous les alias disponibles
Get-Alias

# Avec format tableau pour une meilleure lisibilité
Get-Alias | Format-Table -AutoSize
```

### Rechercher un alias spécifique

```powershell
# Rechercher l'alias "ls"
Get-Alias -Name ls

# Rechercher plusieurs alias
Get-Alias -Name ls, pwd, cd
```

### Trouver l'alias d'une cmdlet

```powershell
# Trouver tous les alias qui pointent vers Get-ChildItem
Get-Alias -Definition Get-ChildItem

# Résultat : dir, ls, gci
```

> [!tip] Astuce de recherche
> 
> ```powershell
> # Rechercher tous les alias contenant "get"
> Get-Alias | Where-Object { $_.Name -like "*get*" }
> 
> # Rechercher par définition partielle
> Get-Alias | Where-Object { $_.Definition -like "*Item*" }
> ```

### Propriétés importantes d'un alias

```powershell
# Voir toutes les propriétés d'un alias
Get-Alias ls | Format-List *

# Propriétés principales :
# - Name          : Le nom de l'alias
# - Definition    : La cmdlet complète
# - ResolvedCommand : La commande résolue
# - Options       : Options (None, ReadOnly, AllScope)
```

> [!example] Exploration approfondie
> 
> ```powershell
> # Grouper les alias par cmdlet
> Get-Alias | Group-Object Definition | Sort-Object Count -Descending
> 
> # Compter le nombre d'alias
> (Get-Alias).Count
> 
> # Trouver les alias en lecture seule
> Get-Alias | Where-Object { $_.Options -match "ReadOnly" }
> ```

---

## ⚙️ Créer des alias personnalisés

### New-Alias : Créer un nouvel alias

```powershell
New-Alias [-Name] <String> [-Value] <String> [-Scope <String>]
```

> [!info] Paramètres principaux
> 
> - **Name** : Le nom du nouvel alias (ce que vous tapez)
> - **Value** : La cmdlet ou commande cible
> - **Scope** : Portée de l'alias (Global, Local, Script)

#### Exemples simples

```powershell
# Créer un alias pour Get-Process
New-Alias -Name "proc" -Value "Get-Process"
proc  # Équivaut à Get-Process

# Créer un alias pour notepad
New-Alias -Name "np" -Value "notepad.exe"
np  # Ouvre le Bloc-notes

# Alias pour ouvrir Visual Studio Code
New-Alias -Name "code" -Value "C:\Program Files\Microsoft VS Code\Code.exe"
```

> [!warning] Limitation importante Les alias PowerShell **ne peuvent pas** accepter de paramètres !
> 
> ```powershell
> # ❌ Ceci NE fonctionne PAS
> New-Alias -Name "ll" -Value "Get-ChildItem -Force"
> 
> # Solution : Créer une fonction à la place
> function ll { Get-ChildItem -Force }
> ```

### Set-Alias : Modifier un alias existant

```powershell
Set-Alias [-Name] <String> [-Value] <String> [-Scope <String>]
```

```powershell
# Créer un alias
New-Alias -Name "test" -Value "Get-Service"

# Le modifier
Set-Alias -Name "test" -Value "Get-Process"

# Vérifier
Get-Alias test
```

> [!tip] Différence New-Alias vs Set-Alias
> 
> - **New-Alias** : Crée un nouvel alias, erreur si déjà existant
> - **Set-Alias** : Crée ou modifie un alias existant
> 
> En pratique, `Set-Alias` est plus flexible et souvent préféré.

### Gestion de la portée (Scope)

```powershell
# Alias local (session courante uniquement)
Set-Alias -Name "myalias" -Value "Get-Date" -Scope Local

# Alias global (toute la session PowerShell)
Set-Alias -Name "myalias" -Value "Get-Date" -Scope Global

# Alias script (valable uniquement dans le script)
Set-Alias -Name "myalias" -Value "Get-Date" -Scope Script
```

> [!info] Portées par défaut Sans préciser `-Scope`, l'alias est créé dans la portée **locale** actuelle.

### Supprimer un alias

```powershell
# Supprimer un alias spécifique
Remove-Item -Path Alias:myalias

# Alternative avec Remove-Alias (PowerShell 6+)
Remove-Alias -Name myalias

# Forcer la suppression d'un alias en lecture seule
Remove-Item -Path Alias:myalias -Force
```

> [!example] Cas pratiques d'alias personnalisés
> 
> ```powershell
> # Alias pour des outils fréquents
> Set-Alias -Name "chrome" -Value "C:\Program Files\Google\Chrome\Application\chrome.exe"
> Set-Alias -Name "excel" -Value "C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE"
> 
> # Alias pour des cmdlets longues
> Set-Alias -Name "gps" -Value "Get-Process"
> Set-Alias -Name "gsv" -Value "Get-Service"
> 
> # Attention : pour des commandes avec paramètres, utilisez des fonctions !
> function ll { Get-ChildItem -Force }
> function la { Get-ChildItem -Force -Hidden }
> ```

---

## ⚖️ Alias vs Cmdlets complètes

### Avantages des alias

|Avantage|Description|
|---|---|
|**Rapidité**|Frappe plus courte pour gagner du temps|
|**Familiarité**|Utiliser des commandes connues (Linux, CMD)|
|**Productivité**|Accélère le travail interactif|
|**Compatibilité**|Facilite la transition entre environnements|

### Inconvénients des alias

|Inconvénient|Description|
|---|---|
|**Ambiguïté**|`ls` peut signifier différentes choses selon le contexte|
|**Lisibilité**|Code moins explicite pour les débutants|
|**Portabilité**|Dépendent de la configuration locale|
|**Maintenance**|Scripts difficiles à comprendre à long terme|

### Comparaison détaillée

```powershell
# ❌ Script avec alias (peu lisible)
gci C:\Users | ? { $_.PSIsContainer } | % { $_.Name }

# ✅ Script avec cmdlets complètes (clair et explicite)
Get-ChildItem -Path C:\Users | 
    Where-Object { $_.PSIsContainer } | 
    ForEach-Object { $_.Name }
```

> [!warning] Pièges courants
> 
> ```powershell
> # Piège 1 : Alias masqués par des exécutables
> # Si "curl.exe" existe, l'alias "curl" pour Invoke-WebRequest est masqué
> 
> # Piège 2 : Alias personnalisés non partagés
> # Votre script utilise "myalias" mais d'autres utilisateurs ne l'ont pas
> 
> # Piège 3 : Confusion entre environnements
> # "ls" se comporte différemment sous Linux et PowerShell
> ```

### Quand utiliser quoi ?

|Contexte|Utiliser|
|---|---|
|Console interactive|✅ Alias|
|Tests rapides|✅ Alias|
|Scripts personnels temporaires|✅ Alias|
|Scripts de production|❌ Cmdlets complètes|
|Code partagé en équipe|❌ Cmdlets complètes|
|Modules publiés|❌ Cmdlets complètes|
|Documentation|❌ Cmdlets complètes|

---

## 📏 Bonnes pratiques

### 1. Utilisation contextuelle appropriée

> [!tip] Console vs Scripts
> 
> ```powershell
> # ✅ Console interactive : utilisez des alias
> PS> ls | ? { $_.Length -gt 1MB }
> 
> # ✅ Script de production : utilisez des cmdlets complètes
> Get-ChildItem | Where-Object { $_.Length -gt 1MB }
> ```

### 2. Nommage cohérent

```powershell
# ✅ Noms courts et mémorables
Set-Alias -Name "np" -Value "notepad.exe"
Set-Alias -Name "gh" -Value "Get-Help"

# ❌ Noms trop cryptiques
Set-Alias -Name "x" -Value "Get-Process"  # Trop court, peu clair
Set-Alias -Name "getallprocesses" -Value "Get-Process"  # Trop long, défait l'objectif
```

### 3. Documentation des alias personnalisés

```powershell
# ✅ Documenter vos alias dans un profil
# Mes alias personnalisés pour le développement
Set-Alias -Name "vscode" -Value "C:\Program Files\Microsoft VS Code\Code.exe"  # Visual Studio Code
Set-Alias -Name "chrome" -Value "C:\Program Files\Google\Chrome\Application\chrome.exe"  # Navigateur Chrome
```

### 4. Éviter de redéfinir les alias standard

```powershell
# ❌ Mauvaise pratique : redéfinir un alias courant
Set-Alias -Name "ls" -Value "Get-Service"  # Confusion garantie !

# ✅ Bonne pratique : créer un nouvel alias distinct
Set-Alias -Name "lsvc" -Value "Get-Service"  # Clair et distinct
```

### 5. Privilégier les fonctions pour la complexité

```powershell
# ❌ Impossible avec un alias
Set-Alias -Name "ll" -Value "Get-ChildItem -Force"  # Ne fonctionne pas

# ✅ Utiliser une fonction à la place
function ll { 
    Get-ChildItem -Force @args 
}

# ✅ Fonction avec paramètres avancés
function ll { 
    param([string]$Path = ".")
    Get-ChildItem -Path $Path -Force 
}
```

### 6. Vérifier les conflits avant de créer un alias

```powershell
# Vérifier si un alias existe déjà
if (Get-Alias -Name "myalias" -ErrorAction SilentlyContinue) {
    Write-Warning "L'alias 'myalias' existe déjà !"
} else {
    Set-Alias -Name "myalias" -Value "Get-Process"
}

# Vérifier si une commande existe
if (Get-Command "myalias" -ErrorAction SilentlyContinue) {
    Write-Warning "Une commande 'myalias' existe déjà !"
}
```

> [!warning] Ordre de priorité des commandes PowerShell résout les commandes dans cet ordre :
> 
> 1. **Alias**
> 2. **Fonctions**
> 3. **Cmdlets**
> 4. **Exécutables** (fichiers .exe, .bat, etc.)
> 
> Un alias peut masquer une fonction ou une cmdlet !

---

## 💾 Exportation et persistance des alias

### Problème : Les alias sont temporaires

```powershell
# Créer un alias dans la session courante
Set-Alias -Name "np" -Value "notepad.exe"

# ❌ Après fermeture de PowerShell, l'alias est perdu !
```

> [!info] Les alias disparaissent Par défaut, les alias créés dans une session PowerShell sont **perdus** à la fermeture de la session.

### Solution 1 : Le profil PowerShell

Le **profil PowerShell** est un script qui s'exécute automatiquement au démarrage de chaque session.

#### Localisation du profil

```powershell
# Afficher le chemin du profil
$PROFILE

# Résultat typique :
# C:\Users\VotreNom\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
```

#### Créer et éditer le profil

```powershell
# Vérifier si le profil existe
Test-Path $PROFILE

# Créer le profil s'il n'existe pas
if (!(Test-Path $PROFILE)) {
    New-Item -Path $PROFILE -ItemType File -Force
}

# Ouvrir le profil dans le Bloc-notes
notepad $PROFILE

# Ou dans votre éditeur préféré
code $PROFILE  # Visual Studio Code
```

#### Ajouter des alias au profil

```powershell
# Contenu du fichier $PROFILE

# Alias système
Set-Alias -Name "np" -Value "notepad.exe"
Set-Alias -Name "chrome" -Value "C:\Program Files\Google\Chrome\Application\chrome.exe"

# Fonctions avec paramètres
function ll { Get-ChildItem -Force @args }
function la { Get-ChildItem -Force -Hidden @args }

# Alias pour des cmdlets longues
Set-Alias -Name "gps" -Value "Get-Process"
Set-Alias -Name "gsv" -Value "Get-Service"

Write-Host "Profil PowerShell chargé avec succès !" -ForegroundColor Green
```

> [!tip] Recharger le profil sans redémarrer
> 
> ```powershell
> # Recharger le profil après modification
> . $PROFILE
> 
> # Alternative
> & $PROFILE
> ```

### Solution 2 : Export-Alias et Import-Alias

#### Exporter les alias actuels

```powershell
# Exporter tous les alias dans un fichier
Export-Alias -Path "C:\MesAlias\aliases.txt"

# Exporter uniquement les alias personnalisés (non ReadOnly)
Get-Alias | Where-Object { $_.Options -notmatch "ReadOnly" } | 
    Export-Alias -Path "C:\MesAlias\custom_aliases.txt"
```

#### Importer des alias depuis un fichier

```powershell
# Importer les alias
Import-Alias -Path "C:\MesAlias\aliases.txt"

# Importer avec remplacement des alias existants
Import-Alias -Path "C:\MesAlias\aliases.txt" -Force
```

> [!warning] Limitations d'Export-Alias
> 
> - **Ne sauvegarde que le nom et la définition**, pas les fonctions complexes
> - **Format propriétaire PowerShell**, pas du code exécutable direct
> - Mieux adapté pour la sauvegarde que pour le partage

### Solution 3 : Module personnalisé

Pour une gestion professionnelle, créez un module.

```powershell
# Structure du module
# C:\Users\VotreNom\Documents\WindowsPowerShell\Modules\MesAlias\
#   ├── MesAlias.psm1
#   └── MesAlias.psd1

# Contenu de MesAlias.psm1
Set-Alias -Name "np" -Value "notepad.exe"
Set-Alias -Name "chrome" -Value "C:\Program Files\Google\Chrome\Application\chrome.exe"

function ll { Get-ChildItem -Force @args }
function la { Get-ChildItem -Force -Hidden @args }

Export-ModuleMember -Alias * -Function *
```

```powershell
# Dans votre profil $PROFILE
Import-Module MesAlias
```

> [!tip] Avantages d'un module
> 
> - Organisation professionnelle
> - Facilité de partage
> - Gestion de versions
> - Peut contenir fonctions, alias et variables

### Comparaison des méthodes de persistance

|Méthode|Avantages|Inconvénients|Usage recommandé|
|---|---|---|---|
|**Profil PowerShell**|Simple, automatique|Spécifique à votre machine|Usage personnel|
|**Export/Import-Alias**|Sauvegarde rapide|Format non standard|Backup/Restore|
|**Module personnalisé**|Professionnel, partageable|Plus complexe à configurer|Équipes, projets|

> [!example] Combinaison recommandée
> 
> ```powershell
> # Dans $PROFILE
> 
> # Alias simples directs
> Set-Alias -Name "np" -Value "notepad.exe"
> 
> # Fonctions plus complexes
> function ll { Get-ChildItem -Force @args }
> 
> # Import d'un module pour les alias d'équipe
> if (Test-Path "C:\SharedModules\TeamAliases") {
>     Import-Module "C:\SharedModules\TeamAliases"
> }
> ```

---

## 🎓 Récapitulatif

Les alias PowerShell sont des outils puissants pour améliorer votre productivité dans la console interactive. Retenez :

- ✅ **Utilisez les alias** dans la console pour gagner du temps
- ✅ **Explorez les alias prédéfinis** avec `Get-Alias`
- ✅ **Créez des alias personnalisés** avec `Set-Alias` pour vos commandes fréquentes
- ❌ **Évitez les alias** dans les scripts de production
- ✅ **Privilégiez les fonctions** pour les commandes avec paramètres
- ✅ **Persistez vos alias** via le profil PowerShell ou un module
- ✅ **Documentez vos alias** pour vous et votre équipe

> [!tip] Commandes essentielles à retenir
> 
> ```powershell
> Get-Alias                        # Lister tous les alias
> Get-Alias -Name ls               # Détails d'un alias
> Get-Alias -Definition Get-Item   # Trouver les alias d'une cmdlet
> Set-Alias -Name myalias -Value Get-Process  # Créer un alias
> Remove-Item Alias:myalias        # Supprimer un alias
> $PROFILE                         # Chemin du profil
> . $PROFILE                       # Recharger le profil
> ```

---

**💡 Les alias sont vos alliés dans la console, mais vos cmdlets complètes sont vos amis dans les scripts !**