

> [!info] Vue d'ensemble Cette partie du cours couvre l'utilisation des codes ANSI pour ajouter des couleurs et des styles à vos scripts Bash. Vous apprendrez à rendre vos sorties terminal plus lisibles et professionnelles.

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

## 🔰 Introduction aux codes ANSI

Les codes ANSI (American National Standards Institute) sont des séquences d'échappement qui permettent de contrôler le formatage du texte dans un terminal. Ils fonctionnent sur la plupart des terminaux modernes (Linux, macOS, Windows 10+).

### Syntaxe de base

```bash
\033[<code>m
# ou
\e[<code>m
```

> [!info] Décomposition
> 
> - `\033` ou `\e` : caractère d'échappement ESC
> - `[` : début de la séquence de contrôle
> - `<code>` : le code de formatage (couleur, style)
> - `m` : fin de la séquence

### Pourquoi utiliser les couleurs ?

- **Lisibilité** : distinguer visuellement les erreurs, avertissements et succès
- **Hiérarchie visuelle** : mettre en évidence les informations importantes
- **Expérience utilisateur** : rendre les scripts plus professionnels et agréables
- **Débogage** : identifier rapidement les différents types de messages

---

## 🌈 Couleurs de texte

### Couleurs standard (30-37)

Les couleurs standard sont les 8 couleurs de base disponibles sur tous les terminaux.

```bash
# Définir une couleur de texte
echo -e "\033[31mTexte en rouge\033[0m"
echo -e "\e[32mTexte en vert\e[0m"
```

|Code|Couleur|Utilisation courante|
|---|---|---|
|30|Noir|Rarement utilisé (invisible sur fond noir)|
|31|Rouge|Erreurs, alertes critiques|
|32|Vert|Succès, validations|
|33|Jaune|Avertissements, informations importantes|
|34|Bleu|Informations générales|
|35|Magenta|Titres, sections spéciales|
|36|Cyan|Commandes, code, chemins|
|37|Blanc|Texte normal|

> [!example] Exemple pratique : Messages de statut
> 
> ```bash
> #!/bin/bash
> 
> # Définir les couleurs
> RED='\033[31m'
> GREEN='\033[32m'
> YELLOW='\033[33m'
> RESET='\033[0m'
> 
> # Utilisation
> echo -e "${RED}[ERREUR]${RESET} Le fichier n'existe pas"
> echo -e "${GREEN}[SUCCÈS]${RESET} Opération réussie"
> echo -e "${YELLOW}[ATTENTION]${RESET} Espace disque faible"
> ```

### Couleurs vives (90-97)

Les couleurs vives offrent des versions plus lumineuses et contrastées des couleurs standard.

```bash
# Couleur vive
echo -e "\033[91mRouge vif\033[0m"
echo -e "\033[92mVert vif\033[0m"
```

|Code|Couleur|Différence avec standard|
|---|---|---|
|90|Noir vif (gris)|Visible sur fond noir, utile pour le texte secondaire|
|91|Rouge vif|Plus visible, pour les erreurs critiques|
|92|Vert vif|Plus éclatant, pour les succès importants|
|93|Jaune vif|Plus contrasté, pour les avertissements urgents|
|94|Bleu vif|Plus lumineux, pour mettre en valeur|
|95|Magenta vif|Plus saturé, pour les titres principaux|
|96|Cyan vif|Plus clair, pour les liens ou commandes|
|97|Blanc vif|Texte très contrasté|

> [!tip] Quand utiliser les couleurs vives ?
> 
> - Pour les messages nécessitant une attention immédiate
> - Dans les interfaces utilisateur interactives
> - Pour améliorer la lisibilité sur des fonds sombres
> - Pour créer une hiérarchie visuelle claire

> [!example] Comparaison standard vs vif
> 
> ```bash
> #!/bin/bash
> 
> echo "Couleurs standard :"
> echo -e "\033[31m■ Rouge standard\033[0m"
> echo -e "\033[32m■ Vert standard\033[0m"
> echo -e "\033[33m■ Jaune standard\033[0m"
> 
> echo -e "\nCouleurs vives :"
> echo -e "\033[91m■ Rouge vif\033[0m"
> echo -e "\033[92m■ Vert vif\033[0m"
> echo -e "\033[93m■ Jaune vif\033[0m"
> ```

