

## Table des matières

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

## Introduction au formatage

Le formatage de texte dans la console permet de créer des scripts PowerShell professionnels et lisibles. Un bon alignement et espacement améliore considérablement l'expérience utilisateur, notamment pour :

- **Menus et interfaces textuelles** : présentation claire des options
- **Rapports et logs** : données organisées en colonnes
- **Messages de statut** : affichage cohérent des informations
- **Bannières et séparateurs** : délimitation visuelle des sections

> [!info] Pourquoi le formatage est important Dans un environnement professionnel, un script bien formaté :
> 
> - Facilite la lecture et la compréhension
> - Donne une impression de qualité et de fiabilité
> - Améliore l'expérience utilisateur
> - Réduit les erreurs de lecture

---

## Alignement du texte

L'alignement consiste à positionner le texte à un emplacement spécifique dans une largeur donnée. PowerShell propose deux méthodes principales via les chaînes de caractères.

### Alignement à gauche

L'alignement à gauche est le comportement par défaut. Le texte commence au début de l'espace disponible.

```powershell
# Méthode 1 : PadRight pour forcer une largeur
$texte = "Bonjour"
$texte.PadRight(20)  # "Bonjour             " (13 espaces à droite)

# Utilisation pratique
$largeur = 30
$message = "Statut"
$valeur = "OK"
Write-Host ($message.PadRight($largeur) + $valeur)
# Affiche : "Statut                        OK"
```

> [!example] Exemple : Menu aligné à gauche
> 
> ```powershell
> $largeur = 40
> Write-Host ("1. Démarrer le service".PadRight($largeur) + "[Option]")
> Write-Host ("2. Arrêter le service".PadRight($largeur) + "[Option]")
> Write-Host ("3. Redémarrer".PadRight($largeur) + "[Option]")
> ```
> 
> Résultat :
> 
> ```
> 1. Démarrer le service              [Option]
> 2. Arrêter le service               [Option]
> 3. Redémarrer                       [Option]
> ```

### Alignement à droite

L'alignement à droite positionne le texte en fin d'espace, en ajoutant des espaces à gauche.

```powershell
# Méthode : PadLeft ajoute des espaces à gauche
$texte = "Bonjour"
$texte.PadLeft(20)  # "             Bonjour" (13 espaces à gauche)

# Utilisation pour des valeurs numériques
$prix = "29.99€"
Write-Host $prix.PadLeft(30)
# Affiche : "                        29.99€"
```

> [!tip] Astuce : Alignement de colonnes numériques L'alignement à droite est idéal pour les nombres car il facilite la comparaison visuelle :
> 
> ```powershell
> Write-Host "Ventes janvier : " -NoNewline
> Write-Host "1234.50€".PadLeft(15)
> Write-Host "Ventes février : " -NoNewline
> Write-Host "987.30€".PadLeft(15)
> Write-Host "Ventes mars    : " -NoNewline
> Write-Host "12045.75€".PadLeft(15)
> ```
> 
> Résultat :
> 
> ```
> Ventes janvier :        1234.50€
> Ventes février :         987.30€
> Ventes mars    :       12045.75€
> ```

### Alignement centré

L'alignement centré place le texte au milieu de l'espace disponible. PowerShell n'a pas de méthode native, il faut calculer manuellement.

```powershell
# Fonction pour centrer du texte
function Center-Text {
    param(
        [string]$Text,
        [int]$Width
    )
    
    # Calculer l'espace total pour le padding
    $totalPadding = $Width - $Text.Length
    
    # Diviser le padding en deux (gauche et droite)
    $leftPadding = [Math]::Floor($totalPadding / 2)
    
    # Créer le texte centré
    return (' ' * $leftPadding) + $Text
}

# Utilisation
$largeur = 50
$titre = "MENU PRINCIPAL"
Write-Host (Center-Text -Text $titre -Width $largeur)
# Affiche : "                  MENU PRINCIPAL"
```

> [!example] Exemple : Bannière centrée
> 
> ```powershell
> function Show-Banner {
>     param([string]$Title)
>     
>     $width = 60
>     $line = '=' * $width
>     
>     Write-Host $line
>     Write-Host (Center-Text -Text $Title -Width $width)
>     Write-Host $line
> }
> 
> Show-Banner -Title "RAPPORT MENSUEL"
> ```
> 
> Résultat :
> 
> ```
> ============================================================
>                      RAPPORT MENSUEL
> ============================================================
> ```

---

## Padding et espacement

Le padding ajoute des caractères (généralement des espaces) pour atteindre une largeur spécifique. C'est la base du formatage et de l'alignement.

### PadLeft()

Ajoute des caractères à **gauche** de la chaîne jusqu'à atteindre la largeur souhaitée.

