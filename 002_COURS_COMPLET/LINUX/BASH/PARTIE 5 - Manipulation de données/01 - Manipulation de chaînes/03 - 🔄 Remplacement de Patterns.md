

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

## 🎯 Introduction au remplacement de patterns {#introduction}

Le remplacement de patterns permet de modifier le contenu d'une variable sans utiliser de commandes externes comme `sed` ou `awk`. C'est une fonctionnalité native du shell qui offre d'excellentes performances et une syntaxe concise.

> [!info] Pourquoi utiliser le remplacement de patterns ?
> 
> - **Performance** : Pas de processus externe, exécution directe par le shell
> - **Portabilité** : Fonctionne sans dépendances externes
> - **Lisibilité** : Syntaxe compacte pour les opérations simples
> - **Sécurité** : Pas d'injection de commandes possibles

### Quand l'utiliser ?

- Modification de chemins de fichiers
- Nettoyage de données utilisateur
- Transformation de chaînes dans les scripts
- Manipulation d'extensions de fichiers
- Normalisation de formats

---

## 🔍 Première occurrence {#première-occurrence}

### Syntaxe

```bash
${variable/pattern/remplacement}
```

Cette syntaxe remplace **uniquement la première occurrence** du pattern trouvé dans la variable.

### Explication détaillée

```bash
# Déclaration d'une variable
texte="le chat est sur le tapis"

# Remplacement de la première occurrence de "le"
resultat="${texte/le/un}"
echo "$resultat"  # Affiche : un chat est sur le tapis
```

> [!example] Exemples pratiques
> 
> ```bash
> # Remplacement d'espace par underscore
> fichier="mon fichier important.txt"
> nouveau="${fichier/ /_}"
> echo "$nouveau"  # mon_fichier important.txt
> 
> # Modification d'extension
> photo="vacances.jpeg"
> nouvelle="${photo/jpeg/jpg}"
> echo "$nouvelle"  # vacances.jpg
> 
> # Changement de protocole
> url="http://example.com/page"
> secure="${url/http/https}"
> echo "$secure"  # https://example.com/page
> ```

### Cas d'usage courants

|Situation|Exemple|Résultat|
|---|---|---|
|Correction de typo|`${text/teh/the}`|Corrige la première occurrence|
|Changement de séparateur|`${csv/,/;}`|Remplace la première virgule|
|Modification de préfixe|`${path/old/new}`|Change le premier segment|

---

## 🔄 Toutes les occurrences {#toutes-les-occurrences}

### Syntaxe

```bash
${variable//pattern/remplacement}
```

Le double slash `//` indique que **toutes les occurrences** doivent être remplacées.

### Explication détaillée

```bash
# Variable avec répétitions
texte="le chat et le chien et le poisson"

# Remplacement de toutes les occurrences
resultat="${texte//le/un}"
echo "$resultat"  # un chat et un chien et un poisson
```

> [!example] Exemples pratiques
> 
> ```bash
> # Nettoyage d'espaces multiples (simpliste)
> phrase="trop    d'espaces    ici"
> propre="${phrase//  / }"  # Remplace doubles espaces
> echo "$propre"  # trop  d'espaces  ici
> 
> # Suppression de caractères spéciaux
> telephone="+33-6-12-34-56-78"
> sans_tirets="${telephone//-/}"
> echo "$sans_tirets"  # +33612345678
> 
> # Remplacement de séparateurs
> chemin="dir1/dir2/dir3/fichier.txt"
> windows="${chemin//\//\\}"
> echo "$windows"  # dir1\dir2\dir3\fichier.txt
> 
> # Normalisation de données
> csv="valeur1,valeur2,valeur3"
> tsv="${csv//,/$'\t'}"  # Remplace virgules par tabulations
> ```

### Différence avec la première occurrence

```bash
data="log-2024-01-log-file.log"

# Une seule occurrence
echo "${data/log/LOG}"      # LOG-2024-01-log-file.log

# Toutes les occurrences
echo "${data//log/LOG}"     # LOG-2024-01-LOG-file.LOG
```

> [!warning] Attention aux patterns trop larges Un pattern trop générique peut modifier plus que prévu :
> 
> ```bash
> texte="information importante"
> echo "${texte//in/XX}"  # XXformation XXportante (pas toujours voulu)
> ```

---

## ⬆️ Remplacement au début {#remplacement-au-début}

### Syntaxe

```bash
${variable/#pattern/remplacement}
```

Le symbole `#` indique que le remplacement ne s'effectue que si le pattern est **au début** de la chaîne (ancrage de début).

### Explication détaillée

```bash
# Variable avec préfixe
chemin="/home/user/documents"

# Remplacement uniquement si le pattern est au début
sans_home="${chemin/#\/home/~}"
echo "$sans_home"  # ~/user/documents

# Si le pattern n'est pas au début, aucun remplacement
autre="/var/home/data"
resultat="${autre/#\/home/~}"
echo "$resultat"  # /var/home/data (inchangé)
```