---

## 🎨 Couleurs de fond

### Fonds standard (40-47)

Les codes de fond fonctionnent exactement comme les codes de texte, mais commencent par 4 au lieu de 3.

```bash
# Fond coloré
echo -e "\033[41mTexte sur fond rouge\033[0m"
echo -e "\033[42mTexte sur fond vert\033[0m"
```

|Code|Couleur de fond|
|---|---|
|40|Fond noir|
|41|Fond rouge|
|42|Fond vert|
|43|Fond jaune|
|44|Fond bleu|
|45|Fond magenta|
|46|Fond cyan|
|47|Fond blanc|

> [!warning] Attention au contraste ! Assurez-vous toujours que le texte reste lisible sur le fond choisi. Évitez les combinaisons comme texte jaune sur fond blanc ou texte noir sur fond bleu foncé.

### Fonds vifs (100-107)

Les fonds vifs offrent des couleurs de fond plus lumineuses et contrastées.

```bash
# Fond vif
echo -e "\033[101mTexte sur fond rouge vif\033[0m"
echo -e "\033[102mTexte sur fond vert vif\033[0m"
```

|Code|Couleur de fond vif|
|---|---|
|100|Fond noir vif (gris)|
|101|Fond rouge vif|
|102|Fond vert vif|
|103|Fond jaune vif|
|104|Fond bleu vif|
|105|Fond magenta vif|
|106|Fond cyan vif|
|107|Fond blanc vif|

> [!example] Exemple : Bannières colorées
> 
> ```bash
> #!/bin/bash
> 
> # Bannières avec fonds colorés
> echo -e "\033[41m                                    \033[0m"
> echo -e "\033[41m  ERREUR : Action impossible      \033[0m"
> echo -e "\033[41m                                    \033[0m"
> 
> echo ""
> 
> echo -e "\033[42m                                    \033[0m"
> echo -e "\033[42m  SUCCÈS : Tout s'est bien passé  \033[0m"
> echo -e "\033[42m                                    \033[0m"
> ```

---

## 🔄 Combinaisons texte + fond

Vous pouvez combiner plusieurs codes en les séparant par des points-virgules (`;`).

### Syntaxe de combinaison

```bash
# Combiner texte et fond
echo -e "\033[31;47mTexte rouge sur fond blanc\033[0m"
echo -e "\033[97;41mTexte blanc sur fond rouge\033[0m"
```

### Ordre des codes

> [!info] L'ordre n'a généralement pas d'importance Les codes peuvent être dans n'importe quel ordre, mais par convention on place souvent :
> 
> 1. Les styles (gras, souligné, etc.)
> 2. La couleur de texte
> 3. La couleur de fond

```bash
# Ces trois commandes sont équivalentes
echo -e "\033[1;32;44mTexte\033[0m"
echo -e "\033[32;1;44mTexte\033[0m"
echo -e "\033[44;32;1mTexte\033[0m"
```

> [!example] Exemples de combinaisons utiles
> 
> ```bash
> #!/bin/bash
> 
> # Messages d'alerte avec fond
> echo -e "\033[97;41m [ERREUR] \033[0m \033[31mFichier non trouvé\033[0m"
> echo -e "\033[30;43m [ATTENTION] \033[0m \033[33mEspace disque < 10%\033[0m"
> echo -e "\033[97;42m [SUCCÈS] \033[0m \033[32mSauvegarde terminée\033[0m"
> echo -e "\033[30;46m [INFO] \033[0m \033[36mChargement en cours...\033[0m"
> 
> # Tableau avec alternance de couleurs
> echo -e "\033[97;44m Nom du fichier        | Taille  \033[0m"
> echo -e "\033[30;47m document.pdf          | 2.5 MB  \033[0m"
> echo -e "\033[37;40m image.png             | 854 KB  \033[0m"
> echo -e "\033[30;47m script.sh             | 12 KB   \033[0m"
> ```

