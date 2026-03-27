

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

## Introduction

L'embellissement des scripts Bash commence par la maîtrise des couleurs. Les codes ANSI permettent de transformer vos sorties en terminal en interfaces claires et professionnelles. Cette partie couvre les fondamentaux essentiels pour comprendre et utiliser les couleurs dans vos scripts.

> [!info] Compatibilité Les codes ANSI fonctionnent sur la quasi-totalité des terminaux modernes (Linux, macOS, WSL). Seuls les très anciens terminaux Windows (cmd.exe sans support ANSI) peuvent poser problème.

---

## Les codes ANSI et séquences d'échappement

### Qu'est-ce qu'une séquence d'échappement ?

Une séquence d'échappement est une suite de caractères qui commence par un caractère spécial (ESC, code ASCII 27) suivi d'instructions pour le terminal. Au lieu d'afficher du texte, ces séquences modifient le comportement du terminal : couleurs, positionnement du curseur, effacement d'écran, etc.

> [!tip] Analogie Pensez aux séquences d'échappement comme des "commandes secrètes" que vous glissez dans votre texte. Le terminal les intercepte et les exécute au lieu de les afficher.

### Les trois notations possibles

En Bash, vous pouvez écrire le caractère d'échappement de trois manières différentes :

|Notation|Description|Contexte d'utilisation|
|---|---|---|
|`\e[`|Forme la plus courte et lisible|**Recommandée** pour `echo -e` et scripts|
|`\033[`|Notation octale du caractère ESC|Compatible POSIX, universelle|
|`\x1b[`|Notation hexadécimale du caractère ESC|Parfois requise dans certains contextes|

> [!example] Exemples équivalents Ces trois lignes produisent exactement le même résultat :
> 
> ```bash
> echo -e "\e[31mTexte rouge\e[0m"
> echo -e "\033[31mTexte rouge\033[0m"
> echo -e "\x1b[31mTexte rouge\x1b[0m"
> ```

### Pourquoi plusieurs notations ?

```bash
# \e[ : La plus courte et lisible (recommandée)
echo -e "\e[32mSuccès\e[0m"

# \033[ : Compatible POSIX strict, fonctionne partout
printf "\033[33mAvertissement\033[0m\n"

# \x1b[ : Parfois nécessaire dans des contextes spécifiques
# (certains shells ou outils externes)
echo -e "\x1b[31mErreur\x1b[0m"
```

> [!tip] Quelle notation choisir ? Utilisez `\e[` par défaut dans vos scripts Bash modernes. C'est la plus concise et parfaitement supportée. Passez à `\033[` uniquement si vous devez garantir une compatibilité POSIX stricte.

---

## Syntaxe de base des codes couleurs

### Structure générale

Une séquence couleur ANSI suit cette structure :

```
\e[ <code(s)> m
│   │         │
│   │         └─ 'm' = fin de la séquence
│   └─ Code(s) numérique(s) séparés par ';'
└─ Début de séquence d'échappement
```

> [!example] Décortiquons un exemple
> 
> ```bash
> echo -e "\e[1;31mTexte en gras rouge\e[0m"
> #        │  │ │               │
> #        │  │ │               └─ Reset
> #        │  │ └─ 31 = rouge
> #        │  └─ 1 = gras
> #        └─ Début de séquence
> ```

### Les codes de couleurs standards

#### Codes pour le texte (foreground)

```bash
# Couleurs normales (30-37)
echo -e "\e[30mNoir\e[0m"
echo -e "\e[31mRouge\e[0m"
echo -e "\e[32mVert\e[0m"
echo -e "\e[33mJaune\e[0m"
echo -e "\e[34mBleu\e[0m"
echo -e "\e[35mMagenta\e[0m"
echo -e "\e[36mCyan\e[0m"
echo -e "\e[37mBlanc\e[0m"
```

|Code|Couleur|Usage typique|
|---|---|---|
|30|Noir|Rarement utilisé (invisible sur fond noir)|
|31|Rouge|Erreurs, alertes critiques|
|32|Vert|Succès, confirmations|
|33|Jaune|Avertissements|
|34|Bleu|Informations|
|35|Magenta|Étapes de processus|
|36|Cyan|Détails techniques, chemins|
|37|Blanc|Texte par défaut|

#### Codes pour le fond (background)

```bash
# Fonds colorés (40-47)
echo -e "\e[41mFond rouge\e[0m"
echo -e "\e[42mFond vert\e[0m"
echo -e "\e[43mFond jaune\e[0m"
echo -e "\e[44mFond bleu\e[0m"
```