> [!example] Exemples pratiques
> 
> ```bash
> # Suppression de préfixe de protocole
> url="https://www.example.com"
> sans_protocole="${url/#https:\/\//}"
> echo "$sans_protocole"  # www.example.com
> 
> # Modification de préfixe de dossier
> path="/tmp/session_12345"
> nouveau="${path/#\/tmp/\/var\/tmp}"
> echo "$nouveau"  # /var/tmp/session_12345
> 
> # Ajout de préfixe si absent (via test)
> nom="fichier.txt"
> avec_prefixe="${nom/#fichier/backup_fichier}"
> echo "$avec_prefixe"  # backup_fichier.txt
> 
> # Normalisation de chemins relatifs
> rel_path="./config/app.conf"
> absolu="${rel_path/#.\//\/etc\/}"
> echo "$absolu"  # /etc/config/app.conf
> ```

### Cas d'usage typiques

|Situation|Exemple|Utilité|
|---|---|---|
|Normalisation de chemins|`${path/#~/$HOME}`|Expansion de tilde|
|Suppression de préfixe|`${str/#PREFIX_/}`|Nettoyage de noms|
|Remplacement conditionnel|`${url/#http:/https:}`|Mise à jour de protocole|

> [!tip] Combinaison avec les conditions
> 
> ```bash
> # Vérifier et remplacer le préfixe
> fichier="temp_data.txt"
> if [[ $fichier == temp_* ]]; then
>     fichier="${fichier/#temp_/final_}"
> fi
> echo "$fichier"  # final_data.txt
> ```

---

## ⬇️ Remplacement à la fin {#remplacement-à-la-fin}

### Syntaxe

```bash
${variable/%pattern/remplacement}
```

Le symbole `%` indique que le remplacement ne s'effectue que si le pattern est **à la fin** de la chaîne (ancrage de fin).

### Explication détaillée

```bash
# Variable avec suffixe
fichier="document.txt"

# Remplacement uniquement si le pattern est à la fin
nouveau="${fichier/%.txt/.pdf}"
echo "$nouveau"  # document.pdf

# Si le pattern n'est pas à la fin, aucun remplacement
autre="txt.backup"
resultat="${autre/%.txt/.pdf}"
echo "$resultat"  # txt.backup (inchangé)
```

> [!example] Exemples pratiques
> 
> ```bash
> # Changement d'extension
> image="photo.jpeg"
> convertie="${image/%.jpeg/.jpg}"
> echo "$convertie"  # photo.jpg
> 
> # Suppression de suffixe
> archive="backup.tar.gz"
> sans_gz="${archive/%.gz/}"
> echo "$sans_gz"  # backup.tar
> 
> # Modification de version
> paquet="app-v1.2.3"
> mise_a_jour="${paquet/%v1.2.3/v2.0.0}"
> echo "$mise_a_jour"  # app-v2.0.0
> 
> # Normalisation de fichiers temporaires
> temp="data.tmp"
> final="${temp/%.tmp/.dat}"
> echo "$final"  # data.dat
> 
> # Suppression de trailing slash
> chemin="/var/log/"
> propre="${chemin/%\//}"
> echo "$propre"  # /var/log
> ```

### Applications pratiques

```bash
# Traitement par lot d'extensions
for fichier in *.jpeg; do
    nouveau="${fichier/%.jpeg/.jpg}"
    echo "Renommer: $fichier -> $nouveau"
done

# Nettoyage de suffixes de backup
backup="config.conf.bak"
original="${backup/%.bak/}"
echo "$original"  # config.conf

# Modification de suffixes de log
log_file="app.log.2024"
archive="${log_file/%.2024/.archive}"
echo "$archive"  # app.log.archive
```

> [!warning] Attention aux extensions composées
> 
> ```bash
> # Extension composée
> fichier="archive.tar.gz"
> 
> # Supprime seulement .gz
> etape1="${fichier/%.gz/}"  # archive.tar
> 
> # Pour supprimer .tar.gz, il faut être explicite
> sans_ext="${fichier/%.tar.gz/}"  # archive
> ```

### Comparaison début vs fin

```bash
url="https://example.com/page.html"

# Remplacement au début
sans_protocole="${url/#https:\/\//}"
echo "$sans_protocole"  # example.com/page.html

# Remplacement à la fin
sans_extension="${url/%.html/}"
echo "$sans_extension"  # https://example.com/page
```

---

## ❌ Suppression de patterns {#suppression-de-patterns}

### Syntaxe

```bash
${variable/pattern/}
${variable//pattern/}
${variable/#pattern/}
${variable/%pattern/}
```

Lorsque le remplacement est **vide**, le pattern est simplement supprimé.

### Explication détaillée

```bash
# Suppression de la première occurrence
texte="le chat le chien"
resultat="${texte/le /}"
echo "$resultat"  # chat le chien

# Suppression de toutes les occurrences
resultat2="${texte//le /}"
echo "$resultat2"  # chat chien
```