> [!tip] Créer un système cohérent Définissez vos combinaisons au début du script pour maintenir la cohérence :
> 
> ```bash
> # Définitions de styles
> ERROR_BADGE="\033[97;41m"
> ERROR_TEXT="\033[31m"
> SUCCESS_BADGE="\033[97;42m"
> SUCCESS_TEXT="\033[32m"
> RESET="\033[0m"
> 
> # Utilisation
> echo -e "${ERROR_BADGE} ERREUR ${RESET} ${ERROR_TEXT}Message d'erreur${RESET}"
> ```

---

## ✨ Styles de texte

En plus des couleurs, les codes ANSI permettent d'appliquer différents styles au texte.

### Styles disponibles

|Code|Style|Support|Usage recommandé|
|---|---|---|---|
|0|Réinitialiser|✅ Universel|Toujours à la fin|
|1|Gras|✅ Universel|Titres, emphase forte|
|2|Faible intensité|⚠️ Variable|Texte secondaire|
|3|Italique|⚠️ Limité|Citations, notes|
|4|Souligné|✅ Bon|Liens, important|
|5|Clignotant lent|⚠️ Éviter|Rarement utilisé|
|6|Clignotant rapide|⚠️ Éviter|Rarement utilisé|
|7|Inverse (vidéo inversée)|✅ Bon|Sélection, focus|
|8|Masqué|⚠️ Variable|Mots de passe|
|9|Barré|⚠️ Variable|Texte obsolète|

### Exemples d'utilisation

```bash
#!/bin/bash

# Gras (1)
echo -e "\033[1mTexte en gras\033[0m"
echo -e "\033[1;32mTexte vert et gras\033[0m"

# Faible intensité (2)
echo -e "\033[2mTexte en faible intensité\033[0m"

# Italique (3)
echo -e "\033[3mTexte en italique\033[0m"

# Souligné (4)
echo -e "\033[4mTexte souligné\033[0m"

# Clignotant (5) - à éviter
echo -e "\033[5mTexte clignotant\033[0m"

# Inverse (7)
echo -e "\033[7mTexte en vidéo inversée\033[0m"

# Masqué (8)
echo -e "\033[8mTexte masqué (invisible)\033[0m"

# Barré (9)
echo -e "\033[9mTexte barré\033[0m"
```

> [!warning] Compatibilité des styles
> 
> - **Gras (1)** et **souligné (4)** : fonctionnent partout
> - **Italique (3)**, **barré (9)** : support variable selon les terminaux
> - **Clignotant (5, 6)** : souvent désactivé, peut être irritant
> - **Masqué (8)** : déconseillé pour la sécurité (peut être copié)

### Combinaison de styles

Vous pouvez combiner plusieurs styles entre eux et avec les couleurs :

```bash
#!/bin/bash

# Gras + souligné
echo -e "\033[1;4mTexte gras et souligné\033[0m"

# Gras + couleur + fond
echo -e "\033[1;97;41mTexte gras blanc sur rouge\033[0m"

# Inverse + gras + couleur
echo -e "\033[7;1;36mTexte cyan gras inversé\033[0m"

# Souligné + couleur
echo -e "\033[4;34mLien souligné bleu\033[0m"
```

> [!example] Application pratique : Menu interactif
> 
> ```bash
> #!/bin/bash
> 
> # Définir les styles
> BOLD="\033[1m"
> UNDERLINE="\033[4m"
> INVERSE="\033[7m"
> GREEN="\033[32m"
> CYAN="\033[36m"
> RESET="\033[0m"
> 
> # Afficher un menu
> echo -e "${BOLD}${UNDERLINE}Menu Principal${RESET}\n"
> echo -e "${GREEN}1.${RESET} Démarrer le service"
> echo -e "${GREEN}2.${RESET} Arrêter le service"
> echo -e "${GREEN}3.${RESET} ${INVERSE}Quitter${RESET}"
> echo ""
> echo -e "${CYAN}Votre choix :${RESET} "
> ```