> [!info] Règle simple Les codes de fond = codes de texte + 10
> 
> - Texte rouge = 31 → Fond rouge = 41
> - Texte vert = 32 → Fond vert = 42

#### Codes de style

```bash
# Styles de texte
echo -e "\e[1mGras\e[0m"
echo -e "\e[2mEstompé\e[0m"
echo -e "\e[3mItalique\e[0m"
echo -e "\e[4mSouligné\e[0m"
echo -e "\e[5mClignotant\e[0m"
echo -e "\e[7mInversé\e[0m"
echo -e "\e[8mMasqué\e[0m"
```

|Code|Style|Support|Usage|
|---|---|---|---|
|1|Gras|✅ Universel|Titres, emphase forte|
|2|Estompé|⚠️ Variable|Texte secondaire|
|3|Italique|⚠️ Variable|Emphase légère|
|4|Souligné|✅ Universel|Liens, importance|
|5|Clignotant|⚠️ Souvent désactivé|À éviter|
|7|Inversé|✅ Universel|Mise en évidence|
|8|Masqué|⚠️ Variable|Mots de passe|

> [!warning] Support variable Les styles 2, 3, 5 et 8 ne sont pas universellement supportés. Testez sur vos terminaux cibles avant de les utiliser en production.

### Combinaison de codes

La puissance des codes ANSI réside dans leur capacité à se combiner :

```bash
# Combiner plusieurs codes avec des points-virgules
echo -e "\e[1;31mGras et rouge\e[0m"
echo -e "\e[4;34mSouligné et bleu\e[0m"
echo -e "\e[1;4;32mGras, souligné et vert\e[0m"

# Texte coloré sur fond coloré
echo -e "\e[33;44mJaune sur fond bleu\e[0m"
echo -e "\e[1;37;41mBlanc gras sur fond rouge\e[0m"
```

> [!tip] Ordre des codes L'ordre des codes n'a généralement pas d'importance :
> 
> - `\e[1;31m` = `\e[31;1m` (même résultat)
> - Par convention, on place le style avant la couleur pour la lisibilité

> [!example] Exemple pratique : bannière d'erreur
> 
> ```bash
> echo -e "\e[1;37;41m ERREUR \e[0m \e[1;31mFichier introuvable\e[0m"
> #        │  │  │  │           │        │  │  │
> #        │  │  │  │           │        │  │  └─ Rouge
> #        │  │  │  │           │        │  └─ Gras
> #        │  │  │  │           │        └─ Reset puis nouvelle séquence
> #        │  │  │  │           └─ Reset
> #        │  │  │  └─ Fond rouge
> #        │  │  └─ Blanc
> #        │  └─ Gras
> #        └─ Début
> ```

---

## Réinitialisation des styles

### Le code de reset universel

Le code `\e[0m` est le plus important à connaître : il réinitialise TOUS les styles et couleurs aux valeurs par défaut du terminal.

```bash
# Sans reset : la couleur continue !
echo -e "\e[31mRouge"
echo "Ce texte est encore rouge !"

# Avec reset : retour à la normale
echo -e "\e[31mRouge\e[0m"
echo "Ce texte est normal"
```

> [!warning] Piège fréquent Oublier le `\e[0m` est l'erreur n°1 des débutants. Sans reset, votre terminal reste coloré et tous les textes suivants héritent du style !

### Pourquoi la réinitialisation est cruciale

```bash
# ❌ MAUVAIS : Sans reset
#!/bin/bash
echo -e "\e[32m✓ Installation réussie"
echo "Redémarrage du service..."  # Restera vert !
ls -la  # Même ls sera en vert !

# ✅ BON : Avec reset
#!/bin/bash
echo -e "\e[32m✓ Installation réussie\e[0m"
echo "Redémarrage du service..."  # Couleur normale
ls -la  # Affichage normal
```

> [!danger] Problème en production Un script sans resets corrects peut "polluer" le terminal de l'utilisateur. Même après la fin du script, le terminal reste coloré. C'est très frustrant et peu professionnel.

### Bonnes pratiques de réinitialisation

#### 1. Reset systématique après chaque couleur

```bash
# Toujours fermer ce que vous ouvrez
echo -e "\e[31mErreur\e[0m : fichier manquant"
echo -e "\e[32mSuccès\e[0m : opération terminée"
```

#### 2. Reset dans les variables

```bash
# Définir des constantes avec reset intégré
RED="\e[31m"
GREEN="\e[32m"
RESET="\e[0m"

echo -e "${RED}Erreur${RESET} : quelque chose a échoué"
echo -e "${GREEN}Succès${RESET} : tout va bien"
```