> [!example] Exemples de suppression pratiques
> 
> ```bash
> # Nettoyage de caractères spéciaux
> telephone="+33 6 12 34 56 78"
> propre="${telephone// /}"  # Supprime tous les espaces
> echo "$propre"  # +33612345678
> 
> # Suppression d'extension
> fichier="document.backup.txt"
> sans_ext="${fichier/%.txt/}"
> echo "$sans_ext"  # document.backup
> 
> # Nettoyage de préfixe
> log="[INFO] Message important"
> message="${log/#\[INFO\] /}"
> echo "$message"  # Message important
> 
> # Suppression de suffixe
> url="https://example.com/"
> propre="${url/%\//}"
> echo "$propre"  # https://example.com
> 
> # Suppression de marqueurs
> code="<TAG>contenu</TAG>"
> sans_tags="${code//<TAG>/}"
> sans_tags="${sans_tags//<\/TAG>/}"
> echo "$sans_tags"  # contenu
> ```

### Cas d'usage courants

```bash
# Nettoyage de données CSV
ligne="valeur1, valeur2, valeur3"
sans_espaces="${ligne//, /,}"
echo "$sans_espaces"  # valeur1,valeur2,valeur3

# Suppression de quotes
chaine='"texte entre guillemets"'
nettoye="${chaine//\"/}"
echo "$nettoye"  # texte entre guillemets

# Suppression de caractères de contrôle (retour chariot Windows)
windows_text="ligne1\r\nligne2\r\n"
unix_text="${windows_text//$'\r'/}"

# Suppression de préfixes multiples
fichier="tmp.tmp.data.txt"
sans_tmp="${fichier//tmp./}"
echo "$sans_tmp"  # data.txt
```

> [!tip] Suppression vs remplacement par vide Ces deux syntaxes sont équivalentes :
> 
> ```bash
> texte="test"
> echo "${texte/t/}"     # es (suppression)
> echo "${texte/t//}"    # ERREUR - interprété comme "toutes occurrences"
> ```
> 
> Pour supprimer, ne mettez rien après le dernier `/`.

---

## 🎨 Patterns et expressions {#patterns-et-expressions}

### Types de patterns supportés

Le remplacement de patterns en Bash utilise les **glob patterns**, pas les expressions régulières.

#### Caractères spéciaux des glob patterns

|Caractère|Signification|Exemple|
|---|---|---|
|`*`|N'importe quelle séquence de caractères|`${var//*.txt/}`|
|`?`|Un seul caractère quelconque|`${var//?.log/}`|
|`[abc]`|Un caractère parmi a, b ou c|`${var//[0-9]/X}`|
|`[a-z]`|Un caractère dans la plage|`${var//[a-z]/}`|
|`[!abc]`|Un caractère qui n'est pas a, b ou c|`${var//[!0-9]/}`|

### Exemples de patterns

```bash
# Wildcard *
fichier="rapport_2024_final_v2.pdf"
simplifie="${fichier//_*_/_}"
echo "$simplifie"  # rapport_final_v2.pdf (supprime tout entre les _)

# Caractère unique ?
code="A1B2C3"
anonymise="${code//[A-Z]?/XX}"
echo "$anonymise"  # XXXXXX

# Classes de caractères
texte="Prix: 1234.56 EUR"
sans_chiffres="${texte//[0-9]/}"
echo "$sans_chiffres"  # Prix: . EUR

# Négation
identifiant="User_123_Admin"
sans_chiffres="${identifiant//[!0-9]/}"
echo "$sans_chiffres"  # 123 (garde seulement les chiffres)
```

> [!example] Patterns avancés
> 
> ```bash
> # Suppression de multiples extensions
> fichier="document.backup.old.txt"
> base="${fichier%%.*}"  # document (tout après le premier point)
> 
> # Extraction avec pattern
> email="user@example.com"
> domaine="${email//*@/}"  # example.com
> 
> # Remplacement de plages
> texte="Test123Test"
> majuscules="${texte//[a-z]/X}"
> echo "$majuscules"  # TXXX123TXXX
> 
> # Nettoyage sélectif
> path="/home/user/./documents/../files"
> sans_relatif="${path//\/.\//\/}"
> sans_relatif="${sans_relatif//\/\.\.\//\/}"
> echo "$sans_relatif"  # /home/user/documents/files
> ```

### Échappement de caractères spéciaux

```bash
# Échappement nécessaire pour les caractères littéraux
texte="Prix: 10.50$"

# Mauvais - le point est un wildcard
echo "${texte/./,}"  # Prix, 10.50$ (remplace le premier caractère)

# Correct - échappement du point
echo "${texte/\./,}"  # Prix: 10,50$

# Autres caractères à échapper
special="test[123]test"
sans_crochets="${special//\[*\]/}"
echo "$sans_crochets"  # testtest
```