```powershell
# Syntaxe de base
$chaine.PadLeft([int]$totalWidth)
$chaine.PadLeft([int]$totalWidth, [char]$paddingChar)

# Exemples
"42".PadLeft(5)           # "   42" (3 espaces + "42")
"42".PadLeft(5, '0')      # "00042" (3 zéros + "42")
"Test".PadLeft(10, '-')   # "------Test"

# Application pratique : numéros formatés
$numero = 7
$numeroFormate = $numero.ToString().PadLeft(4, '0')
Write-Host "Commande #$numeroFormate"  # "Commande #0007"
```

> [!info] Paramètres de PadLeft()
> 
> - **$totalWidth** : Largeur totale finale de la chaîne
> - **$paddingChar** : Caractère de remplissage (par défaut : espace)
> 
> Si la chaîne est déjà plus longue que $totalWidth, elle reste inchangée.

### PadRight()

Ajoute des caractères à **droite** de la chaîne jusqu'à atteindre la largeur souhaitée.

```powershell
# Syntaxe de base
$chaine.PadRight([int]$totalWidth)
$chaine.PadRight([int]$totalWidth, [char]$paddingChar)

# Exemples
"42".PadRight(5)          # "42   " ("42" + 3 espaces)
"Test".PadRight(10, '.')  # "Test......"
"OK".PadRight(8, '-')     # "OK------"

# Application pratique : tableaux simples
$colonne1 = "Nom".PadRight(20)
$colonne2 = "Statut".PadRight(15)
$colonne3 = "Code"
Write-Host ($colonne1 + $colonne2 + $colonne3)
Write-Host ("-" * 40)
```

> [!tip] Astuce : Créer des lignes de séparation
> 
> ```powershell
> # Ligne simple
> Write-Host "".PadRight(50, '-')
> 
> # Ligne double
> Write-Host "".PadRight(50, '=')
> 
> # Ligne en pointillés
> Write-Host "".PadRight(50, '.')
> ```

### Combinaison de padding

Combiner PadLeft et PadRight permet de créer des mises en page complexes.

```powershell
# Tableau à deux colonnes
function Format-TableRow {
    param(
        [string]$Label,
        [string]$Value,
        [int]$Width = 50
    )
    
    # Calculer l'espace pour chaque colonne
    $colonneGauche = $Label.PadRight($Width - $Value.Length)
    
    return $colonneGauche + $Value
}

# Utilisation
Write-Host (Format-TableRow -Label "Nom d'utilisateur" -Value "jdupont")
Write-Host (Format-TableRow -Label "Rôle" -Value "Administrateur")
Write-Host (Format-TableRow -Label "Dernière connexion" -Value "31/12/2025")

# Résultat :
# Nom d'utilisateur                               jdupont
# Rôle                                    Administrateur
# Dernière connexion                          31/12/2025
```

> [!example] Exemple : Création d'un tableau complexe
> 
> ```powershell
> function Show-FormattedTable {
>     $data = @(
>         @{Nom="Alice"; Age=28; Ville="Paris"},
>         @{Nom="Bob"; Age=35; Ville="Lyon"},
>         @{Nom="Charlie"; Age=42; Ville="Marseille"}
>     )
>     
>     # Définir les largeurs de colonnes
>     $w1 = 15
>     $w2 = 8
>     $w3 = 15
>     
>     # En-tête
>     Write-Host ("Nom".PadRight($w1) + "Age".PadLeft($w2) + "Ville".PadRight($w3))
>     Write-Host ("".PadRight($w1 + $w2 + $w3, '-'))
>     
>     # Données
>     foreach ($item in $data) {
>         Write-Host ($item.Nom.PadRight($w1) + $item.Age.ToString().PadLeft($w2) + $item.Ville.PadRight($w3))
>     }
> }
> 
> Show-FormattedTable
> ```
> 
> Résultat :
> 
> ```
> Nom                 AgeVille          
> ---------------------------------------
> Alice                 28Paris          
> Bob                   35Lyon           
> Charlie               42Marseille
> ```

---

## Travailler avec la largeur de la console

La console PowerShell a une largeur variable selon la fenêtre. Pour un formatage adaptatif, il faut récupérer cette largeur dynamiquement.

```powershell
# Obtenir la largeur actuelle de la console
$largeurConsole = $Host.UI.RawUI.WindowSize.Width

# Afficher une ligne sur toute la largeur
Write-Host ("".PadRight($largeurConsole, '='))

# Créer un titre centré dynamiquement
$titre = "RAPPORT SYSTEME"
$espacesGauche = [Math]::Floor(($largeurConsole - $titre.Length) / 2)
Write-Host ((' ' * $espacesGauche) + $titre)
```

