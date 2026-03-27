

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

La manipulation de chaînes de caractères en Bash permet de supprimer des portions de texte sans utiliser de commandes externes comme `sed` ou `awk`. Ces opérations sont **plus rapides** et **plus efficaces** car elles sont intégrées directement au shell.

> [!info] Pourquoi utiliser ces techniques ?
> 
> - **Performance** : Pas de processus externe à lancer
> - **Simplicité** : Syntaxe concise et lisible
> - **Portabilité** : Fonctionne dans tous les shells POSIX modernes
> - **Manipulation de chemins** : Idéal pour extraire noms de fichiers, extensions, répertoires

### Syntaxe générale

Les opérateurs utilisent des **patterns** (motifs) qui peuvent contenir :

- Des caractères littéraux : `abc`, `test`
- Des wildcards : `*` (zéro ou plusieurs caractères), `?` (un caractère)
- Des classes de caractères : `[0-9]`, `[a-z]`

---

## ✂️ Suppression de préfixes

### Plus court préfixe : `${var#pattern}`

Supprime la **plus courte** correspondance du pattern depuis le **début** de la chaîne.

```bash
# Syntaxe
${variable#pattern}

# Exemple basique
fichier="rapport-2024-final.pdf"
echo ${fichier#*-}  # Affiche : 2024-final.pdf
# Le * correspond à "rapport", le - est littéral
```

> [!example] Exemples d'utilisation
> 
> ```bash
> chemin="/home/user/documents/fichier.txt"
> 
> # Supprimer jusqu'au premier /
> echo ${chemin#*/}        # home/user/documents/fichier.txt
> 
> # Supprimer un préfixe connu
> url="https://example.com/page"
> echo ${url#https://}     # example.com/page
> 
> # Supprimer des zéros de tête
> numero="00042"
> echo ${numero#0}         # 0042 (un seul zéro supprimé)
> ```

### Plus long préfixe : `${var##pattern}`

Supprime la **plus longue** correspondance du pattern depuis le **début** de la chaîne.

```bash
# Syntaxe
${variable##pattern}

# Exemple basique
fichier="rapport-2024-final.pdf"
echo ${fichier##*-}  # Affiche : final.pdf
# Le * correspond à "rapport-2024", le - est littéral
```

> [!example] Exemples d'utilisation
> 
> ```bash
> chemin="/home/user/documents/fichier.txt"
> 
> # Extraire uniquement le nom du fichier (supprimer tout le chemin)
> echo ${chemin##*/}       # fichier.txt
> 
> # Supprimer tous les zéros de tête
> numero="00042"
> echo ${numero##0}        # 42
> 
> # Extraire le domaine d'une URL complexe
> url="https://subdomain.example.com/page"
> echo ${url##*/}          # page
> ```

### Comparaison `#` vs `##`

|Pattern|Avec `#` (plus court)|Avec `##` (plus long)|
|---|---|---|
|`var="a-b-c-d"`|`${var#*-}` → `b-c-d`|`${var##*-}` → `d`|
|`var="/usr/local/bin"`|`${var#*/}` → `usr/local/bin`|`${var##*/}` → `bin`|
|`var="test.tar.gz"`|`${var#*.}` → `tar.gz`|`${var##*.}` → `gz`|

> [!tip] Mnémotechnique **Un `#` = court = première occurrence**  
> **Deux `##` = long = dernière occurrence**

---

## ✂️ Suppression de suffixes

### Plus court suffixe : `${var%pattern}`

Supprime la **plus courte** correspondance du pattern depuis la **fin** de la chaîne.

```bash
# Syntaxe
${variable%pattern}

# Exemple basique
fichier="rapport.tar.gz"
echo ${fichier%.*}  # Affiche : rapport.tar
# Le .* correspond à ".gz"
```

> [!example] Exemples d'utilisation
> 
> ```bash
> fichier="document.backup.txt"
> 
> # Supprimer l'extension
> echo ${fichier%.*}       # document.backup
> 
> # Supprimer un suffixe connu
> nom="fichier_temp"
> echo ${nom%_temp}        # fichier
> 
> # Nettoyer des espaces de fin (avec un pattern)
> texte="hello   "
> echo ${texte% *}         # hello
> ```

### Plus long suffixe : `${var%%pattern}`

Supprime la **plus longue** correspondance du pattern depuis la **fin** de la chaîne.

```bash
# Syntaxe
${variable%%pattern}

# Exemple basique
fichier="rapport.tar.gz"
echo ${fichier%%.*}  # Affiche : rapport
# Le .* correspond à ".tar.gz"
```

> [!example] Exemples d'utilisation
> 
> ```bash
> chemin="/home/user/documents/fichier.txt"
> 
> # Extraire uniquement le répertoire parent
> echo ${chemin%%/*}       # (vide, car commence par /)
> 
> # Supprimer toutes les extensions
> fichier="archive.tar.gz.bak"
> echo ${fichier%%.*}      # archive
> 
> # Extraire le nom de base sans extension
> url="https://example.com/file.html"
> nom=${url##*/}           # file.html
> echo ${nom%%.*}          # file
> ```