> [!warning] Différence avec les regex Les patterns Bash ne sont **pas** des expressions régulières :
> 
> ```bash
> texte="test123test"
> 
> # Ceci ne fonctionne PAS (pas de + en glob)
> # echo "${texte//[0-9]+/NUM}"
> 
> # À la place, utilisez * ou répétez
> echo "${texte//[0-9]*/NUM}"  # testNUMtest
> ```

### Patterns de chemins

```bash
# Extraction de nom de fichier
chemin="/var/log/app/error.log"
fichier="${chemin##*/}"
echo "$fichier"  # error.log

# Extraction de répertoire
repertoire="${chemin%/*}"
echo "$repertoire"  # /var/log/app

# Remplacement dans les chemins
ancien="/opt/app/v1/bin/exec"
nouveau="${ancien//\/v1\//\/v2\/}"
echo "$nouveau"  # /opt/app/v2/bin/exec
```

---

## ⚠️ Pièges courants {#pièges-courants}

### 1. Confusion entre / et //

```bash
texte="aaa bbb aaa ccc"

# Une seule occurrence
echo "${texte/aaa/XXX}"   # XXX bbb aaa ccc

# Toutes les occurrences
echo "${texte//aaa/XXX}"  # XXX bbb XXX ccc
```

> [!warning] Oubli du double slash C'est l'erreur la plus fréquente - pensez toujours à vérifier si vous voulez remplacer toutes les occurrences.

### 2. Échappement des caractères spéciaux

```bash
# Les caractères /, *, ?, [ et ] ont des significations spéciales
chemin="/home/user/file.txt"

# Mauvais - le / n'est pas échappé dans le pattern
# echo "${chemin//home/user/tmp/user}"  # ERREUR de syntaxe

# Correct - échappement des /
echo "${chemin//\/home\/user/\/tmp\/user}"  # /tmp/user/file.txt

# Alternative - utiliser des variables
ancien="/home/user"
nouveau="/tmp/user"
echo "${chemin//$ancien/$nouveau}"  # /tmp/user/file.txt
```

### 3. Patterns trop gourmands

```bash
fichier="backup.2024.01.15.tar.gz"

# Pattern trop large avec *
echo "${fichier//*.*/}"  # .gz (supprime tout jusqu'au dernier point)

# Plus précis
echo "${fichier/%\.tar\.gz/}"  # backup.2024.01.15
```

> [!warning] Le wildcard * est gourmand Le `*` correspond à la plus longue séquence possible, pas la plus courte.

### 4. Oubli des ancrages # et %

```bash
url="https://api.example.com/v1/users"

# Sans ancrage - peut matcher n'importe où
echo "${url//api/web}"  # https://web.example.com/v1/users

# Mais si "api" apparaît ailleurs ?
url2="https://api.example.com/api/v1"
echo "${url2//api/web}"  # https://web.example.com/web/v1 (pas voulu!)

# Avec ancrage au début
echo "${url2/#https:\/\/api/https:\/\/web}"  # https://web.example.com/api/v1
```

### 5. Variables non quotées

```bash
texte="fichier  avec  espaces"
pattern=" "
replacement="_"

# Mauvais - expansion incorrecte
# resultat=${texte//$pattern/$replacement}

# Correct - toujours quoter
resultat="${texte//$pattern/$replacement}"
echo "$resultat"  # fichier__avec__espaces
```

### 6. Patterns avec des slashes

```bash
path="/usr/local/bin"

# Difficile à lire et à maintenir
nouveau="${path//\/usr\/local/\/opt}"

# Alternative plus lisible
ancien="/usr/local"
nouv="/opt"
nouveau="${path//$ancien/$nouv}"
echo "$nouveau"  # /opt/bin
```

> [!tip] Utilisez des variables pour les patterns complexes C'est plus lisible et plus facile à maintenir.

### 7. Confusion avec la suppression de préfixes/suffixes

```bash
fichier="document.txt"

# Remplacement (cherche le pattern n'importe où à la fin)
echo "${fichier/%.txt/.pdf}"     # document.pdf

# Suppression de suffixe (opérateur différent)
echo "${fichier%.txt}"           # document

# Ne confondez pas avec :
echo "${fichier/%.txt/}"         # document (même résultat mais syntaxe différente)
```

---

## ✅ Bonnes pratiques {#bonnes-pratiques}

### 1. Toujours quoter les variables

```bash
# ✅ Bon
fichier="mon fichier.txt"
nouveau="${fichier// /_}"

# ❌ Mauvais - risque de word splitting
nouveau=${fichier// /_}
```

### 2. Utiliser des variables pour les patterns complexes

```bash
# ✅ Bon - lisible et maintenable
ancien_chemin="/usr/local/bin"
nouveau_chemin="/opt/bin"
path="/usr/local/bin/app"
resultat="${path//$ancien_chemin/$nouveau_chemin}"

# ❌ Mauvais - difficile à lire
resultat="${path//\/usr\/local\/bin/\/opt\/bin}"
```