> [!info] Propriétés utiles de la console
> 
> ```powershell
> # Largeur de la console
> $Host.UI.RawUI.WindowSize.Width
> 
> # Hauteur de la console
> $Host.UI.RawUI.WindowSize.Height
> 
> # Taille complète
> $taille = $Host.UI.RawUI.WindowSize
> Write-Host "Console : $($taille.Width)x$($taille.Height)"
> ```

> [!warning] Attention aux environnements sans interface Dans certains environnements (scripts automatisés, tâches planifiées), `$Host.UI.RawUI` peut ne pas être disponible. Prévoyez toujours une valeur par défaut :
> 
> ```powershell
> $largeurConsole = try {
>     $Host.UI.RawUI.WindowSize.Width
> } catch {
>     80  # Valeur par défaut
> }
> ```

### Applications pratiques avec largeur dynamique

```powershell
# Fonction pour créer un cadre adaptatif
function Show-BoxedMessage {
    param([string]$Message)
    
    $largeur = $Host.UI.RawUI.WindowSize.Width - 4  # Marge de 2 de chaque côté
    $ligne = "".PadRight($largeur, '─')
    
    Write-Host "┌$ligne┐"
    
    # Centrer le message
    $padding = [Math]::Floor(($largeur - $Message.Length) / 2)
    $texteFormate = (' ' * $padding) + $Message
    Write-Host "│$($texteFormate.PadRight($largeur))│"
    
    Write-Host "└$ligne┘"
}

Show-BoxedMessage -Message "Installation terminée avec succès"

# Barre de progression adaptative
function Show-ProgressBar {
    param(
        [int]$Percent,
        [string]$Label = "Progression"
    )
    
    $largeurBarre = $Host.UI.RawUI.WindowSize.Width - $Label.Length - 10
    $rempli = [Math]::Floor($largeurBarre * $Percent / 100)
    $vide = $largeurBarre - $rempli
    
    $barre = ('█' * $rempli) + ('░' * $vide)
    Write-Host "$Label [$barre] $Percent%"
}

Show-ProgressBar -Percent 65 -Label "Installation"
```

---

## Cas pratiques et patterns

### Pattern 1 : Tableau de données

```powershell
function Show-DataTable {
    param([array]$Data)
    
    # Définir les largeurs
    $colWidths = @{
        ID = 8
        Name = 25
        Status = 15
        Value = 12
    }
    
    # En-tête
    $header = "ID".PadRight($colWidths.ID) +
              "Name".PadRight($colWidths.Name) +
              "Status".PadRight($colWidths.Status) +
              "Value".PadLeft($colWidths.Value)
    
    Write-Host $header
    Write-Host ("".PadRight($header.Length, '─'))
    
    # Lignes de données
    foreach ($item in $Data) {
        $ligne = $item.ID.ToString().PadRight($colWidths.ID) +
                 $item.Name.PadRight($colWidths.Name) +
                 $item.Status.PadRight($colWidths.Status) +
                 $item.Value.PadLeft($colWidths.Value)
        Write-Host $ligne
    }
}

# Exemple d'utilisation
$donnees = @(
    @{ID=1; Name="Service Web"; Status="Running"; Value="100%"},
    @{ID=2; Name="Database"; Status="Stopped"; Value="0%"},
    @{ID=3; Name="API Gateway"; Status="Running"; Value="87%"}
)

Show-DataTable -Data $donnees
```

### Pattern 2 : Menu formaté

```powershell
function Show-Menu {
    param([string]$Title, [array]$Options)
    
    $largeur = 60
    
    # Bordure supérieure
    Write-Host ("╔" + ("═" * ($largeur - 2)) + "╗")
    
    # Titre centré
    $espaceTitre = [Math]::Floor(($largeur - 2 - $Title.Length) / 2)
    $titreLigne = "║" + (' ' * $espaceTitre) + $Title
    Write-Host ($titreLigne.PadRight($largeur - 1) + "║")
    
    # Séparateur
    Write-Host ("╠" + ("═" * ($largeur - 2)) + "╣")
    
    # Options
    for ($i = 0; $i -lt $Options.Count; $i++) {
        $optionTexte = "  $($i + 1). $($Options[$i])"
        Write-Host ("║" + $optionTexte.PadRight($largeur - 2) + "║")
    }
    
    # Bordure inférieure
    Write-Host ("╚" + ("═" * ($largeur - 2)) + "╝")
}

Show-Menu -Title "MENU PRINCIPAL" -Options @(
    "Afficher les services",
    "Gérer les utilisateurs",
    "Configuration système",
    "Quitter"
)
```

### Pattern 3 : Affichage clé-valeur