### Désactiver les styles

Pour revenir au texte normal, utilisez toujours le code `0` :

```bash
# Méthode complète
echo -e "\033[1;31mRouge et gras\033[0m texte normal"

# Code 0 réinitialise TOUS les styles
echo -e "\033[1;4;33;44mMulti-styles\033[0m"
```

> [!tip] Bonnes pratiques pour les styles
> 
> - **Toujours réinitialiser** : utilisez `\033[0m` après chaque texte stylé
> - **Restez sobre** : trop de styles nuit à la lisibilité
> - **Testez la compatibilité** : vérifiez sur différents terminaux
> - **Privilégiez le gras et souligné** : ils fonctionnent partout
> - **Évitez le clignotant** : c'est généralement une mauvaise UX

---

## 📋 Bonnes pratiques

### 1. Toujours réinitialiser les styles

```bash
# ❌ Mauvais - le style persiste
echo -e "\033[31mErreur"
echo "Ce texte sera aussi rouge"

# ✅ Bon - réinitialisation explicite
echo -e "\033[31mErreur\033[0m"
echo "Ce texte est normal"
```

### 2. Utiliser des variables pour la maintenabilité

```bash
# ❌ Mauvais - codes en dur partout
echo -e "\033[31mErreur\033[0m"
echo -e "\033[31mAutre erreur\033[0m"

# ✅ Bon - définitions centralisées
RED='\033[31m'
RESET='\033[0m'
echo -e "${RED}Erreur${RESET}"
echo -e "${RED}Autre erreur${RESET}"
```

### 3. Créer des fonctions réutilisables

```bash
#!/bin/bash

# Fonctions d'affichage
print_error() {
    echo -e "\033[97;41m [ERREUR] \033[0m \033[31m$1\033[0m" >&2
}

print_success() {
    echo -e "\033[97;42m [SUCCÈS] \033[0m \033[32m$1\033[0m"
}

print_warning() {
    echo -e "\033[30;43m [ATTENTION] \033[0m \033[33m$1\033[0m"
}

# Utilisation
print_error "Fichier non trouvé"
print_success "Opération réussie"
print_warning "Espace disque faible"
```

### 4. Vérifier si le terminal supporte les couleurs

```bash
#!/bin/bash

# Fonction pour détecter le support des couleurs
supports_colors() {
    # Vérifie si stdout est un terminal
    [ -t 1 ] || return 1
    
    # Vérifie le nombre de couleurs supportées
    if [ -n "$TERM" ]; then
        case "$TERM" in
            *-256color|*-24bit) return 0 ;;
            xterm|xterm-color|screen|linux) return 0 ;;
        esac
    fi
    
    return 1
}

# Définir les couleurs conditionnellement
if supports_colors; then
    RED='\033[31m'
    GREEN='\033[32m'
    RESET='\033[0m'
else
    RED=''
    GREEN=''
    RESET=''
fi

echo -e "${RED}Texte rouge (ou normal)${RESET}"
```

### 5. Tenir compte de la redirection

```bash
#!/bin/bash

# Désactiver les couleurs lors de la redirection
if [ -t 1 ]; then
    # stdout est un terminal
    RED='\033[31m'
    RESET='\033[0m'
else
    # stdout est redirigé (fichier, pipe)
    RED=''
    RESET=''
fi

echo -e "${RED}Message${RESET}"
```

### 6. Maintenir un contraste suffisant

```bash
# ❌ Mauvais - faible contraste
echo -e "\033[33;43mTexte jaune sur fond jaune\033[0m"
echo -e "\033[34;40mTexte bleu sombre sur fond noir\033[0m"

# ✅ Bon - contraste élevé
echo -e "\033[30;43mTexte noir sur fond jaune\033[0m"
echo -e "\033[97;44mTexte blanc sur fond bleu\033[0m"
```

### 7. Créer une palette cohérente