### 3. Commenter les patterns non évidents

```bash
# Supprime les caractères de contrôle Windows (CR+LF -> LF)
texte="${texte//$'\r'/}"

# Remplace les séquences de chiffres par XXX
anonymise="${data//[0-9][0-9]*/XXX}"

# Normalise les chemins en retirant les doubles slashes
path="${path//\/\//\/}"
```

### 4. Préférer les ancrages quand c'est approprié

```bash
# ✅ Bon - intention claire
extension="${fichier/%.old.bak/}"

# ❌ Moins bon - pourrait matcher au milieu
extension="${fichier//.old.bak/}"
```

### 5. Tester avec des cas limites

```bash
# Fonction de nettoyage
nettoyer_fichier() {
    local fichier="$1"
    # Supprime les espaces et caractères spéciaux
    fichier="${fichier// /_}"
    fichier="${fichier//[^a-zA-Z0-9._-]/}"
    echo "$fichier"
}

# Tests
echo "$(nettoyer_fichier 'mon fichier (copie).txt')"  # mon_fichier_copie.txt
echo "$(nettoyer_fichier '  .hidden')"                 # _.hidden
echo "$(nettoyer_fichier 'файл.txt')"                  # .txt
```

### 6. Combiner avec des tests de validation

```bash
# ✅ Bon - vérification avant traitement
fichier="config.conf"
if [[ $fichier == *.conf ]]; then
    backup="${fichier/%.conf/.conf.bak}"
    echo "Création de $backup"
fi

# ✅ Bon - validation du résultat
url="http://example.com"
secure="${url/#http:/https:}"
if [[ $secure == https://* ]]; then
    echo "URL sécurisée: $secure"
fi
```

### 7. Documenter les transformations complexes

```bash
# Fonction bien documentée
normaliser_nom_fichier() {
    local nom="$1"
    
    # 1. Convertir les espaces en underscores
    nom="${nom// /_}"
    
    # 2. Supprimer les caractères non-alphanumériques (sauf ._-)
    nom="${nom//[^a-zA-Z0-9._-]/}"
    
    # 3. Supprimer les underscores multiples
    while [[ $nom == *__* ]]; do
        nom="${nom/__/_}"
    done
    
    # 4. Supprimer les underscores de début/fin
    nom="${nom/#_/}"
    nom="${nom/%_/}"
    
    echo "$nom"
}
```

### 8. Utiliser des fonctions pour la réutilisabilité

```bash
# ✅ Bon - fonction réutilisable
remplacer_extension() {
    local fichier="$1"
    local ancienne="$2"
    local nouvelle="$3"
    echo "${fichier/%.$ancienne/.$nouvelle}"
}

# Usage
nouveau=$(remplacer_extension "photo.jpeg" "jpeg" "jpg")
```

---

## 💡 Astuces avancées {#astuces-avancées}

### 1. Chaînage de remplacements

```bash
# Plusieurs transformations successives
texte="Hello  World  !"

# Étape par étape
texte="${texte//  / }"       # Supprime doubles espaces
texte="${texte// /_}"        # Remplace espaces par underscores
texte="${texte//_!/_}"       # Nettoie le point d'exclamation

echo "$texte"  # Hello_World_
```

### 2. Remplacement conditionnel avec tests

```bash
# Remplacement uniquement si condition remplie
fichier="document.txt"

if [[ $fichier == *.txt ]]; then
    markdown="${fichier/%.txt/.md}"
    echo "Conversion: $fichier -> $markdown"
fi

# Avec valeur par défaut
url="${url:-http://localhost}"
secure="${url/#http:/https:}"
```

### 3. Boucles de normalisation

```bash
# Normaliser jusqu'à stabilité
texte="a___b____c___d"

# Remplacer les underscores multiples par un seul
while [[ $texte == *__* ]]; do
    texte="${texte//__/_}"
done

echo "$texte"  # a_b_c_d
```

### 4. Utilisation avec des tableaux

```bash
# Traiter tous les fichiers d'un répertoire
fichiers=(*.jpeg)

for f in "${fichiers[@]}"; do
    nouveau="${f/%.jpeg/.jpg}"
    echo "Renommer: $f -> $nouveau"
done
```

### 5. Manipulation de listes

```bash
# Liste CSV
liste="valeur1,valeur2,valeur3,valeur4"

# Convertir en liste Bash (array)
IFS=',' read -ra tableau <<< "$liste"

# Ou remplacer les séparateurs
liste_espaces="${liste//,/ }"
echo "$liste_espaces"  # valeur1 valeur2 valeur3 valeur4
```

### 6. Extraction avec patterns