### Comparaison `%` vs `%%`

|Pattern|Avec `%` (plus court)|Avec `%%` (plus long)|
|---|---|---|
|`var="a.b.c.d"`|`${var%.*}` → `a.b.c`|`${var%%.*}` → `a`|
|`var="file.tar.gz"`|`${var%.*}` → `file.tar`|`${var%%.*}` → `file`|
|`var="path/to/file"`|`${var%/*}` → `path/to`|`${var%%/*}` → `path`|

> [!tip] Mnémotechnique **Un `%` = court = dernière occurrence**  
> **Deux `%%` = long = première occurrence (depuis la fin)**

---

## 🛠️ Applications pratiques

### Extraction de nom de fichier et extension

```bash
chemin="/home/user/documents/rapport_final.pdf"

# Extraire le nom complet du fichier
nom_complet=${chemin##*/}
echo "Fichier : $nom_complet"  # rapport_final.pdf

# Extraire le nom sans extension
nom_base=${nom_complet%.*}
echo "Nom de base : $nom_base"  # rapport_final

# Extraire l'extension
extension=${nom_complet##*.}
echo "Extension : $extension"   # pdf

# Extraire le répertoire parent
repertoire=${chemin%/*}
echo "Répertoire : $repertoire"  # /home/user/documents
```

### Traitement par lots de fichiers

```bash
# Renommer tous les .txt en .md
for fichier in *.txt; do
    nouveau=${fichier%.txt}.md
    mv "$fichier" "$nouveau"
    echo "Renommé : $fichier → $nouveau"
done

# Créer des backups
for fichier in *.conf; do
    cp "$fichier" "${fichier%.conf}.conf.bak"
done

# Supprimer les extensions doubles
for fichier in *.tar.gz; do
    base=${fichier%%.*}  # Garde seulement le nom
    echo "Base : $base"
done
```

### Manipulation d'URLs

```bash
url="https://user:pass@subdomain.example.com:8080/path/to/page.html?query=1#anchor"

# Extraire le protocole
protocole=${url%%://*}
echo "Protocole : $protocole"  # https

# Supprimer le protocole
sans_proto=${url#*://}
echo "Sans protocole : $sans_proto"  # user:pass@subdomain.example.com:8080/path/to/page.html?query=1#anchor

# Extraire le domaine (sans port ni chemin)
domaine=${sans_proto%%:*}      # Supprime à partir du premier :
domaine=${domaine%%/*}          # Supprime à partir du premier /
domaine=${domaine##*@}          # Supprime les credentials
echo "Domaine : $domaine"       # subdomain.example.com

# Extraire le chemin
chemin_url=${url#*://*/}
chemin_url="/${chemin_url%%\?*}"  # Supprime la query string
echo "Chemin : $chemin_url"     # /path/to/page.html
```

### Parsing de versions

```bash
version="v2.34.5-beta+build.123"

# Supprimer le préfixe v
numero=${version#v}              # 2.34.5-beta+build.123

# Extraire la version majeure
majeure=${numero%%.*}            # 2

# Extraire version majeure.mineure
maj_min=${numero%.*}             # 2.34.5-beta+build
maj_min=${maj_min%.*}            # 2.34.5-beta
maj_min=${maj_min%-*}            # 2.34.5
maj_min=${maj_min%.*}            # 2.34

# Supprimer les métadonnées
propre=${numero%%-*}             # 2.34.5
propre=${propre%%+*}             # 2.34.5

echo "Version propre : $propre"
```

### Nettoyage de données

```bash
# Supprimer les espaces de début (simulation)
texte="   hello world   "
# Note : les espaces nécessitent des patterns plus complexes

# Supprimer des préfixes courants
log="[INFO] Le système a démarré"
message=${log#\[*\] }
echo "$message"  # Le système a démarré

# Nettoyer des timestamps
ligne="2024-01-15 10:30:45 - Erreur système"
sans_date=${ligne#* - }
echo "$sans_date"  # Erreur système
```

---

## ⚠️ Pièges courants

### 1. Patterns trop gourmands

> [!warning] Attention aux wildcards
> 
> ```bash
> fichier="file.test.txt"
> 
> # ❌ Mauvais : supprime trop
> echo ${fichier#*.}     # test.txt (on voulait peut-être garder "file.test")
> 
> # ✅ Bon : utiliser le bon opérateur
> echo ${fichier%.*}     # file.test (supprime juste la dernière extension)
> ```

### 2. Caractères spéciaux non échappés

```bash
fichier="test[1].txt"

# ❌ Mauvais : [1] est interprété comme classe de caractères
echo ${fichier%[1]*}    # Ne fonctionne pas comme prévu

# ✅ Bon : échapper les crochets
echo ${fichier%\[1\]*}  # test

# Ou utiliser des quotes
pattern='[1]*'
echo ${fichier%$pattern}
```

### 3. Variables vides ou non définies