```powershell
function Show-KeyValuePair {
    param(
        [string]$Key,
        [string]$Value,
        [int]$Width = 50,
        [string]$Separator = ":"
    )
    
    # Calculer l'espace nécessaire
    $keyPart = "$Key $Separator"
    $spacing = $Width - $keyPart.Length - $Value.Length
    
    if ($spacing -lt 1) { $spacing = 1 }
    
    Write-Host ($keyPart + (' ' * $spacing) + $Value)
}

# Utilisation pour afficher des informations système
Write-Host "`nInformations Système" -ForegroundColor Cyan
Write-Host ("=" * 50)
Show-KeyValuePair -Key "Système d'exploitation" -Value "Windows 11"
Show-KeyValuePair -Key "Version PowerShell" -Value "7.4.1"
Show-KeyValuePair -Key "Utilisateur" -Value $env:USERNAME
Show-KeyValuePair -Key "Ordinateur" -Value $env:COMPUTERNAME
```

---

## Pièges courants

### Piège 1 : Oublier que PadLeft/PadRight retournent une nouvelle chaîne

```powershell
# ❌ INCORRECT - Pas d'effet car le résultat n'est pas utilisé
$texte = "Test"
$texte.PadLeft(10)
Write-Host $texte  # Affiche toujours "Test"

# ✅ CORRECT - Stocker ou utiliser directement le résultat
$texte = "Test"
$texteFormate = $texte.PadLeft(10)
Write-Host $texteFormate  # Affiche "      Test"

# Ou directement
Write-Host ($texte.PadLeft(10))
```

### Piège 2 : Chaînes plus longues que la largeur spécifiée

```powershell
# Le padding ne tronque PAS les chaînes trop longues
$texte = "Texte très long"
$resultat = $texte.PadRight(5)
Write-Host $resultat  # Affiche "Texte très long" (inchangé)

# Solution : tronquer manuellement si nécessaire
function Format-FixedWidth {
    param([string]$Text, [int]$Width)
    
    if ($Text.Length -gt $Width) {
        return $Text.Substring(0, $Width - 3) + "..."
    }
    return $Text.PadRight($Width)
}

$texte = "Texte très long"
Write-Host (Format-FixedWidth -Text $texte -Width 12)  # "Texte tr..."
```

### Piège 3 : Caractères Unicode et largeur d'affichage

```powershell
# Certains caractères Unicode peuvent occuper plus d'espace visuel
$texte = "Test 🚀"
$resultat = $texte.PadRight(20)
# Le résultat peut ne pas être visuellement aligné à cause de l'emoji

# Pour un alignement précis, utilisez des caractères ASCII standard
# ou testez le rendu final dans votre console
```

> [!warning] Attention aux caractères spéciaux Les émojis, caractères accentués et symboles Unicode peuvent avoir des largeurs d'affichage variables selon la console et la police utilisée. Pour un formatage précis, privilégiez les caractères ASCII.

### Piège 4 : Ne pas gérer les valeurs null

```powershell
# ❌ INCORRECT - Erreur si la valeur est null
$valeur = $null
$resultat = $valeur.PadLeft(10)  # Erreur !

# ✅ CORRECT - Vérifier ou fournir une valeur par défaut
$valeur = $null
$resultat = ($valeur ?? "N/A").PadLeft(10)

# Ou avec une fonction sécurisée
function Safe-PadLeft {
    param(
        [AllowNull()][string]$Text,
        [int]$Width,
        [char]$Char = ' '
    )
    
    if ([string]::IsNullOrEmpty($Text)) {
        $Text = ""
    }
    
    return $Text.PadLeft($Width, $Char)
}
```

### Piège 5 : Oublier le paramètre -NoNewline

```powershell
# ❌ INCORRECT - Le formatage est cassé par les retours à la ligne
$label = "Nom".PadRight(20)
$value = "Jean Dupont"
Write-Host $label
Write-Host $value
# Résultat :
# Nom                 
# Jean Dupont

# ✅ CORRECT - Utiliser -NoNewline pour garder sur la même ligne
Write-Host $label -NoNewline
Write-Host $value
# Résultat : Nom                 Jean Dupont

# Ou combiner les chaînes avant
Write-Host ($label + $value)
```

---

> [!tip] Bonnes pratiques générales
> 
> - **Définir des constantes** pour les largeurs de colonnes
> - **Créer des fonctions réutilisables** pour les patterns courants
> - **Tester le rendu** dans différentes tailles de console
> - **Prévoir des valeurs par défaut** pour la largeur de console
> - **Documenter les largeurs** utilisées dans vos scripts
> - **Utiliser des variables** pour faciliter les ajustements

---

_Ce cours fait partie de la série "Embellissement et présentation des scripts PowerShell"_