```bash
# Extraire le domaine d'une URL
url="https://user:pass@example.com:8080/path?query"

# Supprimer le protocole
sans_proto="${url/#*:\/\//}"
echo "$sans_proto"  # user:pass@example.com:8080/path?query

# Extraire le domaine (supprime tout après)
domaine="${sans_proto%%[:/]*}"
echo "$domaine"  # user:pass@example.com
```

### 7. Nettoyage intelligent de chemins

```bash
# Fonction de normalisation de chemin
normaliser_chemin() {
    local chemin="$1"
    
    # Supprimer les doubles slashes
    while [[ $chemin == *//* ]]; do
        chemin="${chemin//\/\//\/}"
    done
    
    # Supprimer le trailing slash (sauf pour /)
    if [[ $chemin != "/" ]]; then
        chemin="${chemin/%\//}"
    fi
    
    echo "$chemin"
}

# Test
echo "$(normaliser_chemin '/home//user//documents/')"  # /home/user/documents
```

### 8. Masquage de données sensibles

```bash
# Anonymiser des numéros de carte
carte="1234-5678-9012-3456"
masque="${carte//[0-9]/*}"
masque="${masque:0:${#masque}-4}${carte: -4}"
echo "$masque"  # ****-****-****-3456

# Version plus simple pour garder les 4 derniers chiffres
anonymiser() {
    local data="$1"
    local visible=4
    local longueur=${#data}
    local masque=$(printf '%*s' $((longueur-visible)) | tr ' ' '*')
    echo "${masque}${data: -$visible}"
}

echo "$(anonymiser '1234567890')"  # ******7890
```

### 9. Génération de slugs

```bash
# Convertir un titre en slug URL-friendly
generer_slug() {
    local titre="$1"
    local slug="$titre"
    
    # Minuscules (nécessite autre commande)
    slug=$(echo "$slug" | tr '[:upper:]' '[:lower:]')
    
    # Remplacer espaces par tirets
    slug="${slug// /-}"
    
    # Supprimer caractères spéciaux
    slug="${slug//[^a-z0-9-]/}"
    
    # Supprimer tirets multiples
    while [[ $slug == *--* ]]; do
        slug="${slug//--/-}"
    done
    
    # Supprimer tirets de début/fin
    slug="${slug/#-/}"
    slug="${slug/%-/}"
    
    echo "$slug"
}

# Usage
echo "$(generer_slug 'Mon Article Super Cool !')"  # mon-article-super-cool
echo "$(generer_slug 'Bash & Shell Scripting')"   # bash-shell-scripting
```

### 10. Validation et transformation combinées

```bash
# Valider et nettoyer un email
valider_email() {
    local email="$1"
    
    # Supprimer les espaces
    email="${email// /}"
    
    # Minuscules (avec autre commande)
    email=$(echo "$email" | tr '[:upper:]' '[:lower:]')
    
    # Vérification basique
    if [[ $email == *@*.* ]]; then
        echo "$email"
        return 0
    else
        echo "Email invalide" >&2
        return 1
    fi
}

# Test
valider_email " User@Example.COM "  # user@example.com
```

### 11. Traitement de logs

```bash
# Nettoyer une ligne de log
nettoyer_log() {
    local ligne="$1"
    
    # Supprimer le timestamp
    ligne="${ligne/#\[*\] /}"
    
    # Supprimer le niveau de log
    ligne="${ligne/#DEBUG: /}"
    ligne="${ligne/#INFO: /}"
    ligne="${ligne/#WARN: /}"
    ligne="${ligne/#ERROR: /}"
    
    echo "$ligne"
}

# Usage
log="[2024-01-15 10:30:45] INFO: Connexion établie"
echo "$(nettoyer_log "$log")"  # Connexion établie
```

### 12. Conversion de formats de dates

```bash
# Convertir date US vers EU
date_us="2024-01-15"  # YYYY-MM-DD

# Extraction avec patterns
annee="${date_us%%-*}"
reste="${date_us#*-}"
mois="${reste%%-*}"
jour="${reste#*-}"

date_eu="$jour/$mois/$annee"
echo "$date_eu"  # 15/01/2024

# Ou avec remplacement
date_slash="${date_us//-/\/}"
echo "$date_slash"  # 2024/01/15
```

### 13. Gestion des versions sémantiques

```bash
# Incrémenter une version
incrementer_version() {
    local version="$1"
    local type="$2"  # major, minor, patch
    
    IFS='.' read -r major minor patch <<< "$version"
    
    case "$type" in
        major)
            ((major++))
            minor=0
            patch=0
            ;;
        minor)
            ((minor++))
            patch=0
            ;;
        patch)
            ((patch++))
            ;;
    esac
    
    echo "$major.$minor.$patch"
}

# Usage
version="1.2.3"
echo "$(incrementer_version "$version" "minor")"  # 1.3.0
```

### 14. Échappement pour SQL ou HTML

