# ⚡ L'essentiel en 5 minutes - PowerShell pour TSSR

## 📌 C'est quoi en 2 lignes ?

PowerShell est un shell et langage de scripting orienté objet .NET pour l'automatisation et la gestion de systèmes Windows. Chaque commande (cmdlet) manipule des objets avec propriétés et méthodes, pas du simple texte.

---

## 💡 Concepts clés à retenir :

- **Cmdlet** : Commande PowerShell au format `Verbe-Nom` (ex: Get-Service, Set-Item)
- **Pipeline (|)** : Passe des objets d'une commande à l'autre, pas du texte
- **Objet .NET** : Tout est objet avec propriétés (données) et méthodes (actions)
- **Variable** : Commence par `$`, typage dynamique ou explicite `[type]$var`
- **$_** : Variable automatique représentant l'objet courant dans le pipeline

---

## 💻 Commandes essentielles :

```powershell
# 🔍 Exploration & Information
Get-ChildItem C:\                  # Lister fichiers/dossiers (alias: ls, dir, gci)
Get-Member                         # Voir propriétés/méthodes d'un objet
Get-Service                        # Lister les services
Get-Process                        # Lister les processus
Get-Help Get-Service               # Aide sur une commande

# 📊 Manipulation d'objets (Pipeline)
Get-Service | Where-Object {$_.Status -eq "Running"}     # Filtrer
Get-Process | Select-Object Name, CPU                     # Sélectionner propriétés
Get-Service | Sort-Object Status                          # Trier
Get-ChildItem | Format-Table Name, Length                 # Formater affichage
Get-Service | ForEach-Object {$_.Stop()}                  # Appliquer action (alias: %)

# 📝 Variables & Substitution
$variable = "valeur"               # Déclaration
$result = $(Get-Date)              # Substitution de commande
"Texte avec $variable"             # Interpolation dans chaîne
[int]$nombre = 42                  # Typage explicite
$env:PATH                          # Variable d'environnement

# 🔄 Structures de contrôle
If ($condition) {code} Else {code} # Condition simple
Switch ($var) {val1 {code}; val2 {code}; default {code}}  # Multi-conditions

For ($i=0; $i -lt 10; $i++) {code}                       # Boucle compteur
ForEach ($item in $collection) {code}                    # Boucle collection
While ($condition) {code}                                # Boucle tant que
Do {code} While ($condition)                             # Boucle do-while (1 passage min)
Do {code} Until ($condition)                             # Boucle jusqu'à

# 📦 Tableaux & Hashtables
$tab = @("val1", "val2", "val3")   # Tableau simple
$tab = 1..10                       # Plage de nombres
$tab[0]                            # Accès index (commence à 0)
$tab[-1]                           # Dernier élément
$tab.Count                         # Nombre d'éléments
$hash = @{cle1="val1"; cle2="val2"} # Hashtable
$hash["cle1"]                      # Accès par clé

# 🔧 Fonctions
function NomFonction {
    param([string]$Param1, [int]$Param2)
    # Code
    return $result
}

# 🌐 Remote PowerShell
Enter-PSSession -ComputerName PC1          # Session interactive distante
Exit-PSSession                             # Quitter session distante
Invoke-Command -ComputerName PC1 -ScriptBlock {code}  # Exécuter code distant
Get-Service -ComputerName PC1              # Cmdlet avec -ComputerName
Test-Connection -ComputerName PC1          # Ping distant

# ⚙️ Jobs (Exécution parallèle)
Start-Job -ScriptBlock {code}              # Lancer job asynchrone
Get-Job                                    # Lister jobs
Receive-Job -Id 1                          # Récupérer résultat job
Wait-Job -Id 1                             # Attendre fin job
Remove-Job -Id 1                           # Supprimer job
Stop-Job -Id 1                             # Arrêter job
```

---

## ⚠️ Pièges à éviter :