```bash
# ❌ Risque d'erreur si la variable n'existe pas
echo ${fichier_inexistant##*/}  # (vide, pas d'erreur mais comportement inattendu)

# ✅ Bon : toujours vérifier
if [[ -n "$fichier" ]]; then
    nom=${fichier##*/}
    echo "$nom"
else
    echo "Erreur : fichier non défini"
fi

# Ou utiliser une valeur par défaut
nom=${fichier:-"default.txt"}
nom=${nom##*/}
```

### 4. Confusion entre # et %

> [!warning] Direction importante
> 
> ```bash
> chemin="/usr/local/bin/program"
> 
> # # travaille depuis le DÉBUT (gauche)
> echo ${chemin#*/}      # usr/local/bin/program
> 
> # % travaille depuis la FIN (droite)
> echo ${chemin%/*}      # /usr/local/bin
> ```

### 5. Patterns qui ne matchent pas

```bash
fichier="document.pdf"

# Si le pattern ne correspond pas, la variable reste inchangée
echo ${fichier%.txt}    # document.pdf (pas de .txt à supprimer)

# Toujours vérifier si le pattern a matché
nouveau=${fichier%.txt}
if [[ "$nouveau" != "$fichier" ]]; then
    echo "Extension .txt supprimée"
else
    echo "Pas d'extension .txt trouvée"
fi
```

---

## 💡 Astuces avancées

### Combiner plusieurs opérations

```bash
# Chaîner les opérations
fichier="/home/user/documents/rapport_final_v2.draft.txt"

# Extraire nom sans chemin ni extension
nom=${fichier##*/}           # rapport_final_v2.draft.txt
nom=${nom%%.*}               # rapport_final_v2
nom=${nom%_v*}               # rapport_final

echo "Nom nettoyé : $nom"
```

### Utiliser des patterns conditionnels

```bash
fichier="test.tar.gz"

# Supprimer .tar.gz OU .zip selon ce qui existe
sans_ext=${fichier%.tar.gz}
sans_ext=${sans_ext%.zip}

# Méthode plus propre avec un case
case "$fichier" in
    *.tar.gz) base=${fichier%.tar.gz} ;;
    *.zip)    base=${fichier%.zip} ;;
    *)        base=${fichier%.*} ;;
esac
```

### Patterns avec alternatives

```bash
# Utiliser les accolades pour plusieurs patterns
fichier="image.jpg"

# Supprimer plusieurs extensions possibles
for ext in jpg jpeg png gif; do
    fichier=${fichier%.$ext}
done

# Ou en une ligne (si pattern simple)
sans_ext=${fichier%.*}  # Plus universel
```

### Validation de format

```bash
# Vérifier qu'une chaîne a le bon format
email="user@example.com"

# Extraire les parties
local_part=${email%@*}
domaine=${email##*@}

if [[ "$local_part" == "$email" ]] || [[ "$domaine" == "$email" ]]; then
    echo "Format email invalide"
else
    echo "Local: $local_part, Domaine: $domaine"
fi
```

### Performance : éviter les sous-shells

```bash
# ❌ Lent : utilise des commandes externes
nom=$(basename "$fichier")
ext=$(echo "$fichier" | sed 's/.*\.//')

# ✅ Rapide : opérations intégrées au shell
nom=${fichier##*/}
ext=${fichier##*.}
```

### Tableau récapitulatif complet

|Opérateur|Direction|Longueur|Utilisation courante|
|---|---|---|---|
|`${var#pattern}`|Début →|Plus courte|Supprimer un préfixe court|
|`${var##pattern}`|Début →|Plus longue|Extraire nom de fichier|
|`${var%pattern}`|← Fin|Plus courte|Supprimer extension simple|
|`${var%%pattern}`|← Fin|Plus longue|Supprimer toutes extensions|

### Pattern de remplacement complet

```bash
#!/bin/bash
# Script complet de manipulation de fichiers

fichier="/home/user/documents/rapport_2024.tar.gz.backup"

echo "=== Analyse du fichier ==="
echo "Chemin complet : $fichier"

# Extraction des composants
repertoire=${fichier%/*}
nom_complet=${fichier##*/}
nom_base=${nom_complet%%.*}
extension_complete=${nom_complet#*.}
extension_finale=${nom_complet##*.}

echo "Répertoire    : $repertoire"
echo "Nom complet   : $nom_complet"
echo "Nom de base   : $nom_base"
echo "Extension(s)  : $extension_complete"
echo "Dernière ext  : $extension_finale"

# Reconstruction
nouveau_fichier="$repertoire/${nom_base}_final.${extension_finale}"
echo "Nouveau nom   : $nouveau_fichier"
```

---

> [!tip] Résumé des bonnes pratiques
> 
> - Utilisez `##` pour extraire les noms de fichiers (supprime le chemin)
> - Utilisez `%%` pour supprimer toutes les extensions
> - Utilisez `%` pour supprimer une seule extension
> - Échappez les caractères spéciaux dans les patterns
> - Préférez ces opérateurs aux commandes externes pour la performance
> - Combinez-les avec d'autres manipulations de chaînes pour plus de puissance