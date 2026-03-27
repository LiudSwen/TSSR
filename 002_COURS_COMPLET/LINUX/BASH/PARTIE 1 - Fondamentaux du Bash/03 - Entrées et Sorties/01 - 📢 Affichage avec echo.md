

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

## 🎯 Introduction

La commande `echo` est l'un des outils les plus fondamentaux en Bash. Elle permet d'afficher du texte dans le terminal ou de rediriger du contenu vers des fichiers. Bien qu'elle semble simple, `echo` possède des options puissantes pour formater et contrôler l'affichage.

> [!info] Pourquoi maîtriser echo ?
> 
> - **Débogage** : Afficher des valeurs de variables pendant l'exécution
> - **Interface utilisateur** : Créer des messages clairs pour l'utilisateur
> - **Génération de contenu** : Créer ou modifier des fichiers via redirection
> - **Formatage** : Contrôler précisément l'apparence du texte

---

## 📝 Syntaxe de base

### Structure fondamentale

```bash
echo "texte à afficher"
```

> [!example] Exemples de base
> 
> ```bash
> # Affichage simple
> echo "Bonjour le monde"
> 
> # Avec des variables
> nom="Alice"
> echo "Bonjour $nom"
> 
> # Sans guillemets (attention aux espaces multiples)
> echo Ceci est un texte
> 
> # Avec guillemets simples (pas d'interprétation)
> echo 'Le prix est $10'
> ```

### Types de guillemets

|Type|Syntaxe|Interprétation variables|Interprétation échappements|
|---|---|---|---|
|**Doubles**|`"texte"`|✅ Oui|✅ Oui (avec -e)|
|**Simples**|`'texte'`|❌ Non|❌ Non|
|**Aucun**|`texte`|✅ Oui|⚠️ Problèmes possibles|

> [!warning] Attention aux guillemets Sans guillemets, Bash interprète certains caractères spéciaux (`*`, `?`, `[]`, etc.) et peut diviser le texte sur les espaces multiples.

---

## 🚫 Option -n : Suppression du retour à la ligne

### Comportement par défaut

Par défaut, `echo` ajoute automatiquement un retour à la ligne (`\n`) à la fin de chaque affichage.

```bash
echo "Première ligne"
echo "Deuxième ligne"
# Résultat :
# Première ligne
# Deuxième ligne
```

### Utilisation de -n

L'option `-n` supprime ce retour à la ligne automatique, permettant de continuer sur la même ligne.

```bash
echo -n "Texte sans retour à la ligne"
```

> [!example] Cas d'usage pratiques
> 
> ```bash
> # Afficher une progression sur la même ligne
> echo -n "Chargement en cours"
> sleep 1
> echo -n "."
> sleep 1
> echo -n "."
> sleep 1
> echo " Terminé !"
> 
> # Demander une saisie utilisateur sur la même ligne
> echo -n "Entrez votre nom : "
> read nom
> 
> # Construire une ligne progressivement
> echo -n "Début "
> echo -n "milieu "
> echo "fin"
> # Résultat : Début milieu fin
> ```

> [!tip] Astuce pour les indicateurs de progression Combinez `-n` avec `\r` (retour chariot) pour écraser la ligne courante :
> 
> ```bash
> for i in {1..100}; do
>     echo -ne "Progression : $i%\r"
>     sleep 0.1
> done
> echo -e "\nTerminé !"
> ```

---

## 🎨 Option -e : Interprétation des échappements

### Activation de l'interprétation

Par défaut, `echo` affiche les séquences d'échappement littéralement. L'option `-e` active leur interprétation.

```bash
# Sans -e (affichage littéral)
echo "Ligne 1\nLigne 2"
# Résultat : Ligne 1\nLigne 2

# Avec -e (interprétation)
echo -e "Ligne 1\nLigne 2"
# Résultat :
# Ligne 1
# Ligne 2
```

> [!info] Quand utiliser -e ?
> 
> - Formatage avancé du texte
> - Création de menus interactifs
> - Affichage de tableaux ou de structures complexes
> - Ajout de couleurs (avec codes ANSI)

---

## 🔤 Séquences d'échappement courantes

### \n - Nouvelle ligne (newline)

Crée un saut de ligne, équivalent à appuyer sur Entrée.

```bash
echo -e "Première ligne\nDeuxième ligne\nTroisième ligne"
# Résultat :
# Première ligne
# Deuxième ligne
# Troisième ligne
```