- ❌ **Confondre -eq avec =** 
- ❌ **Oublier le $ devant les variables** : `$variable` pas `variable` (erreur cmdlet introuvabl
- ❌ **Index commence à 0** : `$tab[0]` est le 1er élément, `$tab[1]` le 2ème
- ❌ **Espaces dans les comparaisons** : `"test "` ≠ `"test"` (attention aux espaces)
- ❌ **Portée des variables** : Variables dans fonction/script isolées, utiliser `return` ou `$global:`
- ❌ **Ne pas vérifier $null** : Tester `if ($var -eq $null)` pas `if ($var)`
- ❌ **Pipeline = objets** : On passe des objets, pas du texte comme en Bash
- ❌ **Fonctions avant appel** : Déclarer la fonction avant de l'appeler dans le script

---

## ✅ Bonnes pratiques :

- ✅ **PascalCase pour variables** : `$MonServeur` plutôt que `$monserveur`
- ✅ **Get-Member systématiquement** : `cmd | Get-Member` pour découvrir propriétés/méthodes
- ✅ **Utiliser le pipeline** : Chaîner les commandes au lieu de stocker dans variables intermédiaires
- ✅ **Paramètres de fonctions** : Utiliser `param()` avec `[Parameter(Mandatory=$True)]` pour forcer saisie
- ✅ **-ErrorAction SilentlyContinue** : Masquer erreurs non critiques dans scripts
- ✅ **Commenter le code** : `# Commentaire` pour documentation
- ✅ **Validation paramètres** : `[ValidateSet]`, `[ValidateRange]` pour sécuriser fonctions
- ✅ **Jobs pour tâches longues** : Paralléliser pour gagner du temps (Start-Job)

---

## 📚 Vocabulaire technique :

|Terme|Définition courte|
|---|---|
|**Cmdlet**|Commande PowerShell au format Verbe-Nom (Get-Service, Set-Item)|
|**Pipeline**|Opérateur `|
|**Objet**|Instance de classe .NET avec propriétés (données) et méthodes (actions)|
|**Propriété**|Attribut d'objet accessible par `$objet.Propriete` (ex: $file.Length)|
|**Méthode**|Action sur objet appelée par `$objet.Methode()` (ex: $file.Delete())|
|**ScriptBlock**|Bloc de code entre accolades `{...}` exécutable|
|**Hashtable**|Tableau associatif clé/valeur : `@{cle="valeur"}`|
|**Job**|Tâche exécutée en arrière-plan de manière asynchrone|
|**$_**|Objet courant dans pipeline ou boucle ForEach-Object|
|**$args**|Tableau des arguments passés à fonction/script|
|**PSSession**|Session PowerShell distante persistante|
|**Wildcard**|Caractères joker : `*` (plusieurs) et `?` (un seul)|

---

## 🎯 Opérateurs de comparaison :

```powershell
# Comparaison
-eq          # Égal à (equal)
-ne          # Différent de (not equal)
-gt          # Supérieur à (greater than)
-lt          # Inférieur à (less than)
-ge          # Supérieur ou égal (greater or equal)
-le          # Inférieur ou égal (less or equal)

# Correspondance
-like        # Correspondance avec wildcards (* et ?)
-notlike     # Ne correspond pas (wildcards)
-match       # Correspondance regex
-notmatch    # Ne correspond pas (regex)

# Logique
-and         # ET logique
-or          # OU logique
-xor         # OU exclusif
-not / !     # NON logique (inverse)

# Exemples
$a -eq 5                           # True si $a vaut 5
"test" -like "t*"                  # True (t suivi de n'importe quoi)
"file1.txt" -match "file\d\.txt"   # True (regex)
$a -gt 10 -and $b -lt 20           # ET logique
```

---

## 🔄 Structures avancées :

```powershell
# Fonction avec validation
function Convert-Number {
    param(
        [Parameter(Mandatory=$True)]
        [ValidateRange(0, 255)]
        [int]$Number,
        
        [ValidateSet('Binaire', 'Octal')]
        [string]$Type
    )
    Switch ($Type) {
        'Binaire' {[convert]::ToString($Number, 2)}
        'Octal'   {[convert]::ToString($Number, 8)}
    }
}

# Job parallèle
$job = Start-Job -ScriptBlock {
    Start-Sleep -Seconds 10
    Get-Service
}
Wait-Job $job
$result = Receive-Job $job
Remove-Job $job

# Remote execution
Invoke-Command -ComputerName Server1, Server2 -ScriptBlock {
    Get-EventLog -LogName System -Newest 10
}
```

---

## 🎯 À retenir ABSOLUMENT (3 points max) :

1. 💡 **Théorique** : PowerShell manipule des **objets .NET** (pas du texte). Utiliser `Get-Member` pour découvrir propriétés et méthodes disponibles sur tout objet.
    
2. 💻 **Pratique** : Le **pipeline** `|` est la clé : `Get-Service | Where-Object {$_.Status -eq "Running"} | Select-Object Name`. Chaîner les cmdlets pour filtrer, trier et transformer.
    
3. ⚠️ **Piège** : **L'index commence à 0** dans les tableaux et **-eq pour comparer** (pas =). Variables toujours préfixées par `$` et les espaces comptent dans les comparaisons de chaînes.
    

---

## 🚀 Workflow typique d'un script :

```powershell
# 1. Définir paramètres
param([string]$ComputerName)

# 2. Définir fonctions
function Get-SystemInfo {
    param([string]$PC)
    Get-WmiObject Win32_OperatingSystem -ComputerName $PC
}

# 3. Logique principale
$servers = @("Server1", "Server2", "Server3")

# 4. Jobs parallèles
$jobs = foreach ($srv in $servers) {
    Start-Job -ScriptBlock {
        param($s)
        Get-SystemInfo -PC $s
    } -ArgumentList $srv
}

# 5. Récupération résultats
$results = $jobs | Wait-Job | Receive-Job
$jobs | Remove-Job

# 6. Traitement
$results | Where-Object {$_.FreePhysicalMemory -lt 1000000} |
           Select-Object CSName, FreePhysicalMemory
```

---

**💾 Variables spéciales critiques :**

- `$_` : Objet courant (pipeline/foreach)
- `$?` : Statut dernière commande (True/False)
- `$args` : Arguments de fonction/script
- `$null` : Valeur nulle
- `$true` / `$false` : Booléens
- `$env:VARIABLE` : Variable d'environnement

**🔐 Portée variables :**

- `$global:var` : Accessible partout
- `$script:var` : Dans le script uniquement
- `$local:var` : Dans le bloc courant
- `$private:var` : Non héritable

**📝 Conventions nommage :**

- Cmdlets : `Verbe-Nom` (PascalCase)
- Variables : `$PascalCase` ou `$camelCase`
- Fonctions : `Verbe-Nom` (comme cmdlets)