```bash
# Échapper les apostrophes pour SQL
echapper_sql() {
    local texte="$1"
    # Doubler les apostrophes
    echo "${texte//\'/\'\'}"
}

# Usage
requete="SELECT * FROM users WHERE name='O'Brien'"
securise=$(echapper_sql "$requete")
echo "$securise"  # SELECT * FROM users WHERE name='O''Brien'

# Échappement HTML basique
echapper_html() {
    local texte="$1"
    texte="${texte//&/&amp;}"
    texte="${texte//</&lt;}"
    texte="${texte//>/&gt;}"
    texte="${texte//\"/&quot;}"
    echo "$texte"
}
```

### 15. Optimisation : éviter les boucles quand possible

```bash
# ❌ Inefficace - boucle caractère par caractère
anonymiser_lent() {
    local resultat="$1"
    for (( i=0; i<${#resultat}-4; i++ )); do
        resultat="${resultat:0:i}*${resultat:i+1}"
    done
    echo "$resultat"
}

# ✅ Efficace - utilisation de patterns
anonymiser_rapide() {
    local data="$1"
    local longueur=${#data}
    local masque=$(printf '%*s' $((longueur-4)) | tr ' ' '*')
    echo "${masque}${data: -4}"
}

# Le second est beaucoup plus rapide sur de grandes chaînes
```

### 16. Composition de fonctions

```bash
# Pipeline de transformations
pipeline_texte() {
    local texte="$1"
    
    # 1. Supprimer les espaces multiples
    texte="${texte//  / }"
    
    # 2. Trim (début et fin)
    texte="${texte# }"
    texte="${texte% }"
    
    # 3. Première lettre en majuscule (nécessite autre commande)
    texte="$(tr '[:lower:]' '[:upper:]' <<< "${texte:0:1}")${texte:1}"
    
    echo "$texte"
}

# Usage
echo "$(pipeline_texte '  hello   world  ')"  # Hello world
```

### 17. Détection et remplacement intelligent

```bash
# Détecter le type de séparateur et le remplacer
normaliser_csv() {
    local ligne="$1"
    local sep_sortie="${2:-,}"
    
    # Détecter le séparateur (virgule, point-virgule, tab)
    if [[ $ligne == *\t'* ]]; then
        ligne="${ligne//\t'/$sep_sortie}"
    elif [[ $ligne == *";"* ]]; then
        ligne="${ligne//;/$sep_sortie}"
    fi
    
    echo "$ligne"
}

# Test
echo "$(normaliser_csv 'a;b;c' ',')"           # a,b,c
echo "$(normaliser_csv 'a	b	c' ';')"  # a;b;c (tab vers ;)
```

### 18. Préservation de patterns

```bash
# Remplacer tout sauf certains patterns
remplacer_sauf() {
    local texte="Code: ABC-123, Ref: XYZ-456"
    
    # Sauvegarder les codes
    local codes=()
    while [[ $texte =~ ([A-Z]+-[0-9]+) ]]; do
        codes+=("${BASH_REMATCH[1]}")
        texte="${texte//${BASH_REMATCH[1]}/§PLACEHOLDER§}"
    done
    
    # Faire les remplacements
    texte="${texte//[A-Z]/x}"
    
    # Restaurer les codes
    for code in "${codes[@]}"; do
        texte="${texte/§PLACEHOLDER§/$code}"
    done
    
    echo "$texte"
}
```

### 19. Remplacement contextuel

```bash
# Remplacer selon le contexte
remplacer_contextuel() {
    local texte="file.txt and file.backup.txt"
    
    # Remplacer .txt seulement s'il n'est pas précédé de .backup
    # (nécessite une approche plus complexe avec regex)
    
    # Alternative : traiter les cas spéciaux d'abord
    texte="${texte//.backup.txt/.backup.BAK}"
    texte="${texte//.txt/.TXT}"
    texte="${texte//.backup.BAK/.backup.txt}"
    
    echo "$texte"  # file.TXT and file.backup.txt
}
```

### 20. Performance : remplacement vs commandes externes

```bash
# Benchmark simple
benchmark() {
    local iterations=10000
    local texte="test string with spaces"
    
    # Avec remplacement interne (RAPIDE)
    time {
        for ((i=0; i<iterations; i++)); do
            result="${texte// /_}"
        done
    }
    
    # Avec sed externe (LENT)
    time {
        for ((i=0; i<iterations; i++)); do
            result=$(echo "$texte" | sed 's/ /_/g')
        done
    }
}

# Le remplacement interne est généralement 10-100x plus rapide
```

> [!tip] Conseil de performance
> 
> - Utilisez toujours le remplacement de patterns natif pour les opérations simples
> - Réservez `sed`, `awk`, ou `perl` pour les transformations complexes nécessitant des regex avancées
> - Évitez les sous-shells et commandes externes dans les boucles

---

## 📚 Récapitulatif des syntaxes