> [!example] Usage dans la création de fichiers
> 
> ```bash
> # Créer un fichier avec plusieurs lignes
> echo -e "#!/bin/bash\n\necho 'Script généré'" > script.sh
> ```

### \t - Tabulation

Insère un caractère de tabulation (équivalent à Tab).

```bash
echo -e "Nom\tPrénom\tÂge"
echo -e "Dupont\tJean\t30"
echo -e "Martin\tMarie\t25"
# Résultat :
# Nom     Prénom  Âge
# Dupont  Jean    30
# Martin  Marie   25
```

> [!example] Création de tableaux alignés
> 
> ```bash
> echo -e "Col1\t\tCol2\t\tCol3"
> echo -e "----\t\t----\t\t----"
> echo -e "A\t\tB\t\tC"
> echo -e "123\t\t456\t\t789"
> ```

### \a - Alerte sonore (bell)

Émet un bip sonore (si le terminal le supporte).

```bash
echo -e "Opération terminée\a"
```

> [!example] Cas d'usage pratiques
> 
> ```bash
> # Alerter l'utilisateur après une longue opération
> ./long_script.sh
> echo -e "\a\a\aScript terminé !"
> 
> # Dans une boucle d'attente
> while ! ping -c 1 google.com &> /dev/null; do
>     echo -n "."
>     sleep 1
> done
> echo -e "\a\nConnexion rétablie !"
> ```

---

## 🔍 Séquences d'échappement supplémentaires

### Tableau récapitulatif

|Séquence|Nom|Description|Exemple|
|---|---|---|---|
|`\n`|Newline|Nouvelle ligne|`echo -e "A\nB"`|
|`\t`|Tab|Tabulation|`echo -e "A\tB"`|
|`\a`|Alert|Bip sonore|`echo -e "Done\a"`|
|`\b`|Backspace|Retour arrière|`echo -e "ABC\bD"` → ABD|
|`\r`|Carriage Return|Retour chariot|`echo -e "ABC\rD"` → DBC|
|`\v`|Vertical Tab|Tab vertical|`echo -e "A\vB"`|
|`\\`|Backslash|Barre oblique inverse|`echo -e "C:\\Users"`|
|`\"`|Quote|Guillemet double|`echo -e "Il dit \"Bonjour\""`|

> [!example] Exemples combinés
> 
> ```bash
> # Retour arrière pour corriger
> echo -e "Chargement : [###\b\b\b===]"
> 
> # Retour chariot pour écraser
> echo -e "Étape 1\rÉtape 2"  # Affiche : Étape 2
> 
> # Échapper un backslash
> echo -e "Chemin Windows : C:\\Program Files\\App"
> ```

---

## ⚠️ Pièges courants

### 1. Oublier l'option -e

> [!warning] Erreur fréquente
> 
> ```bash
> # ❌ Mauvais : affiche littéralement \n
> echo "Ligne 1\nLigne 2"
> 
> # ✅ Correct : interprète \n
> echo -e "Ligne 1\nLigne 2"
> ```

### 2. Mélanger -n et -e sans ordre

```bash
# ❌ Peut ne pas fonctionner sur tous les systèmes
echo -n -e "Texte\n"

# ✅ Ordre recommandé
echo -ne "Texte\n"
```

### 3. Guillemets simples avec variables

> [!warning] Les guillemets simples ne développent pas les variables
> 
> ```bash
> nom="Alice"
> 
> # ❌ Affiche littéralement : Bonjour $nom
> echo 'Bonjour $nom'
> 
> # ✅ Utiliser des guillemets doubles
> echo "Bonjour $nom"
> ```

### 4. Caractères spéciaux non échappés

```bash
# ❌ Le * est interprété comme un glob
echo Les fichiers sont : *.txt

# ✅ Utiliser des guillemets
echo "Les fichiers sont : *.txt"
```

### 5. Échappements dans les guillemets simples

> [!warning] Les guillemets simples ignorent TOUT
> 
> ```bash
> # ❌ Affiche littéralement : Ligne 1\nLigne 2
> echo -e 'Ligne 1\nLigne 2'
> 
> # ✅ Utiliser des guillemets doubles
> echo -e "Ligne 1\nLigne 2"
> ```

---

## ✅ Bonnes pratiques

### 1. Toujours utiliser des guillemets doubles

```bash
# ✅ Recommandé
echo "Texte avec $variable"

# ⚠️ À éviter (sauf cas spécifiques)
echo Texte avec $variable
```