```bash
#!/bin/bash

# Palette de couleurs du projet
readonly COLOR_PRIMARY='\033[36m'      # Cyan pour les infos
readonly COLOR_SUCCESS='\033[32m'     # Vert pour succès
readonly COLOR_WARNING='\033[33m'     # Jaune pour avertissements
readonly COLOR_ERROR='\033[31m'       # Rouge pour erreurs
readonly COLOR_ACCENT='\033[35m'      # Magenta pour les titres
readonly STYLE_BOLD='\033[1m'         # Gras
readonly STYLE_DIM='\033[2m'          # Faible intensité
readonly RESET='\033[0m'              # Réinitialisation

# Utilisation cohérente dans tout le script
echo -e "${STYLE_BOLD}${COLOR_ACCENT}=== Mon Application ===${RESET}"
echo -e "${COLOR_PRIMARY}Démarrage...${RESET}"
echo -e "${COLOR_SUCCESS}✓ Configuration chargée${RESET}"
echo -e "${STYLE_DIM}Version 1.0.0${RESET}"
```

### 8. Documentation et lisibilité

```bash
#!/bin/bash

#─────────────────────────────────────────────────────────────
# Configuration des couleurs et styles
#─────────────────────────────────────────────────────────────

# Couleurs de texte
readonly C_RED='\033[31m'
readonly C_GREEN='\033[32m'
readonly C_YELLOW='\033[33m'
readonly C_CYAN='\033[36m'

# Styles
readonly S_BOLD='\033[1m'
readonly S_UNDERLINE='\033[4m'

# Réinitialisation
readonly RESET='\033[0m'

# Combinaisons prédéfinies
readonly ERROR="${C_RED}${S_BOLD}"
readonly SUCCESS="${C_GREEN}${S_BOLD}"
readonly INFO="${C_CYAN}"

#─────────────────────────────────────────────────────────────
# Utilisation
#─────────────────────────────────────────────────────────────

echo -e "${ERROR}Erreur critique${RESET}"
echo -e "${SUCCESS}Opération réussie${RESET}"
echo -e "${INFO}Information utile${RESET}"
```

> [!warning] Pièges courants à éviter
> 
> - **Oublier le `\033[0m`** : les styles persistent dans le terminal
> - **Utiliser `echo` sans `-e`** : les codes ne seront pas interprétés
> - **Mélanger simple et double quotes** : `echo "\033[31m"` fonctionne, `echo '\033[31m'` ne fonctionne pas
> - **Tester uniquement dans un terminal** : pensez aux redirections et aux logs
> - **Abuser des couleurs** : trop de couleurs = perte de lisibilité

> [!tip] Astuces avancées
> 
> - **Variables readonly** : empêche la modification accidentelle des couleurs
> - **Préfixe systématique** : utilisez `C_` pour couleurs, `S_` pour styles, `BG_` pour fonds
> - **Fichier de configuration** : externalisez vos définitions dans un fichier source séparé
> - **Mode debug** : ajoutez une variable `DEBUG_COLORS=true` pour afficher les codes bruts
> - **Fallback gracieux** : assurez-vous que le script reste utilisable sans couleurs

---

## 🎯 Récapitulatif

|Élément|Codes|Notes|
|---|---|---|
|**Texte standard**|30-37|8 couleurs de base|
|**Texte vif**|90-97|Versions lumineuses|
|**Fond standard**|40-47|8 couleurs de fond|
|**Fond vif**|100-107|Fonds lumineux|
|**Gras**|1|Support universel|
|**Souligné**|4|Support universel|
|**Italique**|3|Support variable|
|**Inverse**|7|Bon support|
|**Réinitialiser**|0|Toujours à la fin|

> [!success] Vous maîtrisez maintenant
> 
> - ✅ Les codes ANSI pour les couleurs de texte (standard et vives)
> - ✅ Les codes ANSI pour les couleurs de fond (standard et vives)
> - ✅ La combinaison de couleurs de texte et de fond
> - ✅ Les styles de texte (gras, souligné, italique, inverse, etc.)
> - ✅ Les bonnes pratiques pour un code maintenable et compatible

---

_Cours rédigé pour une utilisation avec Obsidian - Embellissement des scripts Bash_