|Opération|Syntaxe|Exemple|Résultat|
|---|---|---|---|
|Première occurrence|`${var/pattern/repl}`|`${txt/a/A}`|`Abc` (si txt="abc")|
|Toutes occurrences|`${var//pattern/repl}`|`${txt//a/A}`|`AbcA` (si txt="abca")|
|Au début|`${var/#pattern/repl}`|`${txt/#a/A}`|`Abc` (si txt="abc")|
|À la fin|`${var/%pattern/repl}`|`${txt/%c/C}`|`abC` (si txt="abc")|
|Suppression|`${var/pattern/}`|`${txt//a/}`|`bc` (si txt="abc")|

### Caractères spéciaux à échapper

```bash
# Ces caractères ont une signification spéciale et doivent être échappés
/ → \/    # Séparateur de pattern
* → \*    # Wildcard
? → \?    # Caractère unique
[ → \[    # Début de classe
] → \]    # Fin de classe
$ → \$    # Variable
```

### Patterns glob supportés

```bash
*         # N'importe quelle séquence
?         # Un seul caractère
[abc]     # Un caractère parmi a, b, c
[a-z]     # Un caractère dans la plage
[!abc]    # Un caractère qui n'est PAS a, b, c
```

---

## 🎓 Exemples complets récapitulatifs

### Exemple 1 : Nettoyage de nom de fichier

```bash
nettoyer_nom_fichier() {
    local nom="$1"
    
    # 1. Remplacer espaces par underscores
    nom="${nom// /_}"
    
    # 2. Supprimer caractères interdits
    nom="${nom//[^a-zA-Z0-9._-]/}"
    
    # 3. Supprimer underscores multiples
    while [[ $nom == *__* ]]; do
        nom="${nom/__/_}"
    done
    
    # 4. Nettoyer début et fin
    nom="${nom/#_/}"
    nom="${nom/%_/}"
    
    # 5. Limiter longueur (avec autre méthode)
    if [[ ${#nom} -gt 50 ]]; then
        extension="${nom##*.}"
        base="${nom%.*}"
        nom="${base:0:$((50-${#extension}-1))}.$extension"
    fi
    
    echo "$nom"
}

# Test
nom="Mon Fichier (Copie) [2024].txt"
propre=$(nettoyer_nom_fichier "$nom")
echo "$propre"  # Mon_Fichier_Copie_2024.txt
```

### Exemple 2 : Traitement de configuration

```bash
# Lire et nettoyer une ligne de config
traiter_config() {
    local ligne="$1"
    
    # Supprimer commentaires
    ligne="${ligne%%#*}"
    
    # Trim espaces
    ligne="${ligne# }"
    ligne="${ligne% }"
    
    # Ignorer lignes vides
    [[ -z $ligne ]] && return
    
    # Extraire clé=valeur
    if [[ $ligne == *=* ]]; then
        local cle="${ligne%%=*}"
        local valeur="${ligne#*=}"
        
        # Nettoyer
        cle="${cle// /}"
        valeur="${valeur# }"
        valeur="${valeur% }"
        valeur="${valeur//\"/}"  # Supprimer guillemets
        
        echo "$cle=$valeur"
    fi
}

# Usage
traiter_config "  database_host = \"localhost\"  # serveur DB"
# database_host=localhost
```

### Exemple 3 : Transformation d'URL

```bash
transformer_url() {
    local url="$1"
    
    # 1. Forcer HTTPS
    url="${url/#http:/https:}"
    
    # 2. Supprimer www
    url="${url/#https:\/\/www\./https:\/\/}"
    
    # 3. Supprimer trailing slash
    url="${url/%\//}"
    
    # 4. Supprimer paramètres de tracking
    url="${url%%\?utm_*}"
    
    echo "$url"
}

# Test
transformer_url "http://www.example.com/?utm_source=test"
# https://example.com
```

---

## 🎯 Conclusion

Le remplacement de patterns en Bash est un outil puissant pour manipuler des chaînes de caractères de manière efficace et native. Les points clés à retenir :

> [!info] Points essentiels
> 
> - **Une occurrence** : `${var/pattern/repl}`
> - **Toutes occurrences** : `${var//pattern/repl}`
> - **Au début** : `${var/#pattern/repl}`
> - **À la fin** : `${var/%pattern/repl}`
> - **Suppression** : laisser le remplacement vide

> [!tip] Recommandations
> 
> - Privilégiez le remplacement natif pour les performances
> - Quotez toujours vos variables
> - Utilisez des variables pour les patterns complexes
> - Échappez les caractères spéciaux
> - Testez avec des cas limites
> - Documentez les transformations complexes

> [!warning] Limitations
> 
> - Patterns glob seulement (pas de regex complètes)
> - Pas de lookbehind/lookahead
> - Le `*` est gourmand
> - Nécessite parfois des boucles pour les remplacements itératifs

Le remplacement de patterns est idéal pour les transformations simples à moyennes. Pour des besoins plus complexes impliquant des expressions régulières avancées, considérez l'utilisation de `sed`, `awk` ou `perl`.