#### 3. Reset en fin de script

```bash
#!/bin/bash

# Votre script avec des couleurs...
echo -e "\e[33mTraitement en cours...\e[0m"

# Reset final par sécurité (au cas où)
echo -e "\e[0m"
```

> [!tip] Fonction de nettoyage Pour les scripts complexes, créez une fonction de nettoyage :
> 
> ```bash
> cleanup() {
>     echo -e "\e[0m"  # Reset couleurs
>     # Autres nettoyages...
> }
> trap cleanup EXIT
> ```

#### 4. Reset avant ET après en cas de doute

```bash
# Pour du texte critique (bannières, titres)
echo -e "\e[0m\e[1;37;41m ATTENTION \e[0m"
#        │     │           │
#        │     │           └─ Reset après
#        │     └─ Votre style
#        └─ Reset avant (au cas où)
```

---

## Pièges courants et solutions

### Piège #1 : Oublier l'option `-e` avec echo

```bash
# ❌ MAUVAIS : Sans -e, les séquences s'affichent littéralement
echo "\e[31mRouge\e[0m"
# Affiche : \e[31mRouge\e[0m

# ✅ BON : Avec -e, les séquences sont interprétées
echo -e "\e[31mRouge\e[0m"
# Affiche : Rouge (en couleur)
```

> [!info] Alternative : printf `printf` interprète les séquences par défaut (pas besoin de `-e`) :
> 
> ```bash
> printf "\e[32mVert\e[0m\n"
> ```

### Piège #2 : Doubles quotes vs simples quotes

```bash
# ❌ MAUVAIS : Les simples quotes ne fonctionnent PAS
echo -e '\e[31mRouge\e[0m'
# Affiche : \e[31mRouge\e[0m (littéral)

# ✅ BON : Utilisez toujours des doubles quotes
echo -e "\e[31mRouge\e[0m"
```

> [!warning] Règle d'or Pour les séquences d'échappement, utilisez TOUJOURS des doubles quotes `"..."` et jamais des simples quotes `'...'`.

### Piège #3 : Couleurs qui persistent

```bash
# ❌ MAUVAIS : La couleur se propage
function afficher_erreur() {
    echo -e "\e[31mErreur"
    # Oubli du reset !
}

afficher_erreur
echo "Ce texte sera rouge aussi !"

# ✅ BON : Reset systématique
function afficher_erreur() {
    echo -e "\e[31mErreur\e[0m"
}
```

### Piège #4 : Comptage de caractères faussé

```bash
# Les séquences ANSI comptent dans la longueur de chaîne
texte="\e[31mRouge\e[0m"
echo ${#texte}  # Affiche 18, pas 5 !

# Solution : compter uniquement le texte visible
texte_visible="Rouge"
echo ${#texte_visible}  # Affiche 5
```

> [!tip] Pour l'alignement Quand vous devez aligner du texte coloré (tableaux, menus), travaillez avec la longueur du texte visible, pas celle de la chaîne avec les codes ANSI.

### Piège #5 : Redirection et fichiers

```bash
# ❌ Les codes ANSI polluent les fichiers
echo -e "\e[31mErreur\e[0m" > log.txt
# Le fichier contient : ^[[31mErreur^[[0m (codes bruts)

# ✅ Solution : tester si c'est un terminal
if [ -t 1 ]; then
    # Sortie vers terminal : couleurs OK
    echo -e "\e[31mErreur\e[0m"
else
    # Sortie vers fichier : pas de couleurs
    echo "Erreur"
fi
```

> [!info] Test `-t 1` `-t 1` vérifie si la sortie standard (fd 1) est un terminal. C'est la méthode standard pour détecter les redirections.

---

## 🎯 Points clés à retenir

1. **Trois notations équivalentes** : `\e[`, `\033[`, `\x1b[` (privilégiez `\e[`)
2. **Structure** : `\e[<code(s)>m` avec codes séparés par `;`
3. **Reset universel** : `\e[0m` annule tous les styles
4. **Toujours utiliser** : `echo -e` et doubles quotes `"..."`
5. **Reset systématique** : après chaque couleur pour éviter la pollution
6. **Codes principaux** :
    - Couleurs texte : 30-37
    - Couleurs fond : 40-47
    - Style gras : 1
    - Style souligné : 4

> [!success] Vous maîtrisez maintenant Les fondamentaux des couleurs ANSI en Bash ! Vous savez comment structurer des séquences, combiner des codes, et éviter les pièges courants. Ces bases sont essentielles pour créer des scripts visuellement clairs et professionnels.