### 2. Être explicite avec -e quand nécessaire

```bash
# ✅ Clair et lisible
if [ $error -eq 1 ]; then
    echo -e "\nErreur détectée\a"
fi
```

### 3. Préférer printf pour un formatage complexe

> [!tip] Alternative : printf Pour un contrôle précis du formatage, `printf` est souvent préférable :
> 
> ```bash
> # Alignement précis
> printf "%-10s %-10s %5s\n" "Nom" "Prénom" "Âge"
> printf "%-10s %-10s %5d\n" "Dupont" "Jean" 30
> ```

### 4. Documenter les échappements complexes

```bash
# ✅ Bon : commentaire explicatif
# Affiche une barre de progression avec retour chariot
echo -ne "Progression : [########\r"
```

---

## 💡 Astuces avancées

### 1. Couleurs dans le terminal

```bash
# Codes ANSI pour les couleurs
echo -e "\e[31mTexte en rouge\e[0m"
echo -e "\e[32mTexte en vert\e[0m"
echo -e "\e[33mTexte en jaune\e[0m"
echo -e "\e[1;34mTexte en bleu gras\e[0m"

# Créer des fonctions pour faciliter l'usage
red() { echo -e "\e[31m$1\e[0m"; }
green() { echo -e "\e[32m$1\e[0m"; }

red "Message d'erreur"
green "Opération réussie"
```

### 2. Création de menus interactifs

```bash
echo -e "\n╔════════════════════════╗"
echo -e "║    MENU PRINCIPAL      ║"
echo -e "╠════════════════════════╣"
echo -e "║ 1. Option 1            ║"
echo -e "║ 2. Option 2            ║"
echo -e "║ 3. Quitter             ║"
echo -e "╚════════════════════════╝\n"
echo -n "Votre choix : "
```

### 3. Barre de progression dynamique

```bash
progress_bar() {
    local duration=$1
    local steps=50
    local step_time=$(echo "$duration / $steps" | bc -l)
    
    for ((i=0; i<=steps; i++)); do
        local percent=$((i * 100 / steps))
        local filled=$((i * 40 / steps))
        local empty=$((40 - filled))
        
        printf -v bar "%${filled}s" ""
        printf -v spaces "%${empty}s" ""
        
        echo -ne "\rProgression : [${bar// /#}${spaces}] $percent%%"
        sleep "$step_time"
    done
    echo -e "\n"
}

progress_bar 3
```

### 4. Effacer la ligne courante

```bash
# Efface la ligne et repositionne le curseur
echo -ne "Message temporaire..."
sleep 2
echo -ne "\r\033[K"  # \033[K efface jusqu'à la fin de la ligne
echo "Message définitif"
```

### 5. Redirection intelligente

```bash
# Créer un fichier de log avec horodatage
log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a script.log
}

log "Début du script"
log "Opération en cours..."
log "Script terminé"
```

---

## 📊 Comparaison echo vs printf

|Caractéristique|echo|printf|
|---|---|---|
|**Simplicité**|✅ Plus simple|⚠️ Plus verbeux|
|**Formatage précis**|⚠️ Limité|✅ Très précis|
|**Portabilité**|⚠️ Varie selon shells|✅ Plus portable|
|**Retour ligne auto**|✅ Oui (sauf -n)|❌ Non|
|**Couleurs**|✅ Avec -e|✅ Supporte aussi|
|**Performance**|✅ Plus rapide|⚠️ Légèrement plus lent|

> [!tip] Règle générale
> 
> - Utilisez `echo` pour l'affichage simple et rapide
> - Utilisez `printf` pour le formatage précis et les tableaux

---

## 🎯 Récapitulatif

### Syntaxes essentielles

```bash
# Affichage simple
echo "texte"

# Sans retour à la ligne
echo -n "texte"

# Avec interprétation des échappements
echo -e "texte\navec\téchappements"

# Combinaison
echo -ne "texte sans retour\n"
```

### Séquences à retenir

- `\n` : Nouvelle ligne
- `\t` : Tabulation
- `\a` : Bip sonore
- `\r` : Retour chariot
- `\\` : Backslash littéral

> [!info] Point clé La commande `echo` est simple mais puissante. Maîtriser ses options `-n` et `-e` ainsi que les séquences d'échappement vous permet de créer des scripts avec une interface utilisateur professionnelle et des messages de débogage